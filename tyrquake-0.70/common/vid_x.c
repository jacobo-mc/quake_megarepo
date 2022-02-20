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
// vid_x.c -- general x video driver

#include <ctype.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>

#include <X11/extensions/XShm.h>
#include <X11/extensions/xf86vmode.h>

// FIXME - refactoring X11 support...
#include "x11_core.h"
#include "in_x11.h"
#include "vid_x11.h"

#include "common.h"
#include "console.h"
#include "d_local.h"
#include "input.h"
#include "keys.h"
#include "quakedef.h"
#include "screen.h"
#include "sys.h"
#include "vid.h"

#ifdef NQ_HACK
#include "host.h"
#endif

/* compatibility cludges for new menu code */
qboolean VID_CheckAdequateMem(int width, int height) { return true; }

typedef struct {
    int input;
    int output;
} keymap_t;

viddef_t vid;			// global video state
unsigned short d_8to16table[256];

static qboolean doShm;
static Colormap x_cmap;
static GC x_gc;

static int x_shmeventtype;
static qboolean oktodraw = false;

static int current_framebuffer;
static XImage *x_framebuffer[2] = { 0, 0 };
static XShmSegmentInfo x_shminfo[2];

static int verbose = 0;

static byte current_palette[768];

static long X11_highhunkmark;
static long X11_buffersize;

static int vid_surfcachesize;
static void *vid_surfcache;

typedef unsigned short PIXEL16;
typedef unsigned int PIXEL24;
static PIXEL16 st2d_8to16table[256];
static PIXEL24 st2d_8to24table[256];

static int shiftmask_fl = 0;
static int r_shift, g_shift, b_shift;
static unsigned int r_mask, g_mask, b_mask;

static XF86VidModeModeInfo saved_vidmode;
static qboolean vidmode_active;

void
VID_GetDesktopRect(vrect_t *rect)
{
    rect->x = 0;
    rect->y = 0;
    rect->width = saved_vidmode.hdisplay;
    rect->height = saved_vidmode.vdisplay;
}

static void
VID_CenterWindow()
{
    vrect_t rect;
    int x, y;

    VID_GetDesktopRect(&rect);
    x = qmax((rect.width - vid_currentmode->width) / 2, 0);
    y = qmax((rect.height - vid_currentmode->height) / 2, 0);

    XMoveWindow(x_disp, x_win, x, y);
}

static void
shiftmask_init()
{
    unsigned int x;

    r_mask = x_visinfo->visual->red_mask;
    g_mask = x_visinfo->visual->green_mask;
    b_mask = x_visinfo->visual->blue_mask;
    for (r_shift = -8, x = 1; x < r_mask; x = x << 1)
	r_shift++;
    for (g_shift = -8, x = 1; x < g_mask; x = x << 1)
	g_shift++;
    for (b_shift = -8, x = 1; x < b_mask; x = x << 1)
	b_shift++;
    shiftmask_fl = 1;
}


static PIXEL16
xlib_rgb16(int r, int g, int b)
{
    PIXEL16 p;

    if (shiftmask_fl == 0)
	shiftmask_init();
    p = 0;

    if (r_shift > 0) {
	p = (r << (r_shift)) & r_mask;
    } else if (r_shift < 0) {
	p = (r >> (-r_shift)) & r_mask;
    } else
	p |= (r & r_mask);

    if (g_shift > 0) {
	p |= (g << (g_shift)) & g_mask;
    } else if (g_shift < 0) {
	p |= (g >> (-g_shift)) & g_mask;
    } else
	p |= (g & g_mask);

    if (b_shift > 0) {
	p |= (b << (b_shift)) & b_mask;
    } else if (b_shift < 0) {
	p |= (b >> (-b_shift)) & b_mask;
    } else
	p |= (b & b_mask);

    return p;
}

static PIXEL24
xlib_rgb24(int r, int g, int b)
{
    PIXEL24 p;

    if (shiftmask_fl == 0)
	shiftmask_init();
    p = 0;

    if (r_shift > 0) {
	p = (r << (r_shift)) & r_mask;
    } else if (r_shift < 0) {
	p = (r >> (-r_shift)) & r_mask;
    } else
	p |= (r & r_mask);

    if (g_shift > 0) {
	p |= (g << (g_shift)) & g_mask;
    } else if (g_shift < 0) {
	p |= (g >> (-g_shift)) & g_mask;
    } else
	p |= (g & g_mask);

    if (b_shift > 0) {
	p |= (b << (b_shift)) & b_mask;
    } else if (b_shift < 0) {
	p |= (b >> (-b_shift)) & b_mask;
    } else
	p |= (b & b_mask);

    return p;
}

static void
st1_fixup(XImage *framebuf, const vrect_t *rect)
{
    if (vid.output.scale == 1)
        return;

    const int x = rect->x;
    const int y = rect->y;
    const int width = rect->width;
    const int height = rect->height;

    assert(x >= 0 && y >= 0);

    if (vid.output.scale == 2) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            byte *dest0 = (byte *)&framebuf->data[(2 * yi + 0) * framebuf->bytes_per_line];
            byte *dest1 = (byte *)&framebuf->data[(2 * yi + 1) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                const byte color = src[xi];
                dest0[xi * 2] = dest0[xi * 2 + 1] = color;
                dest1[xi * 2] = dest1[xi * 2 + 1] = color;
            }
        }
    } else if (vid.output.scale == 4) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            byte *dest0 = (byte *)&framebuf->data[(4 * yi + 0) * framebuf->bytes_per_line];
            byte *dest1 = (byte *)&framebuf->data[(4 * yi + 1) * framebuf->bytes_per_line];
            byte *dest2 = (byte *)&framebuf->data[(4 * yi + 2) * framebuf->bytes_per_line];
            byte *dest3 = (byte *)&framebuf->data[(4 * yi + 3) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                const byte color = src[xi];
                dest0[xi * 4] = dest0[xi * 4 + 1] = dest0[xi * 4 + 2] = dest0[xi * 4 + 3] = color;
                dest1[xi * 4] = dest1[xi * 4 + 1] = dest1[xi * 4 + 2] = dest1[xi * 4 + 3] = color;
                dest2[xi * 4] = dest2[xi * 4 + 1] = dest2[xi * 4 + 2] = dest2[xi * 4 + 3] = color;
                dest3[xi * 4] = dest3[xi * 4 + 1] = dest3[xi * 4 + 2] = dest3[xi * 4 + 3] = color;
            }
        }
    } else {
        /*
         * Arbitrary scaling - walk the output lines and calculate the
         * appropriate source lines as we go.
         */
        const int xstep = (vid.width << 16) / vid.output.width;
        for (int yi = vid.output.height - 1; yi >= 0; yi--) {
            byte *dst = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            const int src_row = yi * vid.height / vid.output.height;
            const byte *src = (byte *)&framebuf->data[src_row * framebuf->bytes_per_line];
            int frac = (vid.width - 1) << 16;
            for (int xi = vid.output.width - 1; xi >= 0; xi--) {
                dst[xi] = src[frac >> 16];
                frac -= xstep;
            }
        }
    }
}

static void
st2_fixup(XImage *framebuf, const vrect_t *rect)
{
    const int x = rect->x;
    const int y = rect->y;
    const int width = rect->width;
    const int height = rect->height;

    assert(x >= 0 && y >= 0);

    if (vid.output.scale == 1) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL16 *dest = ((PIXEL16 *)src);
            for(int xi = (x + width - 1); xi >= x; xi--) {
                dest[xi] = st2d_8to16table[src[xi]];
            }
        }
    } else if (vid.output.scale == 2) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL16 *dest0 = (PIXEL16 *)&framebuf->data[(2 * yi + 0) * framebuf->bytes_per_line];
            PIXEL16 *dest1 = (PIXEL16 *)&framebuf->data[(2 * yi + 1) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                const PIXEL16 color = st2d_8to16table[src[xi]];
                dest0[xi * 2] = dest0[xi * 2 + 1] = color;
                dest1[xi * 2] = dest1[xi * 2 + 1] = color;
            }
        }
    } else if (vid.output.scale == 4) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL16 *dest0 = (PIXEL16 *)&framebuf->data[(4 * yi + 0) * framebuf->bytes_per_line];
            PIXEL16 *dest1 = (PIXEL16 *)&framebuf->data[(4 * yi + 1) * framebuf->bytes_per_line];
            PIXEL16 *dest2 = (PIXEL16 *)&framebuf->data[(4 * yi + 2) * framebuf->bytes_per_line];
            PIXEL16 *dest3 = (PIXEL16 *)&framebuf->data[(4 * yi + 3) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                const PIXEL16 color = st2d_8to16table[src[xi]];
                dest0[xi * 4] = dest0[xi * 4 + 1] = dest0[xi * 4 + 2] = dest0[xi * 4 + 3] = color;
                dest1[xi * 4] = dest1[xi * 4 + 1] = dest1[xi * 4 + 2] = dest1[xi * 4 + 3] = color;
                dest2[xi * 4] = dest2[xi * 4 + 1] = dest2[xi * 4 + 2] = dest2[xi * 4 + 3] = color;
                dest3[xi * 4] = dest3[xi * 4 + 1] = dest3[xi * 4 + 2] = dest3[xi * 4 + 3] = color;
            }
        }
    } else {
        /*
         * Arbitrary scaling - walk the output lines and calculate the
         * appropriate source lines as we go.
         */
        const int xstep = (vid.width << 16) / vid.output.width;
        for (int yi = vid.output.height - 1; yi >= 0; yi--) {
            PIXEL16 *dst = (PIXEL16 *)&framebuf->data[yi * framebuf->bytes_per_line];
            const int src_row = yi * vid.height / vid.output.height;
            const byte *src = (byte *)&framebuf->data[src_row * framebuf->bytes_per_line];
            int frac = (vid.width - 1) << 16;
            for (int xi = vid.output.width - 1; xi >= 0; xi--) {
                dst[xi] = st2d_8to16table[src[frac >> 16]];
                frac -= xstep;
            }
        }
    }
}

static void
st3_fixup(XImage *framebuf, const vrect_t *rect)
{
    const int x = rect->x;
    const int y = rect->y;
    const int width = rect->width;
    const int height = rect->height;

    assert(x >= 0 && y >= 0);

    if (vid.output.scale == 1) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL24 *dest = ((PIXEL24 *)src);
            for(int xi = (x + width - 1); xi >= x; xi--) {
                dest[xi] = st2d_8to24table[src[xi]];
            }
        }
    } else if (vid.output.scale == 2) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL24 *dest0 = (PIXEL24 *)&framebuf->data[(2 * yi + 0) * framebuf->bytes_per_line];
            PIXEL24 *dest1 = (PIXEL24 *)&framebuf->data[(2 * yi + 1) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                PIXEL24 color = st2d_8to24table[src[xi]];
                dest0[xi * 2] = dest0[xi * 2 + 1] = color;
                dest1[xi * 2] = dest1[xi * 2 + 1] = color;
            }
        }
    } else if (vid.output.scale == 4) {
        for (int yi = y + height - 1; yi >= y; yi--) {
            const byte *src = (byte *)&framebuf->data[yi * framebuf->bytes_per_line];
            PIXEL24 *dest0 = (PIXEL24 *)&framebuf->data[(4 * yi + 0) * framebuf->bytes_per_line];
            PIXEL24 *dest1 = (PIXEL24 *)&framebuf->data[(4 * yi + 1) * framebuf->bytes_per_line];
            PIXEL24 *dest2 = (PIXEL24 *)&framebuf->data[(4 * yi + 2) * framebuf->bytes_per_line];
            PIXEL24 *dest3 = (PIXEL24 *)&framebuf->data[(4 * yi + 3) * framebuf->bytes_per_line];
            for (int xi = (x + width - 1); xi >= x; xi--) {
                PIXEL24 color = st2d_8to24table[src[xi]];
                dest0[xi * 4] = dest0[xi * 4 + 1] = dest0[xi * 4 + 2] = dest0[xi * 4 + 3] = color;
                dest1[xi * 4] = dest1[xi * 4 + 1] = dest1[xi * 4 + 2] = dest1[xi * 4 + 3] = color;
                dest2[xi * 4] = dest2[xi * 4 + 1] = dest2[xi * 4 + 2] = dest2[xi * 4 + 3] = color;
                dest3[xi * 4] = dest3[xi * 4 + 1] = dest3[xi * 4 + 2] = dest3[xi * 4 + 3] = color;
            }
        }
    } else {
        /*
         * Arbitrary scaling - walk the output lines and calculate the
         * appropriate source lines as we go.
         */
        const int xstep = (vid.width << 16) / vid.output.width;
        for (int yi = vid.output.height - 1; yi >= 0; yi--) {
            PIXEL24 *dst = (PIXEL24 *)&framebuf->data[yi * framebuf->bytes_per_line];
            const int src_row = yi * vid.height / vid.output.height;
            const byte *src = (byte *)&framebuf->data[src_row * framebuf->bytes_per_line];
            int frac = (vid.width - 1) << 16;
            for (int xi = vid.output.width - 1; xi >= 0; xi--) {
                dst[xi] = st2d_8to24table[src[frac >> 16]];
                frac -= xstep;
            }
        }
    }
}

/**
 * Translate the 8-bit rendered image to the color depth of the
 * front-buffer and apply the configured output scaling.
 */
static void
VID_ResolveFramebuffer(XImage *framebuf, const vrect_t *rect)
{
    switch (x_visinfo->depth) {
        case 8:
            st1_fixup(framebuf, rect);
            break;
        case 16:
            st2_fixup(framebuf, rect);
            break;
        case 24:
            st3_fixup(framebuf, rect);
            break;
        default:
            assert(!"Unsupported color format");
            break;
    }
}


// ========================================================================
// Tragic death handler
// ========================================================================

static void
TragicDeath(int signal_num)
{
    if (x_disp)
        XCloseDisplay(x_disp);
    Sys_Error("This death brought to you by the number %d", signal_num);
}

static void
ResetFrameBuffer(void)
{
    int framebuffer_bytes;
    int pixel_width;

    if (x_framebuffer[0]) {
	free(x_framebuffer[0]->data);
	free(x_framebuffer[0]);
    }

    if (d_pzbuffer) {
	D_FlushCaches();
	Hunk_FreeToHighMark(X11_highhunkmark);
	d_pzbuffer = NULL;
    }
    X11_highhunkmark = Hunk_HighMark();

    // Allocate the z_buffer and surface cache together
    vid_surfcachesize = D_SurfaceCacheForRes(vid.width, vid.height);
    X11_buffersize = vid.width * vid.height * sizeof(*d_pzbuffer);
    X11_buffersize += vid_surfcachesize;
    d_pzbuffer = Hunk_HighAllocName(X11_buffersize, "video");
    if (!d_pzbuffer)
	Sys_Error("Not enough memory for video mode");

    vid_surfcache = (byte *)d_pzbuffer + vid.width * vid.height * sizeof(*d_pzbuffer);
    D_InitCaches(vid_surfcache, vid_surfcachesize);

    int framebuffer_width = qmax(vid.width, vid.output.width);
    int framebuffer_height = qmax(vid.height, vid.output.height);

    pixel_width = x_visinfo->depth / 8;
    if (pixel_width == 3)
	pixel_width = 4;
    framebuffer_bytes = ((framebuffer_width * pixel_width + 7) & ~7) * framebuffer_height;
    x_framebuffer[0] = XCreateImage(x_disp,
				    x_visinfo->visual,
				    x_visinfo->depth,
				    ZPixmap,
				    0,
				    malloc(framebuffer_bytes),
				    framebuffer_width, framebuffer_height, 32, 0);
    if (!x_framebuffer[0])
	Sys_Error("VID: XCreateImage failed");

    /* Make the warpbuffer match the X11 shared memory buffer */
    r_warpbuffer = Hunk_HighAllocName(framebuffer_bytes, "warpbuf");

    R_AllocSurfEdges(false);

    vid.buffer = (byte *)x_framebuffer[0]->data;
    vid.conbuffer = vid.buffer;
    current_framebuffer = 0;
}

static void
ResetSharedFrameBuffers(void)
{
    int framebuffer_bytes;
    int key;
    int page_size = getpagesize();
    int frm;

    if (d_pzbuffer) {
	D_FlushCaches();
	Hunk_FreeToHighMark(X11_highhunkmark);
	d_pzbuffer = NULL;
    }

    X11_highhunkmark = Hunk_HighMark();

    // Allocate the z_buffer and surface cache together
    vid_surfcachesize = D_SurfaceCacheForRes(vid.width, vid.height);
    X11_buffersize = vid.width * vid.height * sizeof(*d_pzbuffer);
    X11_buffersize += vid_surfcachesize;
    d_pzbuffer = Hunk_HighAllocName(X11_buffersize, "video");
    if (!d_pzbuffer)
	Sys_Error("Not enough memory for video mode");

    vid_surfcache = (byte *)d_pzbuffer + vid.width * vid.height * sizeof(*d_pzbuffer);
    D_InitCaches(vid_surfcache, vid_surfcachesize);

    int framebuffer_width = qmax(vid.width, vid.output.width);
    int framebuffer_height = qmax(vid.height, vid.output.height);

    for (frm = 0; frm < 2; frm++) {
	// free up old frame buffer memory
	if (x_framebuffer[frm]) {
	    XShmDetach(x_disp, &x_shminfo[frm]);
	    free(x_framebuffer[frm]);
	    shmdt(x_shminfo[frm].shmaddr);
	}

	// create the image
	x_framebuffer[frm] = XShmCreateImage(x_disp,
					     x_visinfo->visual,
					     x_visinfo->depth,
					     ZPixmap,
					     0,
					     &x_shminfo[frm],
					     framebuffer_width,
                                             framebuffer_height);

	// grab shared memory
	framebuffer_bytes = x_framebuffer[frm]->bytes_per_line * x_framebuffer[frm]->height;
	if (framebuffer_bytes < page_size)
	    Sys_Error("VID: Window must use at least %d bytes", page_size);

	key = random();
	x_shminfo[frm].shmid = shmget((key_t) key, framebuffer_bytes, IPC_CREAT | 0777);
	if (x_shminfo[frm].shmid == -1)
	    Sys_Error("VID: Could not get any shared memory");

	// attach to the shared memory segment
	x_shminfo[frm].shmaddr = (void *)shmat(x_shminfo[frm].shmid, 0, 0);

	printf("VID: shared memory id=%d, addr=0x%p\n",
	       x_shminfo[frm].shmid, x_shminfo[frm].shmaddr);

	x_framebuffer[frm]->data = x_shminfo[frm].shmaddr;

	// get the X server to attach to it
	if (!XShmAttach(x_disp, &x_shminfo[frm]))
	    Sys_Error("VID: XShmAttach() failed");
	XSync(x_disp, 0);
	shmctl(x_shminfo[frm].shmid, IPC_RMID, 0);
    }

    /* Make the warpbuffer match the X11 shared memory buffer */
    r_warpbuffer = Hunk_HighAllocName(framebuffer_bytes, "warpbuf");

    R_AllocSurfEdges(false);

    vid.buffer = (byte *)x_framebuffer[0]->data;
    vid.conbuffer = vid.buffer;
    current_framebuffer = 0;
}

/*
 * Before setting a fullscreen mode, save the current video mode so we
 * can try restore it later.  I'm not sure if I've understood
 * correctly, but we can only query the current video mode by getting
 * the VidModeModeLine and the dotclock, from which we have to build
 * our own VidModeModeInfo struct in order to set it later?!?  Let's
 * try it...
 */
static void
VID_save_vidmode()
{
    int dotclock;
    XF86VidModeModeLine modeline;

    XF86VidModeGetModeLine(x_disp, x_visinfo->screen, &dotclock, &modeline);
    saved_vidmode.dotclock = dotclock;
    saved_vidmode.hdisplay = modeline.hdisplay;
    saved_vidmode.hsyncstart = modeline.hsyncstart;
    saved_vidmode.hsyncend = modeline.hsyncend;
    saved_vidmode.htotal = modeline.htotal;
    saved_vidmode.vdisplay = modeline.vdisplay;
    saved_vidmode.vsyncstart = modeline.vsyncstart;
    saved_vidmode.vsyncend = modeline.vsyncend;
    saved_vidmode.vtotal = modeline.vtotal;
    saved_vidmode.flags = modeline.flags;
    saved_vidmode.privsize = modeline.privsize;
    saved_vidmode.private = modeline.private;
}

static void
VID_restore_vidmode()
{
    if (vidmode_active) {
	XF86VidModeSwitchToMode(x_disp, x_visinfo->screen, &saved_vidmode);
	if (saved_vidmode.privsize && saved_vidmode.private)
	    XFree(saved_vidmode.private);
        vidmode_active = false;
    }
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
    unsigned long valuemask;
    XSetWindowAttributes attributes = {0};
    Window root;

    /* Free the existing structures */
    if (x_win) {
        IN_UngrabKeyboard();
        IN_UngrabMouse();
	XDestroyWindow(x_disp, x_win);
	x_win = 0;
    }
    if (x_cmap) {
	XFreeColormap(x_disp, x_cmap);
	x_cmap = 0;
    }

    vid_currentmode = mode;

    root = XRootWindow(x_disp, x_visinfo->screen);

    /* common window attributes */
    valuemask = CWBackPixel | CWColormap | CWEventMask;
    attributes.background_pixel = 0;
    attributes.colormap = XCreateColormap(x_disp, root, x_visinfo->visual, AllocNone);
    attributes.event_mask = X_CORE_MASK | X_KEY_MASK | X_MOUSE_MASK;

    if (VID_IsFullScreen()) {
        XF86VidModeModeInfo **xmodes, *xmode;
        int i, numxmodes, refresh;
        Bool result;

        /* Attempt to set the vid mode */
	XF86VidModeGetAllModeLines(x_disp, x_visinfo->screen, &numxmodes, &xmodes);
	xmode = *xmodes;
	for (i = 0; i < numxmodes; i++, xmode++) {
	    if (xmode->hdisplay != mode->width || xmode->vdisplay != mode->height)
		continue;
	    refresh = 1000 * xmode->dotclock / xmode->htotal / xmode->vtotal;
	    if (refresh == mode->refresh)
		break;
	}
	if (i == numxmodes)
	    Sys_Error("%s: unable to find matching X display mode", __func__);

	result = XF86VidModeSwitchToMode(x_disp, x_visinfo->screen, xmode);
	if (!result)
	    Sys_Error("%s: mode switch failed", __func__);

        XFree(xmodes);

        /* Fullscreen mode is now active */
        vidmode_active = true;

	valuemask |= CWSaveUnder | CWBackingStore | CWOverrideRedirect;
	attributes.override_redirect = True;
	attributes.backing_store = NotUseful;
	attributes.save_under = False;
    } else {
	/* Windowed */
	valuemask |= CWBorderPixel;
	attributes.border_pixel = 0;

        /* Restore the desktop mode, if we were previously fullscreen */
        VID_restore_vidmode();
    }

    /* create the main window */
    x_win = XCreateWindow(x_disp, XRootWindow(x_disp, x_visinfo->screen),
			  0, 0, // x, y
			  mode->width, mode->height, 0,	// borderwidth
			  x_visinfo->depth,
			  InputOutput, x_visinfo->visual, valuemask, &attributes);
    XFreeColormap(x_disp, attributes.colormap);

    VID_X11_SetWindowName("TyrQuake");
    VID_X11_SetIcon();

    if (x_visinfo->depth == 8) {
	/* create and upload the palette */
	if (x_visinfo->class == PseudoColor) {
	    x_cmap = XCreateColormap(x_disp, x_win, x_visinfo->visual, AllocAll);
	    VID_SetPalette(palette);
	    XSetWindowColormap(x_disp, x_win, x_cmap);
	}
    }
    VID_InitColormap(palette);

    /* Create the GC */
    {
	XGCValues xgcvalues = {};
	int valuemask = GCGraphicsExposures;

	xgcvalues.graphics_exposures = False;
	x_gc = XCreateGC(x_disp, x_win, valuemask, &xgcvalues);
    }

    XMapWindow(x_disp, x_win);
    if (VID_IsFullScreen()) {
	XMoveWindow(x_disp, x_win, 0, 0);
	XRaiseWindow(x_disp, x_win);
	XF86VidModeSetViewPort(x_disp, x_visinfo->screen, 0, 0);
    } else if (vid_window_centered.value) {
        VID_CenterWindow();
    } else {
        XMoveWindow(x_disp, x_win, (int)vid_window_x.value, (int)vid_window_y.value);
    }

    /* Wait for first expose event */
    XEvent event;
    do {
        XNextEvent(x_disp, &event);
    } while (event.type != Expose || event.xexpose.count);
    oktodraw = true;

    /* Ensure the new window has the focus */
    XSetInputFocus(x_disp, x_win, RevertToParent, CurrentTime);
    IN_Commands(); // update grabs (FIXME - this is a wierd function call to do that!)

    doShm = false;
    if (XShmQueryExtension(x_disp)) {
	doShm = true;

        /* even if MITSHM is available, make sure it's a local connection */
	char *displayname = (char *)getenv("DISPLAY");
	if (displayname) {
	    char *d = displayname;
	    while (*d && (*d != ':'))
		d++;
	    if (*d)
		*d = 0;
	    if (!(!strcasecmp(displayname, "unix") || !*displayname))
		doShm = false;
	}
    }

    VID_Mode_SetupViddef(mode, &vid);

    vid.aspect = 1;//((float)vid.height / (float)vid.width) * (320.0 / 200.0);
    vid.numpages = 2;

    if (doShm) {
	x_shmeventtype = XShmGetEventBase(x_disp) + ShmCompletion;
	ResetSharedFrameBuffers();
    } else {
	ResetFrameBuffer();
    }

    vid.rowbytes = x_framebuffer[0]->bytes_per_line;
    vid.conrowbytes = vid.rowbytes;
    vid.recalc_refdef = 1;

    SCR_CheckResize();
    Con_CheckResize();

    return true;
}

void
VID_RegisterVariables()
{
}

void
VID_AddCommands()
{
}

// Called at startup to set up translation tables, takes 256 8 bit RGB values
// the palette data will go away after the call, so it must be copied off if
// the video driver will need it again
void
VID_Init(const byte *palette)
{
    int i;
    XVisualInfo template = {};
    int num_visuals;
    int template_mask;
    int MajorVersion, MinorVersion;
    const qvidmode_t *mode;

    srandom(getpid());

    verbose = COM_CheckParm("-verbose");

    /* open the display */
    x_disp = XOpenDisplay(NULL);
    if (x_disp == NULL) {
	if (getenv("DISPLAY"))
	    Sys_Error("VID: Could not open display [%s]", getenv("DISPLAY"));
	else
	    Sys_Error("VID: Could not open local display");
    }

    /* Check video mode extension */
    MajorVersion = MinorVersion = 0;
    if (XF86VidModeQueryVersion(x_disp, &MajorVersion, &MinorVersion)) {
	Con_Printf("Using XFree86-VidModeExtension Version %i.%i\n",
		   MajorVersion, MinorVersion);
    }

    /*
     * Catch signals so i can try restore sane settings (FIXME!)
     */
    {
	struct sigaction sa;

	sigaction(SIGINT, 0, &sa);
	sa.sa_handler = TragicDeath;
	sigaction(SIGINT, &sa, 0);
	sigaction(SIGTERM, &sa, 0);
    }

    /* for debugging only(?) */
    XSynchronize(x_disp, True);

    {
	int screen;
	Visual *visual;

	screen = DefaultScreen(x_disp);
	visual = DefaultVisual(x_disp, screen);
	template.visualid = XVisualIDFromVisual(visual);
	template_mask = VisualIDMask;
    }

    // pick a visual- warn if more than one was available
    x_visinfo =	XGetVisualInfo(x_disp, template_mask, &template, &num_visuals);
    if (num_visuals > 1) {
	printf("Found more than one visual id at depth %d:\n",
	       template.depth);
	for (i = 0; i < num_visuals; i++)
	    printf("	-visualid %d\n", (int)(x_visinfo[i].visualid));
    } else if (num_visuals == 0) {
	if (template_mask == VisualIDMask)
	    Sys_Error("VID: Bad visual id %lu",
		      (unsigned long)template.visualid);
	else
	    Sys_Error("VID: No visuals at depth %u", template.depth);
    }

    if (verbose) {
	printf("Using visualid %d:\n", (int)(x_visinfo->visualid));
	printf("	screen %d\n", x_visinfo->screen);
	printf("	red_mask 0x%x\n", (int)(x_visinfo->red_mask));
	printf("	green_mask 0x%x\n", (int)(x_visinfo->green_mask));
	printf("	blue_mask 0x%x\n", (int)(x_visinfo->blue_mask));
	printf("	colormap_size %d\n", x_visinfo->colormap_size);
	printf("	bits_per_rgb %d\n", x_visinfo->bits_per_rgb);
    }

    /* Save the current video mode so we can restore when moving to windowed modes */
    VID_save_vidmode();

    VID_InitModeList();
    VID_LoadConfig();
    mode = VID_GetCmdlineMode();
    if (!mode)
        mode = VID_GetModeFromCvars();
    if (!mode)
	mode = &vid_windowed_mode;

    VID_SetMode(mode, palette);

    vid_menudrawfn = VID_MenuDraw;
    vid_menukeyfn = VID_MenuKey;
}

void
VID_ShiftPalette(const byte *palette)
{
    VID_SetPalette(palette);
}

void
VID_SetPalette(const byte *palette)
{
    int i;
    XColor colors[256];

    for (i = 0; i < 256; i++) {
	st2d_8to16table[i] = xlib_rgb16(palette[i * 3], palette[i * 3 + 1], palette[i * 3 + 2]);
	st2d_8to24table[i] = xlib_rgb24(palette[i * 3], palette[i * 3 + 1], palette[i * 3 + 2]);
    }

    if (x_visinfo->class == PseudoColor && x_visinfo->depth == 8) {
	if (palette != current_palette)
	    memcpy(current_palette, palette, 768);
	for (i = 0; i < 256; i++) {
	    colors[i].pixel = i;
	    colors[i].flags = DoRed | DoGreen | DoBlue;
	    colors[i].red = palette[i * 3] * 257;
	    colors[i].green = palette[i * 3 + 1] * 257;
	    colors[i].blue = palette[i * 3 + 2] * 257;
	}
	XStoreColors(x_disp, x_cmap, colors, 256);
    }
}

void
VID_Shutdown(void)
{
    Con_Printf("VID_Shutdown\n");
    VID_restore_vidmode();
    if (x_disp)
        XCloseDisplay(x_disp);
}

static int config_notify = 0;
static int config_notify_width;
static int config_notify_height;

void
VID_ProcessEvents(void)
{
    XEvent event;

    if (!x_disp)
	return;

    while (XPending(x_disp)) {
	XNextEvent(x_disp, &event);

	switch (event.type) {
            case KeyPress:
            case KeyRelease:
            case MotionNotify:
            case ButtonPress:
            case ButtonRelease:
            case FocusIn:
            case FocusOut:
                IN_X11_HandleInputEvent(&event);
                break;

            case ConfigureNotify:
                // TODO: set window size hints with size constraints (min/max, multiple of eight width, etc.)
                if (event.xconfigure.width != config_notify_width || event.xconfigure.height != config_notify_height) {
                    config_notify_width = event.xconfigure.width;
                    config_notify_height = event.xconfigure.height;
                    config_notify = 1;
                }
                VID_UpdateWindowPositionCvars(event.xconfigure.x, event.xconfigure.y);
                break;

            default:
                if (doShm && event.type == x_shmeventtype)
                    oktodraw = true;
                break;
	}
    }
}

static vrect_t
GetScaledRect(const vrect_t *in)
{
    vrect_t out;

    if (vid.output.scale) {
        out.x = in->x * vid.output.scale;
        out.y = in->y * vid.output.scale;
        out.width = in->width * vid.output.scale;
        out.height = in->height * vid.output.scale;
    } else {
        const float hscale = (float)vid.output.width / (float)vid.width;
        const float vscale = (float)vid.output.height / (float)vid.height;
        out.x = in->x * hscale;
        out.y = in->y * vscale;
        out.width = in->width * hscale;
        out.height = in->height * vscale;
    }

    return out;
}


// flushes the given rectangles from the view buffer to the screen
void
VID_Update(vrect_t *rects)
{
// if the window changes dimension, skip this frame
    if (config_notify) {
	config_notify = 0;

        if (vid.output.scale) {
            int width = config_notify_width / vid.output.scale;
            int height = config_notify_height / vid.output.scale;
            vid.width = vid.conwidth = qclamp(width & ~7, MINWIDTH, MAXWIDTH);
            vid.height = vid.conheight = qclamp(height, MINHEIGHT, MAXHEIGHT);
            vid.output.width = vid.width * vid.output.scale;
            vid.output.height = vid.height * vid.output.scale;
        } else {
            vid.output.width = qclamp(config_notify_width & ~7, MINWIDTH, MAXWIDTH);
            vid.output.height = qclamp(config_notify_height, MINHEIGHT, MAXHEIGHT);
            vid.width = vid.conwidth = qmin(vid.width, vid.output.width);
            vid.height = vid.conheight = qmin(vid.height, vid.output.height);
        }

	if (doShm)
	    ResetSharedFrameBuffers();
	else
	    ResetFrameBuffer();

	vid.rowbytes = x_framebuffer[0]->bytes_per_line;
	vid.buffer = (byte *)x_framebuffer[current_framebuffer]->data;
	vid.conbuffer = vid.buffer;
	vid.conwidth = vid.width;
	vid.conheight = vid.height;
	vid.conrowbytes = vid.rowbytes;
	vid.recalc_refdef = 1;	// force a surface cache flush
        SCR_CheckResize();
	Con_CheckResize();
	return;
    }

    // force full update if not 8bit
    if (x_visinfo->depth != 8)
	scr_fullupdate = 0;

    if (doShm) {
	while (rects) {
            VID_ResolveFramebuffer(x_framebuffer[current_framebuffer], rects);
            vrect_t scaled = GetScaledRect(rects);
            Bool put_image = XShmPutImage(x_disp, x_win, x_gc,
                                          x_framebuffer[current_framebuffer],
                                          scaled.x, scaled.y,
                                          scaled.x, scaled.y,
                                          scaled.width, scaled.height, True);
            if (!put_image)
                Sys_Error("VID_Update: XShmPutImage failed");

            oktodraw = false;
            while (!oktodraw)
                VID_ProcessEvents();

	    rects = rects->pnext;
	}
	current_framebuffer = !current_framebuffer;
	vid.buffer = (byte *)x_framebuffer[current_framebuffer]->data;
	vid.conbuffer = vid.buffer;
	XSync(x_disp, False);
    } else {
	while (rects) {
            VID_ResolveFramebuffer(x_framebuffer[current_framebuffer], rects);
            vrect_t scaled = GetScaledRect(rects);
            XPutImage(x_disp, x_win, x_gc,
                      x_framebuffer[0],
                      scaled.x, scaled.y,
                      scaled.x, scaled.y,
                      scaled.width, scaled.height);
	    rects = rects->pnext;
	}
	XSync(x_disp, False);
    }
}

void
Sys_SendKeyEvents(void)
{
    VID_ProcessEvents();
}

void
D_BeginDirectRect(int x, int y, const byte *pbitmap, int width, int height)
{
// direct drawing of the "accessing disk" icon isn't supported under Linux
}

void
D_EndDirectRect(int x, int y, int width, int height)
{
// direct drawing of the "accessing disk" icon isn't supported under Linux
}

void
VID_LockBuffer(void)
{
}

void
VID_UnlockBuffer(void)
{
}
