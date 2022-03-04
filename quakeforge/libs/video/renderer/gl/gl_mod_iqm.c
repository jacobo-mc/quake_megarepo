/*
	gl_mod_iqm.c

	GL IQM rendering

	Copyright (C) 2012 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2012/5/17

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#define NH_DEFINE
#include "namehack.h"

#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif
#include <stdlib.h>

#include "QF/cvar.h"
#include "QF/render.h"
#include "QF/skin.h"
#include "QF/sys.h"

#include "QF/GL/defines.h"
#include "QF/GL/funcs.h"
#include "QF/GL/qf_iqm.h"
#include "QF/GL/qf_rmain.h"
#include "QF/GL/qf_vid.h"

#include "r_internal.h"

//FIXME this is really lame: normals are ignored. also, it could be
//faster
static void
gl_draw_iqm_frame (iqm_t *iqm, gliqm_t *gl, iqmframe_t *frame, iqmmesh *mesh)
{
	byte       *vert;
	uint32_t    i, j;

	qfglBegin (GL_TRIANGLES);
	for (i = 0; i < mesh->num_triangles; i++) {
		int     vind = (mesh->first_triangle + i) * 3;
		for (j = 0; j < 3; j++) {
			vert = iqm->vertices + iqm->elements[vind + j] * iqm->stride;
			if (gl->texcoord)
				qfglTexCoord2fv ((float *) (vert + gl->texcoord->offset));
			if (gl->color)
				qfglColor4bv ((GLbyte *) (vert + gl->color->offset));
			if (gl->bindices) {
				vec3_t      position;
				uint32_t    bind = *(uint32_t *) (vert + gl->bindices->offset);
				vec_t      *f = (vec_t *) &frame[bind];
				float      *v = (float *) (vert + gl->position->offset);
				Mat4MultVec (f, v, position);
				qfglVertex3fv (position);
			} else {
				qfglVertex3fv ((float *) (vert + gl->position->offset));
			}
		}
	}
	qfglEnd ();
}

void
gl_R_DrawIQMModel (entity_t *ent)
{
	model_t    *model = ent->renderer.model;
	iqm_t      *iqm = (iqm_t *) model->aliashdr;
	gliqm_t    *gl = (gliqm_t *) iqm->extra_data;
	float       blend;
	iqmframe_t *frame;
	int         i;

	blend = R_IQMGetLerpedFrames (ent, iqm);
	frame = R_IQMBlendPalette (iqm, ent->animation.pose1, ent->animation.pose2,
							   blend, 0, gl->blend_palette, gl->palette_size);

	qfglPushMatrix ();
	gl_R_RotateForEntity (ent);

	for (i = 0; i < iqm->num_meshes; i++) {
		qfglBindTexture (GL_TEXTURE_2D, gl->textures[i]);
		gl_draw_iqm_frame (iqm, gl, frame, &iqm->meshes[i]);
	}
	qfglPopMatrix ();
}
