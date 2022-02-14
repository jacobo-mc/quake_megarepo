/*
    Copyright (C) 1996-1997  Id Software, Inc.
    Copyright (C) 1997       Greg Lewis

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

#ifndef QBSP_SOLIDBSP_HH
#define QBSP_SOLIDBSP_HH

#include <atomic>

extern std::atomic<int> splitnodes;

void DetailToSolid(node_t *node);
const char *GetContentsName( const contentflags_t &Contents );
void DivideFacet(face_t *in, qbsp_plane_t *split, face_t **front, face_t **back);
void CalcSurfaceInfo(surface_t *surf);
void SubdivideFace(face_t *f, face_t **prevptr);

#endif
