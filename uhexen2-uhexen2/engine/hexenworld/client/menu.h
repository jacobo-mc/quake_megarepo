/*
 * menu.h
 *
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

#ifndef __HX2_MENU_H
#define __HX2_MENU_H

enum m_state_e
{
	m_none = 0,
	m_main,
	m_multiplayer,
	m_setup,
	m_options,
#ifdef GLQUAKE
	m_opengl,
#endif
	m_video,
	m_keys,
	m_help,
	m_quit,
	m_mconnect
};

extern	enum m_state_e	m_state;

/* menus */
void M_Init (void);
void M_Keydown (int key);
void M_Keybind (int key);
void M_ToggleMenu_f (void);

void M_Menu_Main_f (void);
void M_Menu_Options_f (void);
void M_Menu_Quit_f (void);

void M_Print (int cx, int cy, const char *str);
void M_PrintWhite (int cx, int cy, const char *str);

void M_Draw (void);
void M_DrawCharacter (int cx, int line, int num);

void M_DrawPic (int x, int y, qpic_t *pic);
void M_DrawTransPic (int x, int y, qpic_t *pic);
void M_DrawTextBox (int x, int y, int width, int lines);

void M_DrawCheckbox (int x, int y, int on);

void ScrollTitle (const char *name);

#endif	/* __HX2_MENU_H */

