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

#ifndef HOST_H
#define HOST_H

#include "qtypes.h"
#include "quakedef.h"
#include "server.h"
#include "wad.h"

// FIXME - some of this is out of place or badly named...

extern quakeparms_t host_parms;

extern cvar_t sys_ticrate;
extern cvar_t sys_nostdout;
extern cvar_t developer;

extern cvar_t host_framerate;
extern cvar_t host_speeds;
extern cvar_t serverprofile;
extern cvar_t samelevel;
extern cvar_t noexit;
extern cvar_t temp1;

extern int host_hunklevel;              // FIXME: probably should be an internal thing
extern qboolean host_initialized;	// true if into command execution
extern double host_frametime;
extern byte *host_basepal;
extern byte *host_colormap;
extern byte **host_transtables;

extern int host_framecount;	// incremented every frame, never reset
extern double realtime;		// not bounded in any way, changed at
				// start of every frame, never reset

void Host_ClearMemory(void);
void Host_ServerFrame(void);
void SV_AddOperatorCommands(void);

typedef const char *(*basedir_fn)();
void Host_Init(quakeparms_t *parms, basedir_fn *basedir_fns);

void Host_Shutdown(void);
void Host_Error(const char *error, ...) __attribute__((noreturn, format(printf,1,2)));
void Host_EndGame(const char *message, ...) __attribute__((noreturn, format(printf,1,2)));
void Host_Frame(float time);
void Host_Quit_f(void);
void Host_ClientCommands(client_t *client, const char *fmt, ...) __attribute__((format(printf,2,3)));
void Host_ShutdownServer(qboolean crash);

extern int current_skill;	// skill level for currently loaded level (in
				//  case the user changes the cvar while the
				//  level is running, this reflects the level
				//  actually in use)

extern qboolean isDedicated;

extern int minimum_memory;

#endif /* HOST_H */
