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

#ifndef IN_X11_H
#define IN_X11_H

#include "qtypes.h"
#include "cvar.h"

#include <X11/Xlib.h>

#define X_KEY_MASK (KeyPressMask | KeyReleaseMask)
#define X_MOUSE_MASK (ButtonPressMask | ButtonReleaseMask | PointerMotionMask)
#define X_MOUSE_BUTTON_MASK (Button1Mask | Button2Mask | Button3Mask | Button4Mask | Button5Mask)

extern cvar_t _windowed_mouse;

void IN_Init();
void IN_Shutdown();

void IN_GrabMouse();
void IN_UngrabMouse();
void IN_GrabKeyboard();
void IN_UngrabKeyboard();

void IN_X11_HandleInputEvent(XEvent *event);

#endif /* IN_X11_H */
