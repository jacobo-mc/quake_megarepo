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
// vid_null.c -- null video driver to aid porting efforts

#include "common.h"
#include "d_local.h"
#include "quakedef.h"

#ifdef NQ_HACK
#include "host.h"
#endif

viddef_t vid;			// global video state

#define	BASEWIDTH	320
#define	BASEHEIGHT	200

byte vid_buffer[BASEWIDTH * BASEHEIGHT];
short zbuffer[BASEWIDTH * BASEHEIGHT];
byte surfcache[256 * 1024];

unsigned short d_8to16table[256];
unsigned d_8to24table[256];

void
VID_GetDesktopRect(vrect_t *rect)
{
    rect->x = 0;
    rect->y = 0;
    rect->width = 0;
    rect->height = 0;
}

void
VID_ShiftPalette(const byte *palette)
{
}

void
VID_SetPalette(const byte *palette)
{
}

void
VID_Init(const byte *palette)
{
    vid.width = vid.conwidth = BASEWIDTH;
    vid.height = vid.conheight = BASEHEIGHT;
    vid.aspect = 1.0;
    vid.numpages = 1;
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong(*((int *)vid.colormap + 2048));
    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = BASEWIDTH;

    d_pzbuffer = zbuffer;
    D_InitCaches(surfcache, sizeof(surfcache));
}

void
VID_InitColormap(const byte *palette)
{
}

void
VID_Shutdown(void)
{
}

void
VID_Update(vrect_t *rects)
{
}

/*
================
D_BeginDirectRect
================
*/
void
D_BeginDirectRect(int x, int y, const byte *pbitmap, int width, int height)
{
}


/*
================
D_EndDirectRect
================
*/
void
D_EndDirectRect(int x, int y, int width, int height)
{
}

qboolean
VID_CheckAdequateMem(int width, int height)
{
    return true;
}

void
VID_ProcessEvents()
{
}

void
VID_LockBuffer(void)
{
}

void
VID_UnlockBuffer(void)
{
}

void
VID_AddCommands()
{
}

void
VID_RegisterVariables()
{
}

qboolean
VID_SetMode(const qvidmode_t *mode, const byte *palette)
{
    return false;
}

void
VID_SetDefaultMode()
{
}

qboolean window_visible(void)
{
    return false;
}

#ifdef GLQUAKE
float gldepthmin, gldepthmax;
void *
GL_GetProcAddress(const char *name)
{
    return NULL;
}
#endif

#ifdef _WIN32
qboolean DDActive;
#endif
