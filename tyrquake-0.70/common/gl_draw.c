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

// draw.c -- this is the only file outside the refresh that touches the
// vid buffer

#include "buildinfo.h"
#include "console.h"
#include "draw.h"
#include "glquake.h"
#include "qpic.h"
#include "quakedef.h"
#include "sbar.h"
#include "screen.h"
#include "sys.h"
#include "view.h"
#include "wad.h"

#ifdef NQ_HACK
#include "host.h"
#endif
#ifdef QW_HACK
#include "vid.h"
#endif

static cvar_t gl_constretch = { "gl_constretch", "0", CVAR_CONFIG };

static wad_t host_gfx; /* gfx.wad */
const byte *draw_chars; /* 8*8 graphic characters */
const qpic8_t *draw_disc;
const qpic8_t *draw_backtile;

texture_id_t charset_texture;
static texture_id_t crosshair_texture;

static const byte crosshair_data[64] = {
    0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
};

static glpic_t *conback;

/*
=============================================================================

  scrap allocation

  Allocate all the little status bar obejcts into a single texture
  to crutch up stupid hardware / drivers

=============================================================================
*/

#define MAX_SCRAPS   2
#define SCRAP_WIDTH  256
#define SCRAP_HEIGHT 256
#define SCRAP_BYTES  (SCRAP_WIDTH * SCRAP_HEIGHT * 4)

typedef struct {
    texture_id_t texture;
    qboolean dirty;
    int allocated[SCRAP_WIDTH];
    qpic8_t pic;
    byte texels[SCRAP_BYTES]; /* referenced via pic->pixels */
} scrap_t;

static scrap_t gl_scraps[MAX_SCRAPS];

static void
Scrap_InitGLTextures()
{
    scrap_t *scrap = gl_scraps;
    for (int scrapnum = 0; scrapnum < MAX_SCRAPS; scrapnum++, scrap++) {
	scrap->pic.width = scrap->pic.stride = SCRAP_WIDTH;
	scrap->pic.height = SCRAP_HEIGHT;
	scrap->pic.pixels = scrap->texels;
        scrap->texture = GL_LoadTexture8(NULL, va("@conscrap_%02d", scrapnum), &scrap->pic, TEXTURE_TYPE_HUD);
    }
}

static void
Scrap_Init(void)
{
    memset(gl_scraps, 0, sizeof(gl_scraps));

    /* Init the whole block to the transparent color so we can pad with transparency */
    scrap_t *scrap = gl_scraps;
    for (int i = 0; i < MAX_SCRAPS; i++, scrap++) {
        memset(scrap->texels, 255, sizeof(scrap->texels));
    }
}

/*
 * Scrap_AllocBlock
 *   Returns a scrap and the position inside it
 */
static scrap_t *
Scrap_AllocBlock(int width, int height, int *x, int *y)
{
    int i, j;
    int best, best2;
    int scrapnum;
    scrap_t *scrap;

    /* Pad the allocation on all sides with by pixel */
    width += 2;
    height += 2;

    /*
     * I'm sure that x & y are always set when we return from this function,
     * but silence the compiler warning anyway. May as well crash with
     * these silly values if that happens.
     */
    *x = *y = 0x818181;

    scrap = gl_scraps;
    for (scrapnum = 0; scrapnum < MAX_SCRAPS; scrapnum++, scrap++) {
	best = SCRAP_HEIGHT;

	for (i = 0; i < SCRAP_WIDTH - width; i++) {
	    best2 = 0;

	    for (j = 0; j < width; j++) {
		if (scrap->allocated[i + j] >= best)
		    break;
		if (scrap->allocated[i + j] > best2)
		    best2 = scrap->allocated[i + j];
	    }
	    if (j == width) {
		/* this is a valid spot */
		*x = i;
		*y = best = best2;
	    }
	}

	if (best + height > SCRAP_HEIGHT)
	    continue;

	for (i = 0; i < width; i++)
	    scrap->allocated[*x + i] = best + height;

	if (*x == 0x818181 || *y == 0x818181)
	    Sys_Error("%s: block allocation problem", __func__);

	scrap->dirty = true;

        /* Remove pad bytes and return */
        *x += 1;
        *y += 1;
	return scrap;
    }

    Sys_Error("%s: full", __func__);
}

static void
Scrap_Alloc(glpic_t *subpic, const qpic8_t *pic)
{
    int x, y;

    scrap_t *scrap = Scrap_AllocBlock(pic->width, pic->height, &x, &y);
    int src = 0;
    for (int i = 0; i < pic->height; i++) {
        for (int j = 0; j < pic->width; j++, src++) {
            const int dst = (y + i) * SCRAP_WIDTH + x + j;
            scrap->texels[dst] = pic->pixels[src];
        }
    }

    /* Set the texture and internal texcoords */
    subpic->sl = (x + 0.01) / (float)SCRAP_WIDTH;
    subpic->sh = (x + pic->width - 0.01) / (float)SCRAP_WIDTH;
    subpic->tl = (y + 0.01) / (float)SCRAP_WIDTH;
    subpic->th = (y + pic->height - 0.01) / (float)SCRAP_WIDTH;

    subpic->is_scrap = true;
    subpic->scrapnum = scrap - gl_scraps;
}

static void
GLPic_Bind(const glpic_t *glpic)
{
    texture_id_t texture;

    if (glpic->is_scrap) {
        scrap_t *scrap = &gl_scraps[glpic->scrapnum];
        if (scrap->dirty) {
	    GL_Upload8(scrap->texture, &scrap->pic);
	    scrap->dirty = false;
	}
        texture = scrap->texture;
    } else {
        texture = glpic->texture;
    }

    GL_Bind(texture);
}

//=============================================================================
/* Support Routines */

typedef struct cachepic_s {
    char name[MAX_QPATH];
    glpic_t glpic;
} cachepic_t;

/*
 * There should be just 41 potential cachepics in the game.
 *
 *   find . -name '*.c' -exec grep 'Draw_CachePic([^c]' {} + \
 *       | sed -r 's/^.*(Draw_CachePic\([^)]+\)).*$/\1/' \
 *       | sort | uniq
 */
#define MAX_CACHED_PICS 64
static cachepic_t menu_cachepics[MAX_CACHED_PICS];
static int menu_numcachepics;

/* Save pointers to all loaded draw pics so we can re-upload them if gl context changes */
#define MAX_DRAW_GLPICS 32
#define MAX_DRAW_GLPIC_NAME 32
struct draw_glpic {
    char name[MAX_DRAW_GLPIC_NAME];
    glpic_t *glpic;
};
static struct draw_glpic draw_glpics[MAX_DRAW_GLPICS];
static int num_draw_glpics;

static model_t drawpic_owner = {
    .name = "drawpics",
};

void
Draw_ResetPicTextures()
{
    GL_DisownTextures(&drawpic_owner);
    num_draw_glpics = 0;

    draw_chars = NULL;
    conback = NULL;
    draw_disc = NULL;
    draw_backtile = NULL;
}

void
Draw_ReloadPicTextures()
{
    int i;
    struct draw_glpic *drawpic;

    for (i = 0; i < num_draw_glpics; i++) {
        drawpic = &draw_glpics[i];
        drawpic->glpic->texture = GL_LoadTexture8_GLPic(NULL, drawpic->name, drawpic->glpic);
    }
}

const qpic8_t *
Draw_PicFromWad(const char *name)
{
    qpic8_t *pic;
    dpic8_t *dpic;
    glpic_t *glpic;
    struct draw_glpic *drawpic;

    glpic = Hunk_AllocName(sizeof(*glpic), name);
    dpic = W_GetLumpName(&host_gfx, name);

    /* Set up the embedded pic */
    pic = &glpic->pic;
    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    /* load little ones into the scrap */
    if (pic->width < 64 && pic->height < 64) {
        Scrap_Alloc(glpic, pic);
	return pic;
    }

    /* Larger pics upload on their own.  Keep track for reloading. */
    if (num_draw_glpics == MAX_DRAW_GLPICS)
        Sys_Error("%s: Exceeded MAX_DRAW_GLPICS (%d)", __func__, MAX_DRAW_GLPICS);
    drawpic = &draw_glpics[num_draw_glpics++];
    qstrncpy(drawpic->name, name, sizeof(drawpic->name));
    drawpic->glpic = glpic;

    glpic->texture = GL_LoadTexture8_GLPic(NULL, name, glpic);

    return pic;
}

/*
================
Draw_CachePic
================
*/
const qpic8_t *
Draw_CachePic(const char *path)
{
    cachepic_t *cachepic;
    dpic8_t *dpic;
    qpic8_t *pic;
    int i, mark;

    cachepic = menu_cachepics;
    for (i = 0; i < menu_numcachepics; i++, cachepic++)
	if (!strcmp(path, cachepic->name))
	    return &cachepic->glpic.pic;

    if (menu_numcachepics == MAX_CACHED_PICS)
	Sys_Error("menu_numcachepics == MAX_CACHED_PICS");
    menu_numcachepics++;

    mark = Hunk_LowMark();

    /* load the pic from disk */
    qsnprintf(cachepic->name, sizeof(cachepic->name), "%s", path);
    dpic = COM_LoadHunkFile(path, NULL);
    if (!dpic)
	Sys_Error("%s: failed to load %s", __func__, path);
    SwapDPic(dpic);

    pic = &cachepic->glpic.pic;
    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    cachepic->glpic.texture = GL_LoadTexture8_GLPic(&drawpic_owner, path, &cachepic->glpic);

    Hunk_FreeToLowMark(mark);

    return pic;
}

#define CHAR_WIDTH  8
#define CHAR_HEIGHT 8

static void
Draw_ScaledCharToConback(const qpic8_t *conback, int num, byte *dest)
{
    const byte *source, *src;
    int row, col;
    int drawlines, drawwidth;
    int x, y, fstep, f;

    drawlines = conback->height * CHAR_HEIGHT / 200;
    drawwidth = conback->width * CHAR_WIDTH / 320;

    num |= 0x80; // Use alt text

    row = num >> 4;
    col = num & 15;
    source = draw_chars + (row << 10) + (col << 3);
    fstep = (320 << 16) / conback->width;

    for (y = 0; y < drawlines; y++, dest += conback->width) {
	src = source + (y * CHAR_HEIGHT / drawlines) * 128;
	f = 0;
	for (x = 0; x < drawwidth; x++, f += fstep) {
	    if (src[f >> 16] != 255)
		dest[x] = src[f >> 16];
	}
    }
}

/*
 * Draw_ConbackString
 *
 * This function draws a string to a very specific location on the console
 * background. The position is such that for a 320x200 background, the text
 * will be 6 pixels from the bottom and 11 pixels from the right. For other
 * sizes, the positioning is scaled so as to make it appear the same size and
 * at the same location.
 */
static void
Draw_ConbackString(const qpic8_t *conback, byte *pixels, const char *str)
{
    int len, row, col, i, x;
    byte *dest;

    len = strlen(str);
    row = conback->height - ((CHAR_HEIGHT + 6) * conback->height / 200);
    col = conback->width - ((11 + CHAR_WIDTH * len) * conback->width / 320);

    dest = pixels + conback->width * row + col;
    for (i = 0; i < len; i++) {
	x = i * CHAR_WIDTH * conback->width / 320;
	Draw_ScaledCharToConback(conback, str[i], dest + x);
    }
}

void
Draw_RegisterVariables()
{
    Cvar_RegisterVariable(&gl_constretch);
}

/*
===============
Draw_Init
===============
*/
void
Draw_Init(void)
{
    dpic8_t *dpic;
    qpic8_t *pic;
    char version[5];

    GL_Textures_Init();

    /* Load the graphics wad onto the hunk */
    W_LoadWadFile(&host_gfx, "gfx.wad");

    /*
     * Load the console background and the charset by hand, because we
     * need to write the version string into the background before
     * turning it into a texture.
     */
    draw_chars = W_GetLumpName(&host_gfx, "conchars");

    conback = Hunk_AllocName(sizeof(*conback), "conback");
    dpic = COM_LoadHunkFile("gfx/conback.lmp", NULL);
    if (!dpic)
	Sys_Error("Couldn't load gfx/conback.lmp");
    SwapDPic(dpic);

    pic = &conback->pic;
    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    /* hack the version number directly into the pic */
    qsnprintf(version, sizeof(version), "%s", build_version);
    Draw_ConbackString(pic, dpic->data, version);

    Scrap_Init();
    Draw_InitGLTextures();

    /* get the other pics we need */
    draw_disc = Draw_PicFromWad("disc");
    draw_backtile = Draw_PicFromWad("backtile");
}

void
Draw_InitGLTextures()
{
    if (!draw_chars)
        return; // Gamedir changed

    /* Upload the charset and crosshair textures */
    qpic8_t charset_pic = { 128, 128, 128, draw_chars };
    charset_texture = GL_LoadTexture8(&drawpic_owner, "charset", &charset_pic, TEXTURE_TYPE_CHARSET);
    qpic8_t crosshair_pic = { 8, 8, 8, crosshair_data };
    crosshair_texture = GL_LoadTexture8(&drawpic_owner, "crosshair", &crosshair_pic, TEXTURE_TYPE_HUD);

    /* Upload the console background texture */
    conback->texture = GL_LoadTexture8_GLPic(&drawpic_owner, "conback", conback);

    /* create textures for scraps */
    Scrap_InitGLTextures();

    /* Reset the menu cachepics */
    menu_numcachepics = 0;

    /* Init the particle texture */
    R_InitParticleTexture();

    GL_LoadNoTexture();
    GL_CreateWarpTableTexture();
}

struct drawrect {
    float x;
    float y;
    float w;
    float h;
};

static inline struct drawrect
Draw_GetScaledRect(int x, int y, int w, int h)
{
    struct drawrect rect = {
        .x = SCR_Scale(x),
        .y = SCR_Scale(y),
        .w = SCR_Scale(w),
        .h = SCR_Scale(h),
    };

    return rect;
}

/*
================
Draw_Character

Draws one 8*8 graphics character with 0 being transparent.
It can be clipped to the top of the screen to allow the console to be
smoothly scrolled off.
================
*/
void
Draw_CharacterAlpha(int x, int y, byte num, float alpha)
{
    int row, col;
    float frow, fcol, size;
    struct drawrect rect;

    rect = Draw_GetScaledRect(x, y, 8, 8);

    if (num == 32)
	return;
    if (rect.y <= -rect.h)
	return;

    row = num >> 4;
    col = num & 15;

    frow = row * 0.0625f;
    fcol = col * 0.0625f;
    size = 0.0625f;

    if (alpha < 1.0f) {
        glDisable(GL_ALPHA_TEST);
        glEnable(GL_BLEND);
    }
    glColor4f(1, 1, 1, alpha);

    GL_Bind(charset_texture);
    glBegin(GL_QUADS);
    glTexCoord2f(fcol, frow);
    glVertex2f(rect.x, rect.y);
    glTexCoord2f(fcol + size, frow);
    glVertex2f(rect.x + rect.w, rect.y);
    glTexCoord2f(fcol + size, frow + size);
    glVertex2f(rect.x + rect.w, rect.y + rect.h);
    glTexCoord2f(fcol, frow + size);
    glVertex2f(rect.x, rect.y + rect.h);
    glEnd();

    if (alpha < 1.0f) {
        glDisable(GL_BLEND);
        glEnable(GL_ALPHA_TEST);
        glColor4f(1, 1, 1, 1);
    }
}

void
Draw_Character(int x, int y, byte num)
{
    Draw_CharacterAlpha(x, y, num, 1.0f);
}

/*
================
Draw_String
================
*/
void
Draw_StringAlpha(int x, int y, const char *str, float alpha)
{
    while (*str) {
	Draw_CharacterAlpha(x, y, *str, alpha);
	str++;
	x += 8;
    }
}

void
Draw_String(int x, int y, const char *str)
{
    Draw_StringAlpha(x, y, str, 1.0f);
}

/*
================
Draw_Alt_String
================
*/
void
Draw_Alt_StringAlpha(int x, int y, const char *str, float alpha)
{
    while (*str) {
	Draw_CharacterAlpha(x, y, (*str) | 0x80, alpha);
	str++;
	x += 8;
    }
}

void
Draw_Alt_String(int x, int y, const char *str)
{
    Draw_Alt_StringAlpha(x, y, str, 1.0f);
}

void
Draw_Crosshair(void)
{
    if (!crosshair.value)
        return;

    if (crosshair.value == 2.0f) {
        /* Since width/height is probably a multiple of two, there is no 'center' pixel */
	float x = scr_vrect.x + scr_vrect.width / 2 + cl_crossx.value;
	float y = scr_vrect.y + scr_vrect.height / 2 + cl_crossy.value;
	byte *rgba = (byte *)&qpal_alpha.colors[(byte)crosshaircolor.value].rgba;

	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glColor4ubv(rgba);
	GL_Bind(crosshair_texture);

        int stretch_offset = SCR_Scale(3.5f);
        int stretch_size = stretch_offset * 2 + 1;
        float stretch_texcoord = stretch_size / 8.0f;

	glBegin(GL_QUADS);

        /* Draw vertical crosshair mark */
	glTexCoord2f(0, 0);
	glVertex2f(x - 3, y - stretch_offset);
	glTexCoord2f(0.875f, 0);
	glVertex2f(x + 4, y - stretch_offset);
	glTexCoord2f(0.875f, stretch_texcoord);
	glVertex2f(x + 4, y + stretch_offset + 1);
	glTexCoord2f(0, stretch_texcoord);
	glVertex2f(x - 3, y + stretch_offset + 1);

        /* Draw horizontal crosshair mark (mirror tex coords on diagonal) */
	glTexCoord2f(0, 0);
	glVertex2f(x - stretch_offset, y - 3);
	glTexCoord2f(0, stretch_texcoord);
	glVertex2f(x + stretch_offset + 1, y - 3);
	glTexCoord2f(0.875f, stretch_texcoord);
	glVertex2f(x + stretch_offset + 1, y + 4);
	glTexCoord2f(0.875f, 0);
	glVertex2f(x - stretch_offset, y + 4);

	glEnd();

	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

        return;
    }

    /* Adjust the coordinates for hud scaling */
    int x = SCR_ScaleCoord(scr_vrect.x + scr_vrect.width / 2);
    int y = SCR_ScaleCoord(scr_vrect.y + scr_vrect.height / 2);

    x += (int)cl_crossx.value - SCR_Scale(4);
    y += (int)cl_crossy.value - SCR_Scale(4);

    Draw_Character(x, y, '+');
}

/*
=============
Draw_Pic
=============
*/
void
Draw_PicAlpha(int x, int y, const qpic8_t *pic, float alpha)
{
    struct drawrect rect = Draw_GetScaledRect(x, y, pic->width, pic->height);
    const glpic_t *glpic;

    glpic = const_container_of(pic, glpic_t, pic);

    if (alpha < 1.0f) {
        glDisable(GL_ALPHA_TEST);
        glEnable(GL_BLEND);
    }
    glColor4f(1, 1, 1, alpha);

    GLPic_Bind(glpic);
    glBegin(GL_QUADS);
    glTexCoord2f(glpic->sl, glpic->tl);
    glVertex2f(rect.x, rect.y);
    glTexCoord2f(glpic->sh, glpic->tl);
    glVertex2f(rect.x + rect.w, rect.y);
    glTexCoord2f(glpic->sh, glpic->th);
    glVertex2f(rect.x + rect.w, rect.y + rect.h);
    glTexCoord2f(glpic->sl, glpic->th);
    glVertex2f(rect.x, rect.y + rect.h);
    glEnd();

    if (alpha < 1.0f) {
        glDisable(GL_BLEND);
        glEnable(GL_ALPHA_TEST);
        glColor4f(1, 1, 1, 1);
    }
}

void
Draw_Pic(int x, int y, const qpic8_t *pic)
{
    Draw_PicAlpha(x, y, pic, 1.0f);
}

void
Draw_SubPicAlpha(int x, int y, const qpic8_t *pic, int srcx, int srcy, int width, int height, float alpha)
{
    struct drawrect rect = Draw_GetScaledRect(x, y, width, height);
    const glpic_t *glpic;
    float newsl, newtl, newsh, newth;
    float oldglwidth, oldglheight;

    glpic = const_container_of(pic, glpic_t, pic);

    oldglwidth = glpic->sh - glpic->sl;
    oldglheight = glpic->th - glpic->tl;

    newsl = glpic->sl + (srcx * oldglwidth) / pic->width;
    newsh = newsl + (width * oldglwidth) / pic->width;

    newtl = glpic->tl + (srcy * oldglheight) / pic->height;
    newth = newtl + (height * oldglheight) / pic->height;

    if (alpha < 1.0f) {
        glDisable(GL_ALPHA_TEST);
        glEnable(GL_BLEND);
    }
    glColor4f(1, 1, 1, alpha);

    GLPic_Bind(glpic);
    glBegin(GL_QUADS);
    glTexCoord2f(newsl, newtl);
    glVertex2f(rect.x, rect.y);
    glTexCoord2f(newsh, newtl);
    glVertex2f(rect.x + rect.w, rect.y);
    glTexCoord2f(newsh, newth);
    glVertex2f(rect.x + rect.w, rect.y + rect.h);
    glTexCoord2f(newsl, newth);
    glVertex2f(rect.x, rect.y + rect.h);
    glEnd();

    if (alpha < 1.0f) {
        glDisable(GL_BLEND);
        glEnable(GL_ALPHA_TEST);
        glColor4f(1, 1, 1, 1);
    }
}

void
Draw_SubPic(int x, int y, const qpic8_t *pic, int srcx, int srcy, int width, int height)
{
    Draw_SubPicAlpha(x, y, pic, srcx, srcy, width, height, 1.0f);
}
/*
=============
Draw_TransPic
=============
*/
void
Draw_TransPic(int x, int y, const qpic8_t *pic, byte transparent_color)
{
    Draw_Pic(x, y, pic);
}

void
Draw_TransPicAlpha(int x, int y, const qpic8_t *pic, byte transparent_color, float alpha)
{
    Draw_PicAlpha(x, y, pic, alpha);
}


static const qpic8_t *
Draw_GetMenuplayerPic()
{
    static qpic8_t pic;
    static cache_user_t menuplyr_cache;

    dpic8_t *dpic = Cache_Check(&menuplyr_cache);
    if (!dpic) {
        COM_LoadCacheFile("gfx/menuplyr.lmp", &menuplyr_cache);
        dpic = menuplyr_cache.data;
        SwapDPic(dpic);
    }
    pic.width = pic.stride = dpic->width;
    pic.height = dpic->height;
    pic.pixels = dpic->data;

    return &pic;
}

/*
=============
Draw_TransPicTranslate

Only used for the player color selection menu
=============
*/
void
Draw_TransPicTranslate(int x, int y, const qpic8_t *pic, const byte *translation)
{
    static texture_id_t translate_texture;

    struct drawrect rect = Draw_GetScaledRect(x, y, pic->width, pic->height);
    const byte *src;
    byte *dest, *buffer;
    int i, buffersize, mark;
    qpic8_t translated;
    const qpic8_t *menupic;

    menupic = Draw_GetMenuplayerPic();
    mark = Hunk_LowMark();

    buffersize = menupic->width * menupic->height;
    buffer = Hunk_AllocName(buffersize, "menuplyr");

    dest = buffer;
    src = menupic->pixels;
    for (i = 0; i < buffersize; i++) {
        *dest++ = translation[*src++];
    }

    translated.width = menupic->width;
    translated.height = menupic->height;
    translated.stride = menupic->stride;
    translated.pixels = buffer;

    if (!TextureIsValid(translate_texture)) {
        translate_texture = GL_AllocTexture8(NULL, "@menuplyr_translate", pic, TEXTURE_TYPE_HUD);
    }
    GL_Upload8(translate_texture, &translated);

    Hunk_FreeToLowMark(mark);

    glColor3f(1, 1, 1);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0);
    glVertex2f(rect.x, rect.y);
    glTexCoord2f(1, 0);
    glVertex2f(rect.x + rect.w, rect.y);
    glTexCoord2f(1, 1);
    glVertex2f(rect.x + rect.w, rect.y + rect.h);
    glTexCoord2f(0, 1);
    glVertex2f(rect.x, rect.y + rect.h);
    glEnd();
}


/*
================
Draw_ConsoleBackground

================
*/
static void
Draw_ConsolePic(int lines, float offset, const glpic_t *glpic, float alpha)
{
    glDisable(GL_ALPHA_TEST);
    glEnable(GL_BLEND);
    glColor4f(1, 1, 1, alpha);
    GLPic_Bind(glpic);

    glBegin (GL_QUADS);
    glTexCoord2f (glpic->sl, offset * glpic->th);
    glVertex2f (0, 0);
    glTexCoord2f (glpic->sh, offset * glpic->th);
    glVertex2f (vid.conwidth, 0);
    glTexCoord2f (glpic->sh, glpic->th);
    glVertex2f (vid.conwidth, lines);
    glTexCoord2f (glpic->sl, glpic->th);
    glVertex2f (0, lines);
    glEnd();

    glColor4f(1, 1, 1, 1);
    glEnable(GL_ALPHA_TEST);
    glDisable(GL_BLEND);
}

void
Draw_ConsoleBackground(int lines)
{
    int y;
    float offset, alpha;

    y = (vid.height * 3) >> 2;

    if (gl_constretch.value)
	offset = 0.0f;
    else
	offset = (vid.conheight - lines) / (float)vid.conheight;

    if (lines > y)
	alpha = 1.0f;
    else
	alpha = (float) 1.1 * lines / y;

    Draw_ConsolePic(lines, offset, conback, alpha);

#ifdef QW_HACK
    {
	if (!cls.download) {
	    const char *version = va("TyrQuake (%s) QuakeWorld", build_version);
            int x = scr_scaled_width - SCR_Scale(strlen(version) * 8 + 11);
            y = SCR_ScaleCoord(lines - 14);
	    Draw_Alt_String(x, y, version);
	}
    }
#endif
}


/*
=============
Draw_TileClear

This repeats a 64*64 tile graphic to fill the screen around a sized down
refresh window.
=============
*/
void
Draw_TileClear(int x, int y, int w, int h)
{
    const glpic_t *glpic = const_container_of(draw_backtile, glpic_t, pic);

    glColor3f(1, 1, 1);
    GLPic_Bind(glpic);
    glBegin(GL_QUADS);
    glTexCoord2f(x / 64.0, y / 64.0);
    glVertex2f(x, y);
    glTexCoord2f((x + w) / 64.0, y / 64.0);
    glVertex2f(x + w, y);
    glTexCoord2f((x + w) / 64.0, (y + h) / 64.0);
    glVertex2f(x + w, y + h);
    glTexCoord2f(x / 64.0, (y + h) / 64.0);
    glVertex2f(x, y + h);
    glEnd();
}

void
Draw_TileClearScaled(int x, int y, int w, int h)
{
    struct drawrect rect = Draw_GetScaledRect(x, y, w, h);
    Draw_TileClear(rect.x, rect.y, rect.w, rect.h);
}


/*
=============
Draw_Fill

Fills a box of pixels with a single color
=============
*/
void
Draw_FillAlpha(int x, int y, int w, int h, int c, float alpha)
{
    struct drawrect rect = Draw_GetScaledRect(x, y, w, h);

    if (alpha < 1.0f) {
        glDisable(GL_ALPHA_TEST);
        glEnable(GL_BLEND);
    }
    glDisable(GL_TEXTURE_2D);
    glColor4f(host_basepal[c * 3] / 255.0f, host_basepal[c * 3 + 1] / 255.0f, host_basepal[c * 3 + 2] / 255.0f, alpha);

    glBegin(GL_QUADS);

    glVertex2f(rect.x, rect.y);
    glVertex2f(rect.x + rect.w, rect.y);
    glVertex2f(rect.x + rect.w, rect.y + rect.h);
    glVertex2f(rect.x, rect.y + rect.h);

    glEnd();

    if (alpha < 1.0f) {
        glDisable(GL_BLEND);
        glEnable(GL_ALPHA_TEST);
    }
    glColor3f(1, 1, 1);
    glEnable(GL_TEXTURE_2D);
}

void
Draw_Fill(int x, int y, int w, int h, int c)
{
    Draw_FillAlpha(x, y, w, h, c, 1.0f);
}
//=============================================================================

/*
================
Draw_FadeScreen

================
*/
void
Draw_FadeScreen(void)
{
    glEnable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);
    glColor4f(0, 0, 0, 0.8);
    glBegin(GL_QUADS);

    glVertex2f(0, 0);
    glVertex2f(vid.width, 0);
    glVertex2f(vid.width, vid.height);
    glVertex2f(0, vid.height);

    glEnd();
    glColor4f(1, 1, 1, 1);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);

    Sbar_Changed();
}

//=============================================================================

/*
================
Draw_BeginDisc

Draws the little blue disc in the corner of the screen.
Call before beginning any disc IO.
================
*/
void
Draw_BeginDisc(void)
{
    if (!draw_disc || scr_block_drawing)
	return;
    glDrawBuffer(GL_FRONT);
    Draw_Pic(vid.width - 24, 0, draw_disc);
    glDrawBuffer(GL_BACK);
}


/*
================
Draw_EndDisc

Erases the disc icon.
Call after completing any disc IO
================
*/
void
Draw_EndDisc(void)
{
}

/*
================
GL_Set2D

Setup as if the screen was 320*200
================
*/
void
GL_Set2D(void)
{
    glViewport(glx, gly, glwidth, glheight);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, vid.width, vid.height, 0, -99999, 99999);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    glEnable(GL_ALPHA_TEST);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    glColor4f(1, 1, 1, 1);
}
