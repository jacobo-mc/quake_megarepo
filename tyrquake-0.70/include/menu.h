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

#ifndef MENU_H
#define MENU_H

#include "keys.h"
#include "qpic.h"
#include "qtypes.h"

//
// menus
//
void M_AddCommands();
void M_Init();

void M_Keydown(knum_t keynum);
void M_Draw(void);

void M_ToggleMenu_f(void);
void M_Menu_Options_f(void);
void M_Menu_Quit_f(void);

void M_DrawPic(int x, int y, const qpic8_t *pic);
void M_DrawTransPic(int x, int y, const qpic8_t *pic);
void M_DrawCharacter(int cx, int line, int num);
void M_DrawCursor(int cx, int line, int num);
void M_DrawCheckbox(int x, int y, qboolean checked);
void M_DrawTextBox(int x, int y, int width, int lines);
void M_Print(int cx, int cy, const char *str);
void M_PrintWhite(int cx, int cy, const char *str);

#ifdef NQ_HACK
/* FIXME - These are only here for NQ/net_dgrm.c */
extern qboolean m_return_onerror;
extern char m_return_reason[32];
extern int m_return_state;
typedef enum {
    m_none, m_main, m_singleplayer, m_load, m_save, m_multiplayer, m_setup,
    m_options, m_video, m_keys, m_help, m_quit, m_lanconfig, m_gameoptions,
    m_search, m_slist
} m_state_t;

extern m_state_t m_state;

#endif

#endif /* MENU_H */
