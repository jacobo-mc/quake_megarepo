/*
 * host.h -- public host structures and functions
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#if defined(SERVERONLY)
#error "this header is for hw client only"
#endif	/* SERVERONLY */

#ifndef HX2_HOST_H
#define HX2_HOST_H

// quakeparms structure specifies the base of the directory tree, the
// command line parms passed to the program, and the amount of memory
// available for the program to use

typedef struct quakeparms_s
{
	const char *basedir;
	const char *userdir;	// user's directory on UNIX platforms.
				// if user directories are enabled, basedir
				// and userdir will point to different
				// memory locations, otherwise to the same.
	int	argc;
	char	**argv;
	void	*membase;
	int	memsize;
	int	errstate;
} quakeparms_t;


extern	quakeparms_t	*host_parms;

#define	isDedicated	0	/* compatibility */

extern	cvar_t		sys_ticrate;
extern	cvar_t		sys_throttle;
extern	cvar_t		sys_nostdout;
extern	cvar_t		developer;

extern	cvar_t		password;
extern	cvar_t		talksounds;

extern	qboolean	host_initialized;	// true if into command execution
extern	double		host_frametime;
extern	byte		*host_basepal;
extern	byte		*host_colormap;
extern	int		host_framecount;	// incremented every frame, never reset
extern	double		realtime;		// not bounded in any way, changed at
						// start of every frame, never reset

void Host_Init (void);
void Host_InitCommands (void);
void Host_Shutdown(void);
/* Host_Error and Host_EndGame doesn't return either due to Sys_Error() or longjmp() */
FUNC_NORETURN void Host_Error (const char *error, ...) FUNC_PRINTF(1,2);
FUNC_NORETURN void Host_EndGame (const char *message, ...) FUNC_PRINTF(1,2);
#ifdef __WATCOMC__
#pragma aux Host_Error aborts;
#pragma aux Host_EndGame aborts;
#endif
void Host_Frame (float time);
void Host_Quit_f (void);
void Host_ClientCommands (const char *fmt, ...) FUNC_PRINTF(1,2);
void Host_ShutdownServer (qboolean crash);
void Host_WriteConfiguration (const char *fname);

#endif	/* HX2_HOST_H */

