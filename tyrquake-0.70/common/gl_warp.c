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
// gl_warp.c -- sky and water polygons

#include <float.h>

#include "console.h"
#include "glquake.h"
#include "model.h"
#include "qpic.h"
#include "quakedef.h"
#include "sbar.h"
#include "sys.h"

#ifdef NQ_HACK
#include "host.h"
#endif

#define TURBSCALE (256.0 / (2 * M_PI))
static float turbsin[256] = {
#include "gl_warp_sin.h"
};

cvar_t r_waterquality = { "r_waterquality", "8", CVAR_CONFIG };

static inline void
AddWarpVert(vec4_t vert, float x, float y)
{
    float turb_s = turbsin[(int)((y * 2.0f) + (realtime * TURBSCALE)) & 255];
    float turb_t = turbsin[(int)((x * 2.0f) + (realtime * TURBSCALE)) & 255];

    vert[0] = x;
    vert[1] = y;
    vert[2] = (x + turb_s) * (1.0f / 128.0f);
    vert[3] = (y + turb_t) * (1.0f / 128.0f);
}

void
R_UpdateWarpTextures()
{
    texture_t *texture;
    int i, s, t, subdivisions, numindices, numverts, gl_warpimagesize;
    float x, y, step, *vertices, *vertex;
    uint16_t *indices, *index;

    if (gl_vertex_program_enabled && gl_fragment_program_enabled)
        return;

    if (cl.paused || r_drawflat.value || r_lightmap.value)
        return;

    subdivisions = qclamp(floorf(r_waterquality.value), 3.0f, 64.0f);
    step = (float)WARP_IMAGE_SIZE / (float)subdivisions;

    /* Draw the whole thing at once with drawelements */
    vertices = alloca((subdivisions + 1) * (subdivisions + 1) * sizeof(float) * 4);
    indices = alloca(subdivisions * subdivisions * 6 * sizeof(uint16_t));

    /* Add the first row of vertices */
    vertex = vertices;
    index = indices;
    x = 0.0f;
    for (s = 0; s <= subdivisions; s++, x += step) {
        AddWarpVert(vertex, x, 0.0f);
        vertex += 4;
    }

    /* Add the remaining rows */
    y = step;
    for (t = 1; t <= subdivisions; t++, y += step) {

        /* Add the first vertex separately, no complete quads yet */
        AddWarpVert(vertex, 0.0f, y);
        vertex += 4;

        x = step;
        for (s = 1; s <= subdivisions; s++, x += step) {
            AddWarpVert(vertex, x, y);
            vertex += 4;
            numverts = (vertex - vertices) >> 2;

            /* Add size indices for the two triangles in this quad */
            *index++ = numverts - subdivisions - 3;
            *index++ = numverts - 2;
            *index++ = numverts - subdivisions - 2;
            *index++ = numverts - subdivisions - 2;
            *index++ = numverts - 2;
            *index++ = numverts - 1;
        }
    }

    numverts = (vertex - vertices) >> 2;
    numindices = index - indices;
    gl_warpimagesize = 0;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, WARP_IMAGE_SIZE, 0, WARP_IMAGE_SIZE, -99999, 99999);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    if (gl_mtexable) {
        GL_DisableMultitexture();
        qglClientActiveTexture(GL_TEXTURE0);
    }
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 4 * sizeof(float), vertices);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 4 * sizeof(float), vertices + 2);

    for (i = 0; i < cl.worldmodel->numtextures; i++) {
        texture = cl.worldmodel->textures[i];
        if (!texture || !texture->mark)
            continue;
        if (texture->name[0] != '*')
            continue;

        /* Set the viewport appropriately for the warp target texture size */
        if (gl_warpimagesize != texture->gl_warpimagesize) {
            gl_warpimagesize = texture->gl_warpimagesize;
            glViewport(glx, gly + glheight - gl_warpimagesize, gl_warpimagesize, gl_warpimagesize);
        }

        // Render warp
        GL_Bind(texture->gl_texturenum);
        glDrawElements(GL_TRIANGLES, numindices, GL_UNSIGNED_SHORT, indices);
        GL_Bind(texture->gl_warpimage);

        // Enable legacy generate mipmap parameter if available
        qglTexParameterGenerateMipmap(GL_TRUE);

        glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, glx, gly + glheight - gl_warpimagesize, gl_warpimagesize, gl_warpimagesize);

        // Regenerate mipmaps if extension is available
        qglGenerateMipmap(GL_TEXTURE_2D);

        texture->mark = 0;
    }

    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
}


//=========================================================
// Vertex/Fragment program version
//=========================================================

/*
From RMQ - I think written by MH?

OK, just so you know where these numbers come from, and so I don't get to waste another 2 hours calculating backwards...

From FitzQuake:

#define WARPCALC(s,t) ((s + turbsin[(int)((t*2)+(cl.time*(128.0/M_PI))) & 255]) * (1.0/64)) //johnfitz -- correct warp

Used when gl_subdivide_size is below a certain threahold.  Now, we warp per-pixel so we're always below, so we use this

Broken out, turbsin lookup replaced with sin and we get:

#define RDT (cl.time * (128 / M_PI))
#define BYTEANGLE (360.0 / 256.0)
#define ANGLERAD (M_PI / 180.0)
#define TIMEMULT (BYTEANGLE * ANGLERAD) // 0.02454369260617025967548940143187
#define WARPCALC(s, t) ((s + sin (((t * 2) + RDT) * TIMEMULT) * 8.0f) * (1.0 / 64))

vertex program.env[0].x stores RDT; this is optionally multiplied by a player-adjustable speed factor
vertex program.env[0].y stores 2, which is multiplied by t above; this is also player-adjustable
TIMEMULT is hardcoded in the vertex program to blah decimal places
fragment program.env[0].z stores 8.0f, also player-adjustable, brings -1...1 scale up to turbsin -8...8
1.0 / 64 is hard-coded in the fragment program to bring the final result back to the regular scale
*/

const char warp_vp_text[] =
    "!!ARBvp1.0\n"
    "\n"
    "ATTRIB pos0 = vertex.position;\n"
    "PARAM mat[4] = { state.matrix.mvp };\n"
    "PARAM params = program.env[0];\n"
    "\n"
    "# Transform by concatenation of the MODELVIEW and PROJECTION matrices.\n"
    "TEMP   pos;\n"
    "DP4    pos.x, mat[0], pos0;\n"
    "DP4    pos.y, mat[1], pos0;\n"
    "DP4    pos.z, mat[2], pos0;\n"
    "DP4    pos.w, mat[3], pos0;\n"
    "MOV    result.position, pos;\n"
    "MOV    result.fogcoord, pos.z;\n"
    "\n"
    "# Offset the primary texcoord by a factor of warpscale\n"
    "SUB result.texcoord[0], vertex.texcoord[0], program.env[0].z;\n"
    "\n"
    "# Offset the index into the lookup table by a factor of the time\n"
    "MAD result.texcoord[1], vertex.texcoord[1], program.env[0].y, program.env[0].x;\n"
    "END\n";

#define WARP_FP_BODY_TEXT                                         \
    "TEMP tc0, tc1;\n"                                            \
    "TEX tc0, fragment.texcoord[1], texture[1], 2D;\n"            \
    "MAD tc0, tc0, program.env[0].w, fragment.texcoord[0];\n"     \
    "TEX tc1, tc0, texture[0], 2D;\n"                             \
    "MUL result.color, tc1, program.env[1];\n"                    \
    "END\n"

const char warp_fp_text[] =
    "!!ARBfp1.0\n"
    WARP_FP_BODY_TEXT;

const char warp_fog_fp_text[] =
    "!!ARBfp1.0\n"
    "OPTION ARB_fog_exp2;\n"
    WARP_FP_BODY_TEXT;

/* This texture is to look up sin values in the fragment program */
texture_id_t r_warp_lookup_table;

static inline byte
GL_WarpSine(int num, int detail)
{
    float angle_in_radians = ((float)num / (float)detail) * M_TAU;
    float value = sinf(angle_in_radians); /* range -1..1 */
    value += 1.0f;                        /* range  0..2 */
    value *= 0.5f;                        /* range  0..1 */

    /* Quantize to byte range */
    return qclamp((int)(value * 255.0f), 0, 255);
}

void
GL_CreateWarpTableTexture()
{
#define WARP_DETAIL 32
    qpic32_t *pic = alloca(offsetof(qpic32_t, pixels[WARP_DETAIL * WARP_DETAIL]));
    pic->width = WARP_DETAIL;
    pic->height = WARP_DETAIL;

    qpixel32_t *pixel = pic->pixels;
    for (int y = 0; y < WARP_DETAIL; y++) {
        for (int x = 0; x < WARP_DETAIL; x++, pixel++) {
            pixel->c.red   = GL_WarpSine(y, WARP_DETAIL);
            pixel->c.green = GL_WarpSine(x, WARP_DETAIL);
            pixel->c.blue  = 0;
            pixel->c.alpha = 0;
        }
    }

    r_warp_lookup_table = GL_AllocTexture32(NULL, "@warptable", pic, TEXTURE_TYPE_DATA);
    GL_Upload32(r_warp_lookup_table, pic);
}
