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

#include <stdint.h>

#include "buildinfo.h"
#include "common.h"
#include "console.h"
#include "d_iface.h"
#include "draw.h"
#include "qpic.h"
#include "quakedef.h"
#include "sys.h"
#include "vid.h"
#include "view.h"
#include "screen.h"
#include "wad.h"
#include "zone.h"

#ifdef NQ_HACK
#include "host.h"
#include "sound.h"
#endif
#ifdef QW_HACK
#include "bothdefs.h"
#include "client.h"
#endif

typedef struct {
    vrect_t rect;
    int width;
    int height;
    const byte *ptexbytes;
    int rowbytes;
} rectdesc_t;

static rectdesc_t r_rectdesc;

static wad_t host_gfx; /* gfx.wad */
const byte *draw_chars; /* 8*8 graphic characters */
const qpic8_t *draw_disc;

const qpic8_t *draw_backtile;

#define CHAR_WIDTH	8
#define CHAR_HEIGHT	8

//=============================================================================
/* Support Routines */

typedef struct cachepic_s {
    char name[MAX_QPATH];
    qpic8_t pic;
    cache_user_t cache;
} cachepic_t;

/*
 * There should be just 41 potential cachepics in the game.
 *
 *   find . -name '*.c' -exec grep 'Draw_CachePic([^c]' {} + \
 *       | sed -r 's/^.*(Draw_CachePic\([^)]+\)).*$/\1/' \
 *       | sort | uniq
 */
#define	MAX_CACHED_PICS 64
static cachepic_t menu_cachepics[MAX_CACHED_PICS];
static int menu_numcachepics;

const qpic8_t *
Draw_PicFromWad(const char *name)
{
    qpic8_t *pic;
    dpic8_t *dpic;

    dpic = W_GetLumpName(&host_gfx, name);
    pic = Hunk_AllocName(sizeof(*pic), "qpic8_t");
    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    return pic;
}

static void
Draw_ClearCache()
{
    int i;
    cachepic_t *cachepic;

    cachepic = menu_cachepics;
    for (i = 0; i < menu_numcachepics; i++, cachepic++)
        if (cachepic->cache.data)
            Cache_Free(&cachepic->cache);
    menu_numcachepics = 0;
}

/*
================
Draw_FindCache
================
*/
static cachepic_t *
Draw_FindCache(const char *path)
{
    cachepic_t *cachepic;
    int i;

    cachepic = menu_cachepics;
    for (i = 0; i < menu_numcachepics; i++, cachepic++)
	if (!strcmp(path, cachepic->name))
	    break;

    if (i == menu_numcachepics) {
	if (menu_numcachepics == MAX_CACHED_PICS)
	    Sys_Error("menu_numcachepics == MAX_CACHED_PICS");
	menu_numcachepics++;
	qsnprintf(cachepic->name, sizeof(cachepic->name), "%s", path);
    }

    Cache_Check(&cachepic->cache);

    return cachepic;
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
    qpic8_t *pic;
    dpic8_t *dpic;

    cachepic = Draw_FindCache(path);
    pic = &cachepic->pic;
    dpic = cachepic->cache.data;
    if (dpic) {
	/* Update pixel pointer in case of cache moves */
	pic->pixels = dpic->data;
	return pic;
    }

    /* load the pic from disk */
    COM_LoadCacheFile(path, &cachepic->cache);
    dpic = cachepic->cache.data;
    if (!dpic)
	Sys_Error("%s: failed to load %s", __func__, path);
    SwapDPic(dpic);

    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    return pic;
}

/*
================
Draw_CacheConback
================
*/
static void Draw_ConbackString(const qpic8_t *conback, byte *pixels,
			       const char *str);

const qpic8_t *
Draw_CacheConback(void)
{
    const char conbackfile[] = "gfx/conback.lmp";
    cachepic_t *cachepic;
    dpic8_t *dpic;
    qpic8_t *pic;
    char version[5];

    cachepic = Draw_FindCache(conbackfile);
    pic = &cachepic->pic;
    dpic = cachepic->cache.data;
    if (dpic) {
	/* Update pixel pointer in case of cache moves */
	pic->pixels = dpic->data;
	return pic;
    }

    /* load the pic from disk */
    COM_LoadCacheFile(conbackfile, &cachepic->cache);
    dpic = cachepic->cache.data;
    if (!dpic)
	Sys_Error("%s: failed to load %s", __func__, conbackfile);
    SwapDPic(dpic);

    pic->width = pic->stride = dpic->width;
    pic->height = dpic->height;
    pic->pixels = dpic->data;

    /* hack the version number directly into the pic */
    qsnprintf(version, sizeof(version), "%s", build_version);
    Draw_ConbackString(pic, dpic->data, version);

    return pic;
}

void
Draw_RegisterVariables()
{
}

/*
===============
Draw_Init
===============
*/
void
Draw_Init(void)
{
    static qpic8_t draw_disc_pic;
    static qpic8_t draw_backtile_pic;
    dpic8_t *dpic;

    Draw_ClearCache();

    /* Load the graphics wad onto the hunk */
    W_LoadWadFile(&host_gfx, "gfx.wad");

    draw_chars = W_GetLumpName(&host_gfx, "conchars");

    dpic = W_GetLumpName(&host_gfx, "disc");
    draw_disc_pic.width = draw_disc_pic.stride = dpic->width;
    draw_disc_pic.height = dpic->height;
    draw_disc_pic.pixels = dpic->data;
    draw_disc = &draw_disc_pic;

    dpic = W_GetLumpName(&host_gfx, "backtile");
    draw_backtile_pic.width = draw_backtile_pic.stride = dpic->width;
    draw_backtile_pic.height = dpic->height;
    draw_backtile_pic.pixels = dpic->data;
    draw_backtile = &draw_backtile_pic;

    r_rectdesc.width = draw_backtile->width;
    r_rectdesc.height = draw_backtile->height;
    r_rectdesc.ptexbytes = draw_backtile->pixels;
    r_rectdesc.rowbytes = draw_backtile->stride;
}

static void
Draw_Pixel(int x, int y, byte color)
{
    byte *dest;
    uint16_t *pusdest;

    if (r_pixbytes == 1) {
	dest = vid.conbuffer + y * vid.conrowbytes + x;
	*dest = color;
    } else {
	pusdest = (uint16_t *)
	    ((byte *)vid.conbuffer + y * vid.conrowbytes + (x << 1));
	*pusdest = d_8to16table[color];
    }
}

void
Draw_Crosshair(void)
{
    int x, y;
    byte c = (byte)crosshaircolor.value;

    if (crosshair.value == 2) {
        /*
         * Drawn directly into the video buffer, so no scaling of coordinates.
         * However, We will scale up the size a bit to match hud scale
         */
        int size = SCR_Scale(4);
        int i;
	x = scr_vrect.x + scr_vrect.width / 2 + cl_crossx.value;
	y = scr_vrect.y + scr_vrect.height / 2 + cl_crossy.value;
        for (i = 1; i < size; i += 2) {
            Draw_Pixel(x - i, y, c);
            Draw_Pixel(x + i, y, c);
            Draw_Pixel(x, y - i, c);
            Draw_Pixel(x, y + i, c);
        }
    } else if (crosshair.value) {
        x = scr_vrect.x + scr_vrect.width / 2;
        y = scr_vrect.y + scr_vrect.height / 2;

        /* Adjust char coordinates for hud scaling */
        if (scr_scale != 1.0f) {
            x = SCR_ScaleCoord(x);
            y = SCR_ScaleCoord(y);
        }

        x += (int)cl_crossx.value - SCR_Scale(4);
        y += (int)cl_crossy.value - SCR_Scale(4);
	Draw_Character(x, y, '+');
    }
}

static void
Draw_ScaledPic(int x, int y, const qpic8_t *pic)
{
    assert(pic->stride);

    /* Calculate the destination pixels */
    int dst_x_start = SCR_Scale(x);
    int dst_y_start = SCR_Scale(y);
    int dst_x_end = SCR_Scale(x + pic->width);
    int dst_y_end = SCR_Scale(y + pic->height);
    int dst_width = dst_x_end - dst_x_start;
    int dst_height = dst_y_end - dst_y_start;

    /* Clip to the output buffer size */
    dst_x_end = qmin(dst_x_end, vid.conwidth);
    dst_y_end = qmin(dst_y_end, vid.conheight);

    /* Fractional source step, 16-bits of precision */
    const int fstep = pic->width * 0x10000 / dst_width;
    for (int dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
        byte *dst = vid.buffer + dst_y * vid.rowbytes;
        int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
        const byte *src = pic->pixels + src_row * pic->stride;
        for (int dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
            dst[dst_x] = src[f >> 16];
        }
    }
}

static void
Draw_ScaledPicAlpha(int x, int y, const qpic8_t *pic, float alpha)
{
    assert(pic->stride);

    if (!alpha)
        return;
    const byte *transtable = Alpha_Transtable(alpha);
    if (!transtable) {
        Draw_ScaledPic(x, y, pic);
        return;
    }

    /* Calculate the destination pixels */
    int dst_x_start = SCR_Scale(x);
    int dst_y_start = SCR_Scale(y);
    int dst_x_end = SCR_Scale(x + pic->width);
    int dst_y_end = SCR_Scale(y + pic->height);
    int dst_width = dst_x_end - dst_x_start;
    int dst_height = dst_y_end - dst_y_start;

    /* Clip to the output buffer size */
    dst_x_end = qmin(dst_x_end, vid.conwidth);
    dst_y_end = qmin(dst_y_end, vid.conheight);

    /* Fractional source step, 16-bits of precision */
    const int fstep = pic->width * 0x10000 / dst_width;
    for (int dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
        byte *dst = vid.buffer + dst_y * vid.rowbytes;
        int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
        const byte *src = pic->pixels + src_row * pic->stride;
        for (int dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
            dst[dst_x] = transtable[(((int)dst[dst_x]) << 8) + src[f >> 16]];
        }
    }
}

static void
Draw_ScaledTransPic(int x, int y, const qpic8_t *pic, byte transparent_color)
{
    assert(pic->stride);

    /* Calculate the destination pixels */
    int dst_x_start = SCR_Scale(x);
    int dst_y_start = SCR_Scale(y);
    int dst_x_end = SCR_Scale(x + pic->width);
    int dst_y_end = SCR_Scale(y + pic->height);
    int dst_width = dst_x_end - dst_x_start;
    int dst_height = dst_y_end - dst_y_start;

    /* Clip to the output buffer size */
    dst_x_end = qmin(dst_x_end, vid.conwidth);
    dst_y_end = qmin(dst_y_end, vid.conheight);

    /* Fractional source step, 16-bits of precision */
    const int fstep = pic->width * 0x10000 / dst_width;
    for (int dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
        byte *dst = vid.buffer + dst_y * vid.rowbytes;
        int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
        const byte *src = pic->pixels + src_row * pic->stride;
        for (int dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
            if (src[f >> 16] != transparent_color)
                dst[dst_x] = src[f >> 16];
        }
    }
}

static void
Draw_ScaledTransPicAlpha(int x, int y, const qpic8_t *pic, byte transparent_color, float alpha)
{
    assert(pic->stride);

    if (!alpha)
        return;
    const byte *transtable = Alpha_Transtable(alpha);
    if (!transtable) {
        Draw_ScaledTransPic(x, y, pic, transparent_color);
        return;
    }

    /* Calculate the destination pixels */
    int dst_x_start = SCR_Scale(x);
    int dst_y_start = SCR_Scale(y);
    int dst_x_end = SCR_Scale(x + pic->width);
    int dst_y_end = SCR_Scale(y + pic->height);
    int dst_width = dst_x_end - dst_x_start;
    int dst_height = dst_y_end - dst_y_start;

    /* Clip to the output buffer size */
    dst_x_end = qmin(dst_x_end, vid.conwidth);
    dst_y_end = qmin(dst_y_end, vid.conheight);

    /* Fractional source step, 16-bits of precision */
    const int fstep = pic->width * 0x10000 / dst_width;
    for (int dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
        byte *dst = vid.buffer + dst_y * vid.rowbytes;
        int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
        const byte *src = pic->pixels + src_row * pic->stride;
        for (int dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
            if (src[f >> 16] != transparent_color)
                dst[dst_x] = transtable[(((int)dst[dst_x]) << 8) + src[f >> 16]];
        }
    }
}

/*
=============
Draw_Pic
=============
*/
void
Draw_Pic(int x, int y, const qpic8_t *pic)
{
    assert(r_pixbytes == 1); // TODO: 16-bit back buffer isn't supported, just remove r_pixbytes.

    if (scr_scale != 1.0f) {
        Draw_ScaledPic(x, y, pic);
        return;
    }

    assert(x >= 0 && x + pic->width <= vid.width);
    assert(y >= 0 && y + pic->height <= vid.height);

    const byte *source = pic->pixels;
    byte *dest = vid.buffer + y * vid.rowbytes + x;
    for (int v = 0; v < pic->height; v++) {
        memcpy(dest, source, pic->width);
        dest += vid.rowbytes;
        source += pic->stride;
    }
}

/*
=============
Draw_PicAlpha
=============
*/
void
Draw_PicAlpha(int x, int y, const qpic8_t *pic, float alpha)
{
    assert(r_pixbytes == 1); // TODO: 16-bit back buffer isn't supported, just remove r_pixbytes.

    if (scr_scale != 1.0f) {
        Draw_ScaledPicAlpha(x, y, pic, alpha);
        return;
    }

    if (!alpha)
        return;
    const byte *transtable = Alpha_Transtable(alpha);
    if (!transtable) {
        Draw_Pic(x, y, pic);
        return;
    }

    assert(x >= 0 && x + pic->width <= vid.width);
    assert(y >= 0 && y + pic->height <= vid.height);

    const byte *source = pic->pixels;
    byte *dest = vid.buffer + y * vid.rowbytes + x;
    for (int v = 0; v < pic->height; v++) {
        for (int u = 0; u < pic->width; u++) {
            dest[u] = transtable[(((int)dest[u]) << 8) + source[u]];
        }
        dest += vid.rowbytes;
        source += pic->stride;
    }
}

/*
=============
Draw_SubPic
=============
*/
void
Draw_SubPic(int x, int y, const qpic8_t *pic, int srcx, int srcy, int width, int height)
{
    qpic8_t subpic = {
        .width = width,
        .height = height,
        .stride = pic->width,
        .pixels = pic->pixels + srcy * pic->stride + srcx,
    };

    Draw_Pic(x, y, &subpic);
}

void
Draw_SubPicAlpha(int x, int y, const qpic8_t *pic, int srcx, int srcy, int width, int height, float alpha)
{
    qpic8_t subpic = {
        .width = width,
        .height = height,
        .stride = pic->width,
        .pixels = pic->pixels + srcy * pic->stride + srcx,
    };

    Draw_PicAlpha(x, y, &subpic, alpha);
}

/*
=============
Draw_TransPic
=============
*/
void
Draw_TransPic(int x, int y, const qpic8_t *pic, byte transparent_color)
{
    assert(r_pixbytes == 1); // TODO: 16-bit back buffer isn't supported, just remove r_pixbytes.

    if (scr_scale != 1.0f) {
        Draw_ScaledTransPic(x, y, pic, transparent_color);
        return;
    }

    assert(x >= 0 && x + pic->width <= vid.width);
    assert(y >= 0 && y + pic->height <= vid.height);

    const byte *source = pic->pixels;
    byte *dest = vid.buffer + y * vid.rowbytes + x;
    for (int v = 0; v < pic->height; v++) {
        for (int u = 0; u < pic->width; u++) {
            if (source[u] != transparent_color)
                dest[u] = source[u];
        }
        dest += vid.rowbytes;
        source += pic->width;
    }
}


/*
==================
Draw_TransPicAlpha
==================
*/
void
Draw_TransPicAlpha(int x, int y, const qpic8_t *pic, byte transparent_color, float alpha)
{
    assert(r_pixbytes == 1); // TODO: 16-bit back buffer isn't supported, just remove r_pixbytes.

    if (scr_scale != 1.0f) {
        Draw_ScaledTransPicAlpha(x, y, pic, transparent_color, alpha);
        return;
    }

    if (!alpha)
        return;
    const byte *transtable = Alpha_Transtable(alpha);
    if (!transtable) {
        Draw_TransPic(x, y, pic, transparent_color);
        return;
    }

    assert(x >= 0 && x + pic->width <= vid.width);
    assert(y >= 0 && y + pic->height <= vid.height);

    const byte *source = pic->pixels;
    byte *dest = vid.buffer + y * vid.rowbytes + x;
    for (int v = 0; v < pic->height; v++) {
        for (int u = 0; u < pic->width; u++) {
            if (source[u] != transparent_color)
                dest[u] = transtable[(((int)dest[u]) << 8) + source[u]];
        }
        dest += vid.rowbytes;
        source += pic->width;
    }
}


/*
=============
Draw_TransPicTranslate
=============
*/
void
Draw_TransPicTranslate(int x, int y, const qpic8_t *pic, const byte *translation)
{
    int dst_x, dst_x_start, dst_x_end, dst_width;
    int dst_y, dst_y_start, dst_y_end, dst_height;
    int f, fstep;
    const byte *src;

    assert(pic->stride);

    /* Calculate the destination pixels */
    dst_x_start = SCR_Scale(x);
    dst_y_start = SCR_Scale(y);
    dst_x_end = SCR_Scale(x + pic->width);
    dst_y_end = SCR_Scale(y + pic->height);
    dst_width = dst_x_end - dst_x_start;
    dst_height = dst_y_end - dst_y_start;

    /* Clip to the output buffer size */
    dst_x_end = qmin(dst_x_end, vid.conwidth);
    dst_y_end = qmin(dst_y_end, vid.conheight);

    /* Fractional source step, 16-bits of precision */
    fstep = pic->width * 0x10000 / dst_width;
    if (r_pixbytes == 1) {
        for (dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
            byte *dst = vid.buffer + dst_y * vid.rowbytes;
            int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
            src = pic->pixels + src_row * pic->stride;
            for (dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
                if (src[f >> 16] != TRANSPARENT_COLOR)
                    dst[dst_x] = translation[src[f >> 16]];
            }
        }
    } else {
        for (dst_y = qmax(0, dst_y_start); dst_y < dst_y_end; dst_y++) {
            uint16_t *dst = (uint16_t *)(vid.buffer + dst_y * vid.rowbytes);
            int src_row = (dst_y - dst_y_start) * pic->height / dst_height;
            src = pic->pixels + src_row * pic->stride;
            for (dst_x = qmax(0, dst_x_start), f = 0; dst_x < dst_x_end; dst_x++, f += fstep) {
                if (src[f >> 16] != TRANSPARENT_COLOR)
                    dst[dst_x] = d_8to16table[translation[src[f >> 16]]];
            }
        }
    }
}

/*
 * Draws one 8*8 graphics character with 0 being transparent.
 */
void
Draw_CharacterAlpha(int x, int y, byte num, float alpha)
{
    int row, col;
    qpic8_t pic = {
        .width = 8,
        .height = 8,
        .stride = 128,
    };

    /* Find the source character in the 16x16 grid */
    row = num >> 4;
    col = num & 15;
    pic.pixels = draw_chars + (row << 10) + (col << 3);

    if (scr_scale == 1.0f) {
        Draw_ScaledTransPicAlpha(x, y, &pic, 0, alpha);
    } else {
        Draw_TransPicAlpha(x, y, &pic, 0, alpha);
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
	    if (src[f >> 16])
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


/*
================
Draw_ConsoleBackground

================
*/
void
Draw_ConsoleBackground(int lines)
{
    const qpic8_t *conback;
    const byte *src;
    int x, y, v;
    int f, fstep;

    conback = Draw_CacheConback();

    /* draw the pic */
    if (r_pixbytes == 1) {
	byte *dest = vid.conbuffer;

	for (y = 0; y < lines; y++, dest += vid.conrowbytes) {
	    v = (vid.conheight - lines + y) * conback->height / vid.conheight;
	    src = conback->pixels + v * conback->width;
	    if (vid.conwidth == conback->width)
		memcpy(dest, src, vid.conwidth);
	    else {
		f = 0;
		fstep = conback->width * 0x10000 / vid.conwidth;
		for (x = 0; x < vid.conwidth; x += 4) {
		    dest[x] = src[f >> 16];
		    f += fstep;
		    dest[x + 1] = src[f >> 16];
		    f += fstep;
		    dest[x + 2] = src[f >> 16];
		    f += fstep;
		    dest[x + 3] = src[f >> 16];
		    f += fstep;
		}
	    }
	}
    } else {
	uint16_t *pusdest = (uint16_t *)vid.conbuffer;

	for (y = 0; y < lines; y++, pusdest += vid.conrowbytes / 2) {
	    // FIXME: pre-expand to native format?
	    // FIXME: does the endian switching go away in production?
	    v = (vid.conheight - lines + y) * conback->height / vid.conheight;
	    src = conback->pixels + v * conback->width;
	    f = 0;
	    fstep = conback->width * 0x10000 / vid.conwidth;
	    for (x = 0; x < vid.conwidth; x += 4) {
		pusdest[x] = d_8to16table[src[f >> 16]];
		f += fstep;
		pusdest[x + 1] = d_8to16table[src[f >> 16]];
		f += fstep;
		pusdest[x + 2] = d_8to16table[src[f >> 16]];
		f += fstep;
		pusdest[x + 3] = d_8to16table[src[f >> 16]];
		f += fstep;
	    }
	}
    }
}


/*
==============
R_DrawRect8
==============
*/
static void
R_DrawRect8(const vrect_t *rect, int rowbytes, const byte *psrc, int transparent)
{
    byte t;
    int i, j, srcdelta, destdelta;
    byte *pdest;

    pdest = vid.buffer + (rect->y * vid.rowbytes) + rect->x;

    srcdelta = rowbytes - rect->width;
    destdelta = vid.rowbytes - rect->width;

    if (transparent) {
	for (i = 0; i < rect->height; i++) {
	    for (j = 0; j < rect->width; j++) {
		t = *psrc;
		if (t != TRANSPARENT_COLOR) {
		    *pdest = t;
		}

		psrc++;
		pdest++;
	    }

	    psrc += srcdelta;
	    pdest += destdelta;
	}
    } else {
	for (i = 0; i < rect->height; i++) {
	    memcpy(pdest, psrc, rect->width);
	    psrc += rowbytes;
	    pdest += vid.rowbytes;
	}
    }
}


/*
==============
R_DrawRect16
==============
*/
static void
R_DrawRect16(const vrect_t *rect, int rowbytes, const byte *psrc, int transparent)
{
    byte t;
    int i, j, srcdelta, destdelta;
    uint16_t *pdest;

// FIXME: would it be better to pre-expand native-format versions?

    pdest = (uint16_t *)vid.buffer;
    pdest += rect->y * (vid.rowbytes / 2) + rect->x;

    srcdelta = rowbytes - rect->width;
    destdelta = (vid.rowbytes / 2) - rect->width;

    if (transparent) {
	for (i = 0; i < rect->height; i++) {
	    for (j = 0; j < rect->width; j++) {
		t = *psrc;
		if (t != TRANSPARENT_COLOR) {
		    *pdest = d_8to16table[t];
		}

		psrc++;
		pdest++;
	    }

	    psrc += srcdelta;
	    pdest += destdelta;
	}
    } else {
	for (i = 0; i < rect->height; i++) {
	    for (j = 0; j < rect->width; j++) {
		*pdest = d_8to16table[*psrc];
		psrc++;
		pdest++;
	    }

	    psrc += srcdelta;
	    pdest += destdelta;
	}
    }
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
    int width, height, tileoffsetx, tileoffsety;
    const byte *psrc;
    vrect_t vr;

    if (x < 0 || (unsigned)(x + w) > vid.width ||
	y < 0 || (unsigned)(y + h) > vid.height) {
	Sys_Error("%s: bad coordinates (%d,%d)->(%dx%d) (%dx%d)",
                  __func__, x, y, w, h, vid.width, vid.height);
    }

    r_rectdesc.rect.x = x;
    r_rectdesc.rect.y = y;
    r_rectdesc.rect.width = w;
    r_rectdesc.rect.height = h;

    vr.y = r_rectdesc.rect.y;
    height = r_rectdesc.rect.height;

    tileoffsety = vr.y % r_rectdesc.height;

    while (height > 0) {
	vr.x = r_rectdesc.rect.x;
	width = r_rectdesc.rect.width;

	if (tileoffsety != 0)
	    vr.height = r_rectdesc.height - tileoffsety;
	else
	    vr.height = r_rectdesc.height;

	if (vr.height > height)
	    vr.height = height;

	tileoffsetx = vr.x % r_rectdesc.width;

	while (width > 0) {
	    if (tileoffsetx != 0)
		vr.width = r_rectdesc.width - tileoffsetx;
	    else
		vr.width = r_rectdesc.width;

	    if (vr.width > width)
		vr.width = width;

	    psrc = r_rectdesc.ptexbytes +
		(tileoffsety * r_rectdesc.rowbytes) + tileoffsetx;

	    if (r_pixbytes == 1) {
		R_DrawRect8(&vr, r_rectdesc.rowbytes, psrc, 0);
	    } else {
		R_DrawRect16(&vr, r_rectdesc.rowbytes, psrc, 0);
	    }

	    vr.x += vr.width;
	    width -= vr.width;
	    tileoffsetx = 0;	// only the left tile can be left-clipped
	}

	vr.y += vr.height;
	height -= vr.height;
	tileoffsety = 0;	// only the top tile can be top-clipped
    }
}

void
Draw_TileClearScaled(int x, int y, int w, int h)
{
    if (scr_scale != 1.0f) {
        x = SCR_Scale(x);
        y = SCR_Scale(y);
        w = SCR_Scale(w);
        h = SCR_Scale(h);
    }
    Draw_TileClear(x, y, w, h);
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
    if (scr_scale != 1.0f) {
        x = SCR_Scale(x);
        y = SCR_Scale(y);
        w = SCR_Scale(w);
        h = SCR_Scale(h);
    }

    assert(x >= 0 && x + w <= vid.width);
    assert(y >= 0 && y + h <= vid.height);

    if (!alpha)
        return;
    const byte *transtable = Alpha_Transtable(alpha);

    byte *dest = vid.buffer + y * vid.rowbytes + x;
    if (transtable) {
        for (int v = 0; v < h; v++, dest += vid.rowbytes)
            for (int u = 0; u < w; u++)
                dest[u] = transtable[(((int)dest[u]) << 8) + c];
    } else {
        for (int v = 0; v < h; v++, dest += vid.rowbytes)
            for (int u = 0; u < w; u++)
                dest[u] = c;
    }
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
    int x, y;
    byte *pbuf;

    VID_UnlockBuffer();
    S_ExtraUpdate();
    VID_LockBuffer();

    for (y = 0; y < vid.height; y++) {
	int t;

	pbuf = (byte *)(vid.buffer + vid.rowbytes * y);
	t = (y & 1) << 1;

	for (x = 0; x < vid.width; x++) {
	    if ((x & 3) != t)
		pbuf[x] = 0;
	}
    }

    VID_UnlockBuffer();
    S_ExtraUpdate();
    VID_LockBuffer();
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
    /* May not have loaded the draw disc yet... */
    if (!draw_disc)
	return;

    D_BeginDirectRect(vid.width - 24, 0, draw_disc->pixels, 24, 24);
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
    D_EndDirectRect(vid.width - 24, 0, 24, 24);
}
