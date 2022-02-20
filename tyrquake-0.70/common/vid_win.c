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
// vid_win.c -- Win32 video driver

#include <windows.h>
#include <mmsystem.h>
#include <ddraw.h>

#include "cdaudio.h"
#include "cmd.h"
#include "common.h"
#include "console.h"
#include "d_local.h"
#include "draw.h"
#include "input.h"
#include "keys.h"
#include "menu.h"
#include "quakedef.h"
#include "resource.h"
#include "screen.h"
#include "sound.h"
#include "sys.h"
#include "vid.h"
#include "view.h"
#include "wad.h"
#include "winquake.h"

#ifdef NQ_HACK
#include "host.h"
#endif
#ifdef QW_HACK
#include "client.h"
#endif

static qboolean Minimized;

qboolean
window_visible(void)
{
    return !Minimized;
}

#define Q_WS_FULLSCREEN (WS_POPUP | WS_SYSMENU | WS_CLIPSIBLINGS | WS_CLIPCHILDREN)
#define Q_WS_WINDOWED (WS_OVERLAPPED | WS_BORDER | WS_CAPTION | WS_SYSMENU | \
                       WS_MINIMIZEBOX | WS_MAXIMIZEBOX | \
                       WS_CLIPSIBLINGS | WS_CLIPCHILDREN)

HWND mainwindow = NULL;
qboolean DDActive;
viddef_t vid; /* global video state */

static HDC maindc = NULL;

static HDC hdcDIBSection = NULL;
static HGDIOBJ previously_selected_GDI_obj = NULL;
static HBITMAP hDIBSection;
static unsigned char *pDIBBase = NULL;

static HICON hIcon;
static DEVMODE gdevmode;
static qboolean vid_initialized = false;
static modestate_t modestate = MS_UNINIT;

static qboolean windowed_mode_set = false;

static int firstupdate = 1;
static qboolean vid_palettized;
static const qvidmode_t *vid_fulldib_on_focus_mode;
static qboolean force_minimized, in_mode_set;
static qboolean palette_changed;
static qboolean hide_window;

static byte *vid_surfcache;
static int vid_surfcachesize;
static int VID_highhunkmark;
static byte vid_curpal[256 * 3];

unsigned short d_8to16table[256];
unsigned d_8to24table[256];

static byte backingbuf[48 * 24];

static void AppActivate(BOOL fActive, BOOL minimize);
static LONG WINAPI MainWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static HINSTANCE DDrawLibrary;
static struct IDirectDraw *pDDraw;

static qboolean
VID_InitDDraw()
{
    HRESULT hr;

    assert(!DDrawLibrary);
    assert(!pDDraw);

    DDrawLibrary = LoadLibrary("ddraw.dll");
    if (!DDrawLibrary) {
        Con_SafePrintf("Unable to load ddraw.dll\n");
        return false;
    }

    HRESULT (WINAPI *pDirectDrawCreate)(GUID *, LPDIRECTDRAW *, IUnknown *);
    pDirectDrawCreate = (void *)GetProcAddress(DDrawLibrary, "DirectDrawCreate");
    if (!pDirectDrawCreate) {
        Con_SafePrintf("Unable to load DirectDrawCreate function\n");
        return false;
    }

    hr = pDirectDrawCreate(NULL, &pDDraw, NULL);
    if (hr != DD_OK) {
        Con_SafePrintf("Failed to create DirectDraw instance\n");
        return false;
    }

    hr = IDirectDraw_WaitForVerticalBlank(pDDraw, DDWAITVB_BLOCKBEGIN, 0);
    vsync_available = (hr == DD_OK);

    return true;
}

static void
VID_ShutdownDDraw()
{
    if (pDDraw) {
        IDirectDraw_Release(pDDraw);
        pDDraw = NULL;
    }

    if (DDrawLibrary) {
        FreeLibrary(DDrawLibrary);
        DDrawLibrary = 0;
    }
}


void
VID_GetDesktopRect(vrect_t *rect)
{
    RECT workarea;
    BOOL ret;

    ret = SystemParametersInfo(SPI_GETWORKAREA, 0, &workarea, 0);
    if (!ret)
	Sys_Error("%s: SPI_GETWORKAREA failed", __func__);

    rect->x = 0;
    rect->y = 0;
    rect->width = workarea.right - workarea.left;
    rect->height = workarea.bottom - workarea.top;
}

static void
VID_SetWindowPos(HWND window, int x, int y)
{
    RECT windowRect;
    UINT flags;
    int width, height;

    flags = SWP_NOSIZE | SWP_NOZORDER | SWP_SHOWWINDOW | SWP_DRAWFRAME;
    SetWindowPos(window, NULL, x, y, 0, 0, flags);

    /* Update position cvars */
    VID_UpdateWindowPositionCvars(windowRect.left, windowRect.top);

    /* Update the input rect */
    GetWindowRect(window, &windowRect);
    width = windowRect.right - windowRect.left;
    height = windowRect.bottom - windowRect.top;
    IN_UpdateWindowRect(windowRect.left, windowRect.top, width, height);
}

static void
VID_CenterWindow(HWND window)
{
    RECT windowRect;
    vrect_t workarea;
    int x, y, window_width, window_height;

    VID_GetDesktopRect(&workarea);
    GetWindowRect(window, &windowRect);

    window_width = windowRect.right - windowRect.left;
    window_height = windowRect.bottom - windowRect.top;

    /* Center within the workarea. If too large, justify top left. */
    x = qmax(workarea.x + (workarea.width - window_width) / 2, 0);
    y = qmax(workarea.y + (workarea.height - window_height) / 2, 0);

    VID_SetWindowPos(window, x, y);
}

static void
VID_ShutdownDIB()
{
    if (hdcDIBSection) {
	SelectObject(hdcDIBSection, previously_selected_GDI_obj);
	DeleteDC(hdcDIBSection);
	hdcDIBSection = NULL;
    }
    if (hDIBSection) {
	DeleteObject(hDIBSection);
	hDIBSection = NULL;
	pDIBBase = NULL;
    }
    if (maindc) {
	// if maindc exists mainwindow must also be valid
	ReleaseDC(mainwindow, maindc);
	maindc = NULL;
    }
}

static void
VID_CreateDIB(int width, int height, const byte *palette)
{
    struct {
	BITMAPINFOHEADER header;
	RGBQUAD acolors[256];
    } dibheader;
    BITMAPINFO *pbmiDIB = (BITMAPINFO *)&dibheader;
    int i;

    maindc = GetDC(mainwindow);
    memset(&dibheader, 0, sizeof(dibheader));

    // fill in the bitmap info
    pbmiDIB->bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    pbmiDIB->bmiHeader.biWidth = width;
    pbmiDIB->bmiHeader.biHeight = height;
    pbmiDIB->bmiHeader.biPlanes = 1;
    pbmiDIB->bmiHeader.biBitCount = 8;
    pbmiDIB->bmiHeader.biCompression = BI_RGB;
    pbmiDIB->bmiHeader.biSizeImage = 0;
    pbmiDIB->bmiHeader.biXPelsPerMeter = 0;
    pbmiDIB->bmiHeader.biYPelsPerMeter = 0;
    pbmiDIB->bmiHeader.biClrUsed = 256;
    pbmiDIB->bmiHeader.biClrImportant = 256;

    // fill in the palette
    for (i = 0; i < 256; i++) {
	// d_8to24table isn't filled in yet so this is just for testing
	dibheader.acolors[i].rgbRed   = palette[i * 3];
	dibheader.acolors[i].rgbGreen = palette[i * 3 + 1];
	dibheader.acolors[i].rgbBlue  = palette[i * 3 + 2];
    }

    // create the DIB section
    hDIBSection = CreateDIBSection(maindc, pbmiDIB, DIB_RGB_COLORS, (void **)&pDIBBase, NULL, 0);

    // set video buffers
    if (pbmiDIB->bmiHeader.biHeight > 0) {
	// bottom up
	vid.buffer = pDIBBase + (height - 1) * width;
	vid.rowbytes = -width;
    } else {
	// top down
	vid.buffer = pDIBBase;
	vid.rowbytes = vid.width;
    }

    /*
     * set the rest of the buffers we need (why not just use one
     * single buffer instead of all this crap? oh well, it's Quake...)
     */
    vid.conbuffer = vid.direct = vid.buffer;

    // more crap for the console
    vid.conrowbytes = vid.rowbytes;

    // clear the buffer
    memset(pDIBBase, 0xff, width * height);

    hdcDIBSection = CreateCompatibleDC(maindc);
    if (!hdcDIBSection)
	Sys_Error("%s: CreateCompatibleDC failed\n", __func__);

    previously_selected_GDI_obj = SelectObject(hdcDIBSection, hDIBSection);
    if (!previously_selected_GDI_obj)
	Sys_Error("%s: SelectObject failed\n", __func__);
}

/*
================
ClearAllStates
================
*/
static void
ClearAllStates(void)
{
    Key_ClearAllStates();
    IN_ClearStates();
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
    if ((host_parms.memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 + 0x10000 * 3) < minimum_memory)
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
    if ((host_parms.memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 + 0x10000 * 3) < minimum_memory) {
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
    if (vid.rowbytes < 0) {
        /* Deal with case where we get a bottom up DIBSection */
        r_warpbuffer += (height - 1) * width;
    }
    R_AllocSurfEdges(false);

    return true;
}

static void
VID_InitWindowClass(HINSTANCE hInstance)
{
    WNDCLASS wc;

    hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON2));

    /* Register the frame class */
    wc.style = CS_OWNDC;
    wc.lpfnWndProc = (WNDPROC)MainWndProc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = hInstance;
    wc.hIcon = 0;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = NULL;
    wc.lpszMenuName = 0;
    wc.lpszClassName = "TyrQuake";

    if (!RegisterClass(&wc))
	Sys_Error("Couldn't register window class");
}

/*
=================
VID_InitModeList
=================
*/
static void
VID_InitModeList(void)
{
    DEVMODE devmode;
    DWORD testmodenum;
    LONG result;
    BOOL success;
    qvidmode_t *mode;

    /*
     * FIXME - work out why this is needed to fix sound... obviously
     * it's a problem that we block updates while testing for
     * available modes... but why?
     */
    S_BlockSound();
    S_ClearBuffer();

    /* Query the desktop mode */
    memset(&devmode, 0, sizeof(devmode));
    devmode.dmSize = sizeof(devmode);
    success = EnumDisplaySettings(NULL, ENUM_REGISTRY_SETTINGS, &devmode);
    if (!success)
	Sys_Error("Unable to query desktop display settings");

    /* Setup the default windowed mode */
    mode = &vid_windowed_mode;
    mode->width = 640;
    mode->height = 480;
    mode->min_scale = 1;
    mode->resolution.scale = 1;
    mode->resolution.width = mode->width;
    mode->resolution.height = mode->height;
    mode->bpp = devmode.dmBitsPerPel;
    mode->refresh = devmode.dmDisplayFrequency;

    int mark = Hunk_LowMark();
    vid_modelist = Hunk_AllocName(0, "vidmodes");
    vid_nummodes = 0;

    testmodenum = 0;
    for (;;) {
	memset(&devmode, 0, sizeof(devmode));
	devmode.dmSize = sizeof(devmode);
	success = EnumDisplaySettings(NULL, testmodenum++, &devmode);
	if (!success)
	    break;
	if (devmode.dmPelsWidth < 640 || devmode.dmPelsHeight < 480)
	    continue;
	if (devmode.dmBitsPerPel < 15)
	    continue;

        int scale = 1;
        while (scale <= VID_MAX_SCALE) {
            if (devmode.dmPelsWidth / scale <= MAXWIDTH && devmode.dmPelsHeight / scale <= MAXHEIGHT)
                break;
            scale <<= 1;
        }
        if (scale > VID_MAX_SCALE)
            continue;

	devmode.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY;
	result = ChangeDisplaySettings(&devmode, CDS_TEST | CDS_FULLSCREEN);
	if (result != DISP_CHANGE_SUCCESSFUL)
	    continue;

        Hunk_AllocExtend(vid_modelist, sizeof(qvidmode_t));
        mode = &vid_modelist[vid_nummodes++];
	mode->width = devmode.dmPelsWidth;
	mode->height = devmode.dmPelsHeight;
        mode->min_scale = scale;
        mode->resolution.scale = scale;
        mode->resolution.width = mode->width / scale;
        mode->resolution.height = mode->height / scale;
	mode->bpp = devmode.dmBitsPerPel;
	mode->refresh = devmode.dmDisplayFrequency;
    }

    /* Move the modelist to the high hunk memory */
    qvidmode_t *copy = Hunk_HighAllocName(vid_nummodes * sizeof(*vid_modelist), "vidmodes");
    memcpy(copy, vid_modelist, vid_nummodes * sizeof(*vid_modelist));
    vid_modelist = copy;
    Hunk_FreeToLowMark(mark);

    if (!vid_nummodes)
	Con_SafePrintf("No fullscreen DIB modes found\n");

    S_UnblockSound();
}

/*
 * VID_SetDisplayMode
 * Pass NULL to restore desktop resolution
 */
static void
VID_SetDisplayMode(const qvidmode_t *mode)
{
    LONG result;

    if (!mode) {
	if (modestate == MS_FULLSCREEN)
	    ChangeDisplaySettings(NULL, CDS_FULLSCREEN);
	modestate = MS_WINDOWED;
	return;
    }

    memset(&gdevmode, 0, sizeof(gdevmode));
    gdevmode.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;
    gdevmode.dmFields |= DM_BITSPERPEL | DM_DISPLAYFREQUENCY;
    gdevmode.dmPelsWidth = mode->width;
    gdevmode.dmPelsHeight = mode->height;
    gdevmode.dmBitsPerPel = mode->bpp;
    gdevmode.dmDisplayFrequency = mode->refresh;
    gdevmode.dmSize = sizeof(gdevmode);

    result = ChangeDisplaySettings(&gdevmode, CDS_FULLSCREEN);
    if (result != DISP_CHANGE_SUCCESSFUL)
	Sys_Error("Couldn't set fullscreen DIB mode");

    modestate = MS_FULLSCREEN;
    vid_fulldib_on_focus_mode = mode;
}

static qboolean
VID_SetWindowedMode(const qvidmode_t *mode)
{
    RECT windowRect;

    if (!windowed_mode_set) {
	if (COM_CheckParm("-resetwinpos"))
            VID_UpdateWindowPositionCvars(0, 0);
	windowed_mode_set = true;
    }

    VID_ShutdownDIB();
    VID_SetDisplayMode(NULL);

    windowRect.top = 0;
    windowRect.left = 0;
    windowRect.right = mode->width;
    windowRect.bottom = mode->height;
    AdjustWindowRectEx(&windowRect, Q_WS_WINDOWED, FALSE, 0);

    SetWindowLong(mainwindow, GWL_STYLE, Q_WS_WINDOWED | WS_VISIBLE);
    SetWindowLong(mainwindow, GWL_EXSTYLE, 0);

    if (!SetWindowPos(mainwindow, NULL, 0, 0,
		      windowRect.right - windowRect.left,
		      windowRect.bottom - windowRect.top,
		      SWP_NOCOPYBITS | SWP_NOZORDER | SWP_HIDEWINDOW)) {
	Sys_Error("Couldn't resize window");
    }

    if (hide_window)
	return true;

    /* Position and show the window */
    if (vid_window_centered.value) {
        VID_CenterWindow(mainwindow);
    } else if (vid_window_remember_position.value) {
        VID_SetWindowPos(mainwindow, (int)vid_window_x.value, (int)vid_window_y.value);
    }

    if (force_minimized)
	ShowWindow(mainwindow, SW_MINIMIZE);
    else
	ShowWindow(mainwindow, SW_SHOWDEFAULT);

    UpdateWindow(mainwindow);
    vid_fulldib_on_focus_mode = NULL;

    SendMessage(mainwindow, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
    SendMessage(mainwindow, WM_SETICON, ICON_SMALL, (LPARAM)hIcon);

    return true;
}

static qboolean
VID_SetFullDIBMode(const qvidmode_t *mode)
{
    RECT windowRect;

    VID_ShutdownDIB();
    VID_SetDisplayMode(mode);

    windowRect.top = 0;
    windowRect.left = 0;
    windowRect.right = mode->width;
    windowRect.bottom = mode->height;

    AdjustWindowRectEx(&windowRect, Q_WS_FULLSCREEN, FALSE, 0);

    SetWindowLong(mainwindow, GWL_STYLE, Q_WS_FULLSCREEN | WS_VISIBLE);
    SetWindowLong(mainwindow, GWL_EXSTYLE, 0);

    if (!SetWindowPos(mainwindow, NULL, 0, 0,
		      windowRect.right - windowRect.left,
		      windowRect.bottom - windowRect.top,
		      SWP_NOCOPYBITS | SWP_NOZORDER)) {
	Sys_Error("Couldn't resize DIB window");
    }

    /* Raise to top and show the DIB window */
    SetWindowPos(mainwindow, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_SHOWWINDOW | SWP_DRAWFRAME);
    ShowWindow(mainwindow, SW_SHOWDEFAULT);
    UpdateWindow(mainwindow);

    /* Update the input rect */
    IN_UpdateWindowRect(0, 0, mode->width, mode->height);

    return true;
}

void
VID_SetDefaultMode(void)
{
    if (vid_initialized)
	VID_SetMode(&vid_windowed_mode, vid_curpal);
    IN_DeactivateMouse();
}

qboolean
VID_SetMode(const qvidmode_t *mode, const byte *palette)
{
    RECT windowRect;
    qboolean save_disabled_value, success;
    MSG msg;
    HDC hdc;

    /* so Con_Printfs don't mess us up by forcing vid and snd updates */
    save_disabled_value = scr_disabled_for_loading;
    scr_disabled_for_loading = true;
    in_mode_set = true;

    CDAudio_Pause();
    S_ClearBuffer();

    /* Create the window if we haven't already */
    if (!mainwindow) {
        windowRect.top = 0;
        windowRect.left = 0;
        windowRect.right = mode->width;
        windowRect.bottom = mode->height;
        AdjustWindowRectEx(&windowRect, Q_WS_WINDOWED, FALSE, 0);
	mainwindow = CreateWindowEx(0,
                                    "TyrQuake",
                                    "TyrQuake",
				    Q_WS_WINDOWED,
				    0, 0,
				    windowRect.right - windowRect.left,
				    windowRect.bottom - windowRect.top,
				    NULL, NULL, global_hInstance, NULL);

    }
    if (!mainwindow)
        Sys_Error("Unable to create window");

    maindc = GetDC(mainwindow);

    /* TODO: verify these raster capabilities to turn on/off scaling? */
    int rastercaps = GetDeviceCaps(maindc, RASTERCAPS);
    if (rastercaps & RC_BITBLT)
        Sys_Printf("*** --- *** --- Main window has BITBLT capability\n");
    if (rastercaps & RC_STRETCHBLT)
        Sys_Printf("*** --- *** --- Main window has STRETCHBLT capability\n");

    VID_Mode_SetupViddef(mode, &vid);

    vid.numpages = 1;
    vid.aspect = 1;//((float)vid.height / (float)vid.width) * (320.0 / 240.0);

    /* Set either the fullscreen or windowed mode */
    success = false;
    if (mode != &vid_windowed_mode) {
	success = VID_SetFullDIBMode(mode);
	IN_ActivateMouse();
	IN_HideMouse();
    } else {
	if (_windowed_mouse.value && key_dest == key_game) {
	    success = VID_SetWindowedMode(mode);
	    IN_ActivateMouse();
	    IN_HideMouse();
	} else {
	    IN_DeactivateMouse();
	    IN_ShowMouse();
	    success = VID_SetWindowedMode(mode);
	}
    }

    /* Create the DIB */
    VID_CreateDIB(vid.width, vid.height, palette);

    CDAudio_Resume();
    scr_disabled_for_loading = save_disabled_value;

    if (!success)
	return false;

    vid_currentmode = mode;

    if (hide_window)
	return true;

    /*
     * now we try to make sure we get the focus on the mode switch, because
     * sometimes in some systems we don't.  We grab the foreground, then
     * finish setting up, pump all our messages, and sleep for a little while
     * to let messages finish bouncing around the system, then we put
     * ourselves at the top of the z order, then grab the foreground again,
     * Who knows if it helps, but it probably doesn't hurt
     */
    if (!force_minimized)
	SetForegroundWindow(mainwindow);

    hdc = GetDC(NULL);

    if (GetDeviceCaps(hdc, RASTERCAPS) & RC_PALETTE)
	vid_palettized = true;
    else
	vid_palettized = false;

    VID_SetPalette(palette);
    VID_InitColormap(palette);

    ReleaseDC(NULL, hdc);

    if (!VID_AllocBuffers(vid.width, vid.height))
	return false;

    D_InitCaches(vid_surfcache, vid_surfcachesize);

    while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
	TranslateMessage(&msg);
	DispatchMessage(&msg);
    }

    Sleep(100);

    if (!force_minimized) {
	SetWindowPos(mainwindow, HWND_TOP, 0, 0, 0, 0,
                     SWP_DRAWFRAME | SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW | SWP_NOCOPYBITS);
	SetForegroundWindow(mainwindow);
    }

    /* Fix the leftover Alt from any Alt-Tab or the like that switched us away */
    ClearAllStates();

    VID_SetPalette(palette);
    in_mode_set = false;
    vid.recalc_refdef = 1;

    SCR_CheckResize();
    Con_CheckResize();

    return true;
}

void
VID_SetPalette(const byte *palette)
{
    INT i;
    RGBQUAD colors[256];
    const byte *pal;

    if (window_visible() && hdcDIBSection) {
	/* incoming palette is 3 component */
	pal = palette + 3;
	for (i = 1; i < 255; i++, pal += 3) {
	    colors[i].rgbRed = pal[0];
	    colors[i].rgbGreen = pal[1];
	    colors[i].rgbBlue = pal[2];
	    colors[i].rgbReserved = 0;
	}

	colors[0].rgbRed = 0;
	colors[0].rgbGreen = 0;
	colors[0].rgbBlue = 0;
	colors[255].rgbRed = 0xff;
	colors[255].rgbGreen = 0xff;
	colors[255].rgbBlue = 0xff;

	if (!SetDIBColorTable(hdcDIBSection, 0, 256, colors))
	    Con_SafePrintf("%s: SetDIBColorTable failed\n", __func__);
    }

    memcpy(vid_curpal, palette, sizeof(vid_curpal));
}


void
VID_ShiftPalette(const byte *palette)
{
    VID_SetPalette(palette);
}

/*
=================
VID_Minimize_f
=================
*/
static void
VID_Minimize_f(void)
{
// we only support minimizing windows; if you're fullscreen,
// switch to windowed first
    if (modestate == MS_WINDOWED)
	ShowWindow(mainwindow, SW_MINIMIZE);
}

void
VID_RegisterVariables()
{
}

void
VID_AddCommands()
{
    Cmd_AddCommand("vid_minimize", VID_Minimize_f);
}

void
VID_InitColormap(const byte *palette)
{
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong(*((int *)vid.colormap + 2048));

    int i, bestmatch, bestmatchmetric, t, dr, dg, db;

    /*
     * GDI doesn't let us remap palette index 0, so we'll remap color
     * mappings from that color (black in the default palette) to another one
     */
    bestmatchmetric = 256 * 256 * 3;
    bestmatch = 0;

    for (i = 1; i < 256; i++) {
	dr = palette[0] - palette[i * 3];
	dg = palette[1] - palette[i * 3 + 1];
	db = palette[2] - palette[i * 3 + 2];

	t = (dr * dr) + (dg * dg) + (db * db);

	if (t < bestmatchmetric) {
	    bestmatchmetric = t;
	    bestmatch = i;

	    if (t == 0)
		break;
	}
    }

    /* Replace index 0 in the colormap with the closest match in the palette */
    for (i = 0; i < (1 << (VID_CBITS + 8)); i++) {
	if (vid.colormap[i] == 0)
	    vid.colormap[i] = bestmatch;
    }
}

void
VID_Init(const byte *palette)
{
    const qvidmode_t *mode;

    VID_InitWindowClass(global_hInstance);
    VID_InitModeList();
    VID_LoadConfig();

    mode = VID_GetCmdlineMode();
    if (!mode)
        mode = VID_GetModeFromCvars();
    if (!mode)
	mode = &vid_windowed_mode;

    if (hwnd_dialog)
	DestroyWindow(hwnd_dialog);

    /* keep the window minimized until we're ready for the first mode set */
    hide_window = true;
    VID_SetMode(mode, palette);
    hide_window = false;

    vid_initialized = true;
    VID_SetMode(mode, palette);

    VID_SetPalette(palette);
    vid_menudrawfn = VID_MenuDraw;
    vid_menukeyfn = VID_MenuKey;

    VID_InitDDraw();
}


void
VID_Shutdown(void)
{
    if (vid_initialized) {
        VID_ShutdownDDraw();

	if (modestate == MS_FULLSCREEN)
	    ChangeDisplaySettings(NULL, CDS_FULLSCREEN);

	PostMessage(HWND_BROADCAST, WM_PALETTECHANGED, (WPARAM)mainwindow, (LPARAM)0);
	PostMessage(HWND_BROADCAST, WM_SYSCOLORCHANGE, (WPARAM)0, (LPARAM)0);

	AppActivate(false, false);
	VID_ShutdownDIB();

	if (hwnd_dialog)
	    DestroyWindow(hwnd_dialog);
	if (mainwindow)
	    DestroyWindow(mainwindow);

	vid_initialized = 0;
    }
}

/*
================
FlipScreen
================
*/
static void
FlipScreen(vrect_t *rects, qboolean vsync)
{
    if (!hdcDIBSection)
	return;

    if (vsync && vid_vsync.value && vsync_available && pDDraw)
        IDirectDraw_WaitForVerticalBlank(pDDraw, DDWAITVB_BLOCKBEGIN, 0);

    if (vid.output.scale == 1) {
        /* Fast path for 1:1 blits */
        while (rects) {
            BitBlt(maindc,
                   rects->x, rects->y,
                   rects->width, rects->height,
                   hdcDIBSection,
                   rects->x, rects->y,
                   SRCCOPY);
            rects = rects->pnext;
        }
    } else if (vid.output.scale) {
        /* Integral scaling */
        int shift = Q_log2(vid.output.scale);
        while (rects) {
            StretchBlt(maindc,
                       rects->x << shift, rects->y << shift,
                       rects->width << shift, rects->height << shift,
                       hdcDIBSection,
                       rects->x, rects->y,
                       rects->width, rects->height,
                       SRCCOPY);
            rects = rects->pnext;
        }
    } else {
        /* Arbitrary scaling */
        float hscale = (float)vid.output.width / (float)vid.width;
        float vscale = (float)vid.output.height / (float)vid.height;
        while (rects) {
            StretchBlt(maindc,
                       rects->x * hscale, rects->y * vscale,
                       rects->width * hscale, rects->height * vscale,
                       hdcDIBSection,
                       rects->x, rects->y,
                       rects->width, rects->height,
                       SRCCOPY);
            rects = rects->pnext;
        }
    }
}

/*
================
D_BeginDirectRect
================
*/
void
D_BeginDirectRect(int x, int y, const byte *pbitmap, int width, int height)
{
    int i, j, reps, repshift;
    vrect_t rect;

    if (!vid_initialized)
	return;
    if (!vid.direct)
	return;

    if (vid.aspect > 1.5) {
	reps = 2;
	repshift = 1;
    } else {
	reps = 1;
	repshift = 0;
    }

    for (i = 0; i < (height << repshift); i += reps) {
	for (j = 0; j < reps; j++) {
	    memcpy(&backingbuf[(i + j) * 24],
		   vid.direct + x + ((y << repshift) + i + j) * vid.rowbytes,
		   width);
	    memcpy(vid.direct + x + ((y << repshift) + i + j) * vid.rowbytes,
		   &pbitmap[(i >> repshift) * width], width);
	}
    }

    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height << repshift;
    rect.pnext = NULL;

    FlipScreen(&rect, false);
}


/*
================
D_EndDirectRect
================
*/
void
D_EndDirectRect(int x, int y, int width, int height)
{
    int i, j, reps, repshift;
    vrect_t rect;

    if (!vid_initialized)
	return;
    if (!vid.direct)
	return;

    if (vid.aspect > 1.5) {
	reps = 2;
	repshift = 1;
    } else {
	reps = 1;
	repshift = 0;
    }

    for (i = 0; i < (height << repshift); i += reps) {
	for (j = 0; j < reps; j++) {
	    memcpy(vid.direct + x + ((y << repshift) + i + j) * vid.rowbytes,
		   &backingbuf[(i + j) * 24], width);
	}
    }

    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height << repshift;
    rect.pnext = NULL;

    FlipScreen(&rect, false);
}

void
VID_Update(vrect_t *rects)
{
    vrect_t rect;
    RECT trect;

    if (!vid_palettized && palette_changed) {
	palette_changed = false;
	rect.x = 0;
	rect.y = 0;
	rect.width = vid.width;
	rect.height = vid.height;
	rect.pnext = NULL;
	rects = &rect;
    }

    if (firstupdate && host_initialized) {
	if (modestate == MS_WINDOWED) {
	    GetWindowRect(mainwindow, &trect);

	    if ((trect.left != (int)vid_window_x.value) || (trect.top != (int)vid_window_y.value)) {
		if (COM_CheckParm("-resetwinpos"))
                    VID_UpdateWindowPositionCvars(0, 0);
                if (vid_window_centered.value) {
                    VID_CenterWindow(mainwindow);
                } else if (vid_window_remember_position.value) {
                    VID_SetWindowPos(mainwindow, (int)vid_window_x.value, (int)vid_window_y.value);
                }
	    }
            firstupdate = false;
	}
    }
    // We've drawn the frame; copy it to the screen
    FlipScreen(rects, true);

// handle the mouse state when windowed if that's changed
    if (modestate == MS_WINDOWED) {
	if (!_windowed_mouse.value) {
	    if (mouseactive) {
		IN_DeactivateMouse();
		IN_ShowMouse();
	    }
	} else if (mouseactive) {
	    if (key_dest != key_game) {
		IN_DeactivateMouse();
		IN_ShowMouse();
	    }
	} else if (key_dest == key_game && IN_HaveFocus()) {
	    IN_ActivateMouse();
	    IN_HideMouse();
	}
    }
}


//==========================================================================

static knum_t scantokey[128] = {
//  0       1       2       3       4       5       6       7
//  8       9       A       B       C       D       E       F
    0,      K_ESCAPE, '1',  '2',    '3',    '4',    '5',    '6',
    '7',    '8',    '9',    '0',    '-',    '=',    K_BACKSPACE, K_TAB,	// 0
    'q',    'w',    'e',    'r',    't',    'y',    'u',    'i',
    'o',    'p',    '[',    ']',    13,     K_LCTRL,'a',    's',	// 1
    'd',    'f',    'g',    'h',    'j',    'k',    'l',    ';',
    '\'',   '`',    K_LSHIFT, '\\', 'z',    'x',    'c',    'v',	// 2
    'b',    'n',    'm',    ',',    '.',    '/',    K_RSHIFT, '*',
    K_LALT, ' ',    0,      K_F1,   K_F2,   K_F3,   K_F4,   K_F5,	// 3
    K_F6,   K_F7,   K_F8,   K_F9,   K_F10,  K_PAUSE, 0,     K_HOME,
    K_UPARROW, K_PGUP, '-', K_LEFTARROW, '5', K_RIGHTARROW, '+', K_END,	// 4
    K_DOWNARROW, K_PGDN, K_INS, K_DEL, 0,   0,      0,      K_F11,
    K_F12,  0,      0,      0,      0,      0,      0,      0,		// 5
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0,		// 6
    0,      0,      0,      0,      0,      0,      0,      0,
    0,      0,      0,      0,      0,      0,      0,      0		// 7
};

/*
=======
MapKey

Map from windows to quake keynums
=======
*/
static knum_t
MapKey(int key)
{
    key = (key >> 16) & 255;
    if (key > 127)
	return 0;

    return scantokey[key];
}

/*
 * Function:     AppActivate
 * Parameters:   fActive - True if app is activating
 *
 * Description:  If the application is activating, then swap the system
 *               into SYSPAL_NOSTATIC mode so that our palettes will display
 *               correctly.
 */
static void
AppActivate(BOOL fActive, BOOL minimize)
{
    HDC hdc;
    static BOOL sound_active;

    IN_SetFocus(fActive);

    /* messy, but it seems to work */
    if (vid_fulldib_on_focus_mode) {
	Minimized = minimize;
	if (Minimized)
	    IN_SetFocus(false);
    }

    if (vid_initialized) {
	/* yield the palette if we're losing the focus */
	hdc = GetDC(NULL);
	if (!Minimized)
	    VID_SetPalette(vid_curpal);

	scr_fullupdate = 0;
	ReleaseDC(NULL, hdc);
    }

    /* enable/disable sound on focus gain/loss */
    if (!IN_HaveFocus() && sound_active) {
	S_BlockSound();
	S_ClearBuffer();
	sound_active = false;
    } else if (IN_HaveFocus() && !sound_active) {
	S_UnblockSound();
	S_ClearBuffer();
	sound_active = true;
    }

    /* Minimize/restore windows & mouse-capture on demand */
    if (!in_mode_set) {
	if (IN_HaveFocus()) {
	    if (vid_fulldib_on_focus_mode) {
		if (vid_initialized) {
		    VID_SetMode(vid_fulldib_on_focus_mode, vid_curpal);

		    qboolean old_in_mode_set_value = in_mode_set;
		    in_mode_set = true;
		    AppActivate(true, false);
		    in_mode_set = old_in_mode_set_value;
		}
		IN_ActivateMouse();
		IN_HideMouse();
	    } else if ((modestate == MS_WINDOWED) && _windowed_mouse.value
		       && key_dest == key_game) {
		IN_ActivateMouse();
		IN_HideMouse();
	    }
	}

	if (!IN_HaveFocus()) {
	    if (modestate == MS_FULLSCREEN) {
		if (vid_initialized) {
		    force_minimized = true;
		    const qvidmode_t *saved_fulldib_on_focus_mode = vid_fulldib_on_focus_mode;

		    VID_SetMode(&vid_windowed_mode, vid_curpal);
		    vid_fulldib_on_focus_mode = saved_fulldib_on_focus_mode;
		    force_minimized = false;

		    /*
		     * we never seem to get WM_ACTIVATE inactive from this mode
		     * set, so we'll do it manually
		     */
		    qboolean saved_in_mode_set_value = in_mode_set;
		    in_mode_set = true;
		    AppActivate(false, true);
		    in_mode_set = saved_in_mode_set_value;
		}
		IN_DeactivateMouse();
		IN_ShowMouse();
	    } else if ((modestate == MS_WINDOWED) && _windowed_mouse.value) {
		IN_DeactivateMouse();
		IN_ShowMouse();
	    }
	}
    }
}


/*
===================================================================
MAIN WINDOW
===================================================================
*/

/* main window procedure */
static LONG WINAPI
MainWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    RECT windowRect;
    LONG msg_handled = 0;
    int fActive, fMinimized, buttons, window_x, window_y, result;
    HDC hdc;
    PAINTSTRUCT ps;

    if (uMsg == uiWheelMessage) {
	uMsg = WM_MOUSEWHEEL;
	wParam <<= 16;
    }

    switch (uMsg) {
    case WM_CREATE:
	break;

    case WM_SYSCOMMAND:
	/* Check for maximize being hit */
	switch (wParam & ~0x0F) {
	case SC_MAXIMIZE:
	    /*
	     * if minimized, bring up as a window before going
	     * fullscreen, so we will have the right state to restore
	     */
	    if (Minimized) {
		VID_SetMode(&vid_windowed_mode, vid_curpal);
	    }

	    VID_SetMode(vid_currentmode, vid_curpal);
	    break;

	case SC_SCREENSAVE:
	case SC_MONITORPOWER:
	    if (modestate != MS_WINDOWED) {
		/*
		 * don't call DefWindowProc() because we don't want to
		 * start the screen saver fullscreen
		 */
		break;
	    }
	    /* fall through windowed and allow the screen saver to start */

	default:
	    if (!in_mode_set) {
		S_BlockSound();
		S_ClearBuffer();
	    }
	    msg_handled = DefWindowProc(hWnd, uMsg, wParam, lParam);
	    if (!in_mode_set)
		S_UnblockSound();
	}
	break;

    case WM_MOVE:
	window_x = (int)LOWORD(lParam);
	window_y = (int)HIWORD(lParam);
	IN_UpdateWindowRect(window_x, window_y, vid_currentmode->width, vid_currentmode->height);
	if ((modestate == MS_WINDOWED) && !in_mode_set && !Minimized) {
            GetWindowRect(mainwindow, &windowRect);
            VID_UpdateWindowPositionCvars(windowRect.left, windowRect.top);
        }
	break;

    case WM_SIZE:
	Minimized = false;
	if (!(wParam & SIZE_RESTORED) && (wParam & SIZE_MINIMIZED))
	    Minimized = true;
	break;

    case WM_SYSCHAR:
	/* keep Alt-Space from happening */
	break;

    case WM_ACTIVATE:
	fActive = LOWORD(wParam);
	fMinimized = (BOOL)HIWORD(wParam);
	AppActivate(!(fActive == WA_INACTIVE), fMinimized);

	/*
	 * Fix the leftover Alt from any Alt-Tab or the like that
	 * switched us away
	 */
	ClearAllStates();
	if (!in_mode_set)
	    VID_SetPalette(vid_curpal);
	break;

    case WM_PAINT:
	hdc = BeginPaint(hWnd, &ps);
	if (!hdc)
	    break;
	if (!in_mode_set && host_initialized)
	    SCR_UpdateWholeScreen();
	EndPaint(hWnd, &ps);
	break;

    case WM_KEYDOWN:
    case WM_SYSKEYDOWN:
	if (!in_mode_set)
	    Key_Event(MapKey(lParam), true);
	break;

    case WM_KEYUP:
    case WM_SYSKEYUP:
	if (!in_mode_set)
	    Key_Event(MapKey(lParam), false);
	break;

    case WM_LBUTTONDOWN:
    case WM_LBUTTONUP:
    case WM_RBUTTONDOWN:
    case WM_RBUTTONUP:
    case WM_MBUTTONDOWN:
    case WM_MBUTTONUP:
    case WM_MOUSEMOVE:
	/*
	 * this is complicated because Win32 seems to pack multiple
	 * mouse events into one update sometimes, so we always check
	 * all states and look for events
	 */
	if (!in_mode_set) {
	    buttons = 0;
	    if (wParam & MK_LBUTTON)
		buttons |= 1;
	    if (wParam & MK_RBUTTON)
		buttons |= 2;
	    if (wParam & MK_MBUTTON)
		buttons |= 4;
	    IN_MouseEvent(buttons);
	}
	break;

    case WM_MOUSEWHEEL:
	/*
	 * This is the mouse wheel with the Intellimouse. Its delta is
	 * either positive or neg, and we generate the proper Event.
	 */
	if ((short)HIWORD(wParam) > 0) {
	    Key_Event(K_MWHEELUP, true);
	    Key_Event(K_MWHEELUP, false);
	} else {
	    Key_Event(K_MWHEELDOWN, true);
	    Key_Event(K_MWHEELDOWN, false);
	}
	break;

    case WM_DISPLAYCHANGE:
	if (!in_mode_set && (modestate == MS_WINDOWED)
	    && !vid_fulldib_on_focus_mode) {
	    VID_SetMode(vid_currentmode, vid_curpal);
	}
	break;

    case WM_CLOSE:
	/*
	 * this causes Close in the right-click task bar menu not to work, but
	 * right now bad things happen if Close is handled in that case
	 * (garbage and a crash on Win95)
	 */
	if (!in_mode_set) {
	    result = MessageBox(mainwindow,
				"Are you sure you want to quit?",
				"Confirm Exit",
				MB_YESNO | MB_SETFOREGROUND | MB_ICONQUESTION);
	    if (result == IDYES)
		Sys_Quit();
	}
	break;

    case MM_MCINOTIFY:
	msg_handled = CDDrv_MessageHandler(hWnd, uMsg, wParam, lParam);
	break;

    default:
	/* pass all unhandled messages to DefWindowProc */
	msg_handled = DefWindowProc(hWnd, uMsg, wParam, lParam);
	break;
    }

    /* return 0 if handled message, 1 if not */
    return msg_handled;
}

/* All Win32 events are handled via callback MainWndProc */
void VID_ProcessEvents() {}

void VID_LockBuffer(void) {}
void VID_UnlockBuffer(void) {}
