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

#include <windows.h>
#include <commctrl.h>
#include <mmsystem.h>

#include "cdaudio.h"
#include "cmd.h"
#include "console.h"
#include "draw.h"
#include "glquake.h"
#include "input.h"
#include "keys.h"
#include "menu.h"
#include "quakedef.h"
#include "resource.h"
#include "sbar.h"
#include "screen.h"
#include "sound.h"
#include "sys.h"
#include "vid.h"
#include "wad.h"
#include "winquake.h"

#ifdef NQ_HACK
#include "host.h"
#endif

qboolean VID_CheckAdequateMem(int width, int height) { return true; }

static qboolean Minimized;

qboolean
window_visible(void)
{
    return !Minimized;
}

#define Q_WS_FULLSCREEN (WS_POPUP)
#define Q_WS_WINDOWED (WS_OVERLAPPED | WS_BORDER | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX)

HWND mainwindow;
qboolean DDActive;
viddef_t vid; /* global video state */

static byte vid_curpal[256 * 3];

static HICON hIcon;
static DEVMODE gdevmode;
static qboolean vid_initialized = false;
static qboolean in_mode_set;
static modestate_t modestate = MS_UNINIT;

static HDC maindc;

static HGLRC baseRC;
static RECT GL_WindowRect;
static qboolean vid_canalttab;
static qboolean vid_wassuspended;
static int windowed_mouse;

static qboolean fullsbardraw;
static qboolean hide_window;

static float vid_gamma = 1.0;

float gldepthmin, gldepthmax;
static qboolean reload_textures; // Flag to set/test on gl context destroy/create

static void AppActivate(BOOL fActive, BOOL minimize);
static LONG WINAPI MainWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

static void ClearAllStates(void);

static BOOL bSetupPixelFormat(HDC hDC);

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

void *
GL_GetProcAddress(const char *name)
{
    return wglGetProcAddress(name);
}

static const char * (WINAPI *qwglGetExtensionsStringARB)(HDC hdc);
static BOOL (WINAPI *qwglSwapIntervalEXT)(int interval);

static qboolean
WGL_ExtensionCheck(const char *extension)
{
    if (!qwglGetExtensionsStringARB) {
        qwglGetExtensionsStringARB = (void *)wglGetProcAddress("wglGetExtensionsStringARB");
        if (!qwglGetExtensionsStringARB)
            return false;
    }
    const char *string = qwglGetExtensionsStringARB(maindc);
    return GL_ExtensionCheck_String(extension, string);
}

static void
WGL_ExtensionCheck_SwapControl()
{
    if (WGL_ExtensionCheck("WGL_EXT_swap_control") && GL_ExtensionCheck("WGL_EXT_swap_control"))
        qwglSwapIntervalEXT = (void *)wglGetProcAddress("wglSwapIntervalEXT");

    if (qwglSwapIntervalEXT) {
        vsync_available = true;
        if (WGL_ExtensionCheck("WGL_EXT_swap_control_tear")) {
            adaptive_vsync_available = true;
        }
    }
}

static void
VID_ShutdownGLContext()
{
    HGLRC hrc;
    HDC hdc;

    hrc = wglGetCurrentContext();
    hdc = wglGetCurrentDC();
    wglMakeCurrent(NULL, NULL);

    if (hdc && mainwindow)
	ReleaseDC(mainwindow, hdc);
    if (maindc && mainwindow)
	ReleaseDC(mainwindow, maindc);
    maindc = NULL;

    if (hrc) {
        GL_Shutdown();
        wglDeleteContext(hrc);
        if (host_initialized)
            reload_textures = true;
    }
}

static void
VID_CreateGLContext(int width, int height, const byte *palette)
{
    HDC hdc;

    /*
     * Because we have set the background brush for the window to NULL
     * (to avoid flickering when re-sizing the window on the desktop), we
     * clear the window to black when created, otherwise it will be
     * empty while Quake starts up.
     */
    hdc = GetDC(mainwindow);
    PatBlt(hdc, 0, 0, width, height, BLACKNESS);
    ReleaseDC(mainwindow, hdc);

    maindc = GetDC(mainwindow);
    bSetupPixelFormat(maindc);

    baseRC = wglCreateContext(maindc);
    if (!baseRC)
	Sys_Error("Could not initialize GL (wglCreateContext failed).\n\n"
		  "Make sure you in are 65535 color mode, "
		  "and try running -window.");
    if (!wglMakeCurrent(maindc, baseRC))
	Sys_Error("wglMakeCurrent failed");

    GL_Init();
    if (reload_textures) {
	GL_ReloadTextures();
        reload_textures = false;
    }

    WGL_ExtensionCheck_SwapControl();
    if (qwglSwapIntervalEXT) {
        int swap_interval = 0;
        if (adaptive_vsync_available && vid_vsync.value == VSYNC_STATE_ADAPTIVE)
            swap_interval = -1;
        else if (vsync_available && vid_vsync.value)
            swap_interval = 1;
        qwglSwapIntervalEXT(swap_interval);
    }
}

/*
================
ClearAllStates
================
*/
static void
ClearAllStates(void)
{
    knum_t keynum;

    /* send an up event for each key, to ensure the server clears them all */
    for (keynum = K_UNKNOWN; keynum < K_LAST; keynum++)
	Key_Event(keynum, false);

    Key_ClearStates();
    IN_ClearStates();
}

static void
VID_InitWindowClass(HINSTANCE hInstance)
{
    WNDCLASS wc;

    /* Register the frame class */
    wc.style = 0;
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
	if (devmode.dmPelsWidth > MAXWIDTH || devmode.dmPelsHeight > MAXHEIGHT)
	    continue;
	if (devmode.dmBitsPerPel < 15)
	    continue;

	devmode.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY;
	result = ChangeDisplaySettings(&devmode, CDS_TEST | CDS_FULLSCREEN);
	if (result != DISP_CHANGE_SUCCESSFUL)
	    continue;

        Hunk_AllocExtend(vid_modelist, sizeof(qvidmode_t));
        mode = &vid_modelist[vid_nummodes++];
	mode->width = devmode.dmPelsWidth;
	mode->height = devmode.dmPelsHeight;
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
}

static qboolean
VID_SetWindowedMode(const qvidmode_t *mode)
{
    RECT windowRect;

    VID_ShutdownGLContext();
    VID_SetDisplayMode(NULL);

    windowRect.top = 0;
    windowRect.left = 0;
    windowRect.right = mode->width;
    windowRect.bottom = mode->height;

    GL_WindowRect = windowRect;
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

    ShowWindow(mainwindow, SW_SHOWDEFAULT);
    UpdateWindow(mainwindow);

    vid.numpages = 0; /* Contents of the back buffer are undefined after swap */
    vid.width = vid.conwidth = mode->width;
    vid.height = vid.conheight = mode->height;

    SendMessage(mainwindow, WM_SETICON, ICON_BIG, (LPARAM)hIcon);
    SendMessage(mainwindow, WM_SETICON, ICON_SMALL, (LPARAM)hIcon);

    return true;
}

static qboolean
VID_SetFullDIBMode(const qvidmode_t *mode)
{
    RECT windowRect;

    VID_ShutdownGLContext();
    VID_SetDisplayMode(mode);

    windowRect.top = 0;
    windowRect.left = 0;
    windowRect.right = mode->width;
    windowRect.bottom = mode->height;

    GL_WindowRect = windowRect;
    AdjustWindowRectEx(&windowRect, Q_WS_FULLSCREEN, FALSE, 0);

    SetWindowLong(mainwindow, GWL_STYLE, Q_WS_FULLSCREEN | WS_VISIBLE);
    SetWindowLong(mainwindow, GWL_EXSTYLE, 0);

    if (!SetWindowPos(mainwindow, NULL, 0, 0,
		      windowRect.right - windowRect.left,
		      windowRect.bottom - windowRect.top,
		      SWP_NOCOPYBITS | SWP_NOZORDER)) {
	Sys_Error("Couldn't resize window");
    }

    /* Raise to top and show the DIB window */
    SetWindowPos(mainwindow, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_SHOWWINDOW | SWP_DRAWFRAME);
    ShowWindow(mainwindow, SW_SHOWDEFAULT);
    UpdateWindow(mainwindow);

    /* Update the input layer with the new window geometry */
    IN_UpdateWindowRect(0, 0, mode->width, mode->height);

    vid.numpages = 0; /* Contents of the back buffer are undefined after swap */
    vid.width = vid.conwidth = mode->width;
    vid.height = vid.conheight = mode->height;

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
    RECT windowRect;
    qboolean scr_disabled_for_loading_save, success;
    MSG msg;

    /* so Con_Printfs don't mess us up by forcing vid and snd updates */
    scr_disabled_for_loading_save = scr_disabled_for_loading;
    scr_disabled_for_loading = true;
    in_mode_set = true;

    CDAudio_Pause();
    S_ClearBuffer();

    if (!mainwindow) {
        windowRect.top = 0;
        windowRect.left = 0;
        windowRect.right = mode->width;
        windowRect.bottom = mode->height;

        GL_WindowRect = windowRect;
        AdjustWindowRectEx(&windowRect, Q_WS_WINDOWED, FALSE, 0);

        /* Create the window if we haven't already */
        mainwindow = CreateWindowEx(0,
                                    "TyrQuake",
                                    "TyrQuake",
                                    Q_WS_WINDOWED,
                                    windowRect.left, windowRect.top,
                                    windowRect.right - windowRect.left,
                                    windowRect.bottom - windowRect.top,
                                    NULL, NULL, global_hInstance, NULL);
    }
    if (!mainwindow)
	Sys_Error("Couldn't create window");

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

    /* Create the GL Context */
    VID_CreateGLContext(mode->width, mode->height, palette);

    CDAudio_Resume();
    scr_disabled_for_loading = scr_disabled_for_loading_save;

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
    SetForegroundWindow(mainwindow);

    VID_SetPalette(palette);
    VID_InitColormap(palette);

    while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
	TranslateMessage(&msg);
	DispatchMessage(&msg);
    }

    Sleep(100);

    SetWindowPos(mainwindow, HWND_TOP, 0, 0, 0, 0,
		 SWP_DRAWFRAME | SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW |
		 SWP_NOCOPYBITS);

    SetForegroundWindow(mainwindow);

    /* Fix the leftover Alt from any Alt-Tab or the like that switched us away */
    ClearAllStates();

    VID_SetPalette(palette);
    in_mode_set = false;
    vid.recalc_refdef = 1;

    SCR_CheckResize();
    Con_CheckResize();

    return true;
}

/*
=================
GL_BeginRendering
=================
*/
void
GL_BeginRendering(int *x, int *y, int *width, int *height)
{
    *x = *y = 0;
    *width = GL_WindowRect.right - GL_WindowRect.left;
    *height = GL_WindowRect.bottom - GL_WindowRect.top;
}

void
GL_EndRendering(void)
{
    if (!scr_skipupdate || scr_block_drawing)
	SwapBuffers(maindc);

// handle the mouse state when windowed if that's changed
    if (modestate == MS_WINDOWED) {
	if (!_windowed_mouse.value) {
	    if (windowed_mouse) {
		IN_DeactivateMouse();
		IN_ShowMouse();
		windowed_mouse = false;
	    }
	} else {
	    windowed_mouse = true;
	    if (key_dest == key_game && !mouseactive && IN_HaveFocus()) {
		IN_ActivateMouse();
		IN_HideMouse();
	    } else if (mouseactive && key_dest != key_game) {
		IN_DeactivateMouse();
		IN_ShowMouse();
	    }
	}
    }
    if (fullsbardraw)
	Sbar_Changed();
}

void
VID_SetPalette(const byte *palette)
{
    QPic32_InitPalettes(palette);
    memcpy(vid_curpal, palette, sizeof(vid_curpal));
}

void (*VID_SetGammaRamp)(unsigned short ramp[3][256]);
static unsigned short saved_gamma_ramp[3][256];

static void
VID_SetWinGammaRamp(unsigned short ramp[3][256])
{
    BOOL result;

    result = SetDeviceGammaRamp(maindc, ramp);
}

void
Gamma_Init(void)
{
    BOOL result = GetDeviceGammaRamp(maindc, saved_gamma_ramp);

    if (result)
	result = SetDeviceGammaRamp(maindc, saved_gamma_ramp);
    if (result)
	VID_SetGammaRamp = VID_SetWinGammaRamp;
    else
	VID_SetGammaRamp = NULL;
}

void
VID_ShiftPalette(const byte *palette)
{
    //VID_SetPalette(palette);
    //gammaworks = SetDeviceGammaRamp(maindc, ramps);
}


void
VID_SetDefaultMode(void)
{
    IN_DeactivateMouse();
}


void
VID_Shutdown(void)
{
    HGLRC hRC;
    HDC hDC;

    if (vid_initialized) {
	if (VID_SetGammaRamp)
	    VID_SetGammaRamp(saved_gamma_ramp);

	vid_canalttab = false;
	hRC = wglGetCurrentContext();
	hDC = wglGetCurrentDC();

	wglMakeCurrent(NULL, NULL);

	if (hRC)
	    wglDeleteContext(hRC);

	if (hDC && mainwindow)
	    ReleaseDC(mainwindow, hDC);

	if (modestate == MS_FULLSCREEN)
	    ChangeDisplaySettings(NULL, 0);

	if (maindc && mainwindow)
	    ReleaseDC(mainwindow, maindc);

	AppActivate(false, false);
    }
}


//==========================================================================


static BOOL
bSetupPixelFormat(HDC hDC)
{
    BOOL result;
    int pixelformat;

    static PIXELFORMATDESCRIPTOR pfd = {
	sizeof(PIXELFORMATDESCRIPTOR),	// size of this pfd
	1,			// version number
	PFD_DRAW_TO_WINDOW	// support window
	    | PFD_SUPPORT_OPENGL	// support OpenGL
	    | PFD_DOUBLEBUFFER,	// double buffered
	PFD_TYPE_RGBA,		// RGBA type
	24,			// 24-bit color depth
	0, 0, 0, 0, 0, 0,	// color bits ignored
	0,			// no alpha buffer
	0,			// shift bit ignored
	0,			// no accumulation buffer
	0, 0, 0, 0,		// accum bits ignored
	32,			// 32-bit z-buffer
	0,			// no stencil buffer
	0,			// no auxiliary buffer
	PFD_MAIN_PLANE,		// main layer
	0,			// reserved
	0, 0, 0			// layer masks ignored
    };

    pixelformat = ChoosePixelFormat(hDC, &pfd);
    if (!pixelformat) {
	MessageBox(NULL, "ChoosePixelFormat failed", "Error", MB_OK);
	return FALSE;
    }

    result = SetPixelFormat(hDC, pixelformat, &pfd);
    if (!result) {
	MessageBox(NULL, "SetPixelFormat failed", "Error", MB_OK);
	return FALSE;
    }

    return TRUE;
}

static void
Check_Gamma(const byte *palette, byte *newpalette)
{
    float f, inf;
    int i;

    i = COM_CheckParm("-gamma");
    vid_gamma = i ? Q_atof(com_argv[i + 1]) : 1.0;

    for (i = 0; i < 768; i++) {
	f = pow((palette[i] + 1) / 256.0, vid_gamma);
	inf = f * 255 + 0.5;
	if (inf < 0)
	    inf = 0;
	if (inf > 255)
	    inf = 255;
	newpalette[i] = inf;
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

/*
===================
VID_Init
===================
*/
void
VID_Init(const byte *palette)
{
    byte gamma_palette[256 * 3];
    DEVMODE devmode;
    const qvidmode_t *mode;

    memset(&devmode, 0, sizeof(devmode));

    hIcon = LoadIcon(global_hInstance, MAKEINTRESOURCE(IDI_ICON2));

    InitCommonControls();

    VID_InitWindowClass(global_hInstance);
    VID_InitModeList();
    VID_LoadConfig();
    mode = VID_GetCmdlineMode();
    if (!mode)
	mode = VID_GetModeFromCvars();
    if (!mode)
	mode = &vid_windowed_mode;

    vid_initialized = true;

    DestroyWindow(hwnd_dialog);

    Check_Gamma(palette, gamma_palette);
    VID_SetPalette(gamma_palette);

    hide_window = true;
    VID_SetMode(mode, gamma_palette);
    hide_window = false;

    VID_SetMode(mode, gamma_palette);
    Gamma_Init();

    vid_menudrawfn = VID_MenuDraw;
    vid_menukeyfn = VID_MenuKey;
    vid_canalttab = true;

    if (COM_CheckParm("-fullsbar"))
	fullsbardraw = true;
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
    if (!scantokey[key])
	Con_DPrintf("key 0x%02x has no translation\n", key);
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
    static BOOL sound_active;

    IN_SetFocus(fActive);
    Minimized = minimize;

    /* enable/disable sound on focus gain/loss */
    if (!IN_HaveFocus() && sound_active) {
	S_BlockSound();
	sound_active = false;
    } else if (IN_HaveFocus() && !sound_active) {
	S_UnblockSound();
	sound_active = true;
    }

    if (IN_HaveFocus()) {
	if (modestate == MS_FULLSCREEN) {
	    if (vid_canalttab && vid_wassuspended) {
		vid_wassuspended = false;
		ChangeDisplaySettings(&gdevmode, CDS_FULLSCREEN);
		ShowWindow(mainwindow, SW_SHOWNORMAL);

		/*
		 * Work-around for a bug in some video drivers that don't
		 * correctly update the offsets into the GL front buffer after
		 * alt-tab to the desktop and back.
		 */
		MoveWindow(mainwindow, 0, 0, gdevmode.dmPelsWidth, gdevmode.dmPelsHeight, false);
	    }
	    IN_ActivateMouse();
	    IN_HideMouse();
	} else if ((modestate == MS_WINDOWED) && _windowed_mouse.value && key_dest == key_game) {
	    IN_ActivateMouse();
	    IN_HideMouse();
	}
	/* Restore game gamma */
	if (VID_SetGammaRamp)
	    VID_SetGammaRamp(ramps);
    }

    if (!IN_HaveFocus()) {
	/* Restore desktop gamma */
	if (VID_SetGammaRamp)
	    VID_SetGammaRamp(saved_gamma_ramp);
	if (modestate == MS_FULLSCREEN) {
	    IN_DeactivateMouse();
	    IN_ShowMouse();
	    if (vid_canalttab) {
		ChangeDisplaySettings(NULL, 0);
		vid_wassuspended = true;
	    }
	} else if ((modestate == MS_WINDOWED) && _windowed_mouse.value) {
	    IN_DeactivateMouse();
	    IN_ShowMouse();
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
    LONG msg_handled = 1;
    int fActive, fMinimized, buttons, window_x, window_y, result;

    if (uMsg == uiWheelMessage)
	uMsg = WM_MOUSEWHEEL;

    switch (uMsg) {
    case WM_KILLFOCUS:
	if (modestate == MS_FULLSCREEN)
	    ShowWindow(mainwindow, SW_SHOWMINNOACTIVE);
	break;

    case WM_CREATE:
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
	break;

    case WM_KEYDOWN:
    case WM_SYSKEYDOWN:
	Key_Event(MapKey(lParam), true);
	break;

    case WM_KEYUP:
    case WM_SYSKEYUP:
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
	 * this is complicated because Win32 seems to pack multiple mouse
	 * events into one update sometimes, so we always check all states and
	 * look for events
	 */
	buttons = 0;
	if (wParam & MK_LBUTTON)
	    buttons |= 1;
	if (wParam & MK_RBUTTON)
	    buttons |= 2;
	if (wParam & MK_MBUTTON)
	    buttons |= 4;
	IN_MouseEvent(buttons);
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

    case WM_CLOSE:
	result = MessageBox(mainwindow,
			    "Are you sure you want to quit?",
			    "Confirm Exit",
			    MB_YESNO | MB_SETFOREGROUND | MB_ICONQUESTION);
	if (result == IDYES)
	    Sys_Quit();
	break;

    case WM_DISPLAYCHANGE:
	if (!in_mode_set && (modestate == MS_WINDOWED)) {
	    VID_SetMode(vid_currentmode, vid_curpal);
	}
	break;

    case WM_DESTROY:
	if (mainwindow)
	    DestroyWindow(mainwindow);
	PostQuitMessage(0);
	break;

    case MM_MCINOTIFY:
	msg_handled = CDDrv_MessageHandler(hWnd, uMsg, wParam, lParam);
	break;

    default:
	/* pass all unhandled messages to DefWindowProc */
	msg_handled = DefWindowProc(hWnd, uMsg, wParam, lParam);
	break;
    }

    return msg_handled;
}

/* All Win32 events are handled via callback MainWndProc */
void VID_ProcessEvents() {}

void VID_LockBuffer(void) {}
void VID_UnlockBuffer(void) {}
void D_BeginDirectRect(int x, int y, const byte *pbitmap, int width, int height) {}
void D_EndDirectRect(int x, int y, int width, int height) {}
