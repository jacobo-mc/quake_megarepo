/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// models.c -- model loading and caching

// models are the only shared resource between a client and server running
// on the same machine.

#include <float.h>
#include <math.h>
#include <stdint.h>

#include "cmd.h"
#include "common.h"
#include "console.h"
#include "model.h"

#ifdef GLQUAKE
#include "glquake.h"
#endif

#ifdef SERVERONLY
#include "qwsvdef.h"
#else
#include "quakedef.h"
#include "render.h"
#include "sys.h"
#ifdef QW_HACK
#include "crc.h"
#include "quakedef.h" // host_basepal
#endif
#ifdef NQ_HACK
#include "host.h" // host_basepal
#endif
/* FIXME - quick hack to enable merging of NQ/QWSV shared code */
#define SV_Error Sys_Error
#endif

static void Mod_LoadBrushModel(brushmodel_t *brushmodel, void *buffer, size_t size);
static model_t *Mod_LoadModel(const char *name, qboolean crash);

brushmodel_t *loaded_brushmodels;
static model_t *loaded_sprites;

static const alias_loader_t *alias_loader;
static const brush_loader_t *brush_loader;

static void PVSCache_f(void);

// ======================================================================
// Mipmap code for 8-bit fence textures
// TODO: maybe rework texture_t to better integrate with qpic8_t?

#ifndef SERVERONLY
static byte
qpal_24to8(const byte palette[768], const int rgb[3], int alpha)
{
    int index, best_index, channel;
    int dist, best_dist, delta;

    best_dist = INT_MAX;
    best_index = 0;

    for (index = 0; index < 224; index++) {
        if (index == alpha)
            continue;
        dist = 0;
        for (channel = 0; channel < 3; channel++) {
            delta = abs(rgb[channel] - palette[index * 3 + channel]);
            dist += delta * delta;
        }
        if (dist < best_dist) {
            best_index = index;
            best_dist = dist;
        }
    }

    return (byte)best_index;
}

static byte
qpal_24to8_fullbright(const byte palette[768], const int rgb[3], int alpha)
{
    int index, best_index, channel;
    int dist, best_dist, delta;

    best_index = 0;
    best_dist = INT_MAX;
    best_dist = -1;

    for (index = 224; index < 256; index++) {
        if (index == alpha)
            continue;
        dist = 0;
        for (channel = 0; channel < 3; channel++) {
            delta = abs(rgb[channel] - palette[index * 3 + channel]);
            dist += delta * delta;
        }
        if (dist < best_dist) {
            best_index = index;
            best_dist = dist;
        }
    }

    return (byte)best_index;
}

/**
 * Calculate a new sample index based on the four samples provided.
 * Accounts for fullbright/alpha pixles by keeping them if they
 * dominate the samples (i.e. contribute > 50%).
 */
static byte
QPal_Resample_Alpha(const byte palette[768], byte samples[4], byte alpha)
{
    int i, j;
    int rgb[3];
    int numfullbright, numalpha;

    /* Count average colors, excluding alpha */
    numfullbright = numalpha = 0;
    rgb[0] = rgb[1] = rgb[2] = 0;
    for (i = 0; i < 4; i++) {
        if (samples[i] == alpha) {
            numalpha++;
            continue; // alpha doesn't contribute to any color
        }
        if (samples[i] > 223)
            numfullbright++;
        for (j = 0; j < 3; j++)
            rgb[j] += palette[samples[i] * 3 + j];
    }

    /* If alpha dominant, keep it */
    if (numalpha > 2)
        return alpha;

    /* Otherwise, average the other colors */
    for (i = 0; i < 3; i++)
        rgb[i] = roundf(rgb[i] / (4.0f - numalpha));

    /* If fullbrights dominant, try to find the best matching fullbright */
    if (numfullbright > 2)
        return qpal_24to8_fullbright(palette, rgb, alpha);

    /* Otherwise, choose from the non-fullbright colors */
    return qpal_24to8(palette, rgb, alpha);
}

static void
Remip_FenceTexture(texture_t *texture, const byte palette[768])
{
    int s, t, width, height, miplevel;
    const byte *in;
    byte *out;
    byte samples[4];

    width = texture->width;
    height = texture->height;

    for (miplevel = 0; miplevel < MIPLEVELS - 1; miplevel++) {
        in = (byte *)texture + texture->offsets[miplevel];
        out = (byte *)texture + texture->offsets[miplevel + 1];

        for (t = 0; t < height; t += 2, in += width) {
            for (s = 0; s < width; s += 2, in += 2, out++) {
                samples[0] = in[0];
                samples[1] = in[1];
                samples[2] = in[width];
                samples[3] = in[width + 1];
                *out = QPal_Resample_Alpha(palette, samples, 255);
            }
        }

        width >>= 1;
        height >>= 1;
    }
}

/*
 * Take the color specified in index0 and alpha blend the color in
 * index1 over the top using an alpha value between zero and one.
 * Return the nearest color index in the palette.
 *
 * Only returns standard colours, fullbrights will be matched to the
 * nearest color in the standard palette.
 */
static byte
QPal_AlphaBlendColorIndices(const byte palette[768], byte index0, byte index1, float alpha)
{
    int rgb[3];

    rgb[0] = roundf(palette[index1 * 3 + 0] * alpha + palette[index0 * 3 + 0] * (1.0f - alpha));
    rgb[1] = roundf(palette[index1 * 3 + 1] * alpha + palette[index0 * 3 + 1] * (1.0f - alpha));
    rgb[2] = roundf(palette[index1 * 3 + 2] * alpha + palette[index0 * 3 + 2] * (1.0f - alpha));

    // Exclude black, since it looks terrible on any transparency
    // TODO: find black instead of assuming index 0
    return qpal_24to8(palette, rgb, 0);
}

/*
 * Create a transulcency color map
 * Provides a lookup table for nearest color matching for a fixed alpha value
 */
void
QPal_CreateTranslucencyTable(byte transtable[65536], const byte palette[768], float alpha)
{
    int baseindex, blendindex;
    byte index;

    for (baseindex = 0; baseindex < 256; baseindex++) {
        for (blendindex = 0; blendindex < 256; blendindex++) {
            index = QPal_AlphaBlendColorIndices(palette, baseindex, blendindex, alpha);
            transtable[(baseindex << 8) + blendindex] = index;
        }
    }
}
#endif // SERVERONLY

// ======================================================================

void
Mod_AddCommands()
{
    Cmd_AddCommand("pvscache", PVSCache_f);
}

/*
===============
Mod_Init
===============
*/
void
Mod_Init(const alias_loader_t *alias_loader_in, const brush_loader_t *brush_loader_in)
{
    alias_loader = alias_loader_in;
    brush_loader = brush_loader_in;
}

/*
===============
Mod_PointInLeaf
===============
*/
mleaf_t *
Mod_PointInLeaf(const brushmodel_t *model, const vec3_t point)
{
    mplane_t *plane;
    mnode_t *node;
    float dist;

    if (!model || !model->nodes)
	SV_Error("%s: bad model", __func__);

    node = model->nodes;
    while (1) {
	if (node->contents < 0)
	    return (mleaf_t *)node;
	plane = node->plane;
	dist = DotProduct(point, plane->normal) - plane->dist;
	if (dist > 0)
	    node = node->children[0];
	else
	    node = node->children[1];
    }

    return NULL;		// never reached
}

void
Mod_AddLeafBits(leafbits_t *dst, const leafbits_t *src)
{
    int i, leafblocks;
    const leafblock_t *srcblock;
    leafblock_t *dstblock;

    if (src->numleafs != dst->numleafs)
	SV_Error("%s: src->numleafs (%d) != dst->numleafs (%d)",
		 __func__, src->numleafs, dst->numleafs);

    srcblock = src->bits;
    dstblock = dst->bits;
    leafblocks = (src->numleafs + LEAFMASK) >> LEAFSHIFT;
    for (i = 0; i < leafblocks; i++)
	*dstblock++ |= *srcblock++;
}

#ifdef SERVERONLY
int
Mod_CountLeafBits(const leafbits_t *leafbits)
{
    int i, leafblocks, count;
    leafblock_t block;

    count = 0;
    leafblocks = (leafbits->numleafs + LEAFMASK) >> LEAFSHIFT;
    for (i = 0; i < leafblocks; i++) {
	block = leafbits->bits[i];
	while (block) {
	    count++;
	    block &= (block - 1); /* remove least significant bit */
	}
    }

    return count;
};
#endif

/*
 * Simple LRU cache for decompressed vis data
 */
#define PVSCACHE_ENTRIES 8
typedef struct {
    const brushmodel_t *model;
    const mleaf_t *leaf;
    leafbits_t *leafbits;
} pvscache_t;
static pvscache_t pvscache[PVSCACHE_ENTRIES];
static leafbits_t *fatpvs;
static int pvscache_numleafs;
static int pvscache_bytes;
static int pvscache_blocks;

static unsigned int c_cachehit, c_cachemiss;

static void
Mod_InitPVSCache(int numleafs)
{
    int i;
    int memsize;
    byte *leafmem;

    pvscache_numleafs = numleafs;
    pvscache_bytes = ((numleafs + LEAFMASK) & ~LEAFMASK) >> 3;
    pvscache_blocks = pvscache_bytes / sizeof(leafblock_t);
    memsize = Mod_LeafbitsSize(numleafs);
    fatpvs = Hunk_AllocName(memsize, "fatpvs");

    memset(pvscache, 0, sizeof(pvscache));
    leafmem = Hunk_AllocName(PVSCACHE_ENTRIES * memsize, "pvscache");
    for (i = 0; i < PVSCACHE_ENTRIES; i++)
	pvscache[i].leafbits = (leafbits_t *)(leafmem + i * memsize);
}

/*
===================
Mod_DecompressVis
===================
*/

static void
Mod_DecompressVis(const byte *in, const brushmodel_t *model, leafbits_t *dest)
{
    leafblock_t *out;
    int num_out;
    int shift;
    int count;

    dest->numleafs = model->numleafs;
    out = dest->bits;

    if (!in) {
	/* no vis info, so make all visible */
	memset(out, 0xff, pvscache_bytes);
	return;
    }

    memset(out, 0, pvscache_bytes);
    num_out = 0;
    shift = 0;
    do {
	if (*in) {
	    *out |= (leafblock_t)*in++ << shift;
	    shift += 8;
	    num_out += 8;
	    if (shift == (1 << LEAFSHIFT)) {
		shift = 0;
		out++;
	    }
	    continue;
	}

	/* Run of zeros - skip over */
	count = in[1];
	in += 2;
	out += count / sizeof(leafblock_t);
	shift += (count % sizeof(leafblock_t)) << 3;
	num_out += count << 3;
	if (shift >= (1 << LEAFSHIFT)) {
	    shift -= (1 << LEAFSHIFT);
	    out++;
	}
    } while (num_out < dest->numleafs);
}

const leafbits_t *
Mod_LeafPVS(const brushmodel_t *model, const mleaf_t *leaf)
{
    int slot;
    pvscache_t tmp;

    for (slot = 0; slot < PVSCACHE_ENTRIES; slot++)
	if (pvscache[slot].model == model && pvscache[slot].leaf == leaf) {
	    c_cachehit++;
	    break;
	}

    if (slot) {
	if (slot == PVSCACHE_ENTRIES) {
	    slot--;
	    tmp.model = model;
	    tmp.leaf = leaf;
	    tmp.leafbits = pvscache[slot].leafbits;
	    if (leaf == model->leafs) {
		/* return set with everything visible */
		tmp.leafbits->numleafs = model->numleafs;
		memset(tmp.leafbits->bits, 0xff, pvscache_bytes);
	    } else {
		Mod_DecompressVis(leaf->compressed_vis, model, tmp.leafbits);
	    }
	    c_cachemiss++;
	} else {
	    tmp = pvscache[slot];
	}
	memmove(pvscache + 1, pvscache, slot * sizeof(pvscache_t));
	pvscache[0] = tmp;
    }

    return pvscache[0].leafbits;
}

static void
PVSCache_f(void)
{
    uint32_t hit_percent = (uint64_t)c_cachehit * 100 / ((uint64_t)c_cachehit + c_cachemiss);
    uint32_t cache_bytes = Mod_LeafbitsSize(pvscache_numleafs) * PVSCACHE_ENTRIES;

    Con_Printf("PVSCache: %7d hits %7d misses (%3d%%)\n", c_cachehit, c_cachemiss, hit_percent);
    Con_Printf("  %d entries, %d bytes total.\n", PVSCACHE_ENTRIES, cache_bytes);
}

static void
Mod_AddToFatPVS(const brushmodel_t *model, const vec3_t point,
		const mnode_t *node)
{
    const leafbits_t *pvs;
    mplane_t *plane;
    float d;

    while (1) {
	// if this is a leaf, accumulate the pvs bits
	if (node->contents < 0) {
	    if (node->contents != CONTENTS_SOLID) {
		pvs = Mod_LeafPVS(model, (const mleaf_t *)node);
		Mod_AddLeafBits(fatpvs, pvs);
	    }
	    return;
	}

	plane = node->plane;
	d = DotProduct(point, plane->normal) - plane->dist;
	if (d > 8)
	    node = node->children[0];
	else if (d < -8)
	    node = node->children[1];
	else {			// go down both
	    Mod_AddToFatPVS(model, point, node->children[0]);
	    node = node->children[1];
	}
    }
}

/*
=============
Mod_FatPVS

Calculates a PVS that is the inclusive or of all leafs within 8 pixels of the
given point.

The FatPVS must include a small area around the client to allow head bobbing
or other small motion on the client side.  Otherwise, a bob might cause an
entity that should be visible to not show up, especially when the bob
crosses a waterline.
=============
*/
const leafbits_t *
Mod_FatPVS(const brushmodel_t *model, const vec3_t point)
{
    fatpvs->numleafs = model->numleafs;
    memset(fatpvs->bits, 0, pvscache_bytes);
    Mod_AddToFatPVS(model, point, model->nodes);

    return fatpvs;
}

/*
===================
Mod_ClearAll
===================
*/
void
Mod_ClearAll(void)
{
#ifdef GLQUAKE
    for (brushmodel_t *brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        GL_DisownTextures(&brushmodel->model);
    }
    GL_FreeBmodelVertexBuffers();

    for (model_t *sprite = loaded_sprites; sprite; sprite = sprite->next) {
        GL_DisownTextures(sprite);
    }
#endif

    loaded_brushmodels = NULL;
    loaded_sprites = NULL;
    fatpvs = NULL;
    memset(pvscache, 0, sizeof(pvscache));
    pvscache_numleafs = 0;
    pvscache_bytes = pvscache_blocks = 0;
    c_cachehit = c_cachemiss = 0;
#ifndef SERVERONLY
    Mod_ClearAlias();
#endif
}

/*
==================
Mod_FindName

==================
*/
static model_t *
Mod_FindName(const char *name)
{
    brushmodel_t *brushmodel;
    model_t *model;

    if (!name[0])
	SV_Error("%s: NULL name", __func__);

    /* search the currently loaded models */
    brushmodel = loaded_brushmodels;
    while (brushmodel) {
	if (!strcmp(brushmodel->model.name, name))
	    break;
	brushmodel = brushmodel->next;
    }
    model = brushmodel ? &brushmodel->model : NULL;

#ifndef SERVERONLY
    /* Search the sprite and alias lists */
    if (!model) {
	model = loaded_sprites;
	while (model) {
	    if (!strcmp(model->name, name))
		break;
	    model = model->next;
	}
    }
    if (!model)
	model = Mod_FindAliasName(name);
#endif

    return model;
}

/* Small helper to hunk allocate using the model's "base" name */
void *
Mod_AllocName(int size, const char *modelname)
{
    char hunkname[HUNK_NAMELEN + 1];

    COM_FileBase(modelname, hunkname, sizeof(hunkname));
    return Hunk_AllocName(size, hunkname);
}

/*
==================
Mod_LoadModel

Loads a model into the cache
==================
*/
static model_t *
Mod_LoadModel(const char *name, qboolean crash)
{
    byte stackbuf[64 * 1024];
    unsigned *buffer, header;
    brushmodel_t *brushmodel;
    model_t *model;
    size_t size;
    byte *brushmodel_header;
    int pad;

    /* Load the file - use stack for tiny models to avoid dirtying heap */
    buffer = COM_LoadStackFile(name, stackbuf, sizeof(stackbuf), &size);
    if (!buffer) {
	if (crash)
	    SV_Error("%s: %s not found", __func__, name);
	return NULL;
    }

    /* call the apropriate loader */
    header = LittleLong(*buffer);
    switch (header) {
#ifndef SERVERONLY
    case IDPOLYHEADER:
	model = Mod_NewAliasModel();
	qsnprintf(model->name, sizeof(model->name), "%s", name);
	Mod_LoadAliasModel(alias_loader, model, buffer, size);
	break;

    case IDSPRITEHEADER:
	model = Mod_AllocName(sizeof(*model), name);
	qsnprintf(model->name, sizeof(model->name), "%s", name);
	model->next = loaded_sprites;
	loaded_sprites = model;
	Mod_LoadSpriteModel(model, buffer);
	break;
#endif
    default:
	pad = brush_loader->Padding();
	brushmodel_header = Mod_AllocName(sizeof(brushmodel_t) + pad, name);
	brushmodel = (brushmodel_t *)(brushmodel_header + pad);
	brushmodel->next = loaded_brushmodels;
	loaded_brushmodels = brushmodel;
	model = &brushmodel->model;
	qsnprintf(model->name, sizeof(model->name), "%s", name);
	Mod_LoadBrushModel(brushmodel, buffer, size);
	break;
    }

    return model;
}

/*
==================
Mod_ForName

Loads in a model for the given name
==================
*/
model_t *
Mod_ForName(const char *name, qboolean crash)
{
    model_t *model;

    model = Mod_FindName(name);
    if (model) {
#ifndef SERVERONLY
	void *buffer;
        size_t buffersize;

	if (model->type != mod_alias)
	    return model;
	if (Cache_Check(&model->cache))
	    return model;

	buffer = COM_LoadTempFile(name, &buffersize);
	Mod_LoadAliasModel(alias_loader, model, buffer, buffersize);
#endif
	return model;
    }

    return Mod_LoadModel(name, crash);
}


/*
 * ===========================================================================
 *				BRUSHMODEL LOADING
 * ===========================================================================
 */

#ifdef GLQUAKE
static void
GL_LoadBrushModelTexture(const model_t *model, texture_t *texture)
{
    qpic8_t pic;
    enum texture_type type;

    pic.width = pic.stride = texture->width;
    pic.height = texture->height;
    pic.pixels = (byte *)(texture + 1);

    if (texture->name[0] == '{')
        type = TEXTURE_TYPE_FENCE;
    else if (texture->name[0] == '*')
        type = TEXTURE_TYPE_TURB;
    else
        type = TEXTURE_TYPE_WORLD;

    texture->gl_texturenum = GL_LoadTexture8(model, texture->name, &pic, type);

    /* Add warp target or fullbright mask if required */
    if (type == TEXTURE_TYPE_TURB) {
        texture->gl_warpimage = GL_LoadTexture8(model, va("%s:warp", texture->name), &pic, TEXTURE_TYPE_WARP_TARGET);
        texture->gl_warpimagesize = pic.width;
    } else if (QPic_HasFullbrights(&pic, type)) {
        type = (texture->name[0] == '{') ? TEXTURE_TYPE_FENCE_FULLBRIGHT : TEXTURE_TYPE_WORLD_FULLBRIGHT;
        pic.width = texture->width;   // Possibly modified by picmip in previous upload
        pic.height = texture->height; // Possibly modified by picmip in previous upload
        texture->gl_texturenum_fullbright = GL_LoadTexture8(model, va("%s:fullbright", texture->name), &pic, type);
    } else {
        texture->gl_texturenum_fullbright = invalid_texture_id;
    }
}

static void
GL_LoadBrushModelTextures(const brushmodel_t *brushmodel)
{
    texture_t *texture;
    int i;

    for (i = 0; i < brushmodel->numtextures; i++) {
        texture = brushmodel->textures[i];
        if (!strncmp(texture->name, "sky", 3)) {
	    R_InitSky(&brushmodel->model, texture);
        } else {
            GL_LoadBrushModelTexture(&brushmodel->model, texture);
        }
    }
}
#endif

/*
=================
Mod_LoadTextures
=================
*/
static void
Mod_LoadTextures(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_TEXTURES];
    dmiptexlump_t *lump;
    int i, j, pixels, num, max, altmax, memsize;
    miptex_t *mt;
    texture_t *tx, *tx2;
    texture_t *anims[10];
    texture_t *altanims[10];

    if (!headerlump->filelen) {
	brushmodel->textures = NULL;
	return;
    }

    lump = (dmiptexlump_t *)((byte *)header + headerlump->fileofs);
    lump->nummiptex = LittleLong(lump->nummiptex);

    brushmodel->numtextures = lump->nummiptex;
    memsize = brushmodel->numtextures * sizeof(*brushmodel->textures);
    brushmodel->textures = Mod_AllocName(memsize, model->name);

    for (i = 0; i < lump->nummiptex; i++) {
	lump->dataofs[i] = LittleLong(lump->dataofs[i]);
	if (lump->dataofs[i] == -1) {
            brushmodel->textures[i] = r_notexture_mip;  // checkerboard texture
            brushmodel->textures[i]->texturenum = i;
	    continue;
        }
	mt = (miptex_t *)((byte *)lump + lump->dataofs[i]);
	mt->width = (uint32_t)LittleLong(mt->width);
	mt->height = (uint32_t)LittleLong(mt->height);
	for (j = 0; j < MIPLEVELS; j++)
	    mt->offsets[j] = (uint32_t)LittleLong(mt->offsets[j]);

	if ((mt->width & 15) || (mt->height & 15))
	    SV_Error("Texture %s is not 16 aligned", mt->name);

	pixels = mt->width * mt->height / 64 * 85;
	tx = Mod_AllocName(sizeof(texture_t) + pixels, model->name);
	brushmodel->textures[i] = tx;

	/* FIXME ~ do we handle non-terminated strings everywhere? */
	tx->texturenum = i;
	memcpy(tx->name, mt->name, sizeof(tx->name));
	tx->width = mt->width;
	tx->height = mt->height;
	for (j = 0; j < MIPLEVELS; j++)
	    tx->offsets[j] = mt->offsets[j] + sizeof(texture_t) - sizeof(miptex_t);
	/* the pixels immediately follow the structures */
	memcpy(tx + 1, mt + 1, pixels);

#ifndef SERVERONLY
        if (tx->name[0] == '{') {
            /*
             * Re-sample mipmaps on fence textures, because they're
             * often not properly done in source maps due to most
             * software renderers not supporting them (and OpenGL
             * renders generally do their own mipmapping in RGBA
             * colorspace.
             */
            Remip_FenceTexture(tx, host_basepal);
        }
	if (!strncmp(mt->name, "sky", 3)) {
	    R_InitSky(&brushmodel->model, tx);
#ifdef GLQUAKE
        } else {
            GL_LoadBrushModelTexture(&brushmodel->model, tx);
#endif
	}
#endif
    }

    /*
     * sequence the animations
     */
    for (i = 0; i < lump->nummiptex; i++) {
	tx = brushmodel->textures[i];
	if (!tx || tx->name[0] != '+')
	    continue;
	if (tx->anim_next)
	    continue; /* Already sequenced */

	/* find the number of frames in the animation */
	memset(anims, 0, sizeof(anims));
	memset(altanims, 0, sizeof(altanims));

	max = tx->name[1];
	if (max >= 'a' && max <= 'z')
	    max -= 'a' - 'A';

	if (max >= '0' && max <= '9') {
	    max -= '0';
	    altmax = 0;
	    anims[max] = tx;
	    max++;
	} else if (max >= 'A' && max <= 'J') {
	    altmax = max - 'A';
	    max = 0;
	    altanims[altmax] = tx;
	    altmax++;
	} else
	    SV_Error("Bad animating texture %s", tx->name);

	for (j = i + 1; j < lump->nummiptex; j++) {
	    tx2 = brushmodel->textures[j];
	    if (!tx2 || tx2->name[0] != '+')
		continue;
	    if (strcmp(tx2->name + 2, tx->name + 2))
		continue;

	    num = tx2->name[1];
	    if (num >= 'a' && num <= 'z')
		num -= 'a' - 'A';
	    if (num >= '0' && num <= '9') {
		num -= '0';
		anims[num] = tx2;
		if (num + 1 > max)
		    max = num + 1;
	    } else if (num >= 'A' && num <= 'J') {
		num = num - 'A';
		altanims[num] = tx2;
		if (num + 1 > altmax)
		    altmax = num + 1;
	    } else
		SV_Error("Bad animating texture %s", tx->name);
	}

	/* Link them all together */
	for (j = 0; j < max; j++) {
	    tx2 = anims[j];
	    if (!tx2)
		SV_Error("Missing frame %i of %s", j, tx->name);
	    tx2->anim_total = max;
	    tx2->anim_min = j;
	    tx2->anim_max = (j + 1);
	    tx2->anim_next = anims[(j + 1) % max];
	    if (altmax)
		tx2->alternate_anims = altanims[0];
	}
	for (j = 0; j < altmax; j++) {
	    tx2 = altanims[j];
	    if (!tx2)
		SV_Error("Missing frame %i of %s", j, tx->name);
	    tx2->anim_total = altmax;
	    tx2->anim_min = j;
	    tx2->anim_max = (j + 1);
	    tx2->anim_next = altanims[(j + 1) % altmax];
	    if (max)
		tx2->alternate_anims = anims[0];
	}
    }
}

/*
 * Mod_LoadBytes
 * - Common code for loading lighting, visibility and entities
 */
void *
Mod_LoadBytes(brushmodel_t *brushmodel, dheader_t *header, int lumpnum)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[lumpnum];
    const byte *in;
    byte *out;

    if (!headerlump->filelen)
	return NULL;

    in = (byte *)header + headerlump->fileofs;
    out = Mod_AllocName(headerlump->filelen, model->name);
    memcpy(out, in, headerlump->filelen);

    return out;
}

/*
=================
Mod_LoadVisibility
=================
*/
static void
Mod_LoadVisibility(brushmodel_t *brushmodel, dheader_t *header)
{
    brushmodel->visdata = Mod_LoadBytes(brushmodel, header, LUMP_VISIBILITY);
}


/*
=================
Mod_LoadEntities
=================
*/
static void
Mod_LoadEntities(brushmodel_t *brushmodel, dheader_t *header)
{
    brushmodel->entities = Mod_LoadBytes(brushmodel, header, LUMP_ENTITIES);
}


/*
=================
Mod_LoadVertexes
=================
*/
static void
Mod_LoadVertexes(brushmodel_t *brushmodel, const dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_VERTEXES];
    const dvertex_t *in;
    mvertex_t *out;
    int i, count;

    in = (const dvertex_t *)((const byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->vertexes = out;
    brushmodel->numvertexes = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->position[0] = LittleFloat(in->point[0]);
	out->position[1] = LittleFloat(in->point[1]);
	out->position[2] = LittleFloat(in->point[2]);
    }
}

/*
=================
Mod_LoadSubmodels
=================
*/
static void
Mod_LoadSubmodels(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_MODELS];
    const dmodel_t *in;
    dmodel_t *out;
    int i, j, count;

    in = (dmodel_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->submodels = out;
    brushmodel->numsubmodels = count;

    for (i = 0; i < count; i++, in++, out++) {
	for (j = 0; j < 3; j++) {	// spread the mins / maxs by a pixel
	    out->mins[j] = LittleFloat(in->mins[j]) - 1;
	    out->maxs[j] = LittleFloat(in->maxs[j]) + 1;
	    out->origin[j] = LittleFloat(in->origin[j]);
	}
	for (j = 0; j < MAX_MAP_HULLS; j++)
	    out->headnode[j] = LittleLong(in->headnode[j]);
	out->visleafs = LittleLong(in->visleafs);
	out->firstface = LittleLong(in->firstface);
	out->numfaces = LittleLong(in->numfaces);
    }
}

/*
=================
Mod_LoadEdges
 => Two versions for the different BSP file formats
=================
*/
static void
Mod_LoadEdges_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_EDGES];
    const bsp29_dedge_t *in;
    medge_t *out;
    int i, count;

    in = (bsp29_dedge_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->edges = out;
    brushmodel->numedges = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->v[0] = (uint16_t)LittleShort(in->v[0]);
	out->v[1] = (uint16_t)LittleShort(in->v[1]);
    }
}

static void
Mod_LoadEdges_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_EDGES];
    const bsp2_dedge_t *in;
    medge_t *out;
    int i, count;

    in = (bsp2_dedge_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->edges = out;
    brushmodel->numedges = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->v[0] = (uint32_t)LittleLong(in->v[0]);
	out->v[1] = (uint32_t)LittleLong(in->v[1]);
    }
}

/*
=================
Mod_LoadTexinfo
=================
*/
static void
Mod_LoadTexinfo(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_TEXINFO];
    const texinfo_t *in;
    mtexinfo_t *out;
    int i, j, count;
    int miptex;
    float len1, len2;

    in = (texinfo_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->texinfo = out;
    brushmodel->numtexinfo = count;

    for (i = 0; i < count; i++, in++, out++) {
	for (j = 0; j < 4; j++) {
	    out->vecs[0][j] = LittleFloat(in->vecs[0][j]);
	    out->vecs[1][j] = LittleFloat(in->vecs[1][j]);
	}
	len1 = Length(out->vecs[0]);
	len2 = Length(out->vecs[1]);
	len1 = (len1 + len2) / 2;
	if (len1 < 0.32)
	    out->mipadjust = 4;
	else if (len1 < 0.49)
	    out->mipadjust = 3;
	else if (len1 < 0.99)
	    out->mipadjust = 2;
	else
	    out->mipadjust = 1;

	miptex = LittleLong(in->miptex);
	out->flags = LittleLong(in->flags);

	if (!brushmodel->textures) {
	    out->texture = r_notexture_mip;	// checkerboard texture
	    out->flags = TEX_SPECIAL;
	} else {
	    if (miptex >= brushmodel->numtextures)
		SV_Error("miptex >= brushmodel->numtextures");
	    out->texture = brushmodel->textures[miptex];
	    if (out->texture == r_notexture_mip) {
		out->flags |= TEX_SPECIAL;
	    }
	}
    }
}

/*
================
CalcSurfaceExtents

Fills in s->texturemins[] and s->extents[]
================
*/
static void
CalcSurfaceExtents(const brushmodel_t *brushmodel, msurface_t *surf)
{
    const mtexinfo_t *const texinfo = surf->texinfo;
    const mvertex_t *vertex;
    float mins[2], maxs[2], val;
    int bmins[2], bmaxs[2];
    int i, j;

    mins[0] = mins[1] = FLT_MAX;
    maxs[0] = maxs[1] = -FLT_MAX;

    for (i = 0; i < surf->numedges; i++) {
	const int edgenum = brushmodel->surfedges[surf->firstedge + i];
	if (edgenum >= 0) {
	    const medge_t *const edge = &brushmodel->edges[edgenum];
	    vertex = &brushmodel->vertexes[edge->v[0]];
	} else {
	    const medge_t *const edge = &brushmodel->edges[-edgenum];
	    vertex = &brushmodel->vertexes[edge->v[1]];
	}

	/*
	 * The (long double) casts below are important: The original code was
	 * written for x87 floating-point which uses 80-bit floats for
	 * intermediate calculations. But if you compile it without the casts
	 * for modern x86_64, the compiler will round each intermediate result
	 * to a 32-bit float, which introduces extra rounding error.
	 *
	 * This becomes a problem if the rounding error causes the light
	 * utilities and the engine to disagree about the lightmap size for
	 * some surfaces.
	 *
	 * Casting to (long double) keeps the intermediate values at at least
	 * 64 bits of precision, probably 128.
	 */
	for (j = 0; j < 2; j++) {
	    val =
		(long double)vertex->position[0] * texinfo->vecs[j][0] +
		(long double)vertex->position[1] * texinfo->vecs[j][1] +
		(long double)vertex->position[2] * texinfo->vecs[j][2] +
		                                   texinfo->vecs[j][3];
	    if (val < mins[j])
		mins[j] = val;
	    if (val > maxs[j])
		maxs[j] = val;
	}
    }

    for (i = 0; i < 2; i++) {
	bmins[i] = floorf(mins[i] / 16);
	bmaxs[i] = ceilf(maxs[i] / 16);

	surf->texturemins[i] = bmins[i] * 16;
	surf->extents[i] = (bmaxs[i] - bmins[i]) * 16;
	if (!(texinfo->flags & TEX_SPECIAL) && surf->extents[i] > 256)
	    SV_Error("Bad surface extents");

        // This hack is to stop the software renderer crashing if a
        // bsp with a missing sky texture is loaded.
        if (texinfo->texture == r_notexture_mip && surf->extents[i] > 256)
            surf->extents[i] = 240;
    }
}

static void
CalcSurfaceBounds(const brushmodel_t *brushmodel, msurface_t *surf)
{
    int i, j;
    const mvertex_t *vertex;

    surf->mins[0] = surf->mins[1] = surf->mins[2] = FLT_MAX;
    surf->maxs[0] = surf->maxs[1] = surf->maxs[2] = -FLT_MAX;

    for (i = 0; i < surf->numedges; i++) {
	const int edgenum = brushmodel->surfedges[surf->firstedge + i];
	if (edgenum >= 0) {
	    const medge_t *const edge = &brushmodel->edges[edgenum];
	    vertex = &brushmodel->vertexes[edge->v[0]];
	} else {
	    const medge_t *const edge = &brushmodel->edges[-edgenum];
	    vertex = &brushmodel->vertexes[edge->v[1]];
	}
	for (j = 0; j < 3; j++) {
	    if (surf->mins[j] > vertex->position[j])
		surf->mins[j] = vertex->position[j];
	    if (surf->maxs[j] < vertex->position[j])
		surf->maxs[j] = vertex->position[j];
	}
    }
}

static void
Mod_ProcessSurface(brushmodel_t *brushmodel, msurface_t *surf)
{
    const char *const texturename = surf->texinfo->texture->name;
    int i;

    /* set the surface drawing flags */
    if (surf->texinfo->flags & TEX_SPECIAL)
        surf->flags |= SURF_DRAWTILED;

    if (!strncmp(texturename, "sky", 3)) {
	surf->flags |= SURF_DRAWSKY | SURF_DRAWTILED;
    } else if (texturename[0] == '*') {
	surf->flags |= SURF_DRAWTURB | SURF_DRAWTILED;
        // Detect special liquid types
        if (!strncmp(texturename, "*lava", 5))
            surf->flags |= SURF_DRAWLAVA;
        else if (!strncmp(texturename, "*slime", 6))
            surf->flags |= SURF_DRAWSLIME;
        else if (!strncmp(texturename, "*tele", 5))
            surf->flags |= SURF_DRAWTELE;
        else
            surf->flags |= SURF_DRAWWATER;

	for (i = 0; i < 2; i++) {
	    surf->extents[i] = 16384;
	    surf->texturemins[i] = -8192;
	}
    } else if (texturename[0] == '{') {
        surf->flags |= SURF_DRAWFENCE;
    }
}

/*
=================
Mod_LoadFaces
 => Two versions for the different BSP file formats
=================
*/
static void
Mod_LoadFaces_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_FACES];
    const int lightmap_sample_bytes = brush_loader->lightmap_sample_bytes;
    const bsp29_dface_t *in;
    msurface_t *out;
    int i, count, surfnum;
    int planenum, side;

    in = (bsp29_dface_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->surfaces = out;
    brushmodel->numsurfaces = count;

    for (surfnum = 0; surfnum < count; surfnum++, in++, out++) {
	out->firstedge = LittleLong(in->firstedge);
	out->numedges = LittleShort(in->numedges);
	out->flags = 0;

	/* FIXME - Also check numedges doesn't overflow edges */
	if (out->numedges <= 0)
	    SV_Error("%s: bmodel %s has surface with no edges", __func__,
		     model->name);

	planenum = LittleShort(in->planenum);
	side = LittleShort(in->side);
	if (side)
	    out->flags |= SURF_PLANEBACK;

	out->plane = brushmodel->planes + planenum;
	out->texinfo = brushmodel->texinfo + LittleShort(in->texinfo);

	CalcSurfaceExtents(brushmodel, out);
	CalcSurfaceBounds(brushmodel, out);

	/* lighting info */
	for (i = 0; i < MAXLIGHTMAPS; i++)
	    out->styles[i] = in->styles[i];
	i = LittleLong(in->lightofs);
	if (i == -1)
	    out->samples = NULL;
	else
	    out->samples = brushmodel->lightdata + i * lightmap_sample_bytes;

	Mod_ProcessSurface(brushmodel, out);
    }
}

static void
Mod_LoadFaces_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_FACES];
    const int lightmap_sample_bytes = brush_loader->lightmap_sample_bytes;
    const bsp2_dface_t *in;
    msurface_t *out;
    int i, count, surfnum;
    int planenum, side;

    in = (bsp2_dface_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->surfaces = out;
    brushmodel->numsurfaces = count;

    for (surfnum = 0; surfnum < count; surfnum++, in++, out++) {
	out->firstedge = LittleLong(in->firstedge);
	out->numedges = LittleLong(in->numedges);
	out->flags = 0;

	planenum = LittleLong(in->planenum);
	side = LittleLong(in->side);
	if (side)
	    out->flags |= SURF_PLANEBACK;

	out->plane = brushmodel->planes + planenum;
	out->texinfo = brushmodel->texinfo + LittleLong(in->texinfo);

	CalcSurfaceExtents(brushmodel, out);
	CalcSurfaceBounds(brushmodel, out);

	/* lighting info */
	for (i = 0; i < MAXLIGHTMAPS; i++)
	    out->styles[i] = in->styles[i];
	i = LittleLong(in->lightofs);
	if (i == -1)
	    out->samples = NULL;
	else
	    out->samples = brushmodel->lightdata + i * lightmap_sample_bytes;

	Mod_ProcessSurface(brushmodel, out);
    }
}

/*
=================
Mod_SetParent
=================
*/
static void
Mod_SetParent(mnode_t *node, mnode_t *parent)
{
    node->parent = parent;
    if (node->contents < 0)
	return;
    Mod_SetParent(node->children[0], node);
    Mod_SetParent(node->children[1], node);
}

/*
=================
Mod_LoadNodes
 => Three versions for the different BSP file formats
=================
*/
static void
Mod_LoadNodes_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_NODES];
    const bsp29_dnode_t *in;
    mnode_t *out;
    int i, j, count;

    in = (bsp29_dnode_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->nodes = out;
    brushmodel->numnodes = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->plane = brushmodel->planes + LittleLong(in->planenum);
	out->firstsurface = (uint16_t)LittleShort(in->firstface);
	out->numsurfaces = (uint16_t)LittleShort(in->numfaces);
	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleShort(in->mins[j]);
	    out->maxs[j] = LittleShort(in->maxs[j]);
	}
	for (j = 0; j < 2; j++) {
	    const int nodenum = LittleShort(in->children[j]);
	    if (nodenum >= 0)
		out->children[j] = brushmodel->nodes + nodenum;
	    else
		out->children[j] = (mnode_t *)(brushmodel->leafs - nodenum - 1);
	}
    }

    Mod_SetParent(brushmodel->nodes, NULL);
}

static void
Mod_LoadNodes_BSP2rmq(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_NODES];
    const bsp2rmq_dnode_t *in;
    mnode_t *out;
    int i, j, count;

    in = (bsp2rmq_dnode_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->nodes = out;
    brushmodel->numnodes = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->plane = brushmodel->planes + LittleLong(in->planenum);
	out->firstsurface = (uint32_t)LittleLong(in->firstface);
	out->numsurfaces = (uint32_t)LittleLong(in->numfaces);
	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleShort(in->mins[j]);
	    out->maxs[j] = LittleShort(in->maxs[j]);
	}
	for (j = 0; j < 2; j++) {
	    const int nodenum = LittleLong(in->children[j]);
	    if (nodenum >= 0)
		out->children[j] = brushmodel->nodes + nodenum;
	    else
		out->children[j] = (mnode_t *)(brushmodel->leafs - nodenum - 1);
	}
    }

    Mod_SetParent(brushmodel->nodes, NULL);
}

static void
Mod_LoadNodes_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_NODES];
    const bsp2_dnode_t *in;
    mnode_t *out;
    int i, j, count;

    in = (bsp2_dnode_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->nodes = out;
    brushmodel->numnodes = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->plane = brushmodel->planes + LittleLong(in->planenum);
	out->firstsurface = (uint32_t)LittleLong(in->firstface);
	out->numsurfaces = (uint32_t)LittleLong(in->numfaces);
	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleFloat(in->mins[j]);
	    out->maxs[j] = LittleFloat(in->maxs[j]);
	}
	for (j = 0; j < 2; j++) {
	    const int nodenum = LittleLong(in->children[j]);
	    if (nodenum >= 0)
		out->children[j] = brushmodel->nodes + nodenum;
	    else
		out->children[j] = (mnode_t *)(brushmodel->leafs - nodenum - 1);
	}
    }

    Mod_SetParent(brushmodel->nodes, NULL);
}

/*
=================
Mod_LoadLeafs
 => Three versions for the different BSP file formats
=================
*/
static void
Mod_LoadLeafs_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_LEAFS];
    const bsp29_dleaf_t *in;
    mleaf_t *out;
    int i, j, count, visofs;

    in = (bsp29_dleaf_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->leafs = out;
    brushmodel->numleafs = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->efrags = NULL;
	out->contents = LittleLong(in->contents);
	out->firstmarksurface = brushmodel->marksurfaces +
	    (uint16_t)LittleShort(in->firstmarksurface);
	out->nummarksurfaces = (uint16_t)LittleShort(in->nummarksurfaces);

	visofs = LittleLong(in->visofs);
	if (visofs == -1)
	    out->compressed_vis = NULL;
	else
	    out->compressed_vis = brushmodel->visdata + visofs;

	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleShort(in->mins[j]);
	    out->maxs[j] = LittleShort(in->maxs[j]);
	}
	for (j = 0; j < 4; j++)
	    out->ambient_sound_level[j] = in->ambient_level[j];
    }
}

static void
Mod_LoadLeafs_BSP2rmq(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_LEAFS];
    const bsp2rmq_dleaf_t *in;
    mleaf_t *out;
    int i, j, count, visofs;

    in = (bsp2rmq_dleaf_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->leafs = out;
    brushmodel->numleafs = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->efrags = NULL;
	out->contents = LittleLong(in->contents);
	out->firstmarksurface = brushmodel->marksurfaces +
	    (uint32_t)LittleLong(in->firstmarksurface);
	out->nummarksurfaces = (uint32_t)LittleLong(in->nummarksurfaces);

	visofs = LittleLong(in->visofs);
	if (visofs == -1)
	    out->compressed_vis = NULL;
	else
	    out->compressed_vis = brushmodel->visdata + visofs;

	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleShort(in->mins[j]);
	    out->maxs[j] = LittleShort(in->maxs[j]);
	}
	for (j = 0; j < 4; j++)
	    out->ambient_sound_level[j] = in->ambient_level[j];
    }
}

static void
Mod_LoadLeafs_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_LEAFS];
    const bsp2_dleaf_t *in;
    mleaf_t *out;
    int i, j, count, visofs;

    in = (bsp2_dleaf_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->leafs = out;
    brushmodel->numleafs = count;

    for (i = 0; i < count; i++, in++, out++) {
	out->efrags = NULL;
	out->contents = LittleLong(in->contents);
	out->firstmarksurface = brushmodel->marksurfaces +
	    (uint32_t)LittleLong(in->firstmarksurface);
	out->nummarksurfaces = (uint32_t)LittleLong(in->nummarksurfaces);

	visofs = LittleLong(in->visofs);
	if (visofs == -1)
	    out->compressed_vis = NULL;
	else
	    out->compressed_vis = brushmodel->visdata + visofs;

	for (j = 0; j < 3; j++) {
	    out->mins[j] = LittleFloat(in->mins[j]);
	    out->maxs[j] = LittleFloat(in->maxs[j]);
	}
	for (j = 0; j < 4; j++)
	    out->ambient_sound_level[j] = in->ambient_level[j];
    }
}

static void
Mod_MakeClipHulls(brushmodel_t *brushmodel)
{
    hull_t *hull;

    hull = &brushmodel->hulls[1];
    hull->clipnodes = brushmodel->clipnodes;
    hull->firstclipnode = 0;
    hull->lastclipnode = brushmodel->numclipnodes - 1;
    hull->planes = brushmodel->planes;
    hull->clip_mins[0] = -16;
    hull->clip_mins[1] = -16;
    hull->clip_mins[2] = -24;
    hull->clip_maxs[0] = 16;
    hull->clip_maxs[1] = 16;
    hull->clip_maxs[2] = 32;

    hull = &brushmodel->hulls[2];
    hull->clipnodes = brushmodel->clipnodes;
    hull->firstclipnode = 0;
    hull->lastclipnode = brushmodel->numclipnodes - 1;
    hull->planes = brushmodel->planes;
    hull->clip_mins[0] = -32;
    hull->clip_mins[1] = -32;
    hull->clip_mins[2] = -24;
    hull->clip_maxs[0] = 32;
    hull->clip_maxs[1] = 32;
    hull->clip_maxs[2] = 64;
}

/*
=================
Mod_LoadClipnodes
 => Two versions for the different BSP file formats
=================
*/
static void
Mod_LoadClipnodes_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_CLIPNODES];
    const bsp29_dclipnode_t *in;
    mclipnode_t *out;
    int i, j, count;

    in = (bsp29_dclipnode_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->clipnodes = out;
    brushmodel->numclipnodes = count;
    Mod_MakeClipHulls(brushmodel);

    for (i = 0; i < count; i++, out++, in++) {
	out->planenum = LittleLong(in->planenum);
	for (j = 0; j < 2; j++) {
	    out->children[j] = (uint16_t)LittleShort(in->children[j]);
	    if (out->children[j] > 0xfff0)
		out->children[j] -= 0x10000;
	    if (out->children[j] >= count)
		SV_Error("%s: bad clipnode child number", __func__);
	}
    }
}

static void
Mod_LoadClipnodes_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_CLIPNODES];
    const bsp2_dclipnode_t *in;
    mclipnode_t *out;
    int i, j, count;

    in = (bsp2_dclipnode_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->clipnodes = out;
    brushmodel->numclipnodes = count;
    Mod_MakeClipHulls(brushmodel);

    for (i = 0; i < count; i++, out++, in++) {
	out->planenum = LittleLong(in->planenum);
	for (j = 0; j < 2; j++) {
	    out->children[j] = LittleLong(in->children[j]);
	    if (out->children[j] >= count)
		SV_Error("%s: bad clipnode child number", __func__);
	}
    }
}

/*
=================
Mod_MakeDrawHull

Duplicate the drawing hull structure as a clipping hull
=================
*/
static void
Mod_MakeDrawHull(brushmodel_t *brushmodel)
{
    const model_t *model = &brushmodel->model;
    const mnode_t *in, *child;
    mclipnode_t *out;
    hull_t *hull;
    int i, j, count;

    hull = &brushmodel->hulls[0];

    in = brushmodel->nodes;
    count = brushmodel->numnodes;
    out = Mod_AllocName(count * sizeof(*out), model->name);

    hull->clipnodes = out;
    hull->firstclipnode = 0;
    hull->lastclipnode = count - 1;
    hull->planes = brushmodel->planes;

    for (i = 0; i < count; i++, out++, in++) {
	out->planenum = in->plane - brushmodel->planes;
	for (j = 0; j < 2; j++) {
	    child = in->children[j];
	    if (child->contents < 0)
		out->children[j] = child->contents;
	    else
		out->children[j] = child - brushmodel->nodes;
	}
    }
}

/*
=================
Mod_LoadMarksurfaces
 => Two versions for the different BSP file formats
=================
*/
static void
Mod_LoadMarksurfaces_BSP29(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_MARKSURFACES];
    const uint16_t *in;
    msurface_t **out;
    int i, count;

    in = (uint16_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->marksurfaces = out;
    brushmodel->nummarksurfaces = count;

    for (i = 0; i < count; i++) {
	const int surfnum = (uint16_t)LittleShort(in[i]);
	if (surfnum >= brushmodel->numsurfaces)
	    SV_Error("%s: bad surface number (%d)", __func__, surfnum);
	out[i] = brushmodel->surfaces + surfnum;
    }
}

static void
Mod_LoadMarksurfaces_BSP2(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_MARKSURFACES];
    const uint32_t *in;
    msurface_t **out;
    int i, count;

    in = (uint32_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->marksurfaces = out;
    brushmodel->nummarksurfaces = count;

    for (i = 0; i < count; i++) {
	const int surfnum = (uint32_t)LittleLong(in[i]);
	if (surfnum < 0 || surfnum >= brushmodel->numsurfaces)
	    SV_Error("%s: bad surface number (%d)", __func__, surfnum);
	out[i] = brushmodel->surfaces + surfnum;
    }
}

/*
=================
Mod_LoadSurfedges
=================
*/
static void
Mod_LoadSurfedges(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_SURFEDGES];
    const int32_t *in;
    int32_t *out;
    int i, count;

    in = (int32_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * sizeof(*out), model->name);

    brushmodel->surfedges = out;
    brushmodel->numsurfedges = count;

    for (i = 0; i < count; i++)
	out[i] = LittleLong(in[i]);
}

/*
=================
Mod_LoadPlanes
=================
*/
static void
Mod_LoadPlanes(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_PLANES];
    const dplane_t *in;
    mplane_t *out;
    int i, j, count;

    in = (dplane_t *)((byte *)header + headerlump->fileofs);
    if (headerlump->filelen % sizeof(*in))
	SV_Error("%s: funny lump size in %s", __func__, model->name);
    count = headerlump->filelen / sizeof(*in);
    out = Mod_AllocName(count * 2 * sizeof(*out), model->name);

    brushmodel->planes = out;
    brushmodel->numplanes = count;

    for (i = 0; i < count; i++, in++, out++) {
	int signbits = 0;
	for (j = 0; j < 3; j++) {
	    out->normal[j] = LittleFloat(in->normal[j]);
	    if (out->normal[j] < 0)
		signbits |= 1 << j;
	}
	out->dist = LittleFloat(in->dist);
	out->type = LittleLong(in->type);
	out->signbits = signbits;
    }
}

/*
=================
RadiusFromBounds
=================
*/
static float
RadiusFromBounds(vec3_t mins, vec3_t maxs)
{
    int i;
    vec3_t corner;

    for (i = 0; i < 3; i++)
	corner[i] = qmax(fabsf(mins[i]), fabsf(maxs[i]));

    return Length(corner);
}

static void
Mod_SetupSubmodels(brushmodel_t *world, const brush_loader_t *loader)
{
    const dmodel_t *dmodel;
    brushmodel_t *submodel;
    model_t *model;
    int i, j, pad;
    byte *buffer;

    /* Set up the extra submodel fields, starting with the world */
    submodel = world;
    model = &submodel->model;
    for (i = 0; i < world->numsubmodels; i++) {
	if (i > 0) {
	    pad = loader->Padding();
	    buffer = Hunk_AllocName(sizeof(brushmodel_t) + pad, "submodel");
	    submodel = (brushmodel_t *)(buffer + pad);
	    model = &submodel->model;
	    *submodel = *world; /* start with world info */
	    submodel->parent = world;
	    qsnprintf(model->name, sizeof(model->name), "*%d", i);
	    submodel->next = loaded_brushmodels;
	    loaded_brushmodels = submodel;
	}

	dmodel = &world->submodels[i];
	submodel->hulls[0].firstclipnode = dmodel->headnode[0];
	for (j = 1; j < MAX_MAP_HULLS; j++) {
	    submodel->hulls[j].firstclipnode = dmodel->headnode[j];
	    submodel->hulls[j].lastclipnode = submodel->numclipnodes - 1;
	}

	submodel->firstmodelsurface = dmodel->firstface;
	submodel->nummodelsurfaces = dmodel->numfaces;
	submodel->numleafs = dmodel->visleafs;

	VectorCopy(dmodel->maxs, model->maxs);
	VectorCopy(dmodel->mins, model->mins);
	model->radius = RadiusFromBounds(model->mins, model->maxs);
    }
}

static const char *
BSPVersionString(int32_t version)
{
    static char buffers[2][20];
    static int index;
    char *buffer;

    switch (version) {
    case BSP2RMQVERSION:
	return "BSP2rmq";
    case BSP2VERSION:
	return "BSP2";
    default:
	buffer = buffers[1 & ++index];
	qsnprintf(buffer, sizeof(buffers[0]), "%d", version);
	return buffer;
    }
}

static qboolean
BSPVersionSupported(int32_t version)
{
    switch (version) {
    case BSPVERSION:
    case BSP2VERSION:
    case BSP2RMQVERSION:
	return true;
    default:
	return false;
    }
}

/*
=================
Mod_LoadBrushModel
=================
*/
static void
Mod_LoadBrushModel(brushmodel_t *brushmodel, void *buffer, size_t size)
{
    model_t *model = &brushmodel->model;
    dheader_t *header = buffer;
    int i, j;

    model->type = mod_brush;

    /* swap all the header entries */
    header->version = LittleLong(header->version);
    for (i = 0; i < HEADER_LUMPS; i++) {
	header->lumps[i].fileofs = LittleLong(header->lumps[i].fileofs);
	header->lumps[i].filelen = LittleLong(header->lumps[i].filelen);
    }

    if (!BSPVersionSupported(header->version))
	SV_Error("%s: %s has unsupported version %s",
		 __func__, model->name, BSPVersionString(header->version));

    /*
     * Check the lump extents
     * FIXME - do this more generally... cleanly...?
     */
    for (i = 0; i < HEADER_LUMPS; ++i) {
	int b1 = header->lumps[i].fileofs;
	int e1 = b1 + header->lumps[i].filelen;

	/*
	 * Sanity checks
	 * - begin and end >= 0 (end might overflow).
	 * - end > begin (again, overflow reqd.)
	 * - end < size of file.
	 */
	if (b1 > e1 || e1 > size || b1 < 0 || e1 < 0)
	    SV_Error("%s: bad lump extents in %s", __func__, model->name);

	/* Now, check that it doesn't overlap any other lumps */
	for (j = 0; j < HEADER_LUMPS; ++j) {
	    int b2 = header->lumps[j].fileofs;
	    int e2 = b2 + header->lumps[j].filelen;

	    if ((b1 < b2 && e1 > b2) || (b2 < b1 && e2 > b1))
		SV_Error("%s: overlapping lumps in %s", __func__, model->name);
	}
    }

#ifdef QW_HACK
    brushmodel->checksum = 0;
    brushmodel->checksum2 = 0;

    /* checksum the map */
    for (i = 0; i < HEADER_LUMPS; i++) {
	unsigned int checksum;
	const lump_t *headerlump = &header->lumps[i];
	const byte *data = (byte *)header + headerlump->fileofs;

	/* exclude entities from both checksums */
	if (i == LUMP_ENTITIES)
	    continue;
	checksum = Com_BlockChecksum(data, headerlump->filelen);
	brushmodel->checksum ^= checksum;

	/* Exclude visibility, leafs and nodes from checksum2 */
	if (i == LUMP_VISIBILITY || i == LUMP_LEAFS || i == LUMP_NODES)
	    continue;
	brushmodel->checksum2 ^= checksum;
    }
    brushmodel->checksum = LittleLong(brushmodel->checksum);
    brushmodel->checksum2 = LittleLong(brushmodel->checksum2);
#endif

    /* load into heap */
    Mod_LoadVertexes(brushmodel, header);
    if (header->version == BSPVERSION) {
	Mod_LoadEdges_BSP29(brushmodel, header);
    } else {
	Mod_LoadEdges_BSP2(brushmodel, header);
    }
    Mod_LoadSurfedges(brushmodel, header);
    Mod_LoadTextures(brushmodel, header);

    /* Renderer provides the lighting loader */
    brush_loader->LoadLighting(brushmodel, header);

    Mod_LoadPlanes(brushmodel, header);
    Mod_LoadTexinfo(brushmodel, header);
    if (header->version == BSPVERSION) {
	Mod_LoadFaces_BSP29(brushmodel, header);
	Mod_LoadMarksurfaces_BSP29(brushmodel, header);
    } else {
	Mod_LoadFaces_BSP2(brushmodel, header);
	Mod_LoadMarksurfaces_BSP2(brushmodel, header);
    }
    Mod_LoadVisibility(brushmodel, header);
    if (header->version == BSPVERSION) {
	Mod_LoadLeafs_BSP29(brushmodel, header);
	Mod_LoadNodes_BSP29(brushmodel, header);
	Mod_LoadClipnodes_BSP29(brushmodel, header);
    } else {
	if (header->version == BSP2RMQVERSION) {
	    Mod_LoadLeafs_BSP2rmq(brushmodel, header);
	    Mod_LoadNodes_BSP2rmq(brushmodel, header);
	} else {
	    Mod_LoadLeafs_BSP2(brushmodel, header);
	    Mod_LoadNodes_BSP2(brushmodel, header);
	}
	Mod_LoadClipnodes_BSP2(brushmodel, header);
    }
    Mod_LoadEntities(brushmodel, header);
    Mod_LoadSubmodels(brushmodel, header);

    Mod_MakeDrawHull(brushmodel);

    model->numframes = 2;		// regular and alternate animation
    model->flags = 0;

    /*
     * Create space for the decompressed vis data
     * - We assume the main map is the first BSP file loaded (should be)
     * - If any other model has more leafs, then we may be in trouble...
     */
    if (brushmodel->numleafs > pvscache_numleafs) {
	if (pvscache[0].leafbits)
	    SV_Error("%s: %d allocated for visdata, but model %s has %d leafs",
		     __func__, pvscache_numleafs, model->name,
		     brushmodel->numleafs);
	Mod_InitPVSCache(brushmodel->numleafs);
    }

    Mod_SetupSubmodels(brushmodel, brush_loader);

    // Allow the loader to do additional post-processing
    brush_loader->PostProcess(brushmodel);
}

/*
 * =========================================================================
 *                          CLIENT ONLY FUNCTIONS
 * =========================================================================
 */
#ifndef SERVERONLY

/*
===============
Mod_Extradata

Caches the data if needed
===============
*/
aliashdr_t *
Mod_Extradata(model_t *model)
{
    void *buffer;
    size_t buffersize;

    buffer = Cache_Check(&model->cache);
    if (buffer)
	return buffer;

    buffer = COM_LoadTempFile(model->name, &buffersize);
    Mod_LoadAliasModel(alias_loader, model, buffer, buffersize);
    if (!model->cache.data)
	Sys_Error("%s: caching failed", __func__);

    return model->cache.data;
}

/*
================
Mod_Print
================
*/
void
Mod_Print(void)
{
    int alias = 0, bsp = 0, sprite = 0;
    const brushmodel_t *brushmodel;
    const model_t *model;

    Con_Printf("Cached models:\n");
    for (model = Mod_AliasCache(); model; model = model->next) {
	Con_Printf("%*p : %s\n", (int)sizeof(void *) * 2 + 2,
		   model->cache.data, model->name);
	alias++;
    }
    for (model = Mod_AliasOverflow(); model; model = model->next) {
	Con_Printf("%*p : %s\n", (int)sizeof(void *) * 2 + 2,
		   model->cache.data, model->name);
	alias++;
    }
    for (model = loaded_sprites; model; model = model->next) {
	Con_Printf("%*p : %s\n", (int)sizeof(void *) * 2 + 2,
		   model->cache.data, model->name);
	sprite++;
    }

    brushmodel = loaded_brushmodels;
    while (brushmodel) {
	model = &brushmodel->model;
	Con_Printf("%*p : %s\n", (int)sizeof(void *) * 2 + 2,
		   model->cache.data, model->name);
	bsp++;
	brushmodel = brushmodel->next;
    }

    Con_Printf("%d models: %d alias, %d bsp, %d sprite\n",
	       alias + bsp + sprite, alias, bsp, sprite);
}

#ifdef GLQUAKE
void
Mod_ReloadTextures()
{
    const model_t *model;
    brushmodel_t *brushmodel;

    /* Alias models (textures and vertex buffers) */
    for (model = Mod_AliasCache(); model; model = model->next) {
        GL_LoadAliasSkinTextures(model, NULL);
        GL_UploadAliasMeshData(Cache_Check(&model->cache));
    }
    for (model = Mod_AliasOverflow(); model; model = model->next) {
        GL_LoadAliasSkinTextures(model, NULL);
        GL_UploadAliasMeshData(Cache_Check(&model->cache));
    }

    /* Sprites */
    for (model = loaded_sprites; model; model = model->next) {
        GL_LoadSpriteTextures(model);
    }

    /* Brush models */
    brushmodel = loaded_brushmodels;
    if (brushmodel) {
        glbrushmodel_resource_t *resources = GLBrushModel(brushmodel)->resources;
        for (int i = 0; i < resources->numblocks; i++)
            resources->blocks[i].texture = invalid_texture_id;
        for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
            if (brushmodel->parent)
                continue;
            GL_LoadBrushModelTextures(brushmodel);
            GL_UploadLightmaps(&brushmodel->model, GLBrushModel(brushmodel)->resources);
        }
    }
}
#endif

/*
==================
Mod_TouchModel
==================
*/
void
Mod_TouchModel(const char *name)
{
    model_t *model;

    /* Move models we will need to the head of the LRU list (only alias) */
    model = Mod_FindAliasName(name);
    if (model)
	Cache_Check(&model->cache);
}

#endif /* !SERVERONLY */

/*
 * ===========================================================================
 * HULL BOXES
 *
 * To keep everything totally uniform, bounding boxes are turned into small
 * BSP trees instead of being traced directly.
 * ===========================================================================
 */

static const mclipnode_t box_clipnodes[6] = {
    { .planenum = 0, .children = { CONTENTS_EMPTY, 1 } },
    { .planenum = 1, .children = { 2, CONTENTS_EMPTY } },
    { .planenum = 2, .children = { CONTENTS_EMPTY, 3 } },
    { .planenum = 3, .children = { 4, CONTENTS_EMPTY } },
    { .planenum = 4, .children = { CONTENTS_EMPTY, 5 } },
    { .planenum = 5, .children = { CONTENTS_SOLID, CONTENTS_EMPTY } }
};

static const boxhull_t boxhull_template = {
    .hull = {
	.clipnodes = box_clipnodes,
	.firstclipnode = 0,
	.lastclipnode = 5
    },
    .planes = {
	{ .normal = { 1, 0, 0 }, .dist = 0, .type = 0 },
	{ .normal = { 1, 0, 0 }, .dist = 0, .type = 0 },
	{ .normal = { 0, 1, 0 }, .dist = 0, .type = 1 },
	{ .normal = { 0, 1, 0 }, .dist = 0, .type = 1 },
	{ .normal = { 0, 0, 1 }, .dist = 0, .type = 2 },
	{ .normal = { 0, 0, 1 }, .dist = 0, .type = 2 }
    }
};

/*
===================
SV_CreateBoxHull

Set up the planes and clipnodes using the template so that the six floats
of a bounding box can just be stored out and get a proper hull_t structure.
===================
*/
void
Mod_CreateBoxhull(const vec3_t mins, const vec3_t maxs, boxhull_t *boxhull)
{
    memcpy(boxhull, &boxhull_template, sizeof(boxhull_template));

    boxhull->hull.planes = boxhull->planes;
    boxhull->planes[0].dist = maxs[0];
    boxhull->planes[1].dist = mins[0];
    boxhull->planes[2].dist = maxs[1];
    boxhull->planes[3].dist = mins[1];
    boxhull->planes[4].dist = maxs[2];
    boxhull->planes[5].dist = mins[2];
}


/*
 * ===========================================================================
 * POINT / LINE TESTING IN HULLS
 * ===========================================================================
 */

/*
==================
Mod_HullPointContents
==================
*/
#ifndef USE_X86_ASM
int
Mod_HullPointContents(const hull_t *hull, int nodenum, const vec3_t point)
{
    float dist;
    const mclipnode_t *node;
    const mplane_t *plane;

    while (nodenum >= 0) {
	if (nodenum < hull->firstclipnode || nodenum > hull->lastclipnode)
	    SV_Error("%s: bad node number (%i)", __func__, nodenum);

	node = hull->clipnodes + nodenum;
	plane = hull->planes + node->planenum;

	if (plane->type < 3)
	    dist = point[plane->type] - plane->dist;
	else
	    dist = DotProduct(plane->normal, point) - plane->dist;
	if (dist < 0)
	    nodenum = node->children[1];
	else
	    nodenum = node->children[0];
    }

    return nodenum;
}
#endif

/* 1/32 epsilon to keep floating point happy */
#define	DIST_EPSILON	(0.03125)

/*
==================
MOD_TraceHull
==================
*/
static qboolean
Mod_TraceHull_r(const hull_t *hull, int nodenum,
		const float p1f, const float p2f,
		const vec3_t p1, const vec3_t p2, trace_t *trace)
{
    const mclipnode_t *node;
    const mplane_t *plane;
    vec3_t mid;
    vec_t dist1, dist2, frac, midf;
    int i, child, side, contents;

    /* check for empty */
    if (nodenum < 0) {
	if (nodenum != CONTENTS_SOLID) {
	    trace->allsolid = false;
	    if (nodenum == CONTENTS_EMPTY)
		trace->inopen = true;
	    else
		trace->inwater = true;
	} else {
	    trace->startsolid = true;
	}
	return true;
    }

    if (nodenum < hull->firstclipnode || nodenum > hull->lastclipnode)
	SV_Error("%s: bad node number", __func__);

    /* Find the point distances */
    node = hull->clipnodes + nodenum;
    plane = hull->planes + node->planenum;
    if (plane->type < 3) {
	dist1 = p1[plane->type] - plane->dist;
	dist2 = p2[plane->type] - plane->dist;
    } else {
	dist1 = DotProduct(plane->normal, p1) - plane->dist;
	dist2 = DotProduct(plane->normal, p2) - plane->dist;
    }

#if 1
    if (dist1 >= 0 && dist2 >= 0) {
	child = node->children[0];
	return Mod_TraceHull_r(hull, child, p1f, p2f, p1, p2, trace);
    }
    if (dist1 < 0 && dist2 < 0) {
	child = node->children[1];
	return Mod_TraceHull_r(hull, child, p1f, p2f, p1, p2, trace);
    }
#else
    if ((dist1 >= DIST_EPSILON && dist2 >= DIST_EPSILON) || (dist2 > dist1 && dist1 >= 0)) {
	child = node->children[0];
	return Mod_TraceHull_r(hull, child, p1f, p2f, p1, p2, trace);
    }
    if ((dist1 <= -DIST_EPSILON && dist2 <= -DIST_EPSILON) || (dist2 < dist1 && dist1 <= 0)) {
	child = node->children[1];
	return Mod_TraceHull_r(hull, child, p1f, p2f, p1, p2, trace);
    }
#endif

    /* Put the crosspoint DIST_EPSILON pixels on the near side */
    if (dist1 < 0)
	frac = (dist1 + DIST_EPSILON) / (dist1 - dist2);
    else
	frac = (dist1 - DIST_EPSILON) / (dist1 - dist2);
    if (frac < 0)
	frac = 0;
    if (frac > 1)
	frac = 1;

    midf = p1f + (p2f - p1f) * frac;
    for (i = 0; i < 3; i++)
	mid[i] = p1[i] + frac * (p2[i] - p1[i]);

    side = (dist1 < 0);

    /* move up to the node */
    child = node->children[side];
    if (!Mod_TraceHull_r(hull, child, p1f, midf, p1, mid, trace))
	return false;

#ifdef PARANOID
    if (Mod_HullPointContents(sv_hullmodel, mid, child) == CONTENTS_SOLID) {
	Con_Printf("mid PointInHullSolid\n");
	return false;
    }
#endif

    child = node->children[side ^ 1];
    if (Mod_HullPointContents(hull, child, mid) != CONTENTS_SOLID)
	/* Go past the node */
	return Mod_TraceHull_r(hull, child, midf, p2f, mid, p2, trace);

    /* Never got out of the solid area */
    if (trace->allsolid)
	return false;

    /* The other side of the node is solid, this is the impact point */
    if (!side) {
	VectorCopy(plane->normal, trace->plane.normal);
	trace->plane.dist = plane->dist;
    } else {
	VectorSubtract(vec3_origin, plane->normal, trace->plane.normal);
	trace->plane.dist = -plane->dist;
    }

    /* shouldn't really happen, but does occasionally */
    contents = Mod_HullPointContents(hull, hull->firstclipnode, mid);
    while (contents == CONTENTS_SOLID) {
	frac -= 0.1;
	if (frac < 0) {
	    trace->fraction = midf;
	    VectorCopy(mid, trace->endpos);
	    Con_DPrintf("backup past 0\n");
	    return false;
	}
	midf = p1f + (p2f - p1f) * frac;
	for (i = 0; i < 3; i++)
	    mid[i] = p1[i] + frac * (p2[i] - p1[i]);

	contents = Mod_HullPointContents(hull, hull->firstclipnode, mid);
    }

    trace->fraction = midf;
    VectorCopy(mid, trace->endpos);

    return false;
}

qboolean
Mod_TraceHull(const hull_t *hull, int nodenum,
	      const vec3_t p1, const vec3_t p2, trace_t *trace)
{
    return Mod_TraceHull_r(hull, nodenum, 0, 1, p1, p2, trace);
}
