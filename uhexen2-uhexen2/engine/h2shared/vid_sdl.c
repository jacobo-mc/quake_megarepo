/*
 * vid_sdl.c -- SDL video driver
 * Select window size and mode and init SDL in SOFTWARE mode.
 *
 * Changed by S.A. 7/11/04, 27/12/04
 * Options are now: -fullscreen | -window, -height , -width
 * Currently bpp is 8 bit and it seems fairly hardwired at this depth
 *
 * Changed by O.S 7/01/06
 * - Added video modes enumeration via SDL
 * - Added video mode changing on the fly.
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 2004-2005  Steven Atkinson <stevenaaus@yahoo.com>
 * Copyright (C) 2005-2012  O.Sezer <sezero@users.sourceforge.net>
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

#include "quakedef.h"
#include "d_local.h"
#include "cfgfile.h"
#include "bgmusic.h"
#include "cdaudio.h"
#include "sdl_inc.h"

#define MIN_WIDTH		320
//#define MIN_HEIGHT		200
#define MIN_HEIGHT		240
#define MAX_DESC		13

static unsigned char	vid_curpal[256*3];	/* save for mode changes */

unsigned short	d_8to16table[256];
unsigned int	d_8to24table[256];

byte globalcolormap[VID_GRADES*256], lastglobalcolor = 0;
byte *lastsourcecolormap = NULL;

static qboolean	vid_initialized = false;
static int	lockcount;
qboolean	in_mode_set;
static int	enable_mouse;
static qboolean	palette_changed;

static int	num_fmodes;
static int	num_wmodes;
static int	*nummodes;
//static int	bpp = 8;
static SDL_Surface	*screen;
static qboolean	vid_menu_fs;
static qboolean	fs_toggle_works = true;

viddef_t	vid;		// global video state
// cvar vid_mode must be set before calling VID_SetMode, VID_ChangeVideoMode or VID_Restart_f
static cvar_t	vid_mode = {"vid_mode", "0", CVAR_NONE};
static cvar_t	vid_config_glx = {"vid_config_glx", "640", CVAR_ARCHIVE};
static cvar_t	vid_config_gly = {"vid_config_gly", "480", CVAR_ARCHIVE};
static cvar_t	vid_config_swx = {"vid_config_swx", "320", CVAR_ARCHIVE};
static cvar_t	vid_config_swy = {"vid_config_swy", "240", CVAR_ARCHIVE};
static cvar_t	vid_config_fscr= {"vid_config_fscr", "0", CVAR_ARCHIVE};

static cvar_t	vid_showload = {"vid_showload", "1", CVAR_NONE};

cvar_t		_enable_mouse = {"_enable_mouse", "1", CVAR_ARCHIVE};

static int	vid_default = -1;	// modenum of 320x240 as a safe default
static int	vid_modenum = -1;	// current video mode, set after mode setting succeeds
static int	vid_maxwidth = 640, vid_maxheight = 480;
modestate_t	modestate = MS_UNINIT;

static byte		*vid_surfcache;
static int		vid_surfcachesize;
static int		VID_highhunkmark;

typedef struct {
	modestate_t	type;
	int			width;
	int			height;
	int			modenum;
	int			fullscreen;
	int			bpp;
	int			halfscreen;
	char		modedesc[MAX_DESC];
} vmode_t;

typedef struct {
	int	width;
	int	height;
} stdmode_t;

#define RES_640X480	3
static const stdmode_t	std_modes[] = {
// NOTE: keep this list in order
	{320, 240},	// 0
	{400, 300},	// 1
	{512, 384},	// 2
	{640, 480},	// 3 == RES_640X480, this is our default, below
			//		this is the lowresmodes region.
			//		either do not change its order,
			//		or change the above define, too
	{800,  600},	// 4, RES_640X480 + 1
	{1024, 768}	// 5, RES_640X480 + 2
};

#define MAX_MODE_LIST	64
#define MAX_STDMODES	(sizeof(std_modes) / sizeof(std_modes[0]))
#define NUM_LOWRESMODES	(RES_640X480)
static vmode_t	fmodelist[MAX_MODE_LIST+1];	// list of enumerated fullscreen modes
static vmode_t	wmodelist[MAX_STDMODES +1];	// list of standart 4:3 windowed modes
static vmode_t	*modelist;	// modelist in use, points to one of the above lists

static qboolean VID_SetMode (int modenum, const unsigned char *palette);

static void VID_MenuDraw (void);
static void VID_MenuKey (int key);

// window manager stuff
#if defined(H2W)
#	define WM_TITLEBAR_TEXT	"HexenWorld"
#	define WM_ICON_TEXT	"HexenWorld"
//#elif defined(H2MP)
//#	define WM_TITLEBAR_TEXT	"Hexen II+"
//#	define WM_ICON_TEXT	"HEXEN2MP"
#else
#	define WM_TITLEBAR_TEXT	"Hexen II"
#	define WM_ICON_TEXT	"HEXEN2"
#endif


//====================================

qboolean VID_HasMouseOrInputFocus (void)
{
	return (SDL_GetAppState() & (SDL_APPMOUSEFOCUS | SDL_APPINPUTFOCUS)) != 0;
}

qboolean VID_IsMinimized (void)
{
	return !(SDL_GetAppState() & SDL_APPACTIVE);
}


/*
================
ClearAllStates
================
*/
static void ClearAllStates (void)
{
	Key_ClearStates ();
	IN_ClearStates ();
}


/*
================
VID_AllocBuffers
================
*/
static qboolean VID_AllocBuffers (int width, int height)
{
	int		tsize, tbuffersize;

	tbuffersize = width * height * sizeof (*d_pzbuffer);

	tsize = D_SurfaceCacheForRes (width, height);

	tbuffersize += tsize;

// see if there's enough memory, allowing for the normal mode 0x13 pixel,
// z, and surface buffers
	//if ((host_parms->memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 +
	//	 0x10000 * 3) < MINIMUM_MEMORY)
	// Pa3PyX: using hopefully better estimation now
	// if total memory < needed surface cache + (minimum operational memory
	// less surface cache for 320x200 and typical hunk state after init)
	if (host_parms->memsize < tbuffersize + 0x180000 + 0xC00000)
	{
		Con_SafePrintf ("Not enough memory for video mode\n");
		return false;		// not enough memory for mode
	}

	vid_surfcachesize = tsize;

	if (d_pzbuffer)
	{
		D_FlushCaches ();
		Hunk_FreeToHighMark (VID_highhunkmark);
		d_pzbuffer = NULL;
	}

	VID_highhunkmark = Hunk_HighMark ();

	d_pzbuffer = (short *) Hunk_HighAllocName (tbuffersize, "video");

	vid_surfcache = (byte *)d_pzbuffer +
			width * height * sizeof (*d_pzbuffer);
	
	return true;
}

/*
================
VID_CheckAdequateMem
================
*/
static qboolean VID_CheckAdequateMem (int width, int height)
{
	int		tbuffersize;

	tbuffersize = width * height * sizeof (*d_pzbuffer);

	tbuffersize += D_SurfaceCacheForRes (width, height);

// see if there's enough memory, allowing for the normal mode 0x13 pixel,
// z, and surface buffers
	//if ((host_parms->memsize - tbuffersize + SURFCACHE_SIZE_AT_320X200 +
	//	 0x10000 * 3) < MINIMUM_MEMORY)
	// Pa3PyX: using hopefully better estimation now
	// Experimentation: the heap should have at least 12.0 megs
	// remaining (after init) after setting video mode, otherwise
	// it's Hunk_Alloc failures and cache thrashes upon level load
	if (host_parms->memsize < tbuffersize + 0x180000 + 0xC00000)
	{
		return false;		// not enough memory for mode
	}

	return true;
}

static void VID_SetIcon (void)
{
/* from Kristian Duske:  "AFAIK, the application icon must be present in
 * Contents/Resources and it must be set in the Info.plist file. It will
 * then be used by Finder and Dock as well as for individual windows
 * unless overridden by a document icon. So SDL_WM_SetIcon() is probably
 * not necessary, and will likely use a low-res image anyway." */
#if !defined(PLATFORM_OSX)

#	include "xbm_icon.h"	/* the xbm data */
	SDL_Surface	*icon;
	SDL_Color	color;
	Uint8		*ptr;
	int		i, mask;

	icon = SDL_CreateRGBSurface(SDL_SWSURFACE, hx2icon_width, hx2icon_height, 8, 0, 0, 0, 0);
	if (icon == NULL)
		return;

	SDL_SetColorKey(icon, SDL_SRCCOLORKEY, 0);

	color.r = 255;
	color.g = 255;
	color.b = 255;
	SDL_SetColors(icon, &color, 0, 1);	/* just in case */
	color.r = 192;
	color.g = 0;
	color.b = 0;
	SDL_SetColors(icon, &color, 1, 1);

	ptr = (Uint8 *)icon->pixels;
	/* one bit represents a pixel, black or white:  each
	 * byte in the xbm array contains data for 8 pixels. */
	for (i = 0; i < (int) sizeof(hx2icon_bits); i++)
	{
		for (mask = 1; mask != 0x100; mask <<= 1)
		{
			*ptr = (hx2icon_bits[i] & mask) ? 1 : 0;
			ptr++;
		}
	}

	SDL_WM_SetIcon(icon, NULL);
	SDL_FreeSurface(icon);
#endif /* !OSX */
}

static int sort_modes (const void *arg1, const void *arg2)
{
	const SDL_Rect *a1, *a2;
	a1 = *(SDL_Rect **) arg1;
	a2 = *(SDL_Rect **) arg2;

	if (a1->w == a2->w)
		return a1->h - a2->h;	// lowres-to-highres
	//	return a2->h - a1->h;	// highres-to-lowres
	else
		return a1->w - a2->w;	// lowres-to-highres
	//	return a2->w - a1->w;	// highres-to-lowres
}

static void VID_PrepareModes (SDL_Rect **sdl_modes)
{
	int	i, j;
	qboolean	have_mem, is_multiple;
	SDL_Rect	**cpy_modes;

	num_fmodes = 0;
	num_wmodes = 0;

	// Add the standart 4:3 modes to the windowed modes list
	// In an unlikely case that we receive no fullscreen modes,
	// this will be our modes list (kind of...)
	for (i = 0; i < (int)MAX_STDMODES; i++)
	{
		have_mem = VID_CheckAdequateMem(std_modes[i].width, std_modes[i].height);
		if (!have_mem)
			break;
		wmodelist[num_wmodes].width = std_modes[i].width;
		wmodelist[num_wmodes].height = std_modes[i].height;
		wmodelist[num_wmodes].halfscreen = 0;
		wmodelist[num_wmodes].fullscreen = 0;
		wmodelist[num_wmodes].bpp = 8;
		q_snprintf (wmodelist[num_wmodes].modedesc, MAX_DESC,
				"%d x %d", std_modes[i].width, std_modes[i].height);
		num_wmodes++;
	}

	// disaster scenario #1: no fullscreen modes. bind to the
	// windowed modes list. limit it to 640x480 max. because
	// we don't know the desktop dimensions
	if (sdl_modes == (SDL_Rect **)0)
	{
no_fmodes:
		Con_SafePrintf ("No fullscreen video modes available\n");
		if (num_wmodes > RES_640X480)
			num_wmodes = RES_640X480 + 1;
		modelist = wmodelist;
		nummodes = &num_wmodes;
		vid_default = 0;
		Cvar_SetValueQuick (&vid_config_swx, modelist[vid_default].width);
		Cvar_SetValueQuick (&vid_config_swy, modelist[vid_default].height);
		return;
	}

	// another disaster scenario (#2)
	if (sdl_modes == (SDL_Rect **)-1)
	{	// Really should NOT HAVE happened! this return value is
		// for windowed modes!  Since this means all resolutions
		// are supported, use our standart modes as modes list.
		Con_SafePrintf ("Unexpectedly received -1 from SDL_ListModes\n");
		vid_maxwidth = MAXWIDTH;
		vid_maxheight = MAXHEIGHT;
	//	num_fmodes = -1;
		num_fmodes = num_wmodes;
		nummodes = &num_wmodes;
		modelist = wmodelist;
		vid_default = 0;
		Cvar_SetValueQuick (&vid_config_swx, modelist[vid_default].width);
		Cvar_SetValueQuick (&vid_config_swy, modelist[vid_default].height);
		return;
	}

#if 0
	// print the un-processed modelist as reported by SDL
	for (j = 0; sdl_modes[j]; ++j)
	{
		Con_SafePrintf ("%d x %d\n", sdl_modes[j]->w, sdl_modes[j]->h);
	}
	Con_SafePrintf ("Total %d entries\n", j);
#endif

	// sort the original list from low-res to high-res
	// so that the low resolutions take priority
	// but do so using a copy so that the original order
	// doesn't change, otherwise weird things may happen
	// with at least SDL >= 1.2.14.
	for (j = 0; sdl_modes[j]; ++j)
		;
	cpy_modes = (SDL_Rect **) Z_Malloc ((j + 1) * sizeof(SDL_Rect *), Z_MAINZONE);
	for (j = 0; sdl_modes[j]; ++j)
		cpy_modes[j] = sdl_modes[j];
	sdl_modes = cpy_modes;
	if (j > 1)
		qsort(sdl_modes, j, sizeof *sdl_modes, sort_modes);

	for (i = 0; sdl_modes[i] && num_fmodes < MAX_MODE_LIST; ++i)
	{
		// avoid multiple listings of the same dimension
		is_multiple = false;
		for (j = 0; j < num_fmodes; ++j)
		{
			if (fmodelist[j].width == sdl_modes[i]->w && fmodelist[j].height == sdl_modes[i]->h)
			{
				is_multiple = true;
				break;
			}
		}
		if (is_multiple)
			continue;
		// avoid resolutions < 320x240
		if (sdl_modes[i]->w < MIN_WIDTH || sdl_modes[i]->h < MIN_HEIGHT)
			continue;
		// avoid very high resolutions otherwise waterwarp will segfault
		// (see r_shared.h)
		if (sdl_modes[i]->w > MAXWIDTH || sdl_modes[i]->h > MAXHEIGHT)
			continue;
		// automatically strip-off resolutions that we
		// don't have enough memory for
		have_mem = VID_CheckAdequateMem(sdl_modes[i]->w, sdl_modes[i]->h);
		if (!have_mem)
			continue;

		fmodelist[num_fmodes].width = sdl_modes[i]->w;
		fmodelist[num_fmodes].height = sdl_modes[i]->h;
		// FIXME: look at vid_win.c and learn how to
		// really functionalize the halfscreen field?
		fmodelist[num_fmodes].halfscreen = 0;
		fmodelist[num_fmodes].fullscreen = 1;
		fmodelist[num_fmodes].bpp = 8;
		q_snprintf (fmodelist[num_fmodes].modedesc, MAX_DESC, "%d x %d", sdl_modes[i]->w, sdl_modes[i]->h);
		num_fmodes++;
	}

	Z_Free (cpy_modes);

	if (!num_fmodes)
		goto no_fmodes;

	// At his point, we have a list of valid fullscreen modes:
	// Let's bind to it and use it for windowed modes, as well.
	// The only downside is that if SDL doesn't report any low
	// resolutions to us, we shall not have any for windowed
	// rendering where they would be perfectly legitimate...
	// Since our fullscreen/windowed toggling is instant and
	// doesn't require a vid_restart, switching lists won't be
	// feasible, either. The -width/-height commandline args
	// remain as the user's trusty old friends here.
	nummodes = &num_fmodes;
	modelist = fmodelist;

	vid_maxwidth = fmodelist[num_fmodes-1].width;
	vid_maxheight = fmodelist[num_fmodes-1].height;

	// see if we have 320x240 among the available modes
	for (i = 0; i < num_fmodes; i++)
	{
		if (fmodelist[i].width == 320 && fmodelist[i].height == 240)
		{
			vid_default = i;
			break;
		}
	}

	if (vid_default < 0)
	{
		// 320x240 not found among the supported dimensions
		// set default to the lowest resolution reported
		vid_default = 0;
	}

	// limit the windowed (standart) modes list to desktop dimensions
	for (i = 0; i < num_wmodes; i++)
	{
		if (wmodelist[i].width > vid_maxwidth || wmodelist[i].height > vid_maxheight)
			break;
	}
	if (i < num_wmodes)
		num_wmodes = i;

	Cvar_SetValueQuick (&vid_config_swx, modelist[vid_default].width);
	Cvar_SetValueQuick (&vid_config_swy, modelist[vid_default].height);
}

static void VID_ListModes_f (void)
{
	int	i;

	Con_Printf ("Maximum allowed mode: %d x %d\n", vid_maxwidth, vid_maxheight);
	Con_Printf ("Windowed modes enabled:\n");
	for (i = 0; i < num_wmodes; i++)
		Con_Printf ("%2d:  %d x %d\n", i, wmodelist[i].width, wmodelist[i].height);
	Con_Printf ("Fullscreen modes enumerated:");
	if (num_fmodes)
	{
		Con_Printf ("\n");
		for (i = 0; i < num_fmodes; i++)
			Con_Printf ("%2d:  %d x %d\n", i, fmodelist[i].width, fmodelist[i].height);
	}
	else
	{
		Con_Printf (" None\n");
	}
}

static void VID_NumModes_f (void)
{
	Con_Printf ("%d video modes in current list\n", *nummodes);
}

static qboolean VID_SetMode (int modenum, const unsigned char *palette)
{
	Uint32 flags;
	int	is_fullscreen;

	in_mode_set = true;

	if (screen)
		SDL_FreeSurface(screen);

	flags = (SDL_SWSURFACE|SDL_HWPALETTE);
	if (vid_config_fscr.integer)
		flags |= SDL_FULLSCREEN;

	VID_SetIcon();

	// Set the mode
	screen = SDL_SetVideoMode(modelist[modenum].width, modelist[modenum].height, modelist[modenum].bpp, flags);
	if (!screen)
		return false;

	// initial success. adjust vid vars.
	vid.height = vid.conheight = modelist[modenum].height;
	vid.width = vid.conwidth = modelist[modenum].width;
	vid.buffer = vid.conbuffer = vid.direct = (pixel_t *) screen->pixels;
	vid.rowbytes = vid.conrowbytes = screen->pitch;
	vid.numpages = 1;
	vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);

	if (!VID_AllocBuffers (vid.width, vid.height))
		return false;

	D_InitCaches (vid_surfcache, vid_surfcachesize);

	// real success. set vid_modenum properly.
	vid_modenum = modenum;
	is_fullscreen = (screen->flags & SDL_FULLSCREEN) ? 1 : 0;
	modestate = (is_fullscreen) ? MS_FULLDIB : MS_WINDOWED;
	Cvar_SetValueQuick (&vid_config_swx, modelist[vid_modenum].width);
	Cvar_SetValueQuick (&vid_config_swy, modelist[vid_modenum].height);
	Cvar_SetValueQuick (&vid_config_fscr, is_fullscreen);

	IN_HideMouse ();

	ClearAllStates();

	VID_SetPalette (palette);

	SDL_WM_SetCaption(WM_TITLEBAR_TEXT, WM_ICON_TEXT);

	Con_SafePrintf ("Video Mode: %ux%ux%d\n", vid.width, vid.height, modelist[modenum].bpp);

	in_mode_set = false;
	vid.recalc_refdef = 1;

	return true;
}

//
// VID_ChangeVideoMode
// intended only as a callback for VID_Restart_f
//
static void VID_ChangeVideoMode (int newmode)
{
	int		temp;

	if (!screen)
		return;

	temp = scr_disabled_for_loading;
	scr_disabled_for_loading = true;
	CDAudio_Pause ();
	BGM_Pause ();
	S_ClearBuffer ();

	if (!VID_SetMode (newmode, vid_curpal))
	{
		if (vid_modenum == newmode)
			Sys_Error ("Couldn't set video mode: %s", SDL_GetError());

		// failed setting mode, probably due to insufficient
		// memory. go back to previous mode.
		Cvar_SetValueQuick (&vid_mode, vid_modenum);
		if (!VID_SetMode (vid_modenum, vid_curpal))
			Sys_Error ("Couldn't set video mode: %s", SDL_GetError());
	}

	CDAudio_Resume ();
	BGM_Resume ();
	scr_disabled_for_loading = temp;
}

static void VID_Restart_f (void)
{
	if (vid_mode.integer < 0 || vid_mode.integer >= *nummodes)
	{
		Con_Printf ("Bad video mode %d\n", vid_mode.integer);
		Cvar_SetValueQuick (&vid_mode, vid_modenum);
		return;
	}

	Con_Printf ("Re-initializing video:\n");
	VID_ChangeVideoMode (vid_mode.integer);
}

void VID_LockBuffer (void)
{
	lockcount++;

	if (lockcount > 1)
		return;

	SDL_LockSurface(screen);

	// Update surface pointer for linear access modes
	vid.buffer = vid.conbuffer = vid.direct = (pixel_t *) screen->pixels;
	vid.rowbytes = vid.conrowbytes = screen->pitch;

	if (r_dowarp)
		d_viewbuffer = r_warpbuffer;
	else
		d_viewbuffer = vid.buffer;

	if (r_dowarp)
		screenwidth = WARP_WIDTH;
	else
		screenwidth = vid.rowbytes;
}

void VID_UnlockBuffer (void)
{
	lockcount--;

	if (lockcount > 0)
		return;

	if (lockcount < 0)
		Sys_Error ("Unbalanced unlock");

	SDL_UnlockSurface (screen);

// to turn up any unlocked accesses
	//vid.buffer = vid.conbuffer = vid.direct = d_viewbuffer = NULL;
}


void VID_SetPalette (const unsigned char *palette)
{
	int		i;
	SDL_Color colors[256];

	palette_changed = true;

	if (palette != vid_curpal)
		memcpy(vid_curpal, palette, sizeof(vid_curpal));

	for (i = 0; i < 256; ++i)
	{
		colors[i].r = *palette++;
		colors[i].g = *palette++;
		colors[i].b = *palette++;
	}

	SDL_SetColors(screen, colors, 0, 256);
}


void VID_ShiftPalette (const unsigned char *palette)
{
	VID_SetPalette (palette);
}


/*
===================
VID_Init
===================
*/
void VID_Init (const unsigned char *palette)
{
	int		width, height, i, temp;
	SDL_Rect	**enumlist;
	const char	*read_vars[] = {
				"vid_config_fscr",
				"vid_config_swx",
				"vid_config_swy" };
#define num_readvars	( sizeof(read_vars)/sizeof(read_vars[0]) )

	temp = scr_disabled_for_loading;
	scr_disabled_for_loading = true;

	Cvar_RegisterVariable (&vid_config_fscr);
	Cvar_RegisterVariable (&vid_config_swy);
	Cvar_RegisterVariable (&vid_config_swx);
	Cvar_RegisterVariable (&vid_config_gly);
	Cvar_RegisterVariable (&vid_config_glx);
	Cvar_RegisterVariable (&vid_mode);
	Cvar_RegisterVariable (&_enable_mouse);
	Cvar_RegisterVariable (&vid_showload);

	Cmd_AddCommand ("vid_listmodes", VID_ListModes_f);
	Cmd_AddCommand ("vid_nummodes", VID_NumModes_f);
	Cmd_AddCommand ("vid_restart", VID_Restart_f);

	// init sdl
	// the first check is actually unnecessary
	if ((SDL_WasInit(SDL_INIT_VIDEO)) == 0)
	{
		if (SDL_InitSubSystem(SDL_INIT_VIDEO) < 0)
			Sys_Error("Couldn't init video: %s", SDL_GetError());
	}

	// retrieve the list of fullscreen modes
	enumlist = SDL_ListModes(NULL, SDL_SWSURFACE|SDL_HWPALETTE|SDL_FULLSCREEN);
	// prepare the modelists, find the actual modenum for vid_default
	VID_PrepareModes(enumlist);

	// set vid_mode to our safe default first
	Cvar_SetValueQuick (&vid_mode, vid_default);

	// perform an early read of config.cfg
	CFG_ReadCvars (read_vars, num_readvars);

	// windowed mode is default
	// see if the user wants fullscreen
	if (COM_CheckParm("-fullscreen") || COM_CheckParm("-f"))
	{
		Cvar_SetQuick (&vid_config_fscr, "1");
	}
	else if (COM_CheckParm("-window") || COM_CheckParm("-w"))
	{
		Cvar_SetQuick (&vid_config_fscr, "0");
	}

	if (vid_config_fscr.integer && !num_fmodes) // FIXME: see below, as well
		Sys_Error ("No fullscreen modes available at this color depth");

	width = vid_config_swx.integer;
	height = vid_config_swy.integer;

	// user is always right ...
	i = COM_CheckParm("-width");
	if (i && i < com_argc-1)
	{	// FIXME: this part doesn't know about a disaster case
		// like we aren't reported any fullscreen modes.
		width = atoi(com_argv[i+1]);

		i = COM_CheckParm("-height");
		if (i && i < com_argc-1)
			height = atoi(com_argv[i+1]);
		else	// proceed with 4/3 ratio
			height = 3 * width / 4;
	}

	// user requested a mode either from the config or from the
	// command line
	// scan existing modes to see if this is already available
	// if not, add this as the last "valid" video mode and set
	// vid_mode to it only if it doesn't go beyond vid_maxwidth
	i = 0;
	while (i < *nummodes)
	{
		if (modelist[i].width == width && modelist[i].height == height)
			break;
		i++;
	}
	if (i < *nummodes)
	{
		Cvar_SetValueQuick (&vid_mode, i);
	}
	else if ( (width <= vid_maxwidth && width >= MIN_WIDTH &&
		   height <= vid_maxheight && height >= MIN_HEIGHT) ||
		  COM_CheckParm("-force") )
	{
		modelist[*nummodes].width = width;
		modelist[*nummodes].height = height;
		modelist[*nummodes].halfscreen = 0;
		modelist[*nummodes].fullscreen = 1;
		modelist[*nummodes].bpp = 8;
		q_snprintf (modelist[*nummodes].modedesc, MAX_DESC, "%d x %d (user mode)", width, height);
		Cvar_SetValueQuick (&vid_mode, *nummodes);
		(*nummodes)++;
	}
	else
	{
		Con_SafePrintf ("ignoring invalid -width and/or -height arguments\n");
	}

	vid.maxwarpwidth = WARP_WIDTH;
	vid.maxwarpheight = WARP_HEIGHT;
	vid.colormap = host_colormap;
	vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));

	if (!VID_SetMode(vid_mode.integer, palette))
	{
		if (vid_mode.integer == vid_default)
			Sys_Error ("Couldn't set video mode: %s", SDL_GetError());

		// just one more try before dying
		Con_SafePrintf ("Couldn't set video mode %d\n"
				"Trying the default mode\n", vid_mode.integer);
		//Cvar_SetQuick (&vid_config_fscr, "0");
		Cvar_SetValueQuick (&vid_mode, vid_default);
		if (!VID_SetMode(vid_default, palette))
			Sys_Error ("Couldn't set video mode: %s", SDL_GetError());
	}

	// lock the early-read cvars until Host_Init is finished
	for (i = 0; i < (int)num_readvars; i++)
		Cvar_LockVar (read_vars[i]);

	scr_disabled_for_loading = temp;
	vid_initialized = true;

	vid_menudrawfn = VID_MenuDraw;
	vid_menukeyfn = VID_MenuKey;
}


void VID_Shutdown (void)
{
	if (vid_initialized)
	{
		if (screen != NULL && lockcount > 0)
			SDL_UnlockSurface (screen);

		vid_initialized = 0;
		SDL_QuitSubSystem(SDL_INIT_VIDEO);
	}
}


/*
================
FlipScreen
================
*/
static void FlipScreen (vrect_t *rects)
{
	while (rects)
	{
		SDL_UpdateRect (screen, rects->x, rects->y, rects->width,
				rects->height);
		rects = rects->pnext;
	}
}

void VID_Update (vrect_t *rects)
{
	vrect_t		rect;

	if (palette_changed)
	{
		palette_changed = false;
		rect.x = 0;
		rect.y = 0;
		rect.width = vid.width;
		rect.height = vid.height;
		rect.pnext = NULL;
		rects = &rect;
	}

	// We've drawn the frame; copy it to the screen
	FlipScreen (rects);

	// handle the mouse state when windowed if that's changed
	if (_enable_mouse.integer != enable_mouse /*&& modestate == MS_WINDOWED*/)
	{
		if (_enable_mouse.integer)
			IN_ActivateMouse ();
		else	IN_DeactivateMouse ();

		enable_mouse = _enable_mouse.integer;
	}
}


/*
================
D_BeginDirectRect
================
*/
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
//	these bits from quakeforge
	Uint8	*offset;

	if (!screen)
		return;
	if (x < 0)
		x = screen->w + x - 1;
	offset = (Uint8 *) screen->pixels + y * screen->pitch + x;
	while (height--)
	{
		memcpy (offset, pbitmap, width);
		offset += screen->pitch;
		pbitmap += width;
	}
}

/*
================
D_EndDirectRect
================
*/
void D_EndDirectRect (int x, int y, int width, int height)
{
//	these bits from quakeforge
	if (!screen)
		return;
	if (x < 0)
		x = screen->w + x - 1;
	SDL_UpdateRect (screen, x, y, width, height);
}


#ifndef H2W
// unused in hexenworld
void D_ShowLoadingSize (void)
{
#if defined(DRAW_PROGRESSBARS)
	static int prev_perc;
	int		cur_perc;
	vrect_t		rect;
	viddef_t	save_vid;	// global video state

	if (!vid_showload.integer)
		return;

	if (!vid_initialized)
		return;

	cur_perc = loading_stage * 100;
	if (total_loading_size)
		cur_perc += current_loading_size * 100 / total_loading_size;
	if (cur_perc == prev_perc)
		return;
	prev_perc = cur_perc;

	save_vid = vid;
	if (vid.numpages == 1)
	{
		VID_LockBuffer ();

		if (!vid.direct)
			Sys_Error ("NULL vid.direct pointer");

		vid.buffer = vid.direct;

		SCR_DrawLoading();

		VID_UnlockBuffer ();

		rect.x = 0;
		rect.y = 0;
		rect.width = vid.width;
		rect.height = 112;
		rect.pnext = NULL;

		FlipScreen (&rect);
	}
	else
	{
		vid.buffer = (byte *)screen->pixels;
		vid.rowbytes = screen->pitch;

		SCR_DrawLoading();
	}

	vid = save_vid;
#endif	/* DRAW_PROGRESSBARS */
}
#endif


/*
============================
Gamma functions for UNIX/SDL
============================
*/
#if 0
static void VID_SetGamma (void)
{
	float	value = (v_gamma.value > (1.0 / GAMMA_MAX))?
			(1.0 / v_gamma.value) : GAMMA_MAX;

	SDL_SetGamma(value,value,value);
}
#endif


//==========================================================================

/*
================
VID_HandlePause
================
*/
void VID_HandlePause (qboolean paused)
{
	if (_enable_mouse.integer /*&& (modestate == MS_WINDOWED)*/)
	{
		// for consistency, don't show pointer - S.A
		if (paused)
		{
			IN_DeactivateMouse ();
			// IN_ShowMouse ();
		}
		else
		{
			IN_ActivateMouse ();
			// IN_HideMouse ();
		}
	}
}


/*
================
VID_ToggleFullscreen
Handles switching between fullscreen/windowed modes
and brings the mouse to a proper state afterwards
================
*/
extern qboolean menu_disabled_mouse;
void VID_ToggleFullscreen (void)
{
	int	is_fullscreen;

	if (!screen) return;
	if (!fs_toggle_works)
		return;
	if (!num_fmodes)
		return;

	S_ClearBuffer ();

	fs_toggle_works = (SDL_WM_ToggleFullScreen(screen) == 1);
	if (fs_toggle_works)
	{
		is_fullscreen = (screen->flags & SDL_FULLSCREEN) ? 1 : 0;
		Cvar_SetValueQuick(&vid_config_fscr, is_fullscreen);
		modestate = (is_fullscreen) ? MS_FULLDIB : MS_WINDOWED;
		if (is_fullscreen)
		{
			// activate mouse in fullscreen mode
			// in_sdl.c handles other non-moused cases
			if (menu_disabled_mouse)
				IN_ActivateMouse();
		}
		else
		{	// windowed mode:
			// deactivate mouse if we are in menus
			if (menu_disabled_mouse)
				IN_DeactivateMouse();
		}
		// update the video menu option
		vid_menu_fs = (modestate != MS_WINDOWED);
	}
	else
	{
		Con_Printf ("SDL_WM_ToggleFullScreen failed\n");
	}
}


//========================================================
// Video menu stuff
//========================================================

static int	vid_menunum;
static int	vid_cursor;
static qboolean	want_fstoggle, need_apply;
static qboolean	vid_menu_firsttime = true;

enum {
	VID_FULLSCREEN,	// make sure the fullscreen entry (0)
	VID_RESOLUTION,	// is lower than resolution entry (1)
	VID_BLANKLINE,	// spacer line
	VID_RESET,
	VID_APPLY,
	VID_ITEMS
};

static void M_DrawYesNo (int x, int y, int on, int white)
{
	if (on)
	{
		if (white)
			M_PrintWhite (x, y, "yes");
		else
			M_Print (x, y, "yes");
	}
	else
	{
		if (white)
			M_PrintWhite (x, y, "no");
		else
			M_Print (x, y, "no");
	}
}

/*
================
VID_MenuDraw
================
*/
static void VID_MenuDraw (void)
{
	ScrollTitle("gfx/menu/title7.lmp");

	if (vid_menu_firsttime)
	{	// settings for entering the menu first time
		vid_menunum = vid_modenum;
		vid_menu_fs = (modestate != MS_WINDOWED);
		vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
		vid_menu_firsttime = false;
	}

	want_fstoggle = ( ((modestate == MS_WINDOWED) && vid_menu_fs) || ((modestate != MS_WINDOWED) && !vid_menu_fs) );

	need_apply = (vid_menunum != vid_modenum) || want_fstoggle;

	M_Print (76, 92 + 8*VID_FULLSCREEN, "Fullscreen: ");
	M_DrawYesNo (76+12*8, 92 + 8*VID_FULLSCREEN, vid_menu_fs, !want_fstoggle);

	M_Print (76, 92 + 8*VID_RESOLUTION, "Resolution: ");
	if (vid_menunum == vid_modenum)
		M_PrintWhite (76+12*8, 92 + 8*VID_RESOLUTION, modelist[vid_menunum].modedesc);
	else
		M_Print (76+12*8, 92 + 8*VID_RESOLUTION, modelist[vid_menunum].modedesc);

	if (need_apply)
	{
		M_Print (76, 92 + 8*VID_RESET, "RESET CHANGES");
		M_Print (76, 92 + 8*VID_APPLY, "APPLY CHANGES");
	}

	M_DrawCharacter (64, 92 + vid_cursor*8, 12+((int)(realtime*4)&1));
}

/*
================
VID_MenuKey
================
*/
static void VID_MenuKey (int key)
{
	switch (key)
	{
	case K_ESCAPE:
		vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
		M_Menu_Options_f ();
		return;

	case K_ENTER:
		switch (vid_cursor)
		{
		case VID_RESET:
			vid_menu_fs = (modestate != MS_WINDOWED);
			vid_menunum = vid_modenum;
			vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
			break;
		case VID_APPLY:
			if (need_apply)
			{
				Cvar_SetValueQuick(&vid_mode, vid_menunum);
				Cvar_SetValueQuick(&vid_config_fscr, vid_menu_fs);
				VID_Restart_f();
			}
			vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
			break;
		}
		return;

	case K_LEFTARROW:
		switch (vid_cursor)
		{
		case VID_FULLSCREEN:
			vid_menu_fs = !vid_menu_fs;
			if (fs_toggle_works)
				VID_ToggleFullscreen();
			break;
		case VID_RESOLUTION:
			S_LocalSound ("raven/menu1.wav");
			vid_menunum--;
			if (vid_menunum < 0)
				vid_menunum = 0;
			break;
		}
		return;

	case K_RIGHTARROW:
		switch (vid_cursor)
		{
		case VID_FULLSCREEN:
			vid_menu_fs = !vid_menu_fs;
			if (fs_toggle_works)
				VID_ToggleFullscreen();
			break;
		case VID_RESOLUTION:
			S_LocalSound ("raven/menu1.wav");
			vid_menunum++;
			if (vid_menunum >= *nummodes)
				vid_menunum = *nummodes - 1;
			break;
		}
		return;

	case K_UPARROW:
		S_LocalSound ("raven/menu1.wav");
		vid_cursor--;
		if (vid_cursor < 0)
		{
			vid_cursor = (need_apply) ? VID_ITEMS-1 : VID_BLANKLINE-1;
		}
		else if (vid_cursor == VID_BLANKLINE)
		{
			vid_cursor--;
		}
		break;

	case K_DOWNARROW:
		S_LocalSound ("raven/menu1.wav");
		vid_cursor++;
		if (vid_cursor >= VID_ITEMS)
		{
			vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
			break;
		}
		if (vid_cursor >= VID_BLANKLINE)
		{
			if (need_apply)
			{
				if (vid_cursor == VID_BLANKLINE)
					vid_cursor++;
			}
			else
			{
				vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
			}
		}
		break;

	default:
		return;
	}
}

