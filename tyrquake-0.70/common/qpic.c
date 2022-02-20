/*
Copyright (C) 1996-1997 Id Software, Inc.  Copyright (C) 2013 Kevin
Shanahan

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

#include <assert.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

#include "mathlib.h"
#include "qpic.h"
#include "qtypes.h"
#include "vid.h"
#include "zone.h"

/* Indexed by enum texture_type */
texture_properties_t texture_properties[] = {
    // Palette                Alpha Operation              mipmap picmip plyrmp repeat
    { &qpal_alpha_zero,       QPIC_ALPHA_OP_EDGE_FIX,      false, false, false, false }, // CHARSET
    { &qpal_alpha,            QPIC_ALPHA_OP_EDGE_FIX,      false, false, false, true  }, // HUD
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          true,  true,  false, true  }, // WORLD
    { &qpal_fullbright,       QPIC_ALPHA_OP_NONE,          true,  true,  false, true  }, // WORLD_FULLBRIGHT
    { &qpal_alpha,            QPIC_ALPHA_OP_EDGE_FIX,      true,  true,  false, true  }, // FENCE
    { &qpal_alpha_fullbright, QPIC_ALPHA_OP_EDGE_FIX,      true,  true,  false, true  }, // FENCE_FULLBRIGHT
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          false, true,  false, true  }, // TURB
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          false, false, false, true  }, // SKY_BACKGROUND
    { &qpal_alpha_zero,       QPIC_ALPHA_OP_EDGE_FIX,      false, false, false, true  }, // SKY_FOREGROUND
    { &qpal_alpha_zero,       QPIC_ALPHA_OP_EDGE_FIX,      false, false, false, false }, // SKYBOX
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          true,  true,  false, false }, // ALIAS_SKIN
    { &qpal_fullbright,       QPIC_ALPHA_OP_CLAMP_TO_ZERO, true,  true,  false, false }, // ALIAS_SKIN_FULLBRIGHT
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          true,  false, true,  false }, // PLAYER_SKIN
    { &qpal_fullbright,       QPIC_ALPHA_OP_CLAMP_TO_ZERO, true,  false, true,  false }, // PLAYER_SKIN_FULLBRIGHT
    { &qpal_alpha,            QPIC_ALPHA_OP_EDGE_FIX,      false, false, false, false }, // PARTICLE
    { &qpal_alpha,            QPIC_ALPHA_OP_EDGE_FIX,      true,  true,  false, false }, // SPRITE
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          false, false, false, true  }, // NOTEXTURE
    { NULL,                   QPIC_ALPHA_OP_NONE,          false, false, false, false }, // LIGHTMAP
    { &qpal_standard,         QPIC_ALPHA_OP_NONE,          false, false, false, true  }, // WARP_TARGET
    { NULL,                   QPIC_ALPHA_OP_NONE,          false, false, false, true  }, // DATA
};

/*
 * Detect 8-bit textures containing fullbrights
 */
qboolean
QPic_HasFullbrights(const qpic8_t *pic, enum texture_type type)
{
    int i, j;
    const byte *pixel;
    const qpalette32_t *palette;

    palette = texture_properties[type].palette;
    pixel = pic->pixels;
    for (i = 0; i < pic->height; i++) {
        for (j = 0; j < pic->width; j++) {
            byte index = *pixel++;
            if (index > 223 && palette->colors[index].c.alpha)
                return true;
        }
        pixel += pic->stride - pic->width;
    }

    return false;
}

/* --------------------------------------------------------------------------*/
/* Pic Format Transformations                                                */
/* --------------------------------------------------------------------------*/

qpic32_t *
QPic32_Alloc(int width, int height)
{
    const int memsize = offsetof(qpic32_t, pixels[width * height]);
    qpic32_t *pic = Hunk_AllocName(memsize, "qp32tmp");

    if (pic) {
	pic->width = width;
	pic->height = height;
    }

    return pic;
}

/*
================
QPic32_AlphaEdgeFix

Operates in-place on an RGBA pic assumed to have all alpha values
either fully opaque or transparent.  Fully transparent pixels get
their color components set to the average color of their
non-transparent neighbours to avoid artifacts from blending.

TODO: add an edge clamp mode?
================
*/
static void
QPic32_AlphaEdgeFix(qpic32_t *pic)
{
    const int width = pic->width;
    const int height = pic->height;
    qpixel32_t *pixels = pic->pixels;

    int x, y, n, red, green, blue, count;
    int neighbours[8];

    for (y = 0; y < height; y++) {
	for (x = 0; x < width; x++) {
	    const int current = y * width + x;

	    /* only modify completely transparent pixels */
	    if (pixels[current].c.alpha)
		continue;

	    /*
	     * Neighbour pixel indexes are left to right:
	     *   1 2 3
	     *   4 * 5
	     *   6 7 8
	     */
	    neighbours[0] = current - width - 1;
	    neighbours[1] = current - width;
	    neighbours[2] = current - width + 1;
	    neighbours[3] = current - 1;
	    neighbours[4] = current + 1;
	    neighbours[5] = current + width - 1;
	    neighbours[6] = current + width;
	    neighbours[7] = current + width + 1;

	    /* handle edge cases (wrap around) */
	    if (!x) {
		neighbours[0] += width;
		neighbours[3] += width;
		neighbours[5] += width;
	    } else if (x == width - 1) {
		neighbours[2] -= width;
		neighbours[4] -= width;
		neighbours[7] -= width;
	    }
	    if (!y) {
		neighbours[0] += width * height;
		neighbours[1] += width * height;
		neighbours[2] += width * height;
	    } else if (y == height - 1) {
		neighbours[5] -= width * height;
		neighbours[6] -= width * height;
		neighbours[7] -= width * height;
	    }

	    /* find the average color of non-transparent neighbours */
	    red = green = blue = count = 0;
	    for (n = 0; n < 8; n++) {
		if (!pixels[neighbours[n]].c.alpha)
		    continue;
		red += pixels[neighbours[n]].c.red;
		green += pixels[neighbours[n]].c.green;
		blue += pixels[neighbours[n]].c.blue;
		count++;
	    }

	    /* skip if no non-transparent neighbours */
	    if (!count)
		continue;

	    pixels[current].c.red = red / count;
	    pixels[current].c.green = green / count;
	    pixels[current].c.blue = blue / count;
	}
    }
}

static void
QPic32_AlphaClampToZero(qpic32_t *pic)
{
    const int size = pic->width * pic->height;
    qpixel32_t *pixel;
    int i;

    for (i = 0, pixel = pic->pixels; i < size; i++, pixel++) {
        if (pixel->c.alpha < 255)
            pixel->c.alpha = 0;
    }
}

static void
QPic32_AlphaFix(qpic32_t *pic, enum qpic_alpha_operation alpha_op)
{
    switch (alpha_op) {
        case QPIC_ALPHA_OP_EDGE_FIX:
            QPic32_AlphaEdgeFix(pic);
            break;
        case QPIC_ALPHA_OP_CLAMP_TO_ZERO:
            QPic32_AlphaClampToZero(pic);
            break;
        case QPIC_ALPHA_OP_NONE:
            break;
    }
}

void
QPic_8to32(const qpic8_t *in, qpic32_t *out, const qpalette32_t *palette, enum qpic_alpha_operation alpha_op)
{
    const int width = in->width;
    const int height = in->height;
    const int stride = in->stride ? in->stride : in->width;
    const byte *in_p = in->pixels;
    qpixel32_t *out_p = out->pixels;
    int x, y;

    for (y = 0; y < height; y++) {
	for (x = 0; x < width; x++)
	    *out_p++ = palette->colors[*in_p++];
	in_p += stride - width;
    }

    QPic32_AlphaFix(out, alpha_op);
}

void
QPic32_ScaleAlpha(qpic32_t *pic, byte alpha)
{
    const int width = pic->width;
    const int height = pic->height;
    qpixel32_t *pixel = pic->pixels;
    int x, y;

    for (y = 0; y < height; y++) {
	for (x = 0; x < width; x++) {
	    pixel->c.alpha = ((int)pixel->c.alpha * alpha / 255);
            pixel++;
        }
    }
}

/*
================
QPic32_Stretch
TODO - should probably be doing bilinear filtering or something
================
*/
void
QPic32_Stretch(const qpic32_t *in, qpic32_t *out)
{
    int i, j;
    const qpixel32_t *inrow;
    qpixel32_t *outrow;
    unsigned frac, fracstep;

    assert(!(out->width & 3));

    fracstep = in->width * 0x10000 / out->width;
    outrow = out->pixels;
    for (i = 0; i < out->height; i++, outrow += out->width) {
	inrow = in->pixels + in->width * (i * in->height / out->height);
	frac = fracstep >> 1;
	for (j = 0; j < out->width; j += 4) {
	    outrow[j] = inrow[frac >> 16];
	    frac += fracstep;
	    outrow[j + 1] = inrow[frac >> 16];
	    frac += fracstep;
	    outrow[j + 2] = inrow[frac >> 16];
	    frac += fracstep;
	    outrow[j + 3] = inrow[frac >> 16];
	    frac += fracstep;
	}
    }
}

/*
============
Expand the texture size, copying the source texture into the top left corner.
============
*/
void
QPic32_Expand(const qpic32_t *in, qpic32_t *out)
{
    int i, j;
    const qpixel32_t *src;
    qpixel32_t *dst;
    qpixel32_t fill;

    assert(in->width <= out->width);
    assert(in->height <= out->height);

    src = in->pixels;
    dst = out->pixels;
    i = 0;
    while (i < in->height) {
	/* Copy source pixels in */
	j = 0;
	while (j < in->width) {
	    *dst++ = *src++;
	    j++;
	}
	/* Fill space with color matching last source pixel */
	fill = *(src - 1);
	while (j < out->width) {
	    *dst++ = fill;
	    j++;
	}
	i++;
    }
    /* Fill remaining rows with color matching the pixel above */
    src = dst - out->width;
    while (i < out->height) {
	*dst++ = *src++;
	i++;
    }
}


/* --------------------------------------------------------------------------*/
/* Mipmaps - Handle all variations of even/odd dimensions                    */
/* --------------------------------------------------------------------------*/

/*
 * In this context "even" means downsampling by exactly 2:1.  The "odd"
 * functions support downsampling anything from 2n+1:n to 3n-1:n.  For
 * these "odd" cases we use a sliding box filter three pixels across.
 *
 * This is a helper for calculating where in the source row the
 * sliding window should be positioned and what the weights of the
 * fractional pixels at the start and end should be.  The weight of
 * the center pixel is a constant (outsize / insize) that the caller
 * will have cached.
 */
struct pixel_window {
    float w0;   /* Weight of the first pixel in the window          */
    float w2;   /* Weight of the last pixel in the window           */
    int inpos;  /* Pixel position of the window on the input bitmap */
};

static inline struct pixel_window
QPic32_GetWindow(float instep, float w1, int outpos)
{
    struct pixel_window pw;
    float inpos;
    const float w0_frac = 1.0f - modff(outpos * instep, &inpos);

    pw.w0 = w0_frac * w1;
    pw.w2 = 1.0f - (pw.w0 + w1);
    pw.inpos = inpos;

    return pw;
}

static void
QPic32_MipMap_WidthOnly_Even(qpixel32_t *pixels, int inwidth, int inheight)
{
    const int outwidth = inwidth >> 1;
    const int outheight = inheight;
    const byte *in = (byte *)pixels;
    byte *out = (byte *)pixels;

    for (int y = 0; y < outheight; y++) {
        for (int x = 0; x < outwidth; x++, out += 4, in += 8) {
            out[0] = ((int)in[0] + in[4]) >> 1;
            out[1] = ((int)in[1] + in[5]) >> 1;
            out[2] = ((int)in[2] + in[6]) >> 1;
            out[3] = ((int)in[3] + in[7]) >> 1;
        }
    }
}

static void
QPic32_MipMap_WidthOnly_Odd(qpixel32_t *pixels, int inwidth, int inheight, int outwidth)
{
    const int outheight = inheight;
    byte *out = (byte *)pixels;

    const float instep = (float)inwidth / outwidth;
    const float w1 = (float)outwidth / inwidth;

    const byte *rowstart = (byte *)pixels;
    for (int y = 0; y < outheight; y++, rowstart += inwidth << 2) {
        for (int x = 0; x < outwidth; x++, out += 4) {
            struct pixel_window pw = QPic32_GetWindow(instep, w1, x);
            const byte *in = rowstart + (pw.inpos << 2);

            out[0] = pw.w0 * in[0] + w1 * in[4] + pw.w2 * in[8];
            out[1] = pw.w0 * in[1] + w1 * in[5] + pw.w2 * in[9];
            out[2] = pw.w0 * in[2] + w1 * in[6] + pw.w2 * in[10];
            out[3] = pw.w0 * in[3] + w1 * in[7] + pw.w2 * in[11];
        }
    }
}

static void
QPic32_MipMap_HeightOnly_Even(qpixel32_t *pixels, int inwidth, int inheight)
{
    const int outwidth = inwidth;
    const int outheight = inheight >> 1;
    const byte *in = (byte *)pixels;
    byte *out = (byte *)pixels;

    const int instride = inwidth << 2;
    const int outstride = outwidth << 2;

    for (int y = 0; y < outheight; y++, in += instride) {
        for (int x = 0; x < outstride; x += 4, out += 4, in += 4) {
            out[0] = ((int)in[0] + in[instride + 0]) >> 1;
            out[1] = ((int)in[1] + in[instride + 1]) >> 1;
            out[2] = ((int)in[2] + in[instride + 2]) >> 1;
            out[3] = ((int)in[3] + in[instride + 3]) >> 1;
        }
    }
}

static void
QPic32_MipMap_HeightOnly_Odd(qpixel32_t *pixels, int inwidth, int inheight, int outheight)
{
    const int outwidth = inwidth;
    byte *out = (byte *)pixels;

    const int instride = inwidth << 2;
    const int outstride = outwidth << 2;

    const float instep = (float)inheight / outheight;
    const float w1 = (float)outheight / inheight;

    for (int y = 0; y < outheight; y++) {
        struct pixel_window pw = QPic32_GetWindow(instep, w1, y);
        const byte *in = (byte *)pixels + pw.inpos * inwidth;
        for (int x = 0; x < outstride; x += 4, out += 4, in += 4) {
            out[0] = pw.w0 * in[0] + w1 * in[instride + 0] + pw.w2 * in[(instride << 1) + 0];
            out[1] = pw.w0 * in[1] + w1 * in[instride + 1] + pw.w2 * in[(instride << 1) + 1];
            out[2] = pw.w0 * in[2] + w1 * in[instride + 2] + pw.w2 * in[(instride << 1) + 2];
            out[3] = pw.w0 * in[3] + w1 * in[instride + 3] + pw.w2 * in[(instride << 1) + 3];
        }
    }
}

/*
================
QPic32_MipMap_EvenEven

Simple 2x2 box filter for pics with even width/height
================
*/
static void
QPic32_MipMap_EvenEven(qpixel32_t *pixels, int inwidth, int inheight)
{
    const int outwidth = inwidth >> 1;
    const int outheight = inheight >> 1;
    const byte *in = (byte *)pixels;
    byte *out = (byte *)pixels;

    const int instride = inwidth << 2;

    for (int y = 0; y < outheight; y++, in += instride) {
	for (int x = 0; x < outwidth; x++, out += 4, in += 8) {
	    out[0] = ((int)in[0] + in[4] + in[instride + 0] + in[instride + 4]) >> 2;
	    out[1] = ((int)in[1] + in[5] + in[instride + 1] + in[instride + 5]) >> 2;
	    out[2] = ((int)in[2] + in[6] + in[instride + 2] + in[instride + 6]) >> 2;
	    out[3] = ((int)in[3] + in[7] + in[instride + 3] + in[instride + 7]) >> 2;
	}
    }
}


/*
================
QPic32_MipMap_OddOdd

With two odd dimensions we have a polyphase box filter in two
dimensions, taking weighted samples from a 3x3 square in the original
pic.
================
*/
static void
QPic32_MipMap_OddOdd(qpixel32_t *pixels, int inwidth, int inheight, int outwidth, int outheight)
{
    byte *out = (byte *)pixels;

    const float instep_x = (float)inwidth / outwidth;
    const float instep_y = (float)inheight / outheight;
    const float wy1 = (float)outheight / inheight;
    const float wx1 = (float)outwidth / inwidth;

    for (int y = 0; y < outheight; y++) {
        struct pixel_window pwy = QPic32_GetWindow(instep_y, wy1, y);
        const byte *rowstart = (byte *)pixels + pwy.inpos * (inwidth << 2);

	for (int x = 0; x < outwidth; x++, out += 4) {
            struct pixel_window pwx = QPic32_GetWindow(instep_x, wx1, x);
            const byte *in = rowstart + (pwx.inpos << 2);

	    /* Set up input row pointers to make things read easier below */
	    const byte *r0 = in;
	    const byte *r1 = in + (inwidth << 2);
	    const byte *r2 = in + (inwidth << 3);

	    out[0] =
		pwx.w0 * pwy.w0 * r0[0] + wx1 * pwy.w0 * r0[4] + pwx.w2 * pwy.w0 * r0[ 8] +
		pwx.w0 *    wy1 * r1[0] + wx1 *    wy1 * r1[4] + pwx.w2 *    wy1 * r1[ 8] +
		pwx.w0 * pwy.w2 * r2[0] + wx1 * pwy.w2 * r2[4] + pwx.w2 * pwy.w2 * r2[ 8];
	    out[1] =
		pwx.w0 * pwy.w0 * r0[1] + wx1 * pwy.w0 * r0[5] + pwx.w2 * pwy.w0 * r0[ 9] +
		pwx.w0 *    wy1 * r1[1] + wx1 *    wy1 * r1[5] + pwx.w2 *    wy1 * r1[ 9] +
		pwx.w0 * pwy.w2 * r2[1] + wx1 * pwy.w2 * r2[5] + pwx.w2 * pwy.w2 * r2[ 9];
	    out[2] =
		pwx.w0 * pwy.w0 * r0[2] + wx1 * pwy.w0 * r0[6] + pwx.w2 * pwy.w0 * r0[10] +
		pwx.w0 *    wy1 * r1[2] + wx1 *    wy1 * r1[6] + pwx.w2 *    wy1 * r1[10] +
		pwx.w0 * pwy.w2 * r2[2] + wx1 * pwy.w2 * r2[6] + pwx.w2 * pwy.w2 * r2[10];
	    out[3] =
		pwx.w0 * pwy.w0 * r0[3] + wx1 * pwy.w0 * r0[7] + pwx.w2 * pwy.w0 * r0[11] +
		pwx.w0 *    wy1 * r1[3] + wx1 *    wy1 * r1[7] + pwx.w2 *    wy1 * r1[11] +
		pwx.w0 * pwy.w2 * r2[3] + wx1 * pwy.w2 * r2[7] + pwx.w2 * pwy.w2 * r2[11];
	}
    }
}

/*
================
QPic32_MipMap_OddEven

Handle odd width, even height
================
*/
static void
QPic32_MipMap_OddEven(qpixel32_t *pixels, int inwidth, int inheight, int outwidth)
{
    const int outheight = inheight >> 1;
    byte *out = (byte *)pixels;

    const float instep_x = (float)inwidth / outwidth;
    const float wx1 = (float)outwidth / inwidth;
    const byte *rowstart = (byte *)pixels;

    for (int y = 0; y < outheight; y++, rowstart += inwidth << 3) {
	for (int x = 0; x < outwidth; x++, out += 4) {
            struct pixel_window pw = QPic32_GetWindow(instep_x, wx1, x);
            const byte *in = rowstart + (pw.inpos << 2);

	    /* Set up input row pointers to make things read easier below */
	    const byte *r0 = in;
	    const byte *r1 = in + (inwidth << 2);

	    out[0] = 0.5 * (pw.w0 * r0[0] + wx1 * r0[4] + pw.w2 * r0[ 8] +
			    pw.w0 * r1[0] + wx1 * r1[4] + pw.w2 * r1[ 8]);
	    out[1] = 0.5 * (pw.w0 * r0[1] + wx1 * r0[5] + pw.w2 * r0[ 9] +
			    pw.w0 * r1[1] + wx1 * r1[5] + pw.w2 * r1[ 9]);
	    out[2] = 0.5 * (pw.w0 * r0[2] + wx1 * r0[6] + pw.w2 * r0[10] +
			    pw.w0 * r1[2] + wx1 * r1[6] + pw.w2 * r1[10]);
	    out[3] = 0.5 * (pw.w0 * r0[3] + wx1 * r0[7] + pw.w2 * r0[11] +
			    pw.w0 * r1[3] + wx1 * r1[7] + pw.w2 * r1[11]);
	}
    }
}

/*
================
QPic32_MipMap_EvenOdd

Handle even width, odd height
================
*/
static void
QPic32_MipMap_EvenOdd(qpixel32_t *pixels, int inwidth, int inheight, int outheight)
{
    const int outwidth = inwidth >> 1;
    byte *out = (byte *)pixels;

    const float instep_y = (float)inheight / outheight;
    const float wy1 = (float)outheight / inheight;

    for (int y = 0; y < outheight; y++) {
        struct pixel_window pw = QPic32_GetWindow(instep_y, wy1, y);
        const byte *in = (byte *)pixels + pw.inpos * (inwidth << 2);
	for (int x = 0; x < outwidth; x++, in += 8, out += 4) {
	    /* Set up input row pointers to make things read easier below */
	    const byte *r0 = in;
	    const byte *r1 = in + (inwidth << 2);
	    const byte *r2 = in + (inwidth << 3);

	    out[0] = 0.5 * (pw.w0 * ((int)r0[0] + r0[4]) +
			      wy1 * ((int)r1[0] + r1[4]) +
			    pw.w2 * ((int)r2[0] + r2[4]));
	    out[1] = 0.5 * (pw.w0 * ((int)r0[1] + r0[5]) +
			      wy1 * ((int)r1[1] + r1[5]) +
			    pw.w2 * ((int)r2[1] + r2[5]));
	    out[2] = 0.5 * (pw.w0 * ((int)r0[2] + r0[6]) +
			      wy1 * ((int)r1[2] + r1[6]) +
			    pw.w2 * ((int)r2[2] + r2[6]));
	    out[3] = 0.5 * (pw.w0 * ((int)r0[3] + r0[7]) +
			      wy1 * ((int)r1[3] + r1[7]) +
			    pw.w2 * ((int)r2[3] + r2[7]));
	}
    }
}

/*
================
QPic32_MipMap

Check pic dimensions and call the approriate specialized mipmap
function.  Blocksize is the granularity of the downsample.  For
uncompressed textures, this is usually 1.  For DXT/BC compressed
textures this is 4.
================
*/
void
QPic32_MipMap(qpic32_t *in, enum qpic_alpha_operation alpha_op)
{
    assert(in->width > 1 || in->height > 1);

    int outwidth   = in->width  > 1 ? in->width  >> 1 : 1;
    int outheight  = in->height > 1 ? in->height >> 1 : 1;

    if (in->width == 1) {
	if (outheight & 1)
	    QPic32_MipMap_HeightOnly_Odd(in->pixels, in->width, in->height, outheight);
        else
	    QPic32_MipMap_HeightOnly_Even(in->pixels, in->width, in->height);
	in->height = outheight;
	return;
    }

    if (in->height == 1) {
	if (outwidth & 1)
	    QPic32_MipMap_WidthOnly_Odd(in->pixels, in->width, in->height, outwidth);
	else
	    QPic32_MipMap_WidthOnly_Even(in->pixels, in->width, in->height);
	in->width = outwidth;
	return;
    }

    if (outwidth & 1) {
        if (outheight & 1) {
            QPic32_MipMap_OddOdd(in->pixels, in->width, in->height, outwidth, outheight);
        } else {
            QPic32_MipMap_OddEven(in->pixels, in->width, in->height, outwidth);
        }
    } else if (outheight & 1) {
        QPic32_MipMap_EvenOdd(in->pixels, in->width, in->height, outheight);
    } else {
        QPic32_MipMap_EvenEven(in->pixels, in->width, in->height);
    }

    in->width = outwidth;
    in->height = outheight;

    QPic32_AlphaFix(in, alpha_op);
}

qpalette32_t qpal_standard;
qpalette32_t qpal_fullbright;
qpalette32_t qpal_alpha_zero;
qpalette32_t qpal_alpha;
qpalette32_t qpal_alpha_fullbright;

void
QPic32_InitPalettes(const byte *palette)
{
    int i;
    const byte *src;
    qpixel32_t *dst;

    /* Standard palette - no transparency */
    src = palette;
    dst = qpal_standard.colors;
    for (i = 0; i < 256; i++, dst++) {
        dst->c.red = *src++;
        dst->c.green = *src++;
        dst->c.blue = *src++;
        dst->c.alpha = 255;
    }
    qpal_standard.alpha = false;

    /* Full-bright pallette - 0-223 are transparent but keep their colors (for mipmapping) */
    memcpy(&qpal_fullbright, &qpal_standard, sizeof(qpalette32_t));
    dst = qpal_fullbright.colors;
    for (i = 0; i < 224; i++, dst++)
        dst->c.alpha = 0;
    qpal_fullbright.alpha = true;

    /* Charset/sky palette - 0 is transparent */
    memcpy(&qpal_alpha_zero, &qpal_standard, sizeof(qpalette32_t));
    qpal_alpha_zero.colors[0].c.alpha = 0;
    qpal_alpha_zero.alpha = true;

    /* HUD/sprite/fence palette - 255 is transparent */
    memcpy(&qpal_alpha, &qpal_standard, sizeof(qpalette32_t));
    qpal_alpha.colors[255].c.alpha = 0;
    qpal_alpha.alpha = true;

    /* Fullbright mask for alpha (fence) textures */
    memcpy(&qpal_alpha_fullbright, &qpal_fullbright, sizeof(qpalette32_t));
    qpal_alpha_fullbright.colors[255].c.alpha = 0;
    qpal_alpha_fullbright.alpha = true;
}
