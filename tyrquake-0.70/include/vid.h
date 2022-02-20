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
// vid.h -- video driver defs

#ifndef VID_H
#define VID_H

#include "qtypes.h"
#include "cvar.h"
#include "keys.h"

#define VID_CBITS	6
#define VID_GRADES	(1 << VID_CBITS)

// TODO: Support more scaling options?
#define VID_MAX_SCALE 4

// a pixel can be one, two, or four bytes
typedef byte pixel_t;

typedef struct vrect_s {
    int x, y, width, height;
    struct vrect_s *pnext;
} vrect_t;

typedef struct {
    pixel_t *buffer;		// invisible buffer
    pixel_t *colormap;		// 256 * VID_GRADES size
    unsigned short *colormap16;	// 256 * VID_GRADES size
    int fullbright;		// index of first fullbright color
    int rowbytes;		// may be > width if displayed in a window
    int width;
    int height;
    float aspect;		// width / height -- < 0 is taller than wide
    int numpages;
    int recalc_refdef;		// if true, recalc vid-based stuff
    pixel_t *conbuffer;
    int conrowbytes;
    int conwidth;               // width of the console buffer in pixels
    int conheight;              // height of the console buffer in pixels
    pixel_t *direct;		// direct drawing to framebuffer, if not NULL
    qboolean stretchblit;       // True if the video driver supports arbitrary scaling blit
    struct {
        int scale;              // Integer scaling factor.  Zero implies abitrary scale to window width/height.
        int width;              // Output window resolution width/height
        int height;             // Video driver may or may not support different render/output resolution
    } output;
} viddef_t;

extern viddef_t vid;		// global video state
extern unsigned short d_8to16table[256];
extern unsigned d_8to24table[256];

/*
 * ------------------------------------------------------------------------
 * VIDEO MODES
 * ------------------------------------------------------------------------
 */

typedef struct render_resolution {
    int scale;
    int width;
    int height;
} render_resolution_t;

typedef struct qvidmode_s {
    int width;
    int height;
    int bpp;
    int refresh;
    int min_scale;
    render_resolution_t resolution;
    byte driverdata[8]; /* Allow drivers to stuff some data */
} qvidmode_t;

/* The vid driver will allocate the modelist as needed */
extern qvidmode_t vid_windowed_mode;
extern qvidmode_t *vid_modelist;
extern int vid_nummodes;
extern const qvidmode_t *vid_currentmode;

/* Config variables to save window position between runs */
extern cvar_t vid_window_x;
extern cvar_t vid_window_y;
extern cvar_t vid_window_centered;
extern cvar_t vid_window_remember_position;

/* Vsync */
extern qboolean vsync_available;
extern qboolean adaptive_vsync_available;
extern cvar_t vid_vsync;

enum vid_vsync_state {
    VSYNC_STATE_OFF,
    VSYNC_STATE_ON,
    VSYNC_STATE_ADAPTIVE,
};

void VID_Mode_RegisterVariables();
void VID_Mode_AddCommands();
void VID_Mode_SetupViddef(const qvidmode_t *mode, viddef_t *vid);
void VID_SortModeList(qvidmode_t *modelist, int nummodes);
const qvidmode_t *VID_GetCmdlineMode();
const qvidmode_t *VID_GetModeFromCvars();
void VID_LoadConfig();

/* Ask the vid driver for the desktop dimensions, to help with window positioning */
void VID_GetDesktopRect(vrect_t *rect);

void VID_MenuDraw(void);
void VID_MenuInitState(const qvidmode_t *mode);
void VID_MenuKey(knum_t keynum);
qboolean VID_SetMode(const qvidmode_t *mode, const byte *palette);
qboolean VID_CheckAdequateMem(int width, int height);

void VID_ProcessEvents();

extern void (*vid_menudrawfn)(void);
extern void (*vid_menukeyfn)(knum_t keynum);

/* ------------------------------------------------------------------------ */

void VID_SetPalette(const byte *palette);

// called at startup and after any gamma correction

void VID_ShiftPalette(const byte *palette);

// called for bonus and pain flashes, and for underwater color changes

extern unsigned short ramps[3][256];
extern void (*VID_SetGammaRamp)(unsigned short ramp[3][256]);

// called to set hardware gamma (if available - primarily for OpenGL renderer)

void VID_RegisterVariables();
void VID_AddCommands();
void VID_Init(const byte *palette);
void VID_InitColormap(const byte *palette);

// Called at startup to set up translation tables, takes 256 8 bit RGB values
// the palette data will go away after the call, so it must be copied off if
// the video driver will need it again

void VID_Shutdown(void);

// Called at shutdown

void VID_Update(vrect_t *rects);

// flushes the given rectangles from the view buffer to the screen

void VID_LockBuffer(void);
void VID_UnlockBuffer(void);

qboolean VID_IsFullScreen(void);
void VID_UpdateWindowPositionCvars(int x, int y);

#endif /* VID_H */
