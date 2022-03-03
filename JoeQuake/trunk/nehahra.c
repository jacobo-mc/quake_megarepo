/*
Copyright (C) 2000	LordHavoc, Ender

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
// nehahra.c

#include "quakedef.h"
#include "winquake.h"
#ifndef _WIN32
#include <dlfcn.h>
#endif

int	NehGameType = 0;
static qboolean modplaying = false;

cvar_t	gl_fogenable = {"gl_fogenable", "0"};
cvar_t	gl_fogdensity = {"gl_fogdensity", "0.8"};
cvar_t	gl_fogred = {"gl_fogred","0.3"};
cvar_t	gl_fogblue = {"gl_fogblue","0.3"};
cvar_t	gl_foggreen = {"gl_foggreen","0.3"};

cvar_t	r_oldsky = {"r_oldsky", "1"};
char	prev_skybox[64];

cvar_t	r_nospr32 = {"nospr32", "0"};

// cutscene demo usage
cvar_t	nehx00 = {"nehx00", "0"};
cvar_t	nehx01 = {"nehx01", "0"};
cvar_t	nehx02 = {"nehx02", "0"};
cvar_t	nehx03 = {"nehx03", "0"};
cvar_t	nehx04 = {"nehx04", "0"};
cvar_t	nehx05 = {"nehx05", "0"};
cvar_t	nehx06 = {"nehx06", "0"};
cvar_t	nehx07 = {"nehx07", "0"};
cvar_t	nehx08 = {"nehx08", "0"};
cvar_t	nehx09 = {"nehx09", "0"};
cvar_t	nehx10 = {"nehx10", "0"};
cvar_t	nehx11 = {"nehx11", "0"};
cvar_t	nehx12 = {"nehx12", "0"};
cvar_t	nehx13 = {"nehx13", "0"};
cvar_t	nehx14 = {"nehx14", "0"};
cvar_t	nehx15 = {"nehx15", "0"};
cvar_t	nehx16 = {"nehx16", "0"};
cvar_t	nehx17 = {"nehx17", "0"};
cvar_t	nehx18 = {"nehx18", "0"};
cvar_t	nehx19 = {"nehx19", "0"};
cvar_t	cutscene = {"cutscene", "1"};

int	num_sfxorig;
void Neh_CheckMode (void);

void Neh_DoBindings (void)
{
	if (NehGameType == TYPE_DEMO)
	{
		Cbuf_AddText ("bind F1 \"cl_demospeed 0.4\"\n");
		Cbuf_AddText ("bind F2 \"cl_demospeed 0.6\"\n");
		Cbuf_AddText ("bind F3 \"cl_demospeed 0.8\"\n");
		Cbuf_AddText ("bind F4 \"cl_demospeed 1.0\"\n");
		Cbuf_AddText ("bind F5 \"cl_demospeed 1.4\"\n");
		Cbuf_AddText ("bind F6 \"cl_demospeed 1.6\"\n");
		Cbuf_AddText ("bind F7 \"cl_demospeed 1.8\"\n");
		Cbuf_AddText ("bind F8 \"cl_demospeed 2.0\"\n");
		Cbuf_AddText ("bind F9 \"cl_demospeed 2.4\"\n");
		Cbuf_AddText ("bind F10 \"cl_demospeed 2.6\"\n");

		Cbuf_AddText ("bind PAUSE pausedemo\n");
	}
}

void Neh_Init (void)
{
	Cvar_Register (&gl_fogenable);
	Cvar_Register (&gl_fogdensity);
	Cvar_Register (&gl_fogred);
	Cvar_Register (&gl_foggreen); 
	Cvar_Register (&gl_fogblue);

	Cvar_Register (&r_oldsky);
	Cvar_Register (&r_nospr32);

	// Nehahra uses these to pass data around cutscene demos
	Cvar_Register (&nehx00);
	Cvar_Register (&nehx01);
	Cvar_Register (&nehx02);
	Cvar_Register (&nehx03);
	Cvar_Register (&nehx04);
	Cvar_Register (&nehx05);
	Cvar_Register (&nehx06);
	Cvar_Register (&nehx07);
	Cvar_Register (&nehx08);
	Cvar_Register (&nehx09);
	Cvar_Register (&nehx10);
	Cvar_Register (&nehx11);
	Cvar_Register (&nehx12);
	Cvar_Register (&nehx13);
	Cvar_Register (&nehx14);
	Cvar_Register (&nehx15);
	Cvar_Register (&nehx16);
	Cvar_Register (&nehx17);
	Cvar_Register (&nehx18);
	Cvar_Register (&nehx19);
	Cvar_Register (&cutscene);

	Cvar_SetValue (&gl_hwblend, 0);

	Cmd_AddLegacyCommand ("pausedemo", "pause");

	Neh_CheckMode ();

	if (COM_CheckParm("-matrox"))
		r_nospr32.value = 1;
}

void Neh_SetupFrame (void)
{
	if (gl_fogenable.value)
	{
		float	colors[4] = {gl_fogred.value, gl_foggreen.value, gl_fogblue.value, 1};

		glFogi (GL_FOG_MODE, GL_EXP2);
		glFogf (GL_FOG_DENSITY, gl_fogdensity.value / 100);
		glFogfv (GL_FOG_COLOR, colors);
		glEnable (GL_FOG);
	}
	else
	{
		glDisable (GL_FOG);
	}
}

#define SHOWLMP_MAXLABELS	256
typedef struct showlmp_s
{
	qboolean	isactive;
	float		x, y;
	char		label[32];
	char		pic[128];
} showlmp_t;

showlmp_t	showlmp[SHOWLMP_MAXLABELS];

void SHOWLMP_decodehide (void)
{
	int	i;
	byte	*lmplabel;

	lmplabel = MSG_ReadString ();
	for (i=0 ; i<SHOWLMP_MAXLABELS ; i++)
	{
		if (showlmp[i].isactive && !strcmp(showlmp[i].label, lmplabel))
		{
			showlmp[i].isactive = false;
			return;
		}
	}
}

void SHOWLMP_decodeshow (void)
{
	int	i, k;
	byte	lmplabel[256], picname[256];
	float	x, y;

	strcpy (lmplabel, MSG_ReadString());
	strcpy (picname, MSG_ReadString());
	x = MSG_ReadByte ();
	y = MSG_ReadByte ();
	k = -1;
	for (i=0 ; i<SHOWLMP_MAXLABELS ; i++)
	{
		if (showlmp[i].isactive)
		{
			if (!strcmp(showlmp[i].label, lmplabel))
			{
				k = i;
				break;	// drop out to replace it
			}
		}
		else if (k < 0)	// find first empty one to replace
		{
			k = i;
		}
	}

	if (k < 0)
		return;	// none found to replace
	// change existing one
	showlmp[k].isactive = true;
	strcpy (showlmp[k].label, lmplabel);
	strcpy (showlmp[k].pic, picname);
	showlmp[k].x = x;
	showlmp[k].y = y;
}

void SHOWLMP_drawall (void)
{
	int	i;

	for (i=0 ; i<SHOWLMP_MAXLABELS ; i++)
		if (showlmp[i].isactive)
			Draw_TransPic (showlmp[i].x, showlmp[i].y, Draw_CachePic(showlmp[i].pic), true);
}

void SHOWLMP_clear (void)
{
	int	i;

	for (i=0 ; i<SHOWLMP_MAXLABELS ; i++)
		showlmp[i].isactive = false;
}

void Neh_CheckMode (void)
{
	qboolean	movieinstalled = false, gameinstalled = false;

	Con_Printf ("Beginning Nehahra check...\n");

// Check for movies
	if (COM_FindFile("hearing.dem") || COM_FindFile("hearing.dz"))
		movieinstalled = true;

	Con_Printf ("Found Movie...\n");

// Check for game
	if (COM_FindFile("maps/neh1m4.bsp"))
		gameinstalled = true;

	Con_Printf ("Found Game...\n");

	if (gameinstalled && movieinstalled)
	{
		NehGameType = TYPE_BOTH;             // mainmenu.lmp
		Con_Printf ("Running Both Movie and Game\n");
		return;
	}

	if (gameinstalled && !movieinstalled)
	{
		NehGameType = TYPE_GAME;             // gamemenu.lmp
		Con_Printf ("Running Game Nehahra\n");
		return;
	}

	if (!gameinstalled && movieinstalled)
	{
		NehGameType = TYPE_DEMO;             // demomenu.lmp
		Con_Printf ("Running Movie Nehahra\n");
		return;
	}

	Sys_Error ("You must specify the Nehahra game directory in -game!");
}
