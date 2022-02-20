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

#ifndef SCREEN_H
#define SCREEN_H

#include "qtypes.h"
#include "cvar.h"
#include "render.h"
#include "vid.h"

// screen.h

void SCR_AddCommands();
void SCR_RegisterVariables();
void SCR_Init();

void SCR_CheckResize();
void SCR_UpdateScreen(void);
void SCR_UpdateWholeScreen(void);
void SCR_CenterPrint(const char *str);
void SCR_BeginLoadingPlaque(void);
void SCR_EndLoadingPlaque(void);
int SCR_ModalMessage(const char *text);
void SCR_CalcFOV(refdef_t *refdef, float fov);

extern float scr_con_current;
extern float scr_centertime_off;
extern int scr_fullupdate;	// set to 0 to force full redraw
extern int clearnotify;		// set to 0 whenever notify text is drawn
extern qboolean scr_disabled_for_loading;
extern qboolean scr_skipupdate;
extern qboolean scr_block_drawing;
extern cvar_t scr_viewsize;
extern cvar_t scr_fov;
extern cvar_t scr_sbaralpha;
extern vrect_t scr_vrect;

// only the refresh window will be updated unless these variables are flagged
extern int scr_copytop;
extern int scr_copyeverything;

extern float scr_scale; /* hud scaling factor */
extern int scr_scaled_width;
extern int scr_scaled_height;
extern float scr_conbackscale; /* The scaling applied to the console background */

static inline int SCR_Scale(int pixels)     { return (int)((float)pixels * scr_scale); }
static inline int SCR_ScaleCoord(int coord) { return (int)((float)coord  / scr_scale + 0.5f); }

#endif /* SCREEN_H */
