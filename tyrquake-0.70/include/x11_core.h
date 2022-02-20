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

#ifndef X11_CORE_H
#define X11_CORE_H

#include <X11/Xlib.h>

extern Display *x_disp;
extern Window x_win;

#define X_CORE_MASK (VisibilityChangeMask | StructureNotifyMask | ExposureMask | FocusChangeMask)

#endif /* X11_CORE_H */
