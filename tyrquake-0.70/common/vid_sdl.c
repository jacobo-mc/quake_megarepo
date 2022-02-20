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

#include <stdlib.h>

#include "SDL.h"

#include "cdaudio.h"
#include "cmd.h"
#include "common.h"
#include "console.h"
#include "cvar.h"
#include "d_iface.h"
#include "d_local.h"
#include "draw.h"
#include "input.h"
#include "keys.h"
#include "menu.h"
#include "quakedef.h"
#include "screen.h"
#include "sdl_common.h"
#include "sound.h"
#include "sys.h"
#include "vid.h"
#include "view.h"
#include "wad.h"

#ifdef _WIN32
#include "winquake.h"
#endif

#ifdef NQ_HACK
#include "host.h"
#endif
#ifdef QW_HACK
#include "client.h"
#endif

// FIXME: evil hack to get full DirectSound support with SDL
#ifdef _WIN32
#include <windows.h>
HWND mainwindow;
qboolean DDActive = false;
#endif

static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;
static SDL_PixelFormat *sdl_format = NULL;

/* ------------------------------------------------------------------------- */

static byte *vid_surfcache;
static int vid_surfcachesize;
static int VID_highhunkmark;

unsigned short d_8to16table[256];
unsigned d_8to24table[256];
viddef_t vid; /* global video state */

void
VID_GetDesktopRect(vrect_t *rect)
{
    int display;
    SDL_DisplayMode mode;

    display = SDL_GetWindowDisplayIndex(sdl_window);
    SDL_GetDesktopDisplayMode(display, &mode);

    rect->x = 0;
    rect->y = 0;
    rect->width = mode.w;
    rect->height = mode.h;
}

void VID_Shutdown(void)
{
    if (renderer)
	SDL_DestroyRenderer(renderer);
    if (sdl_window)
	SDL_DestroyWindow(sdl_window);
    if (sdl_format)
	SDL_FreeFormat(sdl_format);
    if (sdl_desktop_format)
	SDL_FreeFormat(sdl_desktop_format);
}

static qboolean palette_changed;

void
VID_ShiftPalette(const byte *palette)
{
    VID_SetPalette(palette);
}

void VID_SetDefaultMode(void) { }

static qboolean Minimized;

qboolean
window_visible(void)
{
    return !Minimized;
}

/*
====================
VID_CheckAdequateMem
====================
*/
qboolean
VID_CheckAdequateMem(int width, int height)
{
    int tbuffersize;

    tbuffersize = width * height * sizeof(*d_pzbuffer);
    tbuffersize += D_SurfaceCacheForRes(width, height);

    /*
     * see if there's enough memory, allowing for the normal mode 0x13 pixel,
     * z, and surface buffers
     */
    if ((host_parms.memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 +
	 0x10000 * 3) < minimum_memory)
	return false;

    return true;
}


/*
================
VID_AllocBuffers
================
*/
static qboolean
VID_AllocBuffers(int width, int height)
{
    int tsize, tbuffersize;

    tsize = D_SurfaceCacheForRes(width, height);
    tbuffersize = width * height * sizeof(*d_pzbuffer);
    tbuffersize += tsize;

    /*
     * see if there's enough memory, allowing for the normal mode 0x13 pixel,
     * z, and surface buffers
     */
    if ((host_parms.memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 +
	 0x10000 * 3) < minimum_memory) {
	Con_SafePrintf("Not enough memory for video mode\n");
	return false;
    }

    vid_surfcachesize = tsize;

    if (d_pzbuffer) {
	D_FlushCaches();
	Hunk_FreeToHighMark(VID_highhunkmark);
	d_pzbuffer = NULL;
    }

    VID_highhunkmark = Hunk_HighMark();
    d_pzbuffer = Hunk_HighAllocName(tbuffersize, "video");
    vid_surfcache = (byte *)d_pzbuffer + width * height * sizeof(*d_pzbuffer);
    r_warpbuffer = Hunk_HighAllocName(width * height, "warpbuf");

    // In-memory buffer which we upload via SDL texture
    vid.buffer = vid.conbuffer = vid.direct = Hunk_HighAllocName(vid.width * vid.height, "vidbuf");
    vid.rowbytes = vid.conrowbytes = vid.width;

    R_AllocSurfEdges(false);

    return true;
}

void
VID_InitColormap(const byte *palette)
{
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong(*((int *)vid.colormap + 2048));
}

qboolean
VID_SetMode(const qvidmode_t *mode, const byte *palette)
{
    Uint32 flags;
    qboolean mouse_grab;
    const qvidformat_t *format;

    /* FIXME - hack to reset mouse grabs */
    mouse_grab = _windowed_mouse.value;
    if (mouse_grab) {
	_windowed_mouse.value = 0;
	_windowed_mouse.callback(&_windowed_mouse);
    }

    flags = SDL_WINDOW_SHOWN;
    if (mode != &vid_windowed_mode)
	flags |= SDL_WINDOW_FULLSCREEN;

    if (renderer)
	SDL_DestroyRenderer(renderer);
    if (sdl_window)
	SDL_DestroyWindow(sdl_window);
    if (sdl_format)
	SDL_FreeFormat(sdl_format);

    format = (const qvidformat_t *)mode->driverdata;
    sdl_format = SDL_AllocFormat(format->format);

    sdl_window = SDL_CreateWindow("TyrQuake",
				  SDL_WINDOWPOS_UNDEFINED,
				  SDL_WINDOWPOS_UNDEFINED,
				  mode->width, mode->height, flags);
    if (!sdl_window)
	Sys_Error("%s: Unable to create window: %s", __func__, SDL_GetError());

    flags = vid_vsync.value ? SDL_RENDERER_PRESENTVSYNC : 0;
    renderer = SDL_CreateRenderer(sdl_window, -1, flags);
    if (!renderer && flags)
        renderer = SDL_CreateRenderer(sdl_window, -1, 0);
    if (!renderer)
	Sys_Error("%s: Unable to create renderer: %s", __func__, SDL_GetError());

    /* Update vsync availability info based on renderer returned */
    if (flags & SDL_RENDERER_PRESENTVSYNC) {
        SDL_RendererInfo renderer_info;
        SDL_GetRendererInfo(renderer, &renderer_info);
        vsync_available = !!(renderer_info.flags & SDL_RENDERER_PRESENTVSYNC);
    }

    texture = SDL_CreateTexture(renderer,
				format->format,
				SDL_TEXTUREACCESS_STREAMING,
				mode->width, mode->height);
    if (!texture)
	Sys_Error("%s: Unable to create texture: %s", __func__, SDL_GetError());

    VID_SDL_SetIcon();
    //VID_InitGamma(palette);
    VID_SetPalette(palette);
    VID_InitColormap(palette);

    VID_Mode_SetupViddef(mode, &vid);

    vid.numpages = 1;
    vid.aspect = 1;//((float)vid.height / (float)vid.width) * (320.0 / 240.0);

    VID_AllocBuffers(vid.width, vid.height);

    D_InitCaches(vid_surfcache, vid_surfcachesize);

    vid_currentmode = mode;

    vid.recalc_refdef = 1;

    SCR_CheckResize();
    Con_CheckResize();

    /* FIXME - hack to reset mouse grabs */
    if (mouse_grab) {
	_windowed_mouse.value = 1;
	_windowed_mouse.callback(&_windowed_mouse);
    }

    Cvar_SetValue("vid_fullscreen", mode != &vid_windowed_mode);
    Cvar_SetValue("vid_width", mode->width);
    Cvar_SetValue("vid_height", mode->height);
    Cvar_SetValue("vid_bpp", mode->bpp);
    Cvar_SetValue("vid_refreshrate", mode->refresh);

    return true;
}

/* ------------------------------------------------------------------------- */

void
VID_SetPalette(const byte *palette)
{
    unsigned i, r, g, b;

    switch (SDL_PIXELTYPE(sdl_format->format)) {
    case SDL_PIXELTYPE_PACKED32:
	for (i = 0; i < 256; i++) {
	    r = palette[0];
	    g = palette[1];
	    b = palette[2];
	    palette += 3;
	    d_8to24table[i] = SDL_MapRGB(sdl_format, r, g, b);
	}
	break;
    case SDL_PIXELTYPE_PACKED16:
	for (i = 0; i < 256; i++) {
	    r = palette[0];
	    g = palette[1];
	    b = palette[2];
	    palette += 3;
	    d_8to16table[i] = SDL_MapRGB(sdl_format, r, g, b);
	}
	break;
    default:
	Sys_Error("%s: unsupported pixel format (%s)", __func__,
		  SDL_GetPixelFormatName(sdl_format->format));
    }

    palette_changed = true;
}

void
VID_ProcessEvents()
{
    SDL_Event event;

    while (SDL_PollEvent(&event)) {
	switch (event.type) {
            case SDL_WINDOWEVENT:
                switch (event.window.event) {
                    case SDL_WINDOWEVENT_FOCUS_GAINED:
                    case SDL_WINDOWEVENT_FOCUS_LOST:
                        IN_SDL_HandleEvent(&event);
                        break;
                }
                break;
            case SDL_KEYDOWN:
            case SDL_KEYUP:
            case SDL_MOUSEBUTTONDOWN:
            case SDL_MOUSEBUTTONUP:
            case SDL_MOUSEWHEEL:
            case SDL_MOUSEMOTION:
                IN_SDL_HandleEvent(&event);
                break;
            case SDL_QUIT:
                Sys_Quit();
                break;
            default:
                break;
        }
    }
}

void
VID_RegisterVariables()
{
}

void
VID_AddCommands()
{
}

void
VID_Init(const byte *palette)
{
    int err;
    const qvidmode_t *mode;

    /*
     * Init SDL and the video subsystem
     */
    Q_SDL_InitOnce();
    err = SDL_InitSubSystem(SDL_INIT_VIDEO);
    if (err < 0)
	Sys_Error("VID: Couldn't load SDL: %s", SDL_GetError());

    VID_SDL_InitModeList();
    VID_LoadConfig();
    mode = VID_GetCmdlineMode();
    if (!mode)
        mode = VID_GetModeFromCvars();
    if (!mode)
	mode = &vid_windowed_mode;

    VID_SetMode(mode, palette);

    vid_menudrawfn = VID_MenuDraw;
    vid_menukeyfn = VID_MenuKey;

    /* Assume vsync is available, we will set false if enable fails */
    vsync_available = true;
}

static void
VID_SDL_BlitRect(int x, int y, int width, int height)
{
    const float hscale = (float)vid.output.width / (float)vid.width;
    const float vscale = (float)vid.output.height / (float)vid.height;

    SDL_Rect src_rect = { x, y, width, height };
    SDL_Rect dst_rect = { x * hscale, y * vscale, width * hscale, height * vscale };
    int err = SDL_RenderCopy(renderer, texture, &src_rect, &dst_rect);
    if (err)
	Sys_Error("%s: unable to render texture (%s)", __func__, SDL_GetError());
    SDL_RenderPresent(renderer);
}

void
VID_Update(vrect_t *rects)
{
    int i;
    vrect_t *rect;
    vrect_t fullrect;
    byte *src;
    void *dst;
    Uint32 *dst32;
    Uint16 *dst16;
    int pitch;
    int height;
    int err;

    /*
     * If the palette changed, refresh the whole screen
     */
    if (palette_changed) {
	palette_changed = false;
	fullrect.x = 0;
	fullrect.y = 0;
	fullrect.width = vid.width;
	fullrect.height = vid.height;
	fullrect.pnext = NULL;
	rects = &fullrect;
    }

    SDL_Rect lock_rect = { 0, 0, vid.width, vid.height };
    err = SDL_LockTexture(texture, &lock_rect, (void **)&dst, &pitch);
    if (err)
        Sys_Error("%s: unable to lock texture (%s)",
                  __func__, SDL_GetError());

    for (rect = rects; rect; rect = rect->pnext) {
	src = vid.buffer + rect->y * vid.width + rect->x;
	height = rect->height;
	switch (SDL_PIXELTYPE(sdl_format->format)) {
	case SDL_PIXELTYPE_PACKED32:
	    dst32 = dst;
	    while (height--) {
		for (i = 0; i < rect->width; i++)
		    dst32[i] = d_8to24table[src[i]];
		dst32 += pitch / sizeof(*dst32);
		src += vid.width;
	    }
	    break;
	case SDL_PIXELTYPE_PACKED16:
	    dst16 = dst;
	    while (height--) {
		for (i = 0; i < rect->width; i++)
		    dst16[i] = d_8to16table[src[i]];
		dst16 += pitch / sizeof(*dst16);
		src += vid.width;
	    }
	    break;
	default:
	    Sys_Error("%s: unsupported pixel format (%s)", __func__,
		      SDL_GetPixelFormatName(sdl_format->format));
	}
    }
    SDL_UnlockTexture(texture);
    VID_SDL_BlitRect(0, 0, vid.width, vid.height);
}

void
D_BeginDirectRect(int x, int y, const byte *pbitmap, int width, int height)
{
    int err, i;
    const byte *src;
    unsigned *dst;
    int pitch;
    SDL_Rect subrect;

    if (!texture || !renderer)
	return;

    subrect.x = (x < 0) ? vid.width + x - 1 : x;
    subrect.y = y;
    subrect.w = width;
    subrect.h = height;

    err = SDL_LockTexture(texture, &subrect, (void **)&dst, &pitch);
    if (err)
	Sys_Error("%s: unable to lock texture (%s)", __func__, SDL_GetError());
    src = pbitmap;
    while (height--) {
	for (i = 0; i < width; i++)
	    dst[i] = d_8to24table[src[i]];
	dst += pitch / sizeof(*dst);
	src += width;
    }
    SDL_UnlockTexture(texture);
    VID_SDL_BlitRect(x, y, width, height);
}

void
D_EndDirectRect(int x, int y, int width, int height)
{
    int err, i;
    byte *src;
    unsigned *dst;
    int pitch;
    SDL_Rect subrect;

    if (!texture || !renderer)
	return;

    subrect.x = (x < 0) ? vid.width + x - 1 : x;
    subrect.y = y;
    subrect.w = width;
    subrect.h = height;

    err = SDL_LockTexture(texture, &subrect, (void **)&dst, &pitch);
    if (err)
	Sys_Error("%s: unable to lock texture (%s)", __func__, SDL_GetError());
    src = vid.buffer + y * vid.width + subrect.x;
    while (height--) {
	for (i = 0; i < width; i++)
	    dst[i] = d_8to24table[src[i]];
	dst += pitch / sizeof(*dst);
	src += vid.width;
    }
    SDL_UnlockTexture(texture);
    VID_SDL_BlitRect(x, y, width, height);
}

void
VID_LockBuffer(void)
{
}

void
VID_UnlockBuffer(void)
{
}

#ifndef _WIN32
void
Sys_SendKeyEvents(void)
{
    VID_ProcessEvents();
}
#endif
