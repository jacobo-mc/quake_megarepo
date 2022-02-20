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

#include "console.h"
#include "glquake.h"
#include "gl_model.h"
#include "sys.h"

int32_t material_max_verts;

/*
 * Model Loader Functions
 */
static int GL_AliashdrPadding() { return offsetof(gl_aliashdr_t, ahdr); }
static int GL_BrushModelPadding() { return offsetof(glbrushmodel_t, brushmodel); }

/*
=================
Mod_FloodFillSkin

Fill background pixels so mipmapping doesn't have haloes - Ed
=================
*/

typedef struct {
    short x, y;
} floodfill_t;

// must be a power of 2
#define FLOODFILL_FIFO_SIZE 0x1000
#define FLOODFILL_FIFO_MASK (FLOODFILL_FIFO_SIZE - 1)

#define FLOODFILL_STEP( off, dx, dy ) \
{ \
	if (pos[off] == fillcolor) \
	{ \
		pos[off] = 255; \
		fifo[inpt].x = x + (dx), fifo[inpt].y = y + (dy); \
		inpt = (inpt + 1) & FLOODFILL_FIFO_MASK; \
	} \
	else if (pos[off] != 255) fdc = pos[off]; \
}

static void
GL_FloodFillSkin(byte *skin, int skinwidth, int skinheight)
{
    byte fillcolor = *skin;	// assume this is the pixel to fill
    floodfill_t fifo[FLOODFILL_FIFO_SIZE];
    int inpt = 0, outpt = 0;
    int filledcolor = -1;
    int i;

    if (filledcolor == -1) {
	filledcolor = 0;
	// attempt to find opaque black (FIXME - precompute!)
        const qpixel32_t black = { .c.red = 0, .c.green = 0, .c.blue = 0, .c.alpha = 255 };
	for (i = 0; i < 256; ++i)
	    if (qpal_standard.colors[i].rgba == black.rgba)
	    {
		filledcolor = i;
		break;
	    }
    }
    // can't fill to filled color or to transparent color (used as visited marker)
    if ((fillcolor == filledcolor) || (fillcolor == 255)) {
	//printf( "not filling skin from %d to %d\n", fillcolor, filledcolor );
	return;
    }

    fifo[inpt].x = 0, fifo[inpt].y = 0;
    inpt = (inpt + 1) & FLOODFILL_FIFO_MASK;

    while (outpt != inpt) {
	int x = fifo[outpt].x, y = fifo[outpt].y;
	int fdc = filledcolor;
	byte *pos = &skin[x + skinwidth * y];

	outpt = (outpt + 1) & FLOODFILL_FIFO_MASK;

	if (x > 0)
	    FLOODFILL_STEP(-1, -1, 0);
	if (x < skinwidth - 1)
	    FLOODFILL_STEP(1, 1, 0);
	if (y > 0)
	    FLOODFILL_STEP(-skinwidth, 0, -1);
	if (y < skinheight - 1)
	    FLOODFILL_STEP(skinwidth, 0, 1);
	skin[x + skinwidth * y] = fdc;
    }
}

static void
GL_LoadAliasSkinData(model_t *model, aliashdr_t *aliashdr, const alias_skindata_t *skindata)
{
    int i, skinsize;
    qgltexture_t *textures;
    byte *pixels;

    skinsize = aliashdr->skinwidth * aliashdr->skinheight;
    pixels = Mod_AllocName(skindata->numskins * skinsize, model->name);
    aliashdr->skindata = (byte *)pixels - (byte *)aliashdr;
    textures = Mod_AllocName(skindata->numskins * sizeof(qgltexture_t), model->name);
    GL_Aliashdr(aliashdr)->textures = (byte *)textures - (byte *)aliashdr;
    GL_Aliashdr(aliashdr)->numtextures = skindata->numskins;

    for (i = 0; i < skindata->numskins; i++) {
	GL_FloodFillSkin(skindata->data[i], aliashdr->skinwidth, aliashdr->skinheight);
	memcpy(pixels, skindata->data[i], skinsize);
        pixels += skinsize;
    }

    GL_LoadAliasSkinTextures(model, aliashdr);
}

static void
GL_AliasModelCacheDestructor(cache_user_t *cache)
{
    const model_t *model = container_of(cache, model_t, cache);
    GL_DisownTextures(model);

    gl_aliashdr_t *glhdr = GL_Aliashdr(cache->data);
    if (glhdr->buffers.all[0]) {
        qglDeleteBuffers(ARRAY_SIZE(glhdr->buffers.all), glhdr->buffers.all);
    }
}

static alias_loader_t GL_AliasModelLoader = {
    .Padding = GL_AliashdrPadding,
    .LoadSkinData = GL_LoadAliasSkinData,
    .LoadMeshData = GL_LoadAliasMeshData,
    .CacheDestructor = GL_AliasModelCacheDestructor,
};

const alias_loader_t *
R_AliasModelLoader(void)
{
    return &GL_AliasModelLoader;
}

/*
 * Allocates space in the lightmap blocks for the surface lightmap
 */
static void
GL_AllocLightmapBlock(glbrushmodel_resource_t *resources, msurface_t *surf)
{
    int i, j;
    int best, best2;
    int blocknum;
    int *allocated;
    int width, height;

    assert(!(surf->flags & (SURF_DRAWSKY | SURF_DRAWTURB)));

    width = (surf->extents[0] >> 4) + 1;
    height = (surf->extents[1] >> 4) + 1;

    /*
     * Only scan over the last four blocks. Only negligable effects on the
     * packing efficiency, but much faster for maps with a lot of lightmaps.
     */
    blocknum = qmax(0, resources->numblocks - 4);
    for ( ;; blocknum++) {
	if (blocknum == resources->numblocks) {
	    Hunk_AllocExtend(resources->blocks, sizeof(lm_block_t));
	    resources->numblocks++;
	}
	allocated = resources->blocks[blocknum].allocated;

	best = BLOCK_HEIGHT - height + 1;
	for (i = 0; i < BLOCK_WIDTH - width; i++) {
	    best2 = 0;
	    for (j = 0; j < width; j++) {
		/* If it's not going to fit, don't check again... */
		if (allocated[i + j] + height > BLOCK_HEIGHT) {
		    i += j + 1;
		    break;
		}
		if (allocated[i + j] >= best)
		    break;
		if (allocated[i + j] > best2)
		    best2 = allocated[i + j];
	    }
	    if (j == width) {	// this is a valid spot
		surf->light_s = i;
		surf->light_t = best = best2;
	    }
	}
	if (best + height <= BLOCK_HEIGHT)
	    break;
    }

    /* Mark the allocation as used */
    for (i = 0; i < width; i++) {
	allocated[surf->light_s + i] = best + height;
    }

    surf->lightmapblock = blocknum;
}

/*
 * Materials are divided into classes to minimise rendering state changes.
 * Probably worth checking if this make much of a difference for the complication...
 */
static enum material_class
GL_GetTextureMaterialClass(texture_t *texture)
{
    if (texture->name[0] == '*')
        return MATERIAL_LIQUID;
    if (texture->name[0] == '{')
        return TextureIsValid(texture->gl_texturenum_fullbright) ? MATERIAL_FENCE_FULLBRIGHT : MATERIAL_FENCE;
    if (!strncmp(texture->name, "sky", 3))
        return MATERIAL_SKY;
    if (TextureIsValid(texture->gl_texturenum_fullbright))
        return MATERIAL_FULLBRIGHT;

    return MATERIAL_BASE;
}

/*
 * Given an animating texture, return the texture corresponding to the first
 * frame in the animation sequence.
 */
static texture_t *
GL_GetAnimationBaseTexture(texture_t *texture)
{
    assert(texture->anim_total);
    assert(texture->name[0] == '+');

    texture_t *frame = texture;
    do {
        char index = frame->name[1];
        if (index == '0' || index == 'a' || index == 'A')
            return frame;
        frame = frame->anim_next;
    } while (frame != texture);

    Sys_Error("%s: Unable to find base texture for %s", __func__, texture->name);
}

/*
 * This 'primary' texture is just finding the first texture in the full animation sequence including
 * alternate animations that will be registered as a material.  This will be the one with the lower
 * material class and if there are multiple within the same class, then the one with the lower
 * texture number.
 */
static texture_t *
GL_GetAnimationPrimaryTexture(texture_t *texture)
{
    assert(texture->anim_total);

    enum material_class primary_class = GL_GetTextureMaterialClass(texture);
    texture_t *primary_texture = texture;

    /* Check animations */
    texture_t *frame = texture;
    do {
        enum material_class frame_class = GL_GetTextureMaterialClass(frame);
        if (frame_class < primary_class) {
            primary_class = frame_class;
            primary_texture = frame;
        } else if (frame_class == primary_class && frame->texturenum < primary_texture->texturenum) {
            primary_texture = frame;
        }
        frame = frame->anim_next;
    } while (frame != texture);

    /* Check alternate animations */
    if (texture->alternate_anims) {
        frame = texture = texture->alternate_anims;
        do {
            enum material_class frame_class = GL_GetTextureMaterialClass(frame);
            if (frame_class < primary_class) {
                primary_class = frame_class;
                primary_texture = frame;
            } else if (frame_class == primary_class && frame->texturenum < primary_texture->texturenum) {
                primary_texture = frame;
            }
            frame = frame->anim_next;
        } while (frame != texture);
    }

    return primary_texture;
}

static void
GL_BrushModelPostProcess(brushmodel_t *brushmodel)
{
    mtexinfo_t *texinfo;
    int i;

    /*
     * For our material based rendering we want to ensure that for all
     * animating textures, the first animation frame is the one applied to the
     * surface.  This allows some simplification to the process for
     * determining the correct animation frame for each surface.
     */
    texinfo = brushmodel->texinfo;
    for (i = 0; i < brushmodel->numtexinfo; i++, texinfo++) {
        if (texinfo->texture->anim_total) {
            texture_t *basetexture = GL_GetAnimationBaseTexture(texinfo->texture);
            if (texinfo->texture != basetexture)
                texinfo->texture = basetexture;
        }
    }

    /*
     * Ensure all sky texinfos point to the active sky texture (there
     * can be more than one sky texture in a brushmodel, but only the
     * last one is used).
     */
    texture_t *skytexture = NULL;
    for (i = 0; i < brushmodel->numtextures; i++) {
        texture_t *texture = brushmodel->textures[i];
        if (texture && !strncmp(texture->name, "sky", 3))
            skytexture = texture;
    }
    if (skytexture) {
        mtexinfo_t *texinfo = brushmodel->texinfo;
        for (i = 0; i < brushmodel->numtexinfo; i++, texinfo++) {
            if (!strncmp(texinfo->texture->name, "sky", 3))
                texinfo->texture = skytexture;
        }
    }
}

#ifdef DEBUG
static const char *material_class_names[] = {
    "MATERIAL_SKY",
    "MATERIAL_BASE",
    "MATERIAL_FULLBRIGHT",
    "MATERIAL_FENCE",
    "MATERIAL_FENCE_FULLBRIGHT",
    "MATERIAL_LIQUID",
    "MATERIAL_END",
};

static void
Debug_PrintMaterials(glbrushmodel_t *glbrushmodel)
{
    brushmodel_t *brushmodel = &glbrushmodel->brushmodel;
    surface_material_t *material;
    material_animation_t *animation;
    enum material_class class;
    int i;

    Sys_Printf("====== %s ======\n", glbrushmodel->brushmodel.model.name);

    for (class = MATERIAL_START; class <= MATERIAL_END; class++) {
        Sys_Printf("%25s: %d\n", material_class_names[class], glbrushmodel->material_index[class]);
    }

    class = MATERIAL_START;
    material = &glbrushmodel->materials[0];
    for (i = 0; i < glbrushmodel->nummaterials; i++, material++) {
        texture_t *texture = brushmodel->textures[material->texturenum];
        Sys_Printf("Material %3d: %-16s (%3d) :: lightmap block %3d",
                   i, texture->name, material->texturenum, material->lightmapblock);
        if (i == glbrushmodel->material_index[class]) {
            while (i == glbrushmodel->material_index[class + 1])
                class++;
            Sys_Printf("  <---- %s\n", material_class_names[class]);
            class++;
        } else {
            Sys_Printf("\n");
        }
    }

    animation = glbrushmodel->animations;
    for (i = 0; i < glbrushmodel->numanimations; i++, animation++) {
        material = &glbrushmodel->materials[animation->material];
        Sys_Printf("Animation %d: material %d (%s / %d), %d frames, %d alt frames\n",
                   i,
                   animation->material,
                   brushmodel->textures[material->texturenum]->name,
                   material->lightmapblock,
                   animation->numframes,
                   animation->numalt);
        int j;
        for (j = 0; j < animation->numframes; j++)
            Sys_Printf("   frame %d: material %d (%s)\n", j, animation->frames[j], brushmodel->textures[glbrushmodel->materials[animation->frames[j]].texturenum]->name);
        for (j = 0; j < animation->numalt; j++)
            Sys_Printf("   alt   %d: material %d (%s)\n", j, animation->alt[j], brushmodel->textures[glbrushmodel->materials[animation->alt[j]].texturenum]->name);
    }
}
#else
static inline void Debug_PrintMaterials(glbrushmodel_t *glbrushmodel) { }
#endif

/*
 * Find a material that we know should exist already
 */
static int
GL_FindAnimationMaterial(glbrushmodel_t *glbrushmodel, int texturenum, int base_material)
{
    int materialnum;
    surface_material_t *material;

    material = glbrushmodel->materials;
    for (materialnum = 0; materialnum < glbrushmodel->nummaterials; materialnum++, material++) {
        if (material->texturenum != texturenum)
            continue;
        if (materialnum != base_material && material->animation_base_material != base_material)
            continue;
        break;
    }

    assert(materialnum < glbrushmodel->nummaterials);

    return materialnum;
}

static void
GL_AllocateMaterial(glbrushmodel_t *glbrushmodel, msurface_t *texturechain, int texturenum, int material_start)
{
    msurface_t *surf;
    surface_material_t *material;

    for (surf = texturechain; surf; surf = surf->chain) {
        int lightmapblock = surf->lightmapblock;
        int materialnum = material_start;
        for ( ; materialnum < glbrushmodel->nummaterials; materialnum++) {
            material = &glbrushmodel->materials[materialnum];
            if (material->texturenum != texturenum)
                continue;
            if (material->lightmapblock != lightmapblock)
                continue;
            if (material->numverts + surf->numedges > material_max_verts)
                continue;
            break;
        }
        surf->material = materialnum;
        if (materialnum < glbrushmodel->nummaterials) {
            material->numverts += surf->numedges;
            continue;
        }

        /*
         * TODO: The hunk extension will be rounded up to the nearest
         * 16 bytes, which might waste some space over the entire
         * material list.  Make a better alloc helper for this case?
         */
        Hunk_AllocExtend(glbrushmodel->materials, sizeof(surface_material_t));
        material = &glbrushmodel->materials[glbrushmodel->nummaterials++];
        material->texturenum = texturenum;
        material->lightmapblock = surf->lightmapblock;
        material->animation_base_material = -1;
        material->numverts = surf->numedges;
    }
}

static void
GL_CopyMaterialsForAnimationFrame(glbrushmodel_t *glbrushmodel, msurface_t *texturechain, texture_t *src, texture_t *dst)
{
    if (src == dst)
        return;

    int nummaterials = glbrushmodel->nummaterials;
    for (int materialnum = 0; materialnum < nummaterials; materialnum++) {
        surface_material_t *src_material = &glbrushmodel->materials[materialnum];
        if (src_material->texturenum != src->texturenum)
            continue;

        assert(src_material->animation_base_material == -1);
        Hunk_AllocExtend(glbrushmodel->materials, sizeof(surface_material_t));
        surface_material_t *dst_material = &glbrushmodel->materials[glbrushmodel->nummaterials++];

        *dst_material = *src_material;
        dst_material->texturenum = dst->texturenum;
        dst_material->animation_base_material = materialnum;

        Debug_Printf("Made a copy of material %d (%s/%d) for alt texture '%s' (%d)\n",
                     materialnum, src->name, src_material->lightmapblock, dst->name, (int)(dst_material - glbrushmodel->materials));
    }
}

static void
GL_CopyBufferInfoForAnimationFrames(glbrushmodel_t *glbrushmodel, int materialnum)
{
    assert(materialnum >= 0);

    const surface_material_t *source_material = &glbrushmodel->materials[materialnum];
    surface_material_t *material = glbrushmodel->materials;
    for (int i = 0; i < glbrushmodel->nummaterials; i++, material++) {
        if (material->animation_base_material == materialnum) {
            Debug_Printf("Copying buffer info for material %d (%s) to %d (%s)\n",
                         materialnum, glbrushmodel->brushmodel.textures[glbrushmodel->materials[materialnum].texturenum]->name,
                         i, glbrushmodel->brushmodel.textures[material->texturenum]->name);
            material->offset = source_material->offset;
            material->numverts = source_material->numverts;
            material->buffer_id = source_material->buffer_id;
        }
    }
}

static void
AddSurfaceVertices(brushmodel_t *brushmodel, msurface_t *surf, vec7_t *verts)
{
    for (int i = 0; i < surf->numedges; i++) {
        const float *bspvertex;
	const int edgenum = brushmodel->surfedges[surf->firstedge + i];
	if (edgenum >= 0) {
	    const medge_t *const edge = &brushmodel->edges[edgenum];
	    bspvertex = brushmodel->vertexes[edge->v[0]].position;
	} else {
	    const medge_t *const edge = &brushmodel->edges[-edgenum];
	    bspvertex = brushmodel->vertexes[edge->v[1]].position;
	}
	VectorCopy(bspvertex, verts[i]);
        if (surf->flags & SURF_DRAWSKY)
            continue;

	/* Texture coordinates */
        const mtexinfo_t *const texinfo = surf->texinfo;
	float s = DotProduct(bspvertex, texinfo->vecs[0]);
	float t = DotProduct(bspvertex, texinfo->vecs[1]);

        if (surf->flags & SURF_DRAWTURB) {
            verts[i][3] = s / 64.0f; /* Scaled by standard warp texture width/height of 64 */
            verts[i][4] = t / 64.0f;
            verts[i][5] = s;         /* Unscaled texcoord for warp fragment program */
            verts[i][6] = t;
        } else {
            s += surf->texinfo->vecs[0][3];
            t += surf->texinfo->vecs[1][3];

            /* Surface texture coordinates */
            verts[i][3] = s / texinfo->texture->width;
            verts[i][4] = t / texinfo->texture->height;

            /* Lightmap texture coordinates */
            verts[i][5] = (s - surf->texturemins[0] + (surf->light_s * 16) + 8) / (BLOCK_WIDTH  * 16);
            verts[i][6] = (t - surf->texturemins[1] + (surf->light_t * 16) + 8) / (BLOCK_HEIGHT * 16);
        }
    }
}

/* ---------------------------------------------------------------------------- */
/*                         VERTEX BUFFER ALLOCATION                             */
/* ---------------------------------------------------------------------------- */

/*
 * We ensure we allocate all vertices for the same material in the same vertex
 * buffer.  Materials that have a smaller number of verties are packed
 * together into a larger buffer so the gl driver doesn't have to track too
 * many separately allocated buffers.
 *
 * The allocator keeps around a small number of buffers from which it can
 * allocate.  We always allocate from the buffer with the least amount of free
 * space that can satisfy the allocation.  When none of those buffers have
 * enough space, we allocate a new buffer.  The allocator then stops tracking
 * the buffer that currently has the least free space.
 */

struct vballoc_state {
    vec7_t *buffer;
    int id;
    int count;
    int free;
};

static int vertex_buffers_total_allocation;
static int vertex_buffers_vertices_wasted;

struct vertex_buffer_info *gl_bmodel_vertex_buffers;
int num_gl_bmodel_vertex_buffers;

#define VBALLOC_NUM_BUFFERS 4
static struct {
    struct vballoc_state states[VBALLOC_NUM_BUFFERS];
    int32_t vertices_remaining;
} vballoc;

static void
VBAlloc_Init(int total_verts, int max_buffers)
{
    memset(&vballoc, 0, sizeof(vballoc));
    vballoc.vertices_remaining = total_verts;

    /* We'll never need this many, but we'll trim it down after we're done */
    gl_bmodel_vertex_buffers = Hunk_TempAllocExtend(max_buffers * sizeof(*gl_bmodel_vertex_buffers));
}

static void
VBAlloc_Complete()
{
    for (int i = 0; i < VBALLOC_NUM_BUFFERS; i++)
        vertex_buffers_vertices_wasted += vballoc.states[i].free;

    struct vertex_buffer_info *buffers = gl_bmodel_vertex_buffers;
    size_t vbo_list_bytes = num_gl_bmodel_vertex_buffers * sizeof(*gl_bmodel_vertex_buffers);
    gl_bmodel_vertex_buffers = Hunk_AllocName(vbo_list_bytes, "vertices");
    memcpy(gl_bmodel_vertex_buffers, buffers, vbo_list_bytes);
}

/*
 * When an allocation doesn't fit into any existing buffers, allocate a new
 * vertex buffer to put them in.  Then evict the most full buffer from the
 * buffer list (could be the new buffer, which means it just won't get added).
 */
static void
VBAlloc_FromNew(int numverts, uint32_t *id, uint32_t *offset)
{
    struct vballoc_state newstate;

    newstate.count = qmin(material_max_verts, vballoc.vertices_remaining);
    newstate.buffer = Hunk_AllocName(newstate.count * sizeof(vec7_t), "vertices");
    newstate.id = num_gl_bmodel_vertex_buffers;
    vertex_buffers_total_allocation += newstate.count * sizeof(vec7_t);
    newstate.free = newstate.count - numverts;
    vballoc.vertices_remaining -= numverts;

    gl_bmodel_vertex_buffers[num_gl_bmodel_vertex_buffers].vertices = newstate.buffer;
    gl_bmodel_vertex_buffers[num_gl_bmodel_vertex_buffers].numverts = newstate.count;
    num_gl_bmodel_vertex_buffers++;

    *id = newstate.id;
    *offset = 0;

    for (int i = VBALLOC_NUM_BUFFERS - 1; i >= 0; i--) {
        if (newstate.free <= vballoc.states[i].free)
            continue;

        /* Track wasted space */
        vertex_buffers_vertices_wasted += (i == 0) ? newstate.free : vballoc.states[0].free;

        /* Move entries above to the left and insert here */
        if (i > 0)
            memmove(&vballoc.states[0], &vballoc.states[1], i * sizeof(struct vballoc_state));
        vballoc.states[i] = newstate;
        break;
    }
}

/*
 * Allocate the requested number of vertices from the buffer at the given index and then re-sort the
 * buffers if necessary to maintain order from most allocated to least allocated.
 */
static void
VBAlloc_FromIndex(int numverts, int index, uint32_t *id, uint32_t *offset)
{
    struct vballoc_state *state = &vballoc.states[index];
    *id = state->id;
    *offset = state->count - state->free;
    state->free -= numverts;
    vballoc.vertices_remaining -= numverts;

    int new_index;
    for (new_index = 0; new_index < index; new_index++) {
        if (state->free < vballoc.states[new_index].free) {
            /* Shuffle the other buffers down and insert here. */
            struct vballoc_state tmp = *state;
            memmove(&vballoc.states[new_index + 1], &vballoc.states[new_index], sizeof(struct vballoc_state) * (index - new_index));
            vballoc.states[new_index] = tmp;
            break;
        }
    }
}

/*
 * Allocate vertex buffer space, return the pointer to the buffer and
 * the offset within the buffer where vertices can be written.
 */
void
VBAlloc_GetSpace(int numverts, uint32_t *id, uint32_t *offset)
{
    assert(numverts > 0);

    struct vballoc_state *state = &vballoc.states[0];
    for (int i = 0; i < VBALLOC_NUM_BUFFERS; i++, state++) {
        if (state->free >= numverts) {
            VBAlloc_FromIndex(numverts, i, id, offset);
            return;
        }
    }
    VBAlloc_FromNew(numverts, id, offset);
}

/* --------------------------------------------------------*/

void
GL_BuildMaterials()
{
    glbrushmodel_resource_t *resources;
    glbrushmodel_t *glbrushmodel;
    brushmodel_t *brushmodel;
    msurface_t **texturechains;
    msurface_t *surf;
    enum material_class material_class;
    texture_t *texture;
    int surfnum, texturenum;

    /* Allocate the shared resource structure for the bmodels */
    resources = Hunk_AllocName(sizeof(glbrushmodel_resource_t), "resources");
    resources->blocks = Hunk_AllocName(sizeof(lm_block_t), "lightmaps");
    resources->numblocks = 1;

    /*
     * Allocate lightmaps for all brush models first, so we get contiguous
     * memory for the lightmap block allocations.
     */
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        if (brushmodel->parent)
            continue;

        /*
         * Setup (temporary) texture chains so we can allocate lightmaps in
         * order of texture.  We borrow the materialchains pointer to store
         * the texturechain until every brushmodel has had it's lightmaps
         * allocated.  We'll also initialise the surface material to -1 here
         * to signify no material yet allocated.
         */
        texturechains = Hunk_TempAllocExtend(brushmodel->numtextures * sizeof(msurface_t *));
        surf = brushmodel->surfaces;
        for (surfnum = 0; surfnum < brushmodel->numsurfaces; surfnum++, surf++) {
            surf->material = -1;
            texture = surf->texinfo->texture;
            if (!texture)
                continue;

            /*
             * For animated materials we place the surfaces on the 'primary' texture's chain.
             */
            if (texture->anim_total) {
                texturenum = GL_GetAnimationPrimaryTexture(texture)->texturenum;
            } else {
                texturenum = texture->texturenum;
            }
            surf->chain = texturechains[texturenum];
            texturechains[texturenum] = surf;
        }

        /* Allocate lightmap blocks in texture order */
        for (texturenum = 0; texturenum < brushmodel->numtextures; texturenum++) {
            surf = texturechains[texturenum];
            if (!surf)
                continue;
            if (surf->flags & (SURF_DRAWSKY | SURF_DRAWTURB | SURF_DRAWTILED))
                continue;
            for ( ; surf; surf = surf->chain) {
                GL_AllocLightmapBlock(resources, surf);
            }
        }

        /* Save the texturechains for material allocation below */
        glbrushmodel = GLBrushModel(brushmodel);
        glbrushmodel->materialchains = (void *)texturechains;
    }

    /*
     * Next we allocate materials for each brushmodel
     */
    int total_material_count = 0;
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        if (brushmodel->parent)
            continue;

        glbrushmodel = GLBrushModel(brushmodel);
        glbrushmodel->nummaterials = 0;
        glbrushmodel->materials = Hunk_AllocName(0, "material");
        texturechains = (void *)glbrushmodel->materialchains; /* saved earlier */

        /* To group the materials by class we'll do multiple passes over the texture list */
        material_class = MATERIAL_START;
        for ( ; material_class < MATERIAL_END; material_class++) {
            glbrushmodel->material_index[material_class] = glbrushmodel->nummaterials;

            for (texturenum = 0; texturenum < brushmodel->numtextures; texturenum++) {
                texture = brushmodel->textures[texturenum];
                if (!texture)
                    continue;

                /*
                 * For animating textures, we need to register materials for all frames and
                 * alternates that would match the current class.  The 'primary' texture in the
                 * animation will be the first one allocated and holds the vertex data.  All other
                 * textures in the animation create copies of the primary material(s) which will
                 * then point to the same vertex data (eventually - see below).
                 */
                if (texture->anim_total) {
                    texture_t *primary = GL_GetAnimationPrimaryTexture(texture);
                    if (texture != primary)
                        continue;

                    if (GL_GetTextureMaterialClass(texture) == material_class) {
                        int index = glbrushmodel->material_index[material_class];
                        GL_AllocateMaterial(glbrushmodel, texturechains[texturenum], texture->texturenum, index);
                    }

                    /* Animation frames */
                    texture_t *frame = texture;
                    do {
                        if (GL_GetTextureMaterialClass(frame) == material_class)
                            GL_CopyMaterialsForAnimationFrame(glbrushmodel, texturechains[texturenum], primary, frame);
                        frame = frame->anim_next;
                    } while (frame != texture);

                    /* Alt-animation frames */
                    if (!texture->alternate_anims)
                        continue;

                    frame = texture = texture->alternate_anims;
                    do {
                        if (GL_GetTextureMaterialClass(frame) == material_class) {
                            GL_CopyMaterialsForAnimationFrame(glbrushmodel, texturechains[texturenum], primary, frame);
                        }
                        frame = frame->anim_next;
                    } while (frame != texture);

                    /* Done with this animating texture */
                    continue;
                }

                if (GL_GetTextureMaterialClass(texture) == material_class) {
                    int index = glbrushmodel->material_index[material_class];
                    GL_AllocateMaterial(glbrushmodel, texturechains[texturenum], texturenum, index);
                }
            }
        }
        glbrushmodel->material_index[MATERIAL_END] = glbrushmodel->nummaterials;

        /*
         * Collect the animation information for each material and
         * store it in the glbrushmodel header.
         */
        glbrushmodel->animations = Hunk_AllocName(0, "animation");
        int materialnum;
        surface_material_t *material = glbrushmodel->materials;
        for (materialnum = 0; materialnum < glbrushmodel->nummaterials; materialnum++, material++) {
            texture = brushmodel->textures[material->texturenum];
            if (!texture->anim_total)
                continue;
            if (texture != GL_GetAnimationBaseTexture(texture))
                continue;
            if (texture->alternate_anims && texture->alternate_anims->name[1] == '0')
                continue;

            /* Allocate and add the base frame */
            Hunk_AllocExtend(glbrushmodel->animations, sizeof(material_animation_t));
            material_animation_t *animation = &glbrushmodel->animations[glbrushmodel->numanimations++];
            animation->material = materialnum;
            animation->frames[animation->numframes++] = materialnum;

            int base_materialnum = (material->animation_base_material >= 0)
                ? material->animation_base_material
                : materialnum;

            /* Add all the animation frames */
            texture_t *frame = texture->anim_next;
            while (frame != texture) {
                int frame_material = GL_FindAnimationMaterial(glbrushmodel, frame->texturenum, base_materialnum);
                animation->frames[animation->numframes++] = frame_material;
                frame = frame->anim_next;
            }

            /* Add all the alternate animation frames */
            if (!texture->alternate_anims)
                continue;
            frame = texture = texture->alternate_anims;
            do {
                int frame_material = GL_FindAnimationMaterial(glbrushmodel, frame->texturenum, base_materialnum);
                animation->alt[animation->numalt++] = frame_material;
                frame = frame->anim_next;
            } while (frame != texture);
        }

        total_material_count += glbrushmodel->nummaterials;
    }

    /*
     * Next we allocate the materialchains for every brushmodel (including
     * submodels).  Submodels share the material list with their parent.  All
     * share the common resources struct.
     */
    void *hunkbase = Hunk_AllocName(0, "matchain");
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        glbrushmodel = GLBrushModel(brushmodel);
        if (brushmodel->parent) {
            glbrushmodel_t *parent = GLBrushModel(brushmodel->parent);
            glbrushmodel->nummaterials = parent->nummaterials;
            glbrushmodel->materials = parent->materials;
            memcpy(glbrushmodel->material_index, parent->material_index, sizeof(glbrushmodel->material_index));

            /* TODO: only include animations for textures present in the submodel */
            glbrushmodel->numanimations = parent->numanimations;
            glbrushmodel->animations = parent->animations;
        }
        glbrushmodel->materialchains = Hunk_AllocExtend(hunkbase, glbrushmodel->nummaterials * sizeof(materialchain_t));
        glbrushmodel->resources = resources;

        /* It's a bit verbose to print for all submodels, usually */
        if (!brushmodel->parent)
            Debug_PrintMaterials(glbrushmodel);
    }

    /*
     * Pre-cache which turb textures each (non-world) brushmodel
     * contains so we know when we need to update the warp render target.
     */
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        if (brushmodel == cl.worldmodel)
            continue;

        /* Count and flag the turb textures referenced */
        int turbcount = 0;
        surf = &brushmodel->surfaces[brushmodel->firstmodelsurface];
        for (surfnum = 0; surfnum < brushmodel->nummodelsurfaces; surfnum++, surf++) {
            if (surf->flags & SURF_DRAWTURB) {
                if (!surf->texinfo->texture->mark) {
                    turbcount++;
                    surf->texinfo->texture->mark = 1;
                }
            }
        }
        if (!turbcount)
            continue;

        /* Allocate the turb texture pointers and fill them out */
        glbrushmodel = GLBrushModel(brushmodel);
        glbrushmodel->numturbtextures = 0;
        glbrushmodel->turbtextures = Hunk_AllocName(turbcount * sizeof(texture_t *), "turbtex");
        for (texturenum = 0; texturenum < brushmodel->numtextures && turbcount; texturenum++) {
            texture = brushmodel->textures[texturenum];
            if (texture->mark) {
                glbrushmodel->turbtextures[glbrushmodel->numturbtextures++] = texture;
                texture->mark = 0;
                turbcount--;
            }
        }
    }

    /*
     * Build up the material chains across all models in preparation for storing vertex data.
     */
    uint32_t total_vertices_to_allocate = 0;
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next) {
        if (brushmodel->parent)
            continue;
        glbrushmodel = GLBrushModel(brushmodel);
        MaterialChains_Init(glbrushmodel->materialchains, glbrushmodel->materials, glbrushmodel->nummaterials);
        surf = brushmodel->surfaces;
        for (surfnum = 0; surfnum < brushmodel->numsurfaces; surfnum++, surf++) {
            MaterialChain_AddSurf(&glbrushmodel->materialchains[surf->material], surf);
            total_vertices_to_allocate += surf->numedges;
        }
    }

    /* Allocate vertex buffer space for each chain and fill out vertex info */
    int modelnum = 0;
    VBAlloc_Init(total_vertices_to_allocate, total_material_count);
    for (brushmodel = loaded_brushmodels; brushmodel; brushmodel = brushmodel->next, modelnum++) {
        if (brushmodel->parent)
            continue;
        glbrushmodel = GLBrushModel(brushmodel);
        surface_material_t *material = glbrushmodel->materials;
        for (int materialnum = 0; materialnum < glbrushmodel->nummaterials; materialnum++, material++) {
            materialchain_t *materialchain = &glbrushmodel->materialchains[materialnum];
            if (!materialchain->surf)
                continue;

            /* Allocate buffer space */
            material->numverts = materialchain->numverts;
            VBAlloc_GetSpace(material->numverts, &material->buffer_id, &material->offset);

            /* Copy buffer info for animation frames */
            texture_t *texture = brushmodel->textures[material->texturenum];
            if (texture->anim_total) {
                GL_CopyBufferInfoForAnimationFrames(glbrushmodel, materialnum);
            }

            vec7_t *buffer = gl_bmodel_vertex_buffers[material->buffer_id].vertices;
            vec7_t *dest = buffer + material->offset;
            for (surf = materialchain->surf; surf; surf = surf->chain) {
                /* Record the offset and create the vertex data */
                surf->buffer_offset = dest - buffer;
                AddSurfaceVertices(brushmodel, surf, dest);
                dest += surf->numedges;

                /* Fixup animated surface materials */
                texture_t *texture = surf->texinfo->texture;
                if (texture->anim_total && texture->texturenum != material->texturenum) {
                    surf->material = GL_FindAnimationMaterial(glbrushmodel, texture->texturenum, materialnum);
                    Debug_Printf("Fixing up surf material from %d (%s) -> %d (%s)\n",
                                 materialnum, brushmodel->textures[material->texturenum]->name,
                                 surf->material, brushmodel->textures[glbrushmodel->materials[surf->material].texturenum]->name);
                }
            }
        }
    }
    VBAlloc_Complete();
    GL_UploadBmodelVertexBuffers();

    Debug_Printf("Material vertex arrays, total allocation is %d bytes\n", vertex_buffers_total_allocation);
    Debug_Printf("Allocated %d buffers (%d bytes of wasted vertices)\n",
                 num_gl_bmodel_vertex_buffers, vertex_buffers_vertices_wasted * (int)sizeof(vec7_t));
}

void
GL_UploadBmodelVertexBuffers()
{
    if (!gl_buffer_objects_enabled)
        return;

    struct vertex_buffer_info *buffer = gl_bmodel_vertex_buffers;
    for (int i = 0; i < num_gl_bmodel_vertex_buffers; i++, buffer++) {
        qglGenBuffers(1, &buffer->vbo);
        qglBindBuffer(GL_ARRAY_BUFFER, buffer->vbo);
        qglBufferData(GL_ARRAY_BUFFER, buffer->numverts * sizeof(vec7_t), buffer->vertices, GL_STATIC_DRAW);
    }
    qglBindBuffer(GL_ARRAY_BUFFER, 0);
}

void
GL_FreeBmodelVertexBuffers()
{
    if (!gl_buffer_objects_enabled)
        return;

    struct vertex_buffer_info *buffer = gl_bmodel_vertex_buffers;
    for (int i = 0; i < num_gl_bmodel_vertex_buffers; i++, buffer++)
        qglDeleteBuffers(1, &buffer->vbo);

    num_gl_bmodel_vertex_buffers = 0;
}


static void
GL_BrushModelLoadLighting(brushmodel_t *brushmodel, dheader_t *header)
{
    const model_t *model = &brushmodel->model;
    const lump_t *headerlump = &header->lumps[LUMP_LIGHTING];
    litheader_t *litheader;
    size_t filesize;
    char litfilename[MAX_QPATH];
    byte *in, *out;

    /* Attempt to load a .lit file for colored lighting */
    int mark = Hunk_LowMark();
    COM_DefaultExtension(model->name, ".lit", litfilename, sizeof(litfilename));
    litheader = COM_LoadHunkFile(litfilename, &filesize);
    if (!litheader)
        goto fallback;
    if (filesize < sizeof(litheader_t) + headerlump->filelen * 3)
        goto fallback_corrupt;
    if (memcmp(litheader->identifier, "QLIT", 4))
        goto fallback_corrupt;

    litheader->version = LittleLong(litheader->version);
    if (litheader->version != 1) {
        Con_Printf("Unknown .lit file version (%d), ignoring\n", litheader->version);
        goto fallback;
    }

    /* Expand to RGBA format */
    Hunk_AllocExtend(litheader, sizeof(litheader_t) + headerlump->filelen * 4);
    out = (byte *)(litheader + 1);
    in = out + headerlump->filelen;
    memmove(in, out, headerlump->filelen * 3);
    for (int i = 0; i < headerlump->filelen; i++) {
        *out++ = *in++;
        *out++ = *in++;
        *out++ = *in++;
        *out++ = 255;
    }

    brushmodel->lightdata = (byte *)(litheader + 1);
    return;

 fallback_corrupt:
    Con_Printf("Corrupt .lit file, ignoring\n");
 fallback:
    Hunk_FreeToLowMark(mark);

    /* Fall back to plain lighting, if any */
    if (!headerlump->filelen) {
	brushmodel->lightdata = NULL;
        return;
    }

    /* Expand to RGBA format */
    brushmodel->lightdata = Mod_AllocName(headerlump->filelen * gl_lightmap_bytes, model->name);
    in = (byte *)header + headerlump->fileofs;
    out = brushmodel->lightdata;
    for (int i = 0; i < headerlump->filelen; i++, in++) {
        *out++ = *in;
        *out++ = *in;
        *out++ = *in;
        *out++ = 255;
    }
}

static brush_loader_t GL_BrushModelLoader = {
    .Padding = GL_BrushModelPadding,
    .LoadLighting = GL_BrushModelLoadLighting,
    .PostProcess = GL_BrushModelPostProcess,
    .lightmap_sample_bytes = gl_lightmap_bytes,
};

const brush_loader_t *
R_BrushModelLoader()
{
    return &GL_BrushModelLoader;
}
