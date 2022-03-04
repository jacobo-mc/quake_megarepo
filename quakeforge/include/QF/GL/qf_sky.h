/*
	qf_sky.h

	GL sky stuff from the renderer.

	Copyright (C) 1996-1997  Id Software, Inc.

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

#ifndef __QF_GL_sky_h
#define __QF_GL_sky_h

#include "QF/qtypes.h"
#include "QF/model.h"

#define SKY_TEX 2000	// Quake 2 environment sky

extern qboolean gl_skyloaded;
extern vec5_t gl_skyvec[6][4];

void R_DrawSky (void);
void R_DrawSkyChain (const instsurf_t *s);

#endif // __QF_GL_sky_h
