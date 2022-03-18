/*
 * vid_cgx.c -- CyberGraphX video driver for AmigaOS & variants.
 * Select window size and mode and init CGX in SOFTWARE mode.
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 2004-2005  Steven Atkinson <stevenaaus@yahoo.com>
 * Copyright (C) 2005-2016  O.Sezer <sezero@users.sourceforge.net>
 * Copyright (C) 2012-2016  Szilard Biro <col.lawrence@gmail.com>
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

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <cybergraphx/cybergraphics.h>
#include <exec/execbase.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/cybergraphics.h>

#include <SDI/SDI_compiler.h> /* IPTR */

/* WriteLUTPixelArray not included in vbcc_target_m68k-amigaos.lha */
#if defined(__VBCC__) && defined(__M68K__) && !defined(WriteLUTPixelArray)
ULONG __WriteLUTPixelArray(__reg("a6") void *, __reg("a0") APTR srcRect, __reg("d0") UWORD SrcX, __reg("d1") UWORD SrcY, __reg("d2") UWORD SrcMod, __reg("a1") struct RastPort * a1arg, __reg("a2") APTR a2arg, __reg("d3") UWORD DestX, __reg("d4") UWORD DestY, __reg("d5") UWORD SizeX, __reg("d6") UWORD SizeY, __reg("d7") UBYTE CTFormat)="\tjsr\t-198(a6)";
#define WriteLUTPixelArray(srcRect, SrcX, SrcY, SrcMod, a1arg, a2arg, DestX, DestY, SizeX, SizeY, CTFormat) __WriteLUTPixelArray(CyberGfxBase, (srcRect), (SrcX), (SrcY), (SrcMod), (a1arg), (a2arg), (DestX), (DestY), (SizeX), (SizeY), (CTFormat))
#endif

#include "quakedef.h"
#include "d_local.h"
#include "cfgfile.h"
#include "bgmusic.h"
#include "cdaudio.h"

#define MIN_WIDTH		320
#define MIN_HEIGHT		240
#define MAX_DESC		33

/* - CGX ----------------------------------- */

struct Window *window = NULL; /* used by in_amiga.c */
static struct Screen *screen = NULL;
static unsigned char ppal[256 * 4];
static pixel_t *buffer = NULL;
static byte *directbitmap = NULL;
#ifdef __CLIB2__
struct GfxBase *GfxBase = NULL;
#endif
#ifdef PLATFORM_AMIGAOS3
struct Library *CyberGfxBase = NULL;
#ifdef USE_C2P
static qboolean use_c2p = false;
static int currentBitMap;
static struct ScreenBuffer *sbuf[2];

#define C2P_BITMAP

#ifdef C2P_BITMAP
typedef void (*c2p_write_bm_func)(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
static c2p_write_bm_func c2p_write_bm;
#else
typedef void (*c2p_init_func)(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d3, WORD scroffsy), REG(d5, LONG bplsize));
typedef void (*c2p_write_func)(REG(a0, APTR c2pscreen), REG(a1, APTR bitplanes));
static c2p_init_func c2p_init;
static c2p_write_func c2p_write;
#endif

ASM_LINKAGE_BEGIN
extern void c2p1x1_8_c5_030_smcinit(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d3, WORD scroffsy), REG(d5, LONG bplsize));
extern void c2p1x1_8_c5_030(REG(a0, APTR c2pscreen), REG(a1, APTR bitplanes));
extern void c2p1x1_8_c5_040_init(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d3, WORD scroffsy), REG(d5, LONG bplsize));
extern void c2p1x1_8_c5_040(REG(a0, APTR c2pscreen), REG(a1, APTR bitplanes));
extern void c2p1x1_8_c5_bm(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
extern void c2p1x1_8_c5_bm_040(REG(d0, WORD chunkyx), REG(d1, WORD chunkyy), REG(d2, WORD offsx), REG(d3, WORD offsy), REG(a0, APTR chunkyscreen), REG(a1, struct BitMap *bitmap));
ASM_LINKAGE_END
#endif /* USE_C2P */
#endif /* PLATFORM_AMIGAOS3 */

/* ----------------------------------------- */

static unsigned char	vid_curpal[256*3];	/* save for mode changes */

unsigned short	d_8to16table[256];
unsigned int	d_8to24table[256];

byte globalcolormap[VID_GRADES*256], lastglobalcolor = 0;
byte *lastsourcecolormap = NULL;

qboolean	in_mode_set;
static int	enable_mouse;
static qboolean	palette_changed;

static int	num_fmodes;
static int	num_wmodes;
static int	*nummodes;

static qboolean	vid_menu_fs;
//static qboolean	fs_toggle_works = false;

viddef_t	vid;		// global video state
// cvar vid_mode must be set before calling VID_SetMode, VID_ChangeVideoMode or VID_Restart_f
static cvar_t	vid_mode = {"vid_mode", "0", CVAR_NONE};
static cvar_t	vid_config_glx = {"vid_config_glx", "640", CVAR_ARCHIVE};
static cvar_t	vid_config_gly = {"vid_config_gly", "480", CVAR_ARCHIVE};
static cvar_t	vid_config_swx = {"vid_config_swx", "320", CVAR_ARCHIVE};
static cvar_t	vid_config_swy = {"vid_config_swy", "240", CVAR_ARCHIVE};
#ifdef PLATFORM_AMIGAOS3
static cvar_t	vid_config_fscr= {"vid_config_fscr", "1", CVAR_ARCHIVE};
#else
static cvar_t	vid_config_fscr= {"vid_config_fscr", "0", CVAR_ARCHIVE};
#endif
static cvar_t	vid_config_mon = {"vid_config_mon", "0", CVAR_ARCHIVE};

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
/*	int			halfscreen;*/
	ULONG		modeid;
#ifdef PLATFORM_AMIGAOS3
	qboolean	noadapt;
#endif
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
#else
#	define WM_TITLEBAR_TEXT	"Hexen II"
#endif

//====================================

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

//------------------------------------
static int sort_modes (const void *arg1, const void *arg2)
{
	const vmode_t *a1, *a2;
	a1 = (const vmode_t *) arg1;
	a2 = (const vmode_t *) arg2;

	if (a1->width == a2->width)
		return a1->height - a2->height;	// lowres-to-highres
	//	return a2->height - a1->height;	// highres-to-lowres
	else
		return a1->width - a2->width;	// lowres-to-highres
	//	return a2->width - a1->width;	// highres-to-lowres
}

static void VID_PrepareModes (void)
{
	qboolean	have_mem;
	ULONG id;
	unsigned int i;
	APTR handle;
	struct DimensionInfo diminfo;
#ifdef PLATFORM_AMIGAOS3
	ULONG monitorid;
	struct DisplayInfo dispinfo;
	struct NameInfo nameinfo;
#endif

	num_fmodes = 0;
	num_wmodes = 0;

	// standard 4:3 windowed modes
	for (i = 0; i < (int)MAX_STDMODES; i++)
	{
		have_mem = VID_CheckAdequateMem(std_modes[i].width, std_modes[i].height);
		if (!have_mem)
			break;
		wmodelist[num_wmodes].width = std_modes[i].width;
		wmodelist[num_wmodes].height = std_modes[i].height;
		wmodelist[num_wmodes].fullscreen = 0;
		wmodelist[num_wmodes].bpp = 8;
		wmodelist[num_wmodes].modeid = INVALID_ID;
#ifdef PLATFORM_AMIGAOS3
		wmodelist[num_wmodes].noadapt = false;
#endif
		q_snprintf (wmodelist[num_wmodes].modedesc, MAX_DESC,
				"%d x %d", std_modes[i].width, std_modes[i].height);
		num_wmodes++;
	}

	// fullscreen modes
	id = INVALID_ID;
	while((id = NextDisplayInfo(id)) != INVALID_ID)
	{
#ifdef PLATFORM_AMIGAOS3
		//if (!IsCyberModeID(id))	continue;
		monitorid = id & MONITOR_ID_MASK;
		if (monitorid == DEFAULT_MONITOR_ID || monitorid == A2024_MONITOR_ID)
			continue;
#endif

		handle = FindDisplayInfo(id);
		if (!handle)
			continue;

#ifdef PLATFORM_AMIGAOS3
		if (!GetDisplayInfoData(handle, (UBYTE *)&dispinfo, sizeof(dispinfo), DTAG_DISP, 0))
			continue;
		// this is a good way to filter out HAM, EHB, DPF modes
		if (!GetDisplayInfoData(handle, (UBYTE *)&nameinfo, sizeof(nameinfo), DTAG_NAME, 0))
			continue;
		//Con_SafePrintf ("modeid %08x name %s\n", id, nameinfo.Name);
#endif

		if (!GetDisplayInfoData(handle, (UBYTE *)&diminfo, sizeof(diminfo), DTAG_DIMS, 0))
			continue;

#ifdef __AROS__
		if (diminfo.MaxDepth != 24 || diminfo.Nominal.MaxX + 1 < MIN_WIDTH)	continue;
#else
		if (diminfo.MaxDepth != 8 || diminfo.Nominal.MaxX + 1 < MIN_WIDTH)	continue;
#endif

		fmodelist[num_fmodes].width = diminfo.Nominal.MaxX + 1;
		fmodelist[num_fmodes].height = diminfo.Nominal.MaxY + 1;
#ifdef PLATFORM_AMIGAOS3
		// round down PAL resolutions to the nearest multiple of 240
		if (fmodelist[num_fmodes].height % 256 == 0)
			fmodelist[num_fmodes].height -= fmodelist[num_fmodes].height % MIN_HEIGHT;
#endif
		fmodelist[num_fmodes].fullscreen = 1;
		fmodelist[num_fmodes].bpp = 8; // diminfo.MaxDepth
		fmodelist[num_fmodes].modeid = id;
		q_snprintf (fmodelist[num_fmodes].modedesc, MAX_DESC, "%d x %d", (fmodelist[num_fmodes].width), (fmodelist[num_fmodes].height));
#ifdef PLATFORM_AMIGAOS3
		if (dispinfo.PropertyFlags & DIPF_IS_LACE)
			q_strlcat(fmodelist[num_fmodes].modedesc, "i", MAX_DESC);
		if (monitorid == PAL_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " PAL", MAX_DESC);
		else if (monitorid == NTSC_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " NTSC", MAX_DESC);
		else if (monitorid == DBLPAL_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " DblPAL", MAX_DESC);
		else if (monitorid == DBLNTSC_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " DblNTSC", MAX_DESC);
		else if (monitorid == EURO36_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " Euro36", MAX_DESC);
		else if (monitorid == EURO72_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " Euro72", MAX_DESC);
		else if (monitorid == SUPER72_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " Super72", MAX_DESC);
		else if (monitorid == VGA_MONITOR_ID)
			q_strlcat(fmodelist[num_fmodes].modedesc, " VGA", MAX_DESC);
		else
			q_strlcat(fmodelist[num_fmodes].modedesc, " RTG", MAX_DESC);

		fmodelist[num_fmodes].noadapt = (!CyberGfxBase || !IsCyberModeID(id));
#endif
		//Con_SafePrintf ("fmodelist[%d].modedesc = %s maxdepth %d id %08x\n", num_fmodes, fmodelist[num_fmodes].modedesc, diminfo.MaxDepth, id);

		if (++num_fmodes == MAX_MODE_LIST)
			break;
	}

	if (num_fmodes == 0)
	{
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

	if (num_fmodes > 1)
		qsort(fmodelist, num_fmodes, sizeof(vmode_t), sort_modes);
	nummodes = &num_fmodes;
	modelist = fmodelist;

	/*vid_maxwidth = fmodelist[num_fmodes-1].width;
	vid_maxheight = fmodelist[num_fmodes-1].height;*/
	if ((screen = LockPubScreen(NULL)))
	{
		vid_maxwidth = screen->Width;
		vid_maxheight = screen->Height;
		UnlockPubScreen(NULL, screen);
		screen = NULL;
	}

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

	// limit the windowed (standard) modes list to desktop dimensions
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

//====================================


static void VID_DestroyWindow (void)
{
	if (window)
	{
		CloseWindow(window);
		window = NULL;
	}

	if (buffer)
	{
		free(buffer);
		buffer = NULL;
	}

	/*if (pointermem)
	{
		FreeVec(pointermem);
		pointermem = NULL;
	}*/

#if defined(PLATFORM_AMIGAOS3) && defined(USE_C2P)
	use_c2p = false;

	if (sbuf[0])
	{
		FreeScreenBuffer(screen, sbuf[0]);
		sbuf[0] = NULL;
	}

	if (sbuf[1])
	{
		FreeScreenBuffer(screen, sbuf[1]);
		sbuf[1] = NULL;
	}
#endif

	if (screen)
	{
		CloseScreen(screen);
		screen = NULL;
	}
}

static qboolean VID_SetMode (int modenum, const unsigned char *palette)
{
	ULONG flags;
	qboolean eightbit = false;

	in_mode_set = true;

	VID_DestroyWindow ();

	if (!vid_config_fscr.integer && (screen = LockPubScreen(NULL)))
	{
		eightbit = (GetBitMapAttr(screen->RastPort.BitMap, BMA_DEPTH) <= 8);
		UnlockPubScreen(NULL, screen);
		screen = NULL;

		if (eightbit)
		{
			struct EasyStruct es;

			es.es_StructSize = sizeof(es);
			es.es_Flags = 0;
			es.es_Title = (STRPTR) ENGINE_NAME;
			es.es_TextFormat = (STRPTR) "Windowed mode requires 15 bit or higher color depth screen\nFalling back to fullscreen.";
			es.es_GadgetFormat = (STRPTR) "OK";

			EasyRequest(0, &es, 0, 0);

			Cvar_SetQuick (&vid_config_fscr, "1");
		}
	}

	flags = WFLG_ACTIVATE | WFLG_RMBTRAP;

	if (vid_config_fscr.integer)
	{
		ULONG ModeID;
		#if defined(PLATFORM_AMIGAOS3) && defined(USE_C2P)
		struct BitMap *bm;
		#endif

		/*ModeID = BestCModeIDTags(
			CYBRBIDTG_Depth, 8,
			CYBRBIDTG_NominalWidth, modelist[modenum].width,
			CYBRBIDTG_NominalHeight, modelist[modenum].height,
			TAG_DONE);*/
		ModeID = modelist[modenum].modeid;

		screen = OpenScreenTags(0,
			ModeID != INVALID_ID ? SA_DisplayID : TAG_IGNORE, ModeID,
			SA_Width, modelist[modenum].width,
			SA_Height, modelist[modenum].height,
			SA_Depth, 8,
			SA_Quiet, TRUE,
			TAG_DONE);

		#if defined(PLATFORM_AMIGAOS3) && defined(USE_C2P)
		currentBitMap = 0;
		bm = screen->RastPort.BitMap;

		if ((GetBitMapAttr(bm, BMA_FLAGS) & BMF_STANDARD) && (modelist[modenum].width % 32) == 0)
		{
			if ((sbuf[0] = AllocScreenBuffer(screen, 0, SB_SCREEN_BITMAP)) && (sbuf[1] = AllocScreenBuffer(screen, 0, 0)))
			{
				use_c2p = true;
				#ifndef C2P_BITMAP
				c2p_init(modelist[modenum].width, modelist[modenum].height, 0, bm->BytesPerRow*bm->Rows);
				#endif
				// this fixes some RTG modes which would otherwise display garbage on the 1st buffer swap
				//VID_Update(NULL);
			}
		}
		#endif
	}

	if (screen)
	{
		flags |= WFLG_BACKDROP | WFLG_BORDERLESS;
	}
	else
	{
		if (eightbit) /* shouldn't happen, but.. */
			Sys_Error("failed OpenScreen ()");
		Cvar_SetQuick (&vid_config_fscr, "0");
		flags |=  WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET;
	}

	window = OpenWindowTags(0,
		WA_InnerWidth, modelist[modenum].width,
		WA_InnerHeight, modelist[modenum].height,
		WA_Title, (IPTR)WM_TITLEBAR_TEXT,
		WA_Flags, flags,
		screen ? WA_CustomScreen : TAG_IGNORE, (IPTR)screen,
		WA_IDCMP, IDCMP_CLOSEWINDOW | IDCMP_ACTIVEWINDOW | IDCMP_INACTIVEWINDOW,
		TAG_DONE);

	if (window)
	{
		/*pointermem = AllocVec(256, MEMF_ANY | MEMF_CLEAR);
		if (pointermem) {*/
			vid.height = vid.conheight = modelist[modenum].height;
			vid.rowbytes = vid.conrowbytes = vid.width = vid.conwidth = modelist[modenum].width;
			buffer = (pixel_t *) malloc(vid.width * vid.height);

			if (buffer)
			{
				vid.buffer = vid.direct = vid.conbuffer = buffer;
				vid.numpages = 1;
				vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);

				if (VID_AllocBuffers (vid.width, vid.height))
				{
					D_InitCaches (vid_surfcache, vid_surfcachesize);

					// real success. set vid_modenum properly.
					vid_modenum = modenum;
					modestate = (screen) ? MS_FULLDIB : MS_WINDOWED;
					Cvar_SetValueQuick (&vid_config_swx, modelist[vid_modenum].width);
					Cvar_SetValueQuick (&vid_config_swy, modelist[vid_modenum].height);
					if (screen)
						Cvar_SetValueQuick (&vid_config_mon, (float)(modelist[vid_modenum].modeid & MONITOR_ID_MASK));

					//IN_HideMouse ();

					ClearAllStates();

					VID_SetPalette (palette);

					Con_SafePrintf ("Video Mode: %ux%ux%d\n", vid.width, vid.height, modelist[modenum].bpp);

					#ifdef PLATFORM_AMIGAOS3
					vid.noadapt = modelist[modenum].noadapt;
					#endif
					in_mode_set = false;
					vid.recalc_refdef = 1;

					return true;
				}
				free(buffer);
				buffer = NULL;
			}
		/*	FreeVec(pointermem);
			pointermem = NULL;
		}*/
		CloseWindow(window);
		window = NULL;
	}

	if (screen)
	{
		CloseScreen(screen);
		screen = NULL;
	}

	in_mode_set = false;
	return false;
}


static void VID_ChangeVideoMode (int newmode)
{
	int		temp;

	temp = scr_disabled_for_loading;
	scr_disabled_for_loading = true;
	CDAudio_Pause ();
	BGM_Pause ();
	S_ClearBuffer ();

	if (!VID_SetMode (newmode, vid_curpal))
	{
		if (vid_modenum == newmode)
			Sys_Error ("Couldn't set video mode");

		// failed setting mode, probably due to insufficient
		// memory. go back to previous mode.
		Cvar_SetValueQuick (&vid_mode, vid_modenum);
		if (!VID_SetMode (vid_modenum, vid_curpal))
			Sys_Error ("Couldn't set video mode");
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

void VID_LockBuffer(void)
{
}

void VID_UnlockBuffer(void)
{
}


void VID_SetPalette(const unsigned char *palette)
{
	const unsigned char *p;
	unsigned char *pp;
	int i;

	palette_changed = true;

	if (palette != vid_curpal)
		memcpy(vid_curpal, palette, sizeof(vid_curpal));

	if (screen)
	{
		ULONG spal[1 + (256 * 3) + 1];
		ULONG *sp = spal;

		*sp++ = 256 << 16;

		for (i = 0, p = palette; i < 256; i++)
		{
			*sp++ = ((ULONG) *p++) << 24;
			*sp++ = ((ULONG) *p++) << 24;
			*sp++ = ((ULONG) *p++) << 24;
		}

		*sp = 0;

		LoadRGB32(&screen->ViewPort, spal);
	}

	for (i = 0, p = palette, pp = ppal; i < 256; i++)
	{
		if (host_bigendian)
		{
			*pp++ = 0;
			*pp++ = *p++;
			*pp++ = *p++;
			*pp++ = *p++;
		}
		else
		{
			*pp++ = p[2];
			*pp++ = p[1];
			*pp++ = p[0];
			*pp++ = 0;
			p += 3;
		}
	}
}

void VID_ShiftPalette(const unsigned char *palette)
{
	VID_SetPalette(palette);
}

void VID_Init (const unsigned char *palette)
{
	int		width, height, i, temp, monitor;
	const char	*read_vars[] = {
				"vid_config_fscr",
				"vid_config_mon",
				"vid_config_swx",
				"vid_config_swy" };
#define num_readvars	( sizeof(read_vars)/sizeof(read_vars[0]) )

#ifdef __CLIB2__
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);
	if (!GfxBase)
		Sys_Error ("Cannot open graphics.library!");
#endif

#ifdef PLATFORM_AMIGAOS3
	CyberGfxBase = OpenLibrary("cybergraphics.library", 0);
	/*if (!CyberGfxBase)
		Sys_Error ("Cannot open cybergraphics.library!");*/

#ifdef USE_C2P
	if (SysBase->AttnFlags & AFF_68040)
	{
#ifdef C2P_BITMAP
		c2p_write_bm = c2p1x1_8_c5_bm_040;
#else
		c2p_init = c2p1x1_8_c5_040_init;
		c2p_write = c2p1x1_8_c5_040;
#endif
	}
	else
	{
#ifdef C2P_BITMAP
		c2p_write_bm = c2p1x1_8_c5_bm;
#else
		c2p_init = c2p1x1_8_c5_030_smcinit;
		c2p_write = c2p1x1_8_c5_030;
#endif
	}
#endif
#endif

	temp = scr_disabled_for_loading;
	scr_disabled_for_loading = true;

	Cvar_RegisterVariable (&vid_config_fscr);
	Cvar_RegisterVariable (&vid_config_mon);
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


	// prepare the modelists, find the actual modenum for vid_default
	VID_PrepareModes();
	//VID_ListModes_f();

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
	monitor = vid_config_mon.integer;

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

	// pick the appropriate list
	if (vid_config_fscr.integer)
	{
		modelist = fmodelist;
		nummodes = &num_fmodes;
	}
	else
	{
		modelist = wmodelist;
		nummodes = &num_wmodes;
	}

	// user requested a mode either from the config or from the
	// command line
	// scan existing modes to see if this is already available
	// if not, add this as the last "valid" video mode and set
	// vid_mode to it only if it doesn't go beyond vid_maxwidth
	i = 0;
	if (vid_config_fscr.integer)
	{
		while (i < *nummodes)
		{
			if (modelist[i].width == width && modelist[i].height == height && (modelist[i].modeid & MONITOR_ID_MASK) == monitor)
				break;
			i++;
		}
	}
	if (i == 0 || i == *nummodes)
	{
		i = 0;
		while (i < *nummodes)
		{
			if (modelist[i].width == width && modelist[i].height == height)
				break;
			i++;
		}
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
		modelist[*nummodes].fullscreen = 1;
		modelist[*nummodes].bpp = 8;
		modelist[*nummodes].modeid = INVALID_ID;
#ifdef PLATFORM_AMIGAOS3
		modelist[*nummodes].noadapt = false;
#endif
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

	if (!VID_SetMode (vid_mode.integer, palette))
	{
		if (vid_mode.integer == vid_default)
			Sys_Error ("Couldn't set video mode");

		// just one more try before dying
		Con_SafePrintf ("Couldn't set video mode %d\n"
				"Trying the default mode\n", vid_mode.integer);
		//Cvar_SetQuick (&vid_config_fscr, "0");
		Cvar_SetValueQuick (&vid_mode, vid_default);
		if (!VID_SetMode (vid_default, palette))
			Sys_Error ("Couldn't set video mode");
	}

	// lock the early-read cvars until Host_Init is finished
	for (i = 0; i < (int)num_readvars; i++)
		Cvar_LockVar (read_vars[i]);

	scr_disabled_for_loading = temp;

	vid_menudrawfn = VID_MenuDraw;
	vid_menukeyfn = VID_MenuKey;
}


void VID_Shutdown (void)
{
	VID_DestroyWindow ();

#ifdef PLATFORM_AMIGAOS3
	if (CyberGfxBase) {
		CloseLibrary(CyberGfxBase);
		CyberGfxBase = NULL;
	}
#endif
#ifdef __CLIB2__
	if (GfxBase) {
		CloseLibrary((struct Library *)GfxBase);
		GfxBase = NULL;
	}
#endif
}


static void FlipScreen (vrect_t *rects)
{
#ifdef USE_C2P
	if (use_c2p)
	{
		currentBitMap ^= 1;
#ifdef C2P_BITMAP
		c2p_write_bm(vid.width, vid.height, 0, 0, vid.buffer, sbuf[currentBitMap]->sb_BitMap);
#else
		c2p_write(vid.buffer, sbuf[currentBitMap]->sb_BitMap->Planes[0]);
#endif
		ChangeScreenBuffer(screen, sbuf[currentBitMap]);
		return;
	}
#endif

	while (rects)
	{
#ifdef PLATFORM_AMIGAOS3
		if (!CyberGfxBase)
		{
			WriteChunkyPixels(window->RPort,
							rects->x,
							rects->y,
							rects->width,
							rects->height,
							vid.buffer,
							vid.rowbytes);
		}
		else
#endif
		if (screen)
		{
			WritePixelArray(vid.buffer,
							rects->x,
							rects->y,
							vid.rowbytes,
							window->RPort,
							rects->x,
							rects->y,
							rects->width,
							rects->height,
							RECTFMT_LUT8);
		}
		else
		{
			WriteLUTPixelArray(vid.buffer,
							rects->x,
							rects->y,
							vid.rowbytes,
							window->RPort, ppal,
							window->BorderLeft + rects->x,
							window->BorderTop + rects->y,
							rects->width,
							rects->height,
							CTABFMT_XRGB8);
		}

		rects = rects->pnext;
	}
}

void VID_Update(vrect_t *rects)
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
	directbitmap = pbitmap;
}

/*
================
D_EndDirectRect
================
*/
void D_EndDirectRect (int x, int y, int width, int height)
{
	if (!window || !directbitmap)
		return;

	if (x < 0)
		x = vid.width + x - 1;

	if (screen)
	{
		WritePixelArray(directbitmap, 0, 0, width, window->RPort, x, y, width, height, RECTFMT_LUT8);
	}
	else
	{
		WriteLUTPixelArray(directbitmap, 0, 0, width, window->RPort, ppal, window->BorderLeft + x, window->BorderTop + y, width, height, CTABFMT_XRGB8);
	}

	directbitmap = NULL;
}

#ifndef H2W
// unused in hexenworld
void D_ShowLoadingSize (void)
{
#if defined(DRAW_PROGRESSBARS)
#error NOT IMPLEMENTED
#endif
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
			//SetPointer(window, pointermem, 16, 16, 0, 0);	
		}
		else
		{
			IN_ActivateMouse ();
			//ClearPointer(window);
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
//extern qboolean menu_disabled_mouse;
void VID_ToggleFullscreen(void)
{
	// implement this...
}


//========================================================
// Video menu stuff
//========================================================

static int	vid_menunum;
static int	vid_cursor;
static vmode_t	*vid_menulist;	// this changes when vid_menu_fs changes
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
		vid_menulist = (modestate == MS_WINDOWED) ? wmodelist : fmodelist;
		vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
		vid_menu_firsttime = false;
	}

	want_fstoggle = ( ((modestate == MS_WINDOWED) && vid_menu_fs) || ((modestate != MS_WINDOWED) && !vid_menu_fs) );

	need_apply = (vid_menunum != vid_modenum) || want_fstoggle;

	M_Print (76, 92 + 8*VID_FULLSCREEN, "Fullscreen: ");
	M_DrawYesNo (76+12*8, 92 + 8*VID_FULLSCREEN, vid_menu_fs, !want_fstoggle);

	M_Print (76, 92 + 8*VID_RESOLUTION, "Resolution: ");
	if (vid_menunum == vid_modenum)
		M_PrintWhite (76+12*8, 92 + 8*VID_RESOLUTION, vid_menulist[vid_menunum].modedesc);
	else
		M_Print (76+12*8, 92 + 8*VID_RESOLUTION, vid_menulist[vid_menunum].modedesc);

	if (need_apply)
	{
		M_Print (76, 92 + 8*VID_RESET, "RESET CHANGES");
		M_Print (76, 92 + 8*VID_APPLY, "APPLY CHANGES");
	}

	M_DrawCharacter (64, 92 + vid_cursor*8, 12+((int)(realtime*4)&1));
}

static int match_windowed_fullscr_modes (void)
{
	int	l;
	vmode_t	*tmplist;
	int	*tmpcount;

	// choose the new mode
	tmplist = (vid_menu_fs) ? fmodelist : wmodelist;
	tmpcount = (vid_menu_fs) ? &num_fmodes : &num_wmodes;
	for (l = 0; l < *tmpcount; l++)
	{
		if (tmplist[l].width == vid_menulist[vid_menunum].width &&
		    tmplist[l].height == vid_menulist[vid_menunum].height)
		{
			return l;
		}
	}
	return 0;
}

/*
================
VID_MenuKey
================
*/
static void VID_MenuKey (int key)
{
	int	*tmpnum;

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
			vid_menulist = (modestate == MS_WINDOWED) ? wmodelist : fmodelist;
			vid_cursor = (num_fmodes) ? 0 : VID_RESOLUTION;
			break;
		case VID_APPLY:
			if (need_apply)
			{
				Cvar_SetValueQuick(&vid_mode, vid_menunum);
				Cvar_SetValueQuick(&vid_config_fscr, vid_menu_fs);
				modelist = (vid_menu_fs) ? fmodelist : wmodelist;
				nummodes = (vid_menu_fs) ? &num_fmodes : &num_wmodes;
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
			vid_menunum = match_windowed_fullscr_modes();
			vid_menulist = (vid_menu_fs) ? fmodelist : wmodelist;
			/*if (fs_toggle_works)
				VID_ToggleFullscreen();*/
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
			vid_menunum = match_windowed_fullscr_modes();
			vid_menulist = (vid_menu_fs) ? fmodelist : wmodelist;
			/*if (fs_toggle_works)
				VID_ToggleFullscreen();*/
			break;
		case VID_RESOLUTION:
			S_LocalSound ("raven/menu1.wav");
			tmpnum = (vid_menu_fs) ? &num_fmodes : &num_wmodes;
			vid_menunum++;
			/*if (vid_menunum >= *nummodes)
				vid_menunum = *nummodes - 1;*/
			if (vid_menunum >= *tmpnum)
				vid_menunum--;
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

