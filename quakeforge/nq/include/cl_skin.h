/*
	cl_skin.h

	Client skin definitions

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

#ifndef _CL_SKIN_H
#define _CL_SKIN_H

#include "QF/qtypes.h"
#include "QF/skin.h"

void	CL_Skins_f (void);
void	CL_AllSkins_f (void);
void	Skin_NextDownload (void);
void	CL_Skin_Init (void);
void	CL_Skin_Init_Cvars (void);

#endif
