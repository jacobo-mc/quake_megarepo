/*
 * winquake.h -- Windows-specific Quake header file
 * Copyright (C) 1996-1997  Id Software, Inc.
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

#ifndef __WINQUAKE_H
#define __WINQUAKE_H

/* include windows.h here, because we need the data types */
#include <windows.h>

/* required compatibility versions for directx components */
#define	DIRECTDRAW_VERSION	0x0300
#define	DIRECTSOUND_VERSION	0x0300
#define	DIRECTINPUT_VERSION	0x0300

#if !defined(__cplusplus) && !defined(CINTERFACE)
#define	CINTERFACE	/* for directx macros. */
#endif

extern	HINSTANCE	global_hInstance;
extern	int		global_nCmdShow;

#ifndef WM_MOUSEWHEEL
#define	WM_MOUSEWHEEL		0x020A
#endif
/* IntelliMouse explorer buttons: These are ifdef'ed out for < Win2000
   in the Feb. 2001 version of MS's platform SDK, but we need them for
   compilation. */
#ifndef WM_XBUTTONDOWN
#define	WM_XBUTTONDOWN		0x020B
#define	WM_XBUTTONUP		0x020C
#endif
#ifndef MK_XBUTTON1
#define	MK_XBUTTON1		0x0020
#define	MK_XBUTTON2		0x0040
#endif


extern qboolean		dinput_init;

extern HWND		mainwindow;
extern qboolean		ActiveApp, Minimized;

extern qboolean		Win95, Win95old, WinNT, WinVista;

extern int		window_center_x, window_center_y;
extern RECT		window_rect;

#if !defined(NO_SPLASHES)
extern HWND		hwnd_dialog;
#endif

LRESULT CDAudio_MessageHandler (HWND, UINT, WPARAM, LPARAM);

#define WM_MSTREAM_UPDATEVOLUME  (WM_USER + 101)
#define WM_MSTREAM_UPDATEVOLUMES (WM_USER + 102)
void MIDI_SetChannelVolume(DWORD chn, DWORD percent);
void MIDI_SetAllChannelVolumes (DWORD percent);

#endif	/* __WINQUAKE_H */

