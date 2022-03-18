/* in_amiga.c -- Intuition game input code for Amiga & co.
 *
 * Copyright (C) 2005-2010 Mark Olsen <bigfoot@private.dk>
 * Copyright (C) 2012-2016 Szilard Biro <col.lawrence@gmail.com>
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

#include <devices/input.h>
#if defined __AROS__
#include <devices/rawkeycodes.h>
#define NM_WHEEL_UP RAWKEY_NM_WHEEL_UP
#define NM_WHEEL_DOWN RAWKEY_NM_WHEEL_DOWN
#define NM_BUTTON_FOURTH RAWKEY_NM_BUTTON_FOURTH
#elif !defined __MORPHOS__
#include <newmouse.h>
#endif
#include <libraries/lowlevel.h>
#include <intuition/intuition.h>
#ifdef __AROS__
#include <proto/alib.h>
#else
#include <clib/alib_protos.h>
#endif
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/keymap.h>
#include <proto/lowlevel.h>
#ifdef __AROS__
#include <SDI/SDI_interrupt.h>
#elif !defined __MORPHOS__
#include <SDI/SDI_interrupt.h>
#endif
#ifdef __AMIGA__
#include <intuition/intuitionbase.h>
#endif

#include "quakedef.h"

struct Library *LowLevelBase = NULL;
#ifdef __CLIB2__
struct Library *KeymapBase = NULL;
#endif

extern struct Window *window;
static struct Interrupt InputHandler;
static struct MsgPort *inputport;
static struct IOStdReq *inputreq;
static UWORD *pointermem;

static int mx;
static int my;
#define MAXIMSGS 32
static struct InputEvent imsgs[MAXIMSGS];
static int imsglow;
static int imsghigh;

/* mouse variables */
static cvar_t	m_filter = {"m_filter", "0", CVAR_NONE};

static int	mouse_x, mouse_y, old_mouse_x, old_mouse_y;

static qboolean	mouseactive = false;
static qboolean	mouseinitialized = false;
static qboolean	mouseactivatetoggle = false;
/*static qboolean	mouseshowtoggle = true;*/

/* joystick support: */
static int joy_port = -1;
static int joy_available = 0;
static ULONG oldjoyflag = 0;

static	cvar_t	in_joystick = {"joystick", "1", CVAR_ARCHIVE};		/* enable/disable joystick */
static	cvar_t	joy_index = {"joy_index", "1", CVAR_NONE};		/* joystick to use when have multiple */

/* forward-referenced functions */
static void IN_StartupJoystick (void);
static void IN_Callback_JoyEnable (cvar_t *var);
static void IN_Callback_JoyIndex (cvar_t *var);

#ifdef PLATFORM_AMIGAOS3
static unsigned char keyconv[] =
{
	'`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',							/*  10 */
	'-', '=', '\\', 0, K_KP_INS, 'q', 'w', 'e', 'r', 't',							/*  20 */
	'y', 'u', 'i', 'o', 'p', '[', ']', 0, K_KP_END, K_KP_DOWNARROW,						/*  30 */
	K_KP_PGDN, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',							/*  40 */
	';', '\'', 0, 0, K_KP_LEFTARROW, K_KP_5, K_KP_RIGHTARROW, '<', 'z', 'x',				/*  50 */
	'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, K_KP_DEL,							/*  60 */
	K_KP_HOME, K_KP_UPARROW, K_KP_PGUP, ' ', K_BACKSPACE, K_TAB, K_KP_ENTER, K_ENTER, K_ESCAPE, K_DEL,	/*  70 */
	0, 0, 0, K_KP_MINUS, 0, K_UPARROW, K_DOWNARROW, K_RIGHTARROW, K_LEFTARROW, K_F1,	/*  80 */
	K_F2, K_F3, K_F4, K_F5, K_F6, K_F7, K_F8, K_F9, K_F10, K_KP_NUMLOCK,						/*  90 */
	0, K_KP_SLASH, K_KP_STAR, K_KP_PLUS, K_PAUSE, K_SHIFT, K_SHIFT, 0, K_CTRL, K_ALT,					/* 100 */
	K_ALT, 0, 0, 0, 0, 0, 0, 0, 0, 0,									/* 110 */
};
#else
static unsigned char keyconv[] =
{
	'`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',							/*  10 */
	'-', '=', 0, 0, K_KP_INS, 'q', 'w', 'e', 'r', 't',							/*  20 */
	'y', 'u', 'i', 'o', 'p', '[', ']', 0, K_KP_END, K_KP_DOWNARROW,						/*  30 */
	K_KP_PGDN, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',							/*  40 */
	';', '\'', '\\', 0, K_KP_LEFTARROW, K_KP_5, K_KP_RIGHTARROW, '<', 'z', 'x',				/*  50 */
	'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, K_KP_DEL,							/*  60 */
	K_KP_HOME, K_KP_UPARROW, K_KP_PGUP, ' ', K_BACKSPACE, K_TAB, K_KP_ENTER, K_ENTER, K_ESCAPE, K_DEL,	/*  70 */
	K_INS, K_PGUP, K_PGDN, K_KP_MINUS, K_F11, K_UPARROW, K_DOWNARROW, K_RIGHTARROW, K_LEFTARROW, K_F1,	/*  80 */
	K_F2, K_F3, K_F4, K_F5, K_F6, K_F7, K_F8, K_F9, K_F10, 0,						/*  90 */
	0, K_KP_SLASH, K_KP_STAR, K_KP_PLUS, 0, K_SHIFT, K_SHIFT, 0, K_CTRL, K_ALT,					/* 100 */
	K_ALT, 0, 0, 0, 0, 0, 0, 0, K_KP_NUMLOCK, K_PAUSE,									/* 110 */
	K_F12, K_HOME, K_END, 0, 0, 0, 0, 0, 0, 0,								/* 120 */
};
#endif
#define MAX_KEYCONV (sizeof keyconv / sizeof keyconv[0])


/*
===========
Force_CenterView_f
===========
*/
static void Force_CenterView_f (void)
{
	cl.viewangles[PITCH] = 0;
}


/*
===========
IN_ShowMouse
===========
*/
void IN_ShowMouse (void)
{
	if (window && window->Pointer == pointermem)
	{
		ClearPointer(window);
		//Con_Printf("IN_ShowMouseOK\n");
	}
}


/*
===========
IN_HideMouse
===========
*/
void IN_HideMouse (void)
{
	if (window && pointermem && window->Pointer != pointermem)
	{
		SetPointer(window, pointermem, 1, 1, 0, 0);
		//Con_Printf("IN_HideMouseOK\n");
	}
}

/* ============================================================
   NOTES on enabling-disabling the mouse:
   - In windowed mode, mouse is temporarily disabled in main
     menu, so the un-grabbed pointer can be used for desktop
     This state is stored in menu_disabled_mouse as true
   - In fullscreen mode, we don't disable the mouse in menus,
     if we toggle windowed/fullscreen, the above state variable
     is used to correct this in VID_ToggleFullscreen()
   - In the console mode and in the options menu-group, mouse
     is not disabled, and menu_disabled_mouse is set to false
   - Starting a or connecting to a server activates the mouse
     and sets menu_disabled_mouse to false
   - Pausing the game disables (so un-grabs) the mouse, unpausing
     activates it. We don't play with menu_disabled_mouse in
     such cases
*/

/*
===========
IN_ActivateMouse
===========
*/
void IN_ActivateMouse (void)
{
	mouseactivatetoggle = true;

	if (mouseinitialized && _enable_mouse.integer)
	{
		IN_HideMouse();
		mouseactive = true;
	}
}

/*
===========
IN_DeactivateMouse
===========
*/
void IN_DeactivateMouse (void)
{
	mouseactivatetoggle = false;

	if (mouseinitialized)
	{
		IN_ShowMouse();
		mouseactive = false;
	}
}

/*
===========
IN_StartupMouse
===========
*/
static void IN_StartupMouse (void)
{
	mx = my = old_mouse_x = old_mouse_y = 0;

/*	IN_HideMouse ();*/
	if (safemode || COM_CheckParm ("-nomouse"))
	{
		IN_DeactivateMouse();
		return;
	}

	mouseinitialized = true;

// if a fullscreen video mode was set before the mouse was initialized,
// set the mouse state appropriately
	if (mouseactivatetoggle)
		IN_ActivateMouse ();
	else
		IN_DeactivateMouse ();
}


/*
===================
IN_ClearStates
===================
*/
void IN_ClearStates (void)
{
}

/*
===================
IN_KeyboardHandler
===================
*/
static qboolean IN_AddEvent(struct InputEvent *coin)
{
	if ((imsghigh > imsglow && !(imsghigh == MAXIMSGS - 1 && imsglow == 0)) ||
		(imsghigh < imsglow && imsghigh != imsglow - 1) ||
		(imsglow == imsghigh))
	{
		CopyMem(coin, &imsgs[imsghigh], sizeof(struct InputEvent));
		imsghigh++;
		imsghigh %= MAXIMSGS;
		return true;
	}

	return false;
}

static struct InputEvent *IN_GetNextEvent(void)
{
	struct InputEvent *ie = NULL;

	if (imsglow != imsghigh)
	{
		ie = &imsgs[imsglow];
		imsglow++;
		imsglow %= MAXIMSGS;
	}

	return ie;
}

#ifdef __MORPHOS__ /* MorphOS SDI handler macros are messed up */
static struct InputEvent *IN_KeyboardHandlerFunc(void);

static struct EmulLibEntry IN_KeyboardHandler =
{
	TRAP_LIB, 0, (void (*)(void))IN_KeyboardHandlerFunc
};

static struct InputEvent *IN_KeyboardHandlerFunc()
{
	struct InputEvent *moo = (struct InputEvent *)REG_A0;
	struct inputdata *id = (struct inputdata *)REG_A1;
#else
HANDLERPROTO(IN_KeyboardHandler, struct InputEvent *, struct InputEvent *moo, APTR id)
{
#endif
	struct InputEvent *coin;

	ULONG screeninfront;

	if (!window || !(window->Flags & WFLG_WINDOWACTIVE))
		return moo;

	if (window->WScreen)
	{
#ifdef __MORPHOS__
		if (IntuitionBase->LibNode.lib_Version > 50 || (IntuitionBase->LibNode.lib_Version == 50 && IntuitionBase->LibNode.lib_Revision >= 56))
			GetAttr(SA_Displayed, window->WScreen, &screeninfront);
		else
#endif
			screeninfront = (window->WScreen == IntuitionBase->FirstScreen);
	}
	else
		screeninfront = 1;

	for (coin = moo; coin; coin = coin->ie_NextEvent)
	{
		if (coin->ie_Class == IECLASS_RAWKEY)
		{
			int code;
			
			// mouse button 4, mouse wheel and keyboard
			code = coin->ie_Code & ~IECODE_UP_PREFIX;
			if (code >= NM_WHEEL_UP && code <= NM_BUTTON_FOURTH)
			{
				// we don't need these, they will be handled under IECLASS_NEWMOUSE
				/*if (mouseactive && screeninfront)
				{
					IN_AddEvent(coin);
					coin->ie_Code = IECODE_NOBUTTON;
				}*/
			}
			else
			{
				IN_AddEvent(coin);
			}
		}
		else if (coin->ie_Class == IECLASS_RAWMOUSE && mouseactive && screeninfront)
		{
			// mouse buttons 1-3
			if (coin->ie_Code != IECODE_NOBUTTON)
			{
				IN_AddEvent(coin);
				coin->ie_Code = IECODE_NOBUTTON;
			}

			// mouse movement
			mx += coin->ie_position.ie_xy.ie_x;
			my += coin->ie_position.ie_xy.ie_y;
			coin->ie_position.ie_xy.ie_x = 0;
			coin->ie_position.ie_xy.ie_y = 0;
		}
		else if (coin->ie_Class == IECLASS_NEWMOUSE && mouseactive && screeninfront)
		{
			// mouse button 4, mouse wheel
			IN_AddEvent(coin);
			coin->ie_Code = IECODE_NOBUTTON;
		}
	}

	return moo;
}
//MakeHandlerPri(InputHandler, &IN_KeyboardHandler, "Hexen II input handler", NULL, 100);

/*
===========
IN_Init
===========
*/
void IN_Init (void)
{
	static char handler_name[] = "Hexen II input handler";

	/* mouse variables */
	Cvar_RegisterVariable (&m_filter);
	/* joystick variables */
	Cvar_RegisterVariable (&in_joystick);
	Cvar_RegisterVariable (&joy_index);

	Cvar_SetCallback (&in_joystick, IN_Callback_JoyEnable);
	Cvar_SetCallback (&joy_index, IN_Callback_JoyIndex);

	Cmd_AddCommand ("force_centerview", Force_CenterView_f);

	pointermem = (UWORD *) AllocVec(2 * 6, MEMF_CHIP | MEMF_CLEAR);

	IN_StartupMouse ();
	IN_StartupJoystick ();

	imsglow = imsghigh = 0;

	inputport = CreateMsgPort();
	if (inputport)
	{
		//inputreq = (struct IOStdReq *) CreateIORequest(inputport, sizeof(*inputreq));
		inputreq = CreateStdIO(inputport);
		if (inputreq)
		{
			if (!OpenDevice("input.device", 0, (struct IORequest *)inputreq, 0))
			{
				InputHandler.is_Node.ln_Type = NT_INTERRUPT;
				InputHandler.is_Node.ln_Pri = 100;
				InputHandler.is_Node.ln_Name = handler_name;
				InputHandler.is_Code = (void (*)())&IN_KeyboardHandler;
				inputreq->io_Data = (void *)&InputHandler;
				inputreq->io_Command = IND_ADDHANDLER;
				DoIO((struct IORequest *)inputreq);
				return;
			}
			//DeleteIORequest(inputreq);
			DeleteStdIO(inputreq);
		}
		DeleteMsgPort(inputport);
	}

	Sys_Error ("Couldn't install input handler");
}

/*
===========
IN_Shutdown
===========
*/
void IN_Shutdown (void)
{
	if (inputreq)
	{
		inputreq->io_Data = (void *)&InputHandler;
		inputreq->io_Command = IND_REMHANDLER;
		DoIO((struct IORequest *)inputreq);

		CloseDevice((struct IORequest *)inputreq);
		//DeleteIORequest(inputreq);
		DeleteStdIO(inputreq);
	}

	if (inputport)
	{
		DeleteMsgPort(inputport);
	}

	IN_DeactivateMouse ();
	/*IN_ShowMouse ();*/

	if (pointermem)
	{
		FreeVec(pointermem);
	}

	mouseinitialized = false;

	if (LowLevelBase)
	{
		CloseLibrary(LowLevelBase);
		LowLevelBase = NULL;
	}

	joy_port = -1;
	joy_available = 0;
	oldjoyflag = 0;

#ifdef __CLIB2__
	if (KeymapBase) {
		CloseLibrary(KeymapBase);
		KeymapBase = NULL;
	}
#endif
}

/*
===========
IN_ReInit
===========
*/
void IN_ReInit (void)
{
	IN_StartupMouse ();
}


/*
===========
IN_MouseMove
===========
*/
static void IN_MouseMove (usercmd_t *cmd/*, int mx, int my*/)
{
	if (m_filter.integer)
	{
		mouse_x = (mx + old_mouse_x) * 0.5;
		mouse_y = (my + old_mouse_y) * 0.5;
	}
	else
	{
		mouse_x = mx;
		mouse_y = my;
	}

	old_mouse_x = mx;
	old_mouse_y = my;

	mouse_x *= sensitivity.value;
	mouse_y *= sensitivity.value;

/* add mouse X/Y movement to cmd */
	if ( (in_strafe.state & 1) || (lookstrafe.integer && (in_mlook.state & 1) ))
		cmd->sidemove += m_side.value * mouse_x;
	else
		cl.viewangles[YAW] -= m_yaw.value * mouse_x;

	if (in_mlook.state & 1)
	{
		if (mx || my)
			V_StopPitchDrift ();
	}

	if ( (in_mlook.state & 1) && !(in_strafe.state & 1))
	{
		cl.viewangles[PITCH] += m_pitch.value * mouse_y;
		if (cl.viewangles[PITCH] > 80)
			cl.viewangles[PITCH] = 80;
		if (cl.viewangles[PITCH] < -70)
			cl.viewangles[PITCH] = -70;
	}
	else
	{
		if ((in_strafe.state & 1) && (cl.v.movetype == MOVETYPE_NOCLIP))
			cmd->upmove -= m_forward.value * mouse_y;
		else
			cmd->forwardmove -= m_forward.value * mouse_y;
	}

	if (cl.idealroll == 0) /* Did keyboard set it already?? */
	{
		if (cl.v.movetype == MOVETYPE_FLY)
		{
			if (mouse_x < 0)
				cl.idealroll = -10;
			else if (mouse_x > 0)
				cl.idealroll = 10;
		}
	}
}

static void IN_DiscardMove (void)
{
	if (mouseinitialized)
	{
		mx = my = old_mouse_x = old_mouse_y = 0;
	}
}

/*
===========
IN_Move
===========
*/
void IN_Move (usercmd_t *cmd)
{
	if (cl.v.cameramode)
	{
	/* stuck in a different camera so don't move */
		memset (cmd, 0, sizeof(*cmd));
	/* ignore any mouse movements in camera mode */
		IN_DiscardMove ();
		return;
	}

	if (mx != 0 || my != 0)
	{
		IN_MouseMove (cmd/*, x, y*/);
		mx = my = 0;
	}
}

static const char *JoystickName(int port)
{
	ULONG joyflag = ReadJoyPort(port);

	switch (joyflag & JP_TYPE_MASK)
	{
	case JP_TYPE_GAMECTLR:
		return "game controller";
	case JP_TYPE_JOYSTK:
		return "joystick controller";
	case JP_TYPE_MOUSE:
		return "mouse";
	case JP_TYPE_NOTAVAIL:
		return "not available";
	case JP_TYPE_UNKNOWN:
		return "unknown device";
	default:
		return "<unknown>";
	}
}

/*
===============
IN_StartupJoystick
===============
*/
static void IN_StartupJoystick (void)
{
	int	i;

	if (safemode || COM_CheckParm ("-nojoy"))
		return;

#ifdef __CLIB2__
	KeymapBase = OpenLibrary("keymap.library", 37);
#endif

	if (!LowLevelBase)
		LowLevelBase = OpenLibrary("lowlevel.library", 37);

	if (LowLevelBase)
	{
		/*
		ULONG joyflag;
		joy_available = 0;

		while (joy_available < 4)
		{
			joyflag = ReadJoyPort(joy_available);
			if ((joyflag & JP_TYPE_MASK) == JP_TYPE_NOTAVAIL)
				break;
			joy_available++;
		}
		*/
		joy_available = 4;
	}
	else
	{
		Con_Printf("Unable to open lowlevel.library\n");
		return;
	}

	/*
	if (joy_available == 0)
	{
		CloseLibrary(LowLevelBase);
		LowLevelBase = NULL;
		Con_Printf ("No joystick devices found\n");
		return;
	}
	*/

	Con_Printf ("lowlevel.library: %d devices are reported:\n", joy_available);
	for (i = 0; i < joy_available; i++)
	{
		Con_Printf("#%d: \"%s\"\n", i, JoystickName(i));
	}

	if (in_joystick.integer)
		IN_Callback_JoyIndex(&joy_index);
}

static void IN_Callback_JoyEnable (cvar_t *var)
{
	if (!LowLevelBase)
		return;

	if (var->integer)
		IN_Callback_JoyIndex(&joy_index);
	else
		joy_port = -1;
}

static void IN_Callback_JoyIndex (cvar_t *var)
{
	int idx = var->integer;

	if (!LowLevelBase)
		return;

	if (idx < 0 || idx >= joy_available)
	{
		Con_Printf ("joystick #%d doesn't exist\n", idx);
	}
	else if (in_joystick.integer)
	{
		//ULONG joyflag;

		//joy_port = -1;
		//joyflag = ReadJoyPort(idx);

		//if (joyflag & (JP_TYPE_GAMECTLR | JP_TYPE_JOYSTK))
			joy_port = idx;

		if (joy_port != -1)
		{
			Con_Printf("joystick open ");
			Con_Printf("#%d: \"%s\"\n", idx, JoystickName(idx));
		}
		else
		{
			Con_Printf("cannot open joystick, unsupported type: %s\n", JoystickName(idx));
		}
	}
}

#define Check_Joy_Event(key, flag, oldflag, mask) \
	if ((flag & mask) != (oldflag & mask)) { Key_Event(key, (flag & mask) ? true : false); }

static void IN_HandleJoystick (void)
{
	ULONG joyflag;

	if (!LowLevelBase || joy_port == -1)
		return;

	joyflag = ReadJoyPort(joy_port);

	if (joyflag != oldjoyflag)
	{
		switch (joyflag & JP_TYPE_MASK)
		{
		case JP_TYPE_GAMECTLR:
			Check_Joy_Event(K_JOY1, joyflag, oldjoyflag, JPF_BUTTON_BLUE);
			Check_Joy_Event(K_JOY2, joyflag, oldjoyflag, JPF_BUTTON_RED);
			Check_Joy_Event(K_JOY3, joyflag, oldjoyflag, JPF_BUTTON_YELLOW);
			Check_Joy_Event(K_JOY4, joyflag, oldjoyflag, JPF_BUTTON_GREEN);
			Check_Joy_Event(K_AUX1, joyflag, oldjoyflag, JPF_BUTTON_FORWARD);
			Check_Joy_Event(K_AUX2, joyflag, oldjoyflag, JPF_BUTTON_REVERSE);
			Check_Joy_Event(K_AUX3, joyflag, oldjoyflag, JPF_BUTTON_PLAY);
			Check_Joy_Event(K_AUX29, joyflag, oldjoyflag, JPF_JOY_UP);
			Check_Joy_Event(K_AUX30, joyflag, oldjoyflag, JPF_JOY_DOWN);
			Check_Joy_Event(K_AUX31, joyflag, oldjoyflag, JPF_JOY_LEFT);
			Check_Joy_Event(K_AUX32, joyflag, oldjoyflag, JPF_JOY_RIGHT);
			break;
		case JP_TYPE_JOYSTK:
			Check_Joy_Event(K_JOY1, joyflag, oldjoyflag, JPF_BUTTON_BLUE);
			Check_Joy_Event(K_JOY2, joyflag, oldjoyflag, JPF_BUTTON_RED);
			Check_Joy_Event(K_AUX29, joyflag, oldjoyflag, JPF_JOY_UP);
			Check_Joy_Event(K_AUX30, joyflag, oldjoyflag, JPF_JOY_DOWN);
			Check_Joy_Event(K_AUX31, joyflag, oldjoyflag, JPF_JOY_LEFT);
			Check_Joy_Event(K_AUX32, joyflag, oldjoyflag, JPF_JOY_RIGHT);
			break;
		default:
			/* nothing to do here */
			break;
		}
		oldjoyflag = joyflag;
	}
}

/*
===========
IN_Commands
===========
*/
void IN_Commands (void)
{
	/* all button events handled by IN_SendKeyEvents() */
}


void IN_SendKeyEvents (void)
{
	struct IntuiMessage *intuimsg;
	struct InputEvent *inputev;
	int sym, state, code;

	if (!window) return;/* dedicated server? */

	while ((intuimsg = (struct IntuiMessage *) GetMsg(window->UserPort)))
	{
		switch (intuimsg->Class)
		{
		case IDCMP_ACTIVEWINDOW:
			S_UnblockSound();
			break;
		case IDCMP_INACTIVEWINDOW:
			S_BlockSound();
			break;
		case IDCMP_CLOSEWINDOW:
			CL_Disconnect ();
			Sys_Quit ();
			break;
		}

		ReplyMsg((struct Message *)intuimsg);
	}

	while ((inputev = IN_GetNextEvent()))
	{
		sym = 0;

		code = inputev->ie_Code & ~IECODE_UP_PREFIX;
		state = !(inputev->ie_Code & IECODE_UP_PREFIX);

		if (inputev->ie_Class == IECLASS_RAWKEY)
		{
			if (!Key_IsGameKey())
			{
				UBYTE bufascii;
				if (KeymapBase && MapRawKey(inputev, (STRPTR) &bufascii, sizeof(bufascii), NULL) > 0)
				{
					//Con_Printf("%d\n", bufascii);
					sym = (bufascii == 8) ? K_BACKSPACE	: bufascii;
				}
			}

			if (!sym && code < MAX_KEYCONV)
				sym = keyconv[code];

			//Con_Printf("rawkey code %d sym %d state %d\n", code, sym, state);
		}
		else if (inputev->ie_Class == IECLASS_RAWMOUSE)
		{
			switch (code)
			{
			case IECODE_LBUTTON:
				sym = K_MOUSE1;
				break;
			case IECODE_RBUTTON:
				sym = K_MOUSE2;
				break;
			case IECODE_MBUTTON:
				sym = K_MOUSE3;
				break;
			}
			//Con_Printf("rawmouse code %d sym %d state %d\n", code, sym, state);
		}
		else if (inputev->ie_Class == IECLASS_NEWMOUSE)
		{
			switch (code)
			{
			case NM_WHEEL_UP:
				sym = K_MWHEELUP;
				break;
			case NM_WHEEL_DOWN:
				sym = K_MWHEELDOWN;
				break;
			case NM_BUTTON_FOURTH:
				sym = K_MOUSE4;
				break;
			}
			//Con_Printf("newmouse code %d sym %d state %d\n", code, sym, state);
		}

		if (sym)
		{
			if (sym == K_MWHEELUP || sym == K_MWHEELDOWN)
			{
				/* the mouse wheel doesn't generate a key up event */
				Key_Event(sym, true);
				Key_Event(sym, false);
			}
			else
			{
				Key_Event(sym, state);
			}
		}
	}

	IN_HandleJoystick();
}

