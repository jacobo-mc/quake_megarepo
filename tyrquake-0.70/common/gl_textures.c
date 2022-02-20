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

#include "cmd.h"
#include "console.h"
#include "crc.h"
#include "cvar.h"
#include "list.h"
#include "glquake.h"
#include "qpic.h"
#include "sys.h"

#ifdef NQ_HACK
#include "host.h"
#endif
#ifdef QW_HACK
#include "client.h"
#endif

// FIXME - should I let this get larger, with view to enhancements?
static cvar_t gl_max_size = { "gl_max_size", "1024" };

static cvar_t gl_playermip = { "gl_playermip", "0" };
static cvar_t gl_nobind = { "gl_nobind", "0" };
static cvar_t gl_npot = { "gl_npot", "1" };
static cvar_t gl_meminfo = { "gl_meminfo", "0" };

cvar_t gl_picmip = { "gl_picmip", "0" };

typedef struct {
    struct list_node list;
    const model_t *owner;
    GLuint texnum;
    int width, height, max_miplevel;
    int last_used_frame;
    float compression_ratio;
    enum texture_type type;
    unsigned short crc;		// CRC for texture cache matching
    char name[MAX_QPATH];
} gltexture_t;

#define DEFAULT_MAX_TEXTURES 2048
static cvar_t gl_max_textures = {
    .name = "gl_max_textures",
    .string = stringify(DEFAULT_MAX_TEXTURES),
    .flags = CVAR_VIDEO,
};

struct {
    struct list_node free;
    struct list_node active;
    struct list_node inactive;
    gltexture_t *textures;
    int num_textures;
    int hunk_highmark;
} manager = {
    .free = LIST_HEAD_INIT(manager.free),
    .active = LIST_HEAD_INIT(manager.active),
    .inactive = LIST_HEAD_INIT(manager.inactive),
};

static inline texture_id_t
TextureToId(const gltexture_t *texture)
{
    /* Array position plus one, so that zero is not a valid id */
    return (texture_id_t){texture - manager.textures + 1};
}

static inline gltexture_t *
IdToTexture(texture_id_t texture_id)
{
    assert(texture_id.id);
    return &manager.textures[texture_id.id - 1];
}

static void
GL_InitTextureManager()
{
    if (manager.textures) {
        Hunk_FreeToHighMark(manager.hunk_highmark);
        manager.textures = NULL;
    }

    manager.num_textures = qmax((int)gl_max_textures.value, 512);
    manager.hunk_highmark = Hunk_HighMark();
    manager.textures = Hunk_HighAllocName(manager.num_textures * sizeof(gltexture_t), "texmgr");

    list_head_init(&manager.free);
    list_head_init(&manager.active);
    list_head_init(&manager.inactive);

    /* Add all textures to the free list */
    for (int i = 0; i < manager.num_textures; i++)
        list_add_tail(&manager.textures[i].list, &manager.free);
}

/*
 * =================
 *    Multitexture
 * =================
 */

lpActiveTextureFUNC qglActiveTextureARB;
lpClientStateFUNC qglClientActiveTexture;

/* For now, we only ever need 3 textures at once */
#define MAX_TMU 3
static GLuint tmu_texture[MAX_TMU];
static int current_tmu;

/*
 * Make the specified texture unit current
 */
void
GL_SelectTMU(GLenum target)
{
    if (!gl_mtexable)
        return;
    if (target - GL_TEXTURE0 == current_tmu)
	return;

    assert(target >= GL_TEXTURE0 && target < GL_TEXTURE0 + MAX_TMU);
    assert(target - GL_TEXTURE0 < gl_num_texture_units);

    qglActiveTextureARB(target);
    current_tmu = target - GL_TEXTURE0;
}

/*
 * TODO: replace this enable/disable interface with something that
 * more directly specifies state.  Currently the 3rd TMU is just
 * manually managed on top of this...
 */
static qboolean mtexenabled = false;

void
GL_DisableMultitexture(void)
{
    if (mtexenabled) {
	glDisable(GL_TEXTURE_2D);
	GL_SelectTMU(GL_TEXTURE0);
	mtexenabled = false;
        current_tmu = 0;
    }
}

void
GL_EnableMultitexture(void)
{
    if (gl_mtexable) {
	GL_SelectTMU(GL_TEXTURE1);
	glEnable(GL_TEXTURE_2D);
	mtexenabled = true;
        current_tmu = 1;
    }
}

void
GL_Bind(texture_id_t texture_id)
{
    gltexture_t *texture = IdToTexture(gl_nobind.value ? charset_texture : texture_id);

    /* For scene/frame texture usage stats */
    texture->last_used_frame = r_framecount;

    if (tmu_texture[current_tmu] == texture->texnum)
	return;
    tmu_texture[current_tmu] = texture->texnum;

    glBindTexture(GL_TEXTURE_2D, texture->texnum);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, texture->max_miplevel);
}

void
GL_FreeTextures()
{
    gltexture_t *texture;

    list_for_each_entry(texture, &manager.active, list)
        glDeleteTextures(1, &texture->texnum);
    list_for_each_entry(texture, &manager.inactive, list)
        glDeleteTextures(1, &texture->texnum);

    for (int i = 0; i < MAX_TMU; i++)
        tmu_texture[i] = 0;
    current_tmu = 0;

    GL_InitTextureManager();
}

static GLint
GL_GetTextureFormat(const gltexture_t *texture)
{
    if (texture->type == TEXTURE_TYPE_LIGHTMAP) {
        return gl_lightmap_format;
    } else if (texture->type == TEXTURE_TYPE_DATA) {
        return GL_RGBA;
    } else if (texture_properties[texture->type].palette->alpha) {
        if (gl_texture_compression_enabled) {
            switch (texture->type) {
                case TEXTURE_TYPE_WORLD_FULLBRIGHT:
                case TEXTURE_TYPE_FENCE:
                case TEXTURE_TYPE_FENCE_FULLBRIGHT:
                case TEXTURE_TYPE_SKY_FOREGROUND:
                case TEXTURE_TYPE_ALIAS_SKIN_FULLBRIGHT:
                case TEXTURE_TYPE_SPRITE:
                    return GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
                default:
                    break;
            }
        }
        return gl_alpha_format;
    } else if (gl_texture_compression_enabled) {
        switch (texture->type) {
            case TEXTURE_TYPE_WORLD:
            case TEXTURE_TYPE_TURB:
            case TEXTURE_TYPE_SKY_BACKGROUND:
            case TEXTURE_TYPE_SKYBOX:
            case TEXTURE_TYPE_ALIAS_SKIN:
                return GL_COMPRESSED_RGB_S3TC_DXT1_EXT;
            default:
                break;
        }
    }

    return gl_solid_format;
}

static int
GL_GetMipMemorySize(int width, int height, GLint format)
{
    int blocksize = 1;
    int blockbytes = 4;
    switch (format) {
        case GL_COMPRESSED_RGB_S3TC_DXT1_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT1_EXT:
            blocksize = 4;
            blockbytes = 8;
            break;
        case GL_COMPRESSED_RGBA_S3TC_DXT3_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT5_EXT:
            blocksize = 4;
            blockbytes = 16;
            break;
    }

    int blockwidth  = (width  + blocksize - 1) / blocksize;
    int blockheight = (height + blocksize - 1) / blocksize;

    return blockwidth * blockheight * blockbytes;
}

static int
GL_GetTextureMemorySize(const gltexture_t *texture)
{
    GLint format = GL_GetTextureFormat(texture);
    int width = texture->width;
    int height = texture->height;
    int memsize = 0;
    for (int miplevel = 0; miplevel < texture->max_miplevel; miplevel++) {
        memsize += GL_GetMipMemorySize(width, height, format);
        width  = (width > 1)  ? width  >> 1 : 1;
        height = (height > 1) ? height >> 1 : 1;
    }

    return memsize;
}

void
GL_FrameMemoryStats()
{
    if (!gl_meminfo.value)
        return;

    int numtextures = 0;
    int numbytes = 0;

    gltexture_t *texture;
    list_for_each_entry(texture, &manager.active, list) {
        if (texture->last_used_frame == r_framecount) {
            numtextures++;
            numbytes += GL_GetTextureMemorySize(texture);
        }
    }

    Con_Printf("Mem usage: %6.1fMB from %4d textures\n", numbytes / 1024.0f / 1024.0f, numtextures);
}

typedef struct {
    const char *name;
    GLenum min_filter;
    GLenum mag_filter;
} glmode_t;

static glmode_t *gl_texturemode_current;

static glmode_t gl_texturemodes[] = {
    { "gl_nearest", GL_NEAREST, GL_NEAREST },
    { "gl_linear", GL_LINEAR, GL_LINEAR },
    { "gl_nearest_mipmap_nearest", GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST },
    { "gl_linear_mipmap_nearest", GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR },
    { "gl_nearest_mipmap_linear", GL_NEAREST_MIPMAP_LINEAR, GL_NEAREST },
    { "gl_linear_mipmap_linear", GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR }
};

static void GL_Texture_Anisotropy_f(cvar_t *cvar);
static cvar_t gl_texture_anisotropy = { "gl_texture_anisotropy", "1", CVAR_CONFIG, .callback = GL_Texture_Anisotropy_f };

static void
GL_SetTextureMode(const gltexture_t *texture)
{
    if (texture->type == TEXTURE_TYPE_LIGHTMAP)
        return; /* Lightmap filter is always GL_LINEAR */

    GL_Bind(TextureToId(texture));
    if (texture->type == TEXTURE_TYPE_NOTEXTURE) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    } else if (texture->type == TEXTURE_TYPE_DATA) {
        /* For warp vertex program we want to interpolate these values when sampling */
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    } else if (texture_properties[texture->type].mipmap) {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_texturemode_current->min_filter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_texturemode_current->mag_filter);
        if (gl_anisotropy_enabled) {
            float anisotropy = qclamp(gl_texture_anisotropy.value, 1.0f, gl_anisotropy_max);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, anisotropy);
        }
    } else {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, gl_texturemode_current->mag_filter);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, gl_texturemode_current->mag_filter);
    }
}

static void
GL_Texture_Anisotropy_f(cvar_t *cvar)
{
    if (gl_anisotropy_enabled && cvar->value > gl_anisotropy_max) {
        Con_Printf("Warning: anisotropy setting of %f will be capped to driver maximum of %f\n",
                   cvar->value, gl_anisotropy_max);
    }

    gltexture_t *texture;
    list_for_each_entry(texture, &manager.active, list)
        GL_SetTextureMode(texture);
}

/*
===============
Draw_TextureMode_f
===============
*/
static void
GL_TextureMode_f(void)
{
    int i;
    gltexture_t *texture;

    if (Cmd_Argc() == 1) {
	Con_Printf("%s\n", gl_texturemode_current->name);
	return;
    }

    for (i = 0; i < ARRAY_SIZE(gl_texturemodes); i++) {
	if (!strcasecmp(gl_texturemodes[i].name, Cmd_Argv(1))) {
	    gl_texturemode_current = &gl_texturemodes[i];
	    break;
	}
    }
    if (i == ARRAY_SIZE(gl_texturemodes)) {
	Con_Printf("bad filter name\n");
	return;
    }

    /* Change all the existing mipmap texture objects */
    list_for_each_entry(texture, &manager.active, list)
        GL_SetTextureMode(texture);
}

static void
GL_TextureMode_Arg_f(struct stree_root *root, int argnum)
{
    int i, arg_len;

    if (argnum != 1)
        return;

    const char *arg = Cmd_Argv(1);
    arg_len = arg ? strlen(arg) : 0;
    for (i = 0; i < ARRAY_SIZE(gl_texturemodes); i++) {
        if (!arg || !strncasecmp(gl_texturemodes[i].name, arg, arg_len))
            STree_InsertAlloc(root, gl_texturemodes[i].name, false);
    }
}

static int
GL_GetMaxMipLevel(qpic32_t *pic, GLint internal_format)
{
    int blocksize = 1;
    switch (internal_format) {
        case GL_COMPRESSED_RGB_S3TC_DXT1_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT1_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT3_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT5_EXT:
            blocksize = 4;
    }

    int max_level = 0;
    int width = pic->width;
    int height = pic->height;
    while (width > blocksize || height > blocksize) {
        max_level++;
	width  = width  > 1 ? width  >> 1 : 1;
	height = height > 1 ? height >> 1 : 1;
    }

    return max_level;
}

/*
 * Some textures we handle padding them to different sizes to satisfy
 * power-of-two or encoding block size requirements.  This is a bit
 * kludgy and should probably just be a texture property.  Perhaps
 * even the 'repeat' property, once that is all handled consistently.
 */
static qboolean
GL_CanPadTexture(const gltexture_t *texture)
{
    switch (texture->type) {
        case TEXTURE_TYPE_HUD:
        case TEXTURE_TYPE_ALIAS_SKIN:
        case TEXTURE_TYPE_ALIAS_SKIN_FULLBRIGHT:
        case TEXTURE_TYPE_PLAYER_SKIN:
        case TEXTURE_TYPE_PLAYER_SKIN_FULLBRIGHT:
            return true;
        default:
            return false;
    }
}

static void QPic_CompressDxt1(const qpic32_t *pic, byte *dst);
static void QPic_CompressDxt5(const qpic32_t *pic, byte *dst);

static void
GL_CompressMip(const qpic32_t *pic, GLint format, byte *dst)
{
    switch (format) {
        case GL_COMPRESSED_RGB_S3TC_DXT1_EXT:
            QPic_CompressDxt1(pic, dst);
            break;
        case GL_COMPRESSED_RGBA_S3TC_DXT5_EXT:
            QPic_CompressDxt5(pic, dst);
            break;
        default:
            assert(!"Unsupported compressed format");
    }
}

/*
 * Uploads a 32-bit RGBA texture.  The original pixels are destroyed during
 * the scaling/mipmap process.  When done, the width and height the source pic
 * are set to the values used to upload the (miplevel 0) texture.
 *
 * This matters in the case of non-power-of-two HUD or skin textures
 * getting expanded, since the texture coordinates need to be adjusted
 * accordingly when drawing.
 */
void
GL_Upload32(texture_id_t texture_id, qpic32_t *pic)
{
    GLint internal_format;
    qpic32_t *scaled;
    int width, height, mark, picmip;
    gltexture_t *texture = IdToTexture(texture_id);
    const texture_properties_t *properties = &texture_properties[texture->type];

    /* This is not written for lightmaps! */
    assert(texture->type != TEXTURE_TYPE_LIGHTMAP);

    if (!gl_npotable || !gl_npot.value) {
	/* find the next power-of-two size up */
	width = 1;
	while (width < pic->width)
	    width <<= 1;
	height = 1;
	while (height < pic->height)
	    height <<= 1;
    } else if (gl_texture_compression_enabled && GL_CanPadTexture(texture)) {
        /* Expand texture to block size */
        width = (pic->width + 3) & ~3;
        height = (pic->height + 3) & ~3;
        if (width != pic->width || height != pic->height) {
            Sys_Printf("Padded texture '%s' (%d x %d) -> (%d x %d)\n", texture->name, pic->width, pic->height, width, height);
        }
    } else {
	width = pic->width;
	height = pic->height;
    }

    mark = Hunk_LowMark();

    /* Begin by expanding the texture if needed */
    if (width != pic->width || height != pic->height) {
	scaled = QPic32_Alloc(width, height);
        if (GL_CanPadTexture(texture)) {
            QPic32_Expand(pic, scaled);
        } else {
            QPic32_Stretch(pic, scaled);
        }
    } else {
	scaled = pic;
    }

    /* Allow some textures to be crunched down by player preference */
    if (properties->playermip) {
        picmip = qmax(0, (int)gl_playermip.value);
    } else if (properties->picmip) {
        picmip = qmax(0, (int)gl_picmip.value);
    } else {
        picmip = 0;
    }
    while (picmip) {
	if (width == 1 && height == 1)
	    break;
	width = qmax(1, width >> 1);
	height = qmax(1, height >> 1);
	QPic32_MipMap(scaled, properties->alpha_op);
	picmip--;
    }

    /* Upload with or without mipmaps, depending on type */
    GL_Bind(texture_id);
    internal_format = GL_GetTextureFormat(texture);
    byte *compressed = NULL;
    int mip_memory_size = GL_GetMipMemorySize(scaled->width, scaled->height, internal_format);
    switch (internal_format) {
        case GL_COMPRESSED_RGB_S3TC_DXT1_EXT:
        case GL_COMPRESSED_RGBA_S3TC_DXT5_EXT:
            compressed = alloca(mip_memory_size);
            break;
    }
    if (properties->mipmap) {
        int max_miplevel = GL_GetMaxMipLevel(scaled, internal_format);
        int miplevel = 0;
        while (1) {
            if (compressed) {
                GL_CompressMip(scaled, internal_format, compressed);
                qglCompressedTexImage2D(GL_TEXTURE_2D, miplevel, internal_format,
                                        scaled->width, scaled->height, 0,
                                        mip_memory_size, compressed);
            } else {
                glTexImage2D(GL_TEXTURE_2D, miplevel, internal_format,
                             scaled->width, scaled->height, 0,
                             GL_RGBA, GL_UNSIGNED_BYTE, scaled->pixels);
            }
            if (miplevel == max_miplevel)
                break;
            QPic32_MipMap(scaled, properties->alpha_op);
            mip_memory_size = GL_GetMipMemorySize(scaled->width, scaled->height, internal_format);
            miplevel++;
        }
        GL_SetTextureMode(texture);
	texture->max_miplevel = max_miplevel;
    } else {
        if (compressed) {
            GL_CompressMip(scaled, internal_format, compressed);
            qglCompressedTexImage2D(GL_TEXTURE_2D, 0, internal_format,
                                    scaled->width, scaled->height, 0,
                                    mip_memory_size, compressed);
        } else {
            glTexImage2D(GL_TEXTURE_2D, 0, internal_format,
                         scaled->width, scaled->height, 0,
                         GL_RGBA, GL_UNSIGNED_BYTE, scaled->pixels);
        }
        GL_SetTextureMode(texture);
	texture->max_miplevel = 0;
    }

    /* Set texture wrap mode */
    GLenum wrap = properties->repeat ? GL_REPEAT : GL_CLAMP_TO_EDGE;
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap);

    Hunk_FreeToLowMark(mark);

    /* Pass back the width and height used on the scaled texture that was uploaded */
    pic->width = width;
    pic->height = height;
}

/**
 * Special rules for determining the required size for the warp target
 * texture (warp texture is assumed to be square).
 *
 * Must be less or equal to the backbuffer size since we need to
 * render into that first then copy the pixels out.  If npot textures
 * are not supported, make sure we select the next *smaller* power of
 * two here to avoid the generic upload function from stretching it
 * up.
 */
static int
GL_GetWarpImageSize(qpic8_t *pic)
{
    int size = qmin(pic->width * 4, WARP_RENDER_TEXTURE_SIZE);

    if (!gl_npotable || !gl_npot.value) {
        int original_size = size;
        size = 1;
        while (size < original_size)
            size <<= 1;
        while (size > vid.width || size > vid.height)
            size >>= 1;
    } else {
        size = qmin(size, vid.width);
        size = qmin(size, vid.height);
    }

    return size;
}

/*
===============
GL_Upload8

Sets the actual uploaded width/height in the original pic, which matters for skin
textures that get expanded up to the nearest power-of-two size.

The alpha version will scale the texture alpha channel by a factor of (alpha / 255).
===============
*/
void
GL_Upload8_Alpha(texture_id_t texture_id, qpic8_t *pic, byte alpha)
{
    gltexture_t *texture = IdToTexture(texture_id);
    const qpalette32_t *palette = texture_properties[texture->type].palette;
    enum qpic_alpha_operation alpha_op = texture_properties[texture->type].alpha_op;
    qpic32_t *pic32;
    int mark;

    mark = Hunk_LowMark();

    if (texture->type == TEXTURE_TYPE_WARP_TARGET) {
        int size = GL_GetWarpImageSize(pic);
        pic32 = QPic32_Alloc(size, size);
    } else {
        pic32 = QPic32_Alloc(pic->width, pic->height);
        QPic_8to32(pic, pic32, palette, alpha_op);
        if (alpha != 255)
            QPic32_ScaleAlpha(pic32, alpha);
    }
    GL_Upload32(texture_id, pic32);

    pic->width = pic32->width;
    pic->height = pic32->height;

    Hunk_FreeToLowMark(mark);
}

void
GL_Upload8(texture_id_t texture, qpic8_t *pic)
{
    GL_Upload8_Alpha(texture, pic, 255);
}

void
GL_Upload8_Translate(texture_id_t texture, qpic8_t *pic, const byte *translation)
{
    const byte *source;
    byte *pixels, *dest;
    qpic8_t translated_pic;
    int mark, i, j;

    mark = Hunk_LowMark();

    source = pic->pixels;
    pixels = dest = Hunk_AllocName(pic->width * pic->height, "transpic");
    for (i = 0; i < pic->height; i++) {
        for (j = 0; j < pic->width; j++) {
            *dest++ = translation[*source++];
        }
        source += pic->stride - pic->width;
    }

    translated_pic.width = pic->width;
    translated_pic.height = pic->height;
    translated_pic.stride = pic->width;
    translated_pic.pixels = pixels;

    GL_Upload8(texture, &translated_pic);

    Hunk_FreeToLowMark(mark);
}

static void
GL_Upload8_GLPic(texture_id_t texture_id, glpic_t *glpic)
{
    assert(IdToTexture(texture_id)->type == TEXTURE_TYPE_HUD);

    const qpalette32_t *palette = texture_properties[TEXTURE_TYPE_HUD].palette;
    enum qpic_alpha_operation alpha_op = texture_properties[TEXTURE_TYPE_HUD].alpha_op;
    qpic32_t *pic32;
    int mark;

    mark = Hunk_LowMark();

    pic32 = QPic32_Alloc(glpic->pic.width, glpic->pic.height);
    QPic_8to32(&glpic->pic, pic32, palette, alpha_op);
    GL_Upload32(texture_id, pic32);

    glpic->sl = 0;
    glpic->sh = qmin(1.0f, (float)glpic->pic.width / (float)pic32->width);
    glpic->tl = 0;
    glpic->th = qmin(1.0f, (float)glpic->pic.height / (float)pic32->height);

    Hunk_FreeToLowMark(mark);
}

/*
================
GL_AllocTexture

Return an existing texture reference if we already have one for this
name (and the CRC matches).  Otherwise allocate and configure a new
one.
================
*/
struct alloc_texture_result {
    qboolean exists;
    texture_id_t texture;
};

static struct alloc_texture_result
GL_AllocTexture(const model_t *owner, const char *name, unsigned short crc, int width, int height, enum texture_type type)
{
    struct alloc_texture_result result = {0};
    gltexture_t *texture;

    /* Check the active list for a match */
    list_for_each_entry(texture, &manager.active, list) {
        if (owner != texture->owner)
            continue;
        if (!strcmp(name, texture->name)) {
            if (type != texture->type || (crc != texture->crc && type < TEXTURE_TYPE_LIGHTMAP))
                goto GL_AllocTexture_setup;
            if (width != texture->width || height != texture->height)
                goto GL_AllocTexture_setup;

            result.exists = true;
            goto GL_AllocTexture_out;
        }
    }

    /* Check the inactive list for a match, these are unowned */
    list_for_each_entry(texture, &manager.inactive, list) {
        if (!strcmp(name, texture->name)) {
            if (type != texture->type || (crc != texture->crc && type < TEXTURE_TYPE_LIGHTMAP))
                goto GL_AllocTexture_setup;
            if (width != texture->width || height != texture->height)
                goto GL_AllocTexture_setup;

            /* Update texture mode, move it back to the active list and return */
            GL_SetTextureMode(texture);
            list_del(&texture->list);
            list_add(&texture->list, &manager.active);
            result.exists = true;
            goto GL_AllocTexture_out;
        }
    }

    if (!list_empty(&manager.free)) {
        /* Grab a texture from the free list */
        texture = container_of(manager.free.next, gltexture_t, list);
        list_del(&texture->list);
    } else if (!list_empty(&manager.inactive)) {
        /* Repurpose the least recently used inactive texture (from the list tail) */
        texture = container_of(manager.inactive.prev, gltexture_t, list);
        list_del(&texture->list);
    } else {
        // TODO: use NOTEXTURE instead?
	Sys_Error("numgltextures == MAX_GLTEXTURES");
    }

    qstrncpy(texture->name, name, sizeof(texture->name));
    glGenTextures(1, &texture->texnum);

    list_add(&texture->list, &manager.active);

 GL_AllocTexture_setup:
    texture->crc = crc;
    texture->width = width;
    texture->height = height;
    texture->type = type;
    texture->compression_ratio = 1.0f;

 GL_AllocTexture_out:
    texture->owner = owner;
    result.texture = TextureToId(texture); // plus 1, so zero is not a valid texture

    return result;
}

static struct alloc_texture_result
GL_AllocTexture8_Result(const model_t *owner, const char *name, const qpic8_t *pic, enum texture_type type)
{
    unsigned short crc = CRC_Block(pic->pixels, pic->width * pic->height * sizeof(pic->pixels[0]));
    return GL_AllocTexture(owner, name, crc, pic->width, pic->height, type);
}

texture_id_t
GL_AllocTexture8(const model_t *owner, const char *name, const qpic8_t *pic, enum texture_type type)
{
    return GL_AllocTexture8_Result(owner, name, pic, type).texture;
}

static struct alloc_texture_result
GL_AllocTexture32_Result(const model_t *owner, const char *name, const qpic32_t *pic, enum texture_type type)
{
    unsigned short crc = CRC_Block(pic->pixels, pic->width * pic->height * sizeof(pic->pixels[0]));
    return GL_AllocTexture(owner, name, crc, pic->width, pic->height, type);
}

texture_id_t
GL_AllocTexture32(const model_t *owner, const char *name, const qpic32_t *pic, enum texture_type type)
{
    return GL_AllocTexture32_Result(owner, name, pic, type).texture;
}

texture_id_t
GL_LoadTexture8_Alpha(const model_t *owner, const char *name, qpic8_t *pic, enum texture_type type, byte alpha)
{
    struct alloc_texture_result result = GL_AllocTexture8_Result(owner, name, pic, type);

    if (!isDedicated) {
        if (!result.exists) {
            GL_Upload8_Alpha(result.texture, pic, alpha);
        } else if (type == TEXTURE_TYPE_WARP_TARGET) {
            /*
             * TODO: Kind of a temporary fix for the terrible interface to handle textures that end
             * up a different size after upload due to picmip, npot stretching and all that.  When
             * fixing that, fix this too!
             *
             * Probably should decide the desired upload size for the input pic in advance and then
             * check the cache for those factors matching as well as the input image size (or at
             * least CRC).
             */
            pic->width = pic->height = GL_GetWarpImageSize(pic);
        }
    }

    return result.texture;
}

texture_id_t
GL_LoadTexture8(const model_t *owner, const char *name, qpic8_t *pic, enum texture_type type)
{
    return GL_LoadTexture8_Alpha(owner, name, pic, type, 255);
}

texture_id_t
GL_LoadTexture8_GLPic(const model_t *owner, const char *name, glpic_t *glpic)
{
    struct alloc_texture_result result = GL_AllocTexture8_Result(owner, name, &glpic->pic, TEXTURE_TYPE_HUD);

    if (!isDedicated && !result.exists) {
	GL_Upload8_GLPic(result.texture, glpic);
    }

    return result.texture;
}

void
GL_DisownTextures(const model_t *owner)
{
    gltexture_t *texture, *next;

    /*
     * Disowned textures are added to the head of the list, so more
     * recently discarded ones are quicker to find.  We then harvest
     * from the tail if we need a new texture so the least recently
     * used ones will be purged.
     */
    list_for_each_entry_safe(texture, next, &manager.active, list) {
        if (texture->owner == owner) {
            list_del(&texture->list);
            list_add(&texture->list, &manager.inactive);
        }
    }
}

static void
GL_AddTexturesToTree(struct stree_root *root, struct list_node *list_head)
{
    gltexture_t *texture;

    /*
     * The same texture name with a different owner could be loaded
     * more than once, so if the insert fails (due to non-uniqueness)
     * add an increasing counter to the string until we can
     * successfully insert.  There are typically very few name
     * clashes, but they do occur.
     */
    *root = STREE_ROOT;
    list_for_each_entry(texture, list_head, list) {
        qboolean result = STree_InsertAlloc(root, texture->name, false);
        if (!result) {
            int counter = 1;
            while (!result) {
                result = STree_InsertAlloc(root, va("%s(%d)", texture->name, counter++), true);
            }
        }
    }
}

static void
GL_PrintTextures_f(void)
{
    struct stree_root root;
    gltexture_t *texture;
    qboolean print_active = true;
    qboolean print_inactive = false;
    qboolean print_free = false;

    if (Cmd_Argc() > 1) {
        if (!strcasecmp(Cmd_Argv(1), "active")) {
            print_active = true;
        } else if (!strcasecmp(Cmd_Argv(1), "inactive")) {
            print_active = false;
            print_inactive = true;
        } else if (!strcasecmp(Cmd_Argv(1), "free")) {
            print_active = false;
            print_free = true;
        } else if (!strcasecmp(Cmd_Argv(1), "all")) {
            print_active = true;
            print_inactive = true;
            print_free = true;
        } else {
            Con_Printf("Usage: %s [active|inactive|free|all]\n", Cmd_Argv(0));
            return;
        }
    }

    STree_AllocInit();

    if (print_active) {
        GL_AddTexturesToTree(&root, &manager.active);
        Con_ShowTree(&root);
        Con_Printf("======== %d active textures ========\n", root.entries);
    }
    if (print_inactive) {
        GL_AddTexturesToTree(&root, &manager.inactive);
        Con_ShowTree(&root);
        Con_Printf("======== %d inactive textures in cache ========\n", root.entries);
    }
    if (print_free) {
        int count = 0;
        list_for_each_entry(texture, &manager.free, list)
            count++;
        Con_Printf("======== %d free textures slots ========\n", count);
    }

    Con_Printf("NO OWNER:\n");
    list_for_each_entry(texture, &manager.active, list) {
        if (texture->owner)
            continue;
        Con_Printf("%s\n", texture->name);
    }
}

static void
GL_PrintTextures_Arg_f(struct stree_root *root, int argnum)
{
    if (argnum != 1)
        return;

    const char *arg = Cmd_Argv(1);
    const char *args[] = { "active", "inactive", "free", "all" };
    int i;
    int arg_len = arg ? strlen(arg) : 0;

    for (i = 0; i < ARRAY_SIZE(args); i++) {
        if (!arg || !strncasecmp(args[i], arg, arg_len))
            STree_InsertAlloc(root, args[i], false);
    }
}

void
GL_Textures_RegisterVariables()
{
    Cvar_RegisterVariable(&gl_nobind);
    Cvar_RegisterVariable(&gl_max_size);
    Cvar_RegisterVariable(&gl_meminfo);
    Cvar_RegisterVariable(&gl_picmip);
    Cvar_RegisterVariable(&gl_playermip);
    Cvar_RegisterVariable(&gl_max_textures);
    Cvar_RegisterVariable(&gl_npot);
    Cvar_RegisterVariable(&gl_texture_anisotropy);
}

void
GL_Textures_AddCommands()
{
    Cmd_AddCommand("gl_texturemode", GL_TextureMode_f);
    Cmd_SetCompletion("gl_texturemode", GL_TextureMode_Arg_f);
    Cmd_AddCommand("gl_printtextures", GL_PrintTextures_f);
    Cmd_SetCompletion("gl_printtextures", GL_PrintTextures_Arg_f);
}

void
GL_Textures_Init(void)
{
    GLint max_size;

    gl_texturemode_current = gl_texturemodes;

    // FIXME - could do better to check on each texture upload with
    //         GL_PROXY_TEXTURE_2D
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &max_size);
    if (gl_max_size.value > max_size) {
	Con_DPrintf("Reducing gl_max_size from %d to %d\n",
		    (int)gl_max_size.value, max_size);
	Cvar_Set("gl_max_size", va("%d", max_size));
    }

    GL_InitTextureManager();
}


#define STB_DXT_IMPLEMENTATION
#include "stb_dxt.h"

static void
DXT_ExtractColorBlock(qpixel32_t dst[16], const qpic32_t *pic, int x, int y)
{
    assert(x % 4 == 0);
    assert(y % 4 == 0);

    const qpixel32_t *src = pic->pixels + y * pic->width + x;
    if (pic->height - y >= 4 && pic->width - x >= 4) {
        /* Fast path for a full block */
        memcpy(dst +  0, src + pic->width * 0, 16);
        memcpy(dst +  4, src + pic->width * 1, 16);
        memcpy(dst +  8, src + pic->width * 2, 16);
        memcpy(dst + 12, src + pic->width * 3, 16);
    } else {
        /* Partial block, pad with black */
        const qpixel32_t black = { .c.red = 0, .c.green = 0, .c.blue = 0, .c.alpha = 1 };
        const int width  = qmin(pic->width  - x, 4);
        const int height = qmin(pic->height - y, 4);
        int y = 0;
        for ( ; y < height; y++) {
            int x = 0;
            for ( ; x < width; x++)
                dst[y * 4 + x] = src[y * pic->width + x];
            for ( ; x < 4; x++)
                dst[y * 4 + x] = black;
        }
        for ( ; y < 4; y++) {
            for (int x = 0; x < 4; x++)
                dst[y * 4 + x] = black;
        }
    }
}

static void
QPic_CompressDxt1(const qpic32_t *pic, byte *dst)
{
    qpixel32_t colorblock[16];
    const int width = pic->width;
    const int height = pic->height;

    for (int y = 0; y < height; y += 4) {
        for (int x = 0; x < width; x += 4) {
            DXT_ExtractColorBlock(colorblock, pic, x, y);
            stb_compress_dxt_block(dst, (byte *)colorblock, false, STB_DXT_HIGHQUAL);
            dst += 8;
        }
    }
}

static void
QPic_CompressDxt5(const qpic32_t *pic, byte *dst)
{
    qpixel32_t colorblock[16];
    const int width = pic->width;
    const int height = pic->height;

    for (int y = 0; y < height; y += 4) {
        for (int x = 0; x < width; x += 4) {
            DXT_ExtractColorBlock(colorblock, pic, x, y);
            stb_compress_dxt_block(dst, (byte *)colorblock, true, STB_DXT_HIGHQUAL);
            dst += 16;
        }
    }
}
