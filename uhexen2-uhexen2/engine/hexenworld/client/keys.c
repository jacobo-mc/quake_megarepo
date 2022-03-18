/*
 * keys.c -- key up events are sent even if in console mode
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 2006-2012  O.Sezer
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

char	key_lines[32][MAXCMDLINE];
int		key_linepos;
static qboolean	shift_down = false;
int		key_lastpress;
int		key_insert = 1;		// insert/overwrite mode toggle

int		edit_line = 0;
static int	history_line = 0;

static keydest_t	key_dest;
static qboolean		key_gamekey, prev_gamekey;

int		key_count;		// incremented every key event

char		*keybindings[256];
static qboolean	consolekeys[256];	// if true, can't be rebound while in console
static qboolean	menubound[256];		// if true, can't be rebound while in menu
static int	keyshift[256];		// key to map to if shift held down in console
static int	key_repeats[256];	// if > 1, it is autorepeating
static qboolean	keyreserved[256];	// hardcoded, can't be rebound by the user
static qboolean	keydown[256];

typedef struct
{
	const char	*name;
	int		keynum;
} keyname_t;

static keyname_t keynames[] =
{
	{"TAB", K_TAB},
	{"ENTER", K_ENTER},
	{"ESCAPE", K_ESCAPE},
	{"SPACE", K_SPACE},
	{"BACKSPACE", K_BACKSPACE},
	{"UPARROW", K_UPARROW},
	{"DOWNARROW", K_DOWNARROW},
	{"LEFTARROW", K_LEFTARROW},
	{"RIGHTARROW", K_RIGHTARROW},

	{"ALT", K_ALT},
	{"CTRL", K_CTRL},
	{"SHIFT", K_SHIFT},
	
	{"F1", K_F1},
	{"F2", K_F2},
	{"F3", K_F3},
	{"F4", K_F4},
	{"F5", K_F5},
	{"F6", K_F6},
	{"F7", K_F7},
	{"F8", K_F8},
	{"F9", K_F9},
	{"F10", K_F10},
	{"F11", K_F11},
	{"F12", K_F12},

	{"INS", K_INS},
	{"DEL", K_DEL},
	{"PGDN", K_PGDN},
	{"PGUP", K_PGUP},
	{"HOME", K_HOME},
	{"END", K_END},

//	{"KP_NUMLOCK", K_KP_NUMLOCK},
	{"KP_SLASH", K_KP_SLASH},
	{"KP_STAR", K_KP_STAR},
	{"KP_MINUS", K_KP_MINUS},
	{"KP_HOME", K_KP_HOME},
	{"KP_UPARROW", K_KP_UPARROW},
	{"KP_PGUP", K_KP_PGUP},
	{"KP_PLUS", K_KP_PLUS},
	{"KP_LEFTARROW", K_KP_LEFTARROW},
	{"KP_5", K_KP_5},
	{"KP_RIGHTARROW", K_KP_RIGHTARROW},
	{"KP_END", K_KP_END},
	{"KP_DOWNARROW", K_KP_DOWNARROW},
	{"KP_PGDN", K_KP_PGDN},
	{"KP_ENTER", K_KP_ENTER},
	{"KP_INS", K_KP_INS},
	{"KP_DEL", K_KP_DEL},

	{"COMMAND", K_COMMAND},

	{"MOUSE1", K_MOUSE1},
	{"MOUSE2", K_MOUSE2},
	{"MOUSE3", K_MOUSE3},
	{"MWHEELUP", K_MWHEELUP},
	{"MWHEELDOWN", K_MWHEELDOWN},
	{"MOUSE4", K_MOUSE4},
	{"MOUSE5", K_MOUSE5},

	{"JOY1", K_JOY1},
	{"JOY2", K_JOY2},
	{"JOY3", K_JOY3},
	{"JOY4", K_JOY4},

	{"AUX1", K_AUX1},
	{"AUX2", K_AUX2},
	{"AUX3", K_AUX3},
	{"AUX4", K_AUX4},
	{"AUX5", K_AUX5},
	{"AUX6", K_AUX6},
	{"AUX7", K_AUX7},
	{"AUX8", K_AUX8},
	{"AUX9", K_AUX9},
	{"AUX10", K_AUX10},
	{"AUX11", K_AUX11},
	{"AUX12", K_AUX12},
	{"AUX13", K_AUX13},
	{"AUX14", K_AUX14},
	{"AUX15", K_AUX15},
	{"AUX16", K_AUX16},
	{"AUX17", K_AUX17},
	{"AUX18", K_AUX18},
	{"AUX19", K_AUX19},
	{"AUX20", K_AUX20},
	{"AUX21", K_AUX21},
	{"AUX22", K_AUX22},
	{"AUX23", K_AUX23},
	{"AUX24", K_AUX24},
	{"AUX25", K_AUX25},
	{"AUX26", K_AUX26},
	{"AUX27", K_AUX27},
	{"AUX28", K_AUX28},
	{"AUX29", K_AUX29},
	{"AUX30", K_AUX30},
	{"AUX31", K_AUX31},
	{"AUX32", K_AUX32},

	{"PAUSE", K_PAUSE},

	{"SEMICOLON", ';'},	// because a raw semicolon seperates commands

	{NULL,		0}
};

/*
==============================================================================

			LINE TYPING INTO THE CONSOLE

==============================================================================
*/

static qboolean CheckForCommand (void)
{
	char	command[128], *s;
	int	i;

	s = key_lines[edit_line] + 1;

	command[0] = '\0';
	for (i = 0; i < 127; i++)
	{
		if (s[i] <= ' ')
			break;
		command[i] = s[i];
	}

	command[i] = 0;

	return Cmd_CheckCommand (command);
}

static void CompleteCommand (void)
{
	char	*matches[MAX_MATCHES];
	char		backup[MAXCMDLINE];
	char		c, *prefix, *workline;
	qboolean	editing;
	int		count, i;
	size_t		len1, len2;

	if (key_linepos < 2)
		return;

	workline = key_lines[edit_line];
	c = workline[key_linepos];
	editing = (c != 0);

	if (editing)
	{
		// make a copy of the text starting from the
		// cursor position (see below)
		q_strlcpy(backup, workline + key_linepos, sizeof(backup));
	}

	// complete the text only up to the cursor position:
	// bash style. cut off the rest for now.
	workline[key_linepos] = 0;
	prefix = workline + 1;

	// skip the leading whitespace and command markers
	while (*prefix)
	{
		if (*prefix != '\\' && *prefix != '/' && *prefix > ' ')
			break;
		++prefix;
	}

	// if the remainder line has no length or has
	// spaces in it, don't bother
	if (!*prefix || strstr(prefix," "))
	{
		workline[key_linepos] = c;
		return;
	}

	// store the length of the relevant partial
	len1 = len2 = strlen(prefix);

	// start checking for matches, finally...
	count = 0;
	count += ListCommands(prefix, (const char**)matches, count);
	count += ListCvars   (prefix, (const char**)matches, count);
	count += ListAlias   (prefix, (const char**)matches, count);

	if (count)
	{
		// do not do a full auto-complete
		// unless there is only one match
		if (count == 1)
		{
			workline[1] = '/';
			q_strlcpy (workline + 2, matches[0], MAXCMDLINE-2);
			key_linepos = 2 + strlen(matches[0]);
		//	q_strlcpy (workline + 1, matches[0], MAXCMDLINE-1);
		//	key_linepos = 1 + strlen(matches[0]);
			workline[key_linepos] = ' ';
			key_linepos++;
		}
		else
		{
			// more than one match, sort and list all of them
			qsort (matches, count, sizeof(char *), COM_StrCompare);
			Con_Printf("\n");
#if 0
			// plain listing
			for (i = 0; i < count && i < MAX_MATCHES; i++)
				Con_Printf ("%s\n", matches[i]);
			Con_Printf("\n%d matches found\n\n", count);
#else
			// S.A.: columnize the listing.
			Con_Printf("%d possible completions:\n\n", count);
			Con_ShowList (count, (const char**) matches);
			Con_Printf("\n");
#endif

			// cycle throgh all matches and see
			// if there is a partial completion
		_search:
			for (i = 1; i < count && i < MAX_MATCHES; i++)
			{
				if (matches[0][len2] != matches[i][len2])
					goto _check;
			}
			++len2;
			goto _search;
		_check:
			if (len2 > len1)	// found a partial match
			{
				workline[1] = '/';
				strncpy (workline + 2, matches[0], len2);
				key_linepos = len2 + 2;
			//	strncpy (workline + 1, matches[0], len2);
			//	key_linepos = len2 + 1;
			}
		}

		workline[key_linepos] = 0;
	}

	// put back the remainder of the original text
	// which was lost after the trimming
	if (editing)
		q_strlcpy (workline + key_linepos, backup, MAXCMDLINE-key_linepos);
}

static void PasteToConsole (void)
{
	char *cbd, *p, *workline;
	int mvlen, inslen;

	if (key_linepos == MAXCMDLINE - 1)
		return;

	if ((cbd = Sys_GetClipboardData()) == NULL)
		return;

	p = cbd;
	while (*p)
	{
		if (*p == '\n' || *p == '\r' || *p == '\b')
		{
			*p = 0;
			break;
		}
		p++;
	}

	inslen = (int) (p - cbd);
	if (inslen + key_linepos > MAXCMDLINE - 1)
		inslen = MAXCMDLINE - 1 - key_linepos;
	if (inslen <= 0) goto done;

	workline = key_lines[edit_line];
	workline += key_linepos;
	mvlen = (int) strlen(workline);
	if (mvlen + inslen + key_linepos > MAXCMDLINE - 1)
	{
		mvlen = MAXCMDLINE - 1 - key_linepos - inslen;
		if (mvlen < 0) mvlen = 0;
	}

	// insert the string
	if (mvlen != 0)
		memmove (workline + inslen, workline, mvlen);
	memcpy (workline, cbd, inslen);
	key_linepos += inslen;
	workline[mvlen + inslen] = '\0';
  done:
	Z_Free(cbd);
}

/*
====================
Key_Console

Interactive line editing and console scrollback
====================
*/
static void Key_Console (int key)
{
	int	history_line_last;
	size_t		len;
	char	*workline = key_lines[edit_line];

	switch (key)
	{
	case K_ENTER:
	// backslash text are commands, else chat
		if (workline[1] == '\\' || workline[1] == '/')
			Cbuf_AddText (workline + 2);	// skip the >
		else if (CheckForCommand())
			Cbuf_AddText (workline + 1);	// valid command
		else
		{	// convert to a chat message
			if (cls.state >= ca_connected)
				Cbuf_AddText ("say ");
			Cbuf_AddText (workline + 1);	// skip the >
		}

		Cbuf_AddText ("\n");
		Con_Printf ("%s\n", workline);
		edit_line = (edit_line + 1) & 31;
		history_line = edit_line;
		key_lines[edit_line][0] = ']';
		key_lines[edit_line][1] = 0;
		key_linepos = 1;
		if (cls.state == ca_disconnected)
			SCR_UpdateScreen ();	// force an update, because the command
								// may take some time
		return;

	case K_TAB:
		CompleteCommand ();
		return;

	case K_LEFTARROW:
		if (key_linepos < 2)
			return;
		if (keydown[K_CTRL])
		{
		/* ctrl - left, word processor style: first,
		 * move to the ending of previous word, then
		 * move to its beginning
		 */
			char *p = workline + key_linepos - 1;
			while (p != workline && *p == ' ')
				--p;
			while (p != workline)
			{
				if (*--p == ' ')
					break;
			}
			key_linepos = (int)(p - workline) + 1;
		}
		else	/* simple cursor-to-left, only. */
		{
			--key_linepos;
		}
		return;

	case K_RIGHTARROW:
		if (!workline[key_linepos])
			return;
		if (keydown[K_CTRL])
		{
		/* ctrl - right, word processor style: if
		 * we are on a text move to its end, then
		 * move to the beginning of the next word
		 */
			char *p = workline + key_linepos;
			while (*p && *p != ' ')
				++p;
			while (*p && *p == ' ')
				++p;
			key_linepos = (int)(p - workline);
		}
		else	/* simple cursor-to-right only. */
		{
			++key_linepos;
		}
		return;

	case K_BACKSPACE:
		if (key_linepos > 1)
		{
			workline += key_linepos - 1;
			if (workline[1])
			{
				len = strlen(workline);
				memmove (workline, workline + 1, len);
			}
			else	*workline = 0;

			key_linepos--;
		}
		return;

	case K_DEL:
		workline += key_linepos;
		if (*workline)
		{
			if (workline[1])
			{
				len = strlen(workline);
				memmove (workline, workline + 1, len);
			}
			else	*workline = 0;
		}
		return;

	case K_UPARROW:
		history_line_last = history_line;
		do
		{
			history_line = (history_line - 1) & 31;
		} while (history_line != edit_line && !key_lines[history_line][1]);

		if (history_line == edit_line)
			history_line = history_line_last;

		strcpy(workline, key_lines[history_line]);
		key_linepos = strlen(workline);
		return;

	case K_DOWNARROW:
		if (history_line == edit_line)
			return;
		do
		{
			history_line = (history_line + 1) & 31;
		} while (history_line != edit_line && !key_lines[history_line][1]);

		if (history_line == edit_line)
		{
			workline[0] = ']';
			workline[1] = 0;
			key_linepos = 1;
		}
		else
		{
			strcpy(workline, key_lines[history_line]);
			key_linepos = strlen(workline);
		}
		return;

	case K_PGUP:
	case K_MWHEELUP:
		con->display -= 2;
		return;

	case K_PGDN:
	case K_MWHEELDOWN:
		con->display += 2;
		if (con->display > con->current)
			con->display = con->current;
		return;

	case K_HOME:
		if (keydown[K_CTRL])
			con->display = con->current - con_totallines + 10;
		else	key_linepos = 1;
		return;

	case K_END:
		if (keydown[K_CTRL])
			con->display = con->current;
		else	key_linepos = strlen(workline);
		return;

	case K_INS:
		if (keydown[K_SHIFT])		/* Shift+Ins paste */
			PasteToConsole();
		else	key_insert ^= 1;
		return;

	case 'v':
	case 'V':
#if defined(PLATFORM_OSX) || defined(PLATFORM_MAC)
		if (keydown[K_COMMAND]) {	/* Cmd+V paste (Mac-only) */
			PasteToConsole();
			return;
		}
#endif
		if (keydown[K_CTRL]) {		/* Ctrl+v paste */
			PasteToConsole();
			return;
		}
		break;

	case 'c':
	case 'C':
		if (keydown[K_CTRL]) {		/* Ctrl+C: abort the line -- S.A */
			Con_Printf ("%s\n", workline);
			workline[0] = ']';
			workline[1] = 0;
			key_linepos = 1;
			history_line= edit_line;
			return;
		}
		break;
	}

	if (key < 32 || key > 127)
		return;	// non printable

	if (key_linepos < MAXCMDLINE - 1)
	{
		qboolean endpos = !workline[key_linepos];
		// if inserting, move the text to the right
		if (key_insert && !endpos)
		{
			workline[MAXCMDLINE - 2] = 0;
			workline += key_linepos;
			len = strlen(workline) + 1;
			memmove (workline + 1, workline, len);
			*workline = key;
		}
		else
		{
			workline += key_linepos;
			*workline = key;
			// null terminate if at the end
			if (endpos)
				workline[1] = 0;
		}
		key_linepos++;
	}
}

//============================================================================

qboolean	chat_team = false;
static char	chat_buffer[MAXCMDLINE];
static int	chat_bufferlen = 0;

const char *Key_GetChatBuffer (void)
{
	return chat_buffer;
}

int Key_GetChatMsgLen (void)
{
	return chat_bufferlen;
}

void Key_EndChat (void)
{
	Key_SetDest (key_game);
	chat_bufferlen = 0;
	chat_buffer[0] = 0;
}

static void Key_Message (int key)
{
	if (key == K_ENTER)
	{
		if (chat_team)
			Cbuf_AddText ("say_team \"");
		else
			Cbuf_AddText ("say \"");
		Cbuf_AddText(chat_buffer);
		Cbuf_AddText("\"\n");

		Key_EndChat ();
		return;
	}

	if (key == K_ESCAPE)
	{
		Key_EndChat ();
		return;
	}

	if (key == K_BACKSPACE)
	{
		if (chat_bufferlen)
			chat_buffer[--chat_bufferlen] = 0;
		return;
	}

	if (key < 32 || key > 127)
		return; // non printable

	if (chat_bufferlen == sizeof(chat_buffer) - 1)
		return; // all full

	chat_buffer[chat_bufferlen++] = key;
	chat_buffer[chat_bufferlen] = 0;
}

//============================================================================


/*
===================
Key_StringToKeynum

Returns a key number to be used to index keybindings[] by looking at
the given string.  Single ascii characters return themselves, while
the K_* names are matched up.
===================
*/
static int Key_StringToKeynum (const char *str)
{
	keyname_t	*kn;

	if (!str || !str[0])
		return -1;
	if (!str[1])
		return str[0];

	for (kn = keynames; kn->name; kn++)
	{
		if (!q_strcasecmp(str,kn->name))
			return kn->keynum;
	}
	return -1;
}

/*
===================
Key_KeynumToString

Returns a string (either a single ascii char, or a K_* name) for the
given keynum.
FIXME: handle quote special (general escape sequence?)
===================
*/
const char *Key_KeynumToString (int keynum)
{
	static	char	tinystr[2];
	keyname_t	*kn;

	if (keynum == -1)
		return "<KEY NOT FOUND>";
	if (keynum > 32 && keynum < 127)
	{	// printable ascii
		tinystr[0] = keynum;
		tinystr[1] = 0;
		return tinystr;
	}

	for (kn = keynames; kn->name; kn++)
	{
		if (keynum == kn->keynum)
			return kn->name;
	}

	return "<UNKNOWN KEYNUM>";
}


/*
===================
Key_SetBinding
===================
*/
void Key_SetBinding (int keynum, const char *binding)
{
	if (keynum == -1)
		return;
	if (keyreserved[keynum])
		return;

// free old bindings
	if (keybindings[keynum])
	{
		Z_Free (keybindings[keynum]);
		keybindings[keynum] = NULL;
	}

// allocate memory for new binding
	if (binding)
		keybindings[keynum] = Z_Strdup(binding);
}

/*
===================
Key_Unbind_f
===================
*/
static void Key_Unbind_f (void)
{
	int	b;

	if (Cmd_Argc() != 2)
	{
		Con_Printf ("unbind <key> : remove commands from a key\n");
		return;
	}

	b = Key_StringToKeynum (Cmd_Argv(1));
	if (b == -1)
	{
		Con_Printf ("\"%s\" isn't a valid key\n", Cmd_Argv(1));
		return;
	}

	Key_SetBinding (b, NULL);
}

static void Key_Unbindall_f (void)
{
	int	i;

	for (i = 0; i < 256; i++)
		Key_SetBinding(i, NULL);
}


/*
===================
Key_Bind_f
===================
*/
static void Key_Bind_f (void)
{
	int	i, c, b;
	char	cmd[1024];

	c = Cmd_Argc();

	if (c != 2 && c != 3)
	{
		Con_Printf ("bind <key> [command] : attach a command to a key\n");
		return;
	}
	b = Key_StringToKeynum (Cmd_Argv(1));
	if (b == -1)
	{
		Con_Printf ("\"%s\" isn't a valid key\n", Cmd_Argv(1));
		return;
	}

	if (c == 2)
	{
		if (keybindings[b])
			Con_Printf ("\"%s\" = \"%s\"\n", Cmd_Argv(1), keybindings[b] );
		else
			Con_Printf ("\"%s\" is not bound\n", Cmd_Argv(1) );
		return;
	}

// copy the rest of the command line
	cmd[0] = 0;
	for (i = 2; i < c; i++)
	{
		q_strlcat (cmd, Cmd_Argv(i), sizeof(cmd));
		if (i != (c-1))
			q_strlcat (cmd, " ", sizeof(cmd));
	}

	Key_SetBinding (b, cmd);
}

/*
============
Key_WriteBindings

Writes lines containing "bind key value"
============
*/
void Key_WriteBindings (FILE *f)
{
	int	i;

	// unbindall before loading stored bindings:
	if (cfg_unbindall.integer)
		fprintf (f, "unbindall\n");
	for (i = 0; i < 256; i++)
	{
		if (keybindings[i] && *keybindings[i])
			fprintf (f, "bind \"%s\" \"%s\"\n", Key_KeynumToString(i), keybindings[i]);
	}
}


/*
===================
Key_Init
===================
*/
void Key_Init (void)
{
	int	i;

	for (i = 0; i < 32; i++)
	{
		key_lines[i][0] = ']';
		key_lines[i][1] = 0;
	}
	key_linepos = 1;

	memset (consolekeys, 0, sizeof(consolekeys));
	memset (menubound, 0, sizeof(menubound));
	memset (keyreserved, 0, sizeof(keyreserved));

// init ascii characters in console mode
	for (i = 32; i < 128; i++)
		consolekeys[i] = true;
	consolekeys[K_ENTER] = true;
	consolekeys[K_TAB] = true;
	consolekeys[K_LEFTARROW] = true;
	consolekeys[K_RIGHTARROW] = true;
	consolekeys[K_UPARROW] = true;
	consolekeys[K_DOWNARROW] = true;
	consolekeys[K_BACKSPACE] = true;
	consolekeys[K_DEL] = true;
	consolekeys[K_INS] = true;
	consolekeys[K_HOME] = true;
	consolekeys[K_END] = true;
	consolekeys[K_PGUP] = true;
	consolekeys[K_PGDN] = true;
	consolekeys[K_SHIFT] = true;
	consolekeys[K_MWHEELUP] = true;
	consolekeys[K_MWHEELDOWN] = true;
	consolekeys['`'] = false;
	consolekeys['~'] = false;

	for (i = 0; i < 256; i++)
		keyshift[i] = i;
	for (i = 'a'; i <= 'z'; i++)
		keyshift[i] = i - 'a' + 'A';
	keyshift['1'] = '!';
	keyshift['2'] = '@';
	keyshift['3'] = '#';
	keyshift['4'] = '$';
	keyshift['5'] = '%';
	keyshift['6'] = '^';
	keyshift['7'] = '&';
	keyshift['8'] = '*';
	keyshift['9'] = '(';
	keyshift['0'] = ')';
	keyshift['-'] = '_';
	keyshift['='] = '+';
	keyshift[','] = '<';
	keyshift['.'] = '>';
	keyshift['/'] = '?';
	keyshift[';'] = ':';
	keyshift['\''] = '"';
	keyshift['['] = '{';
	keyshift[']'] = '}';
	keyshift['`'] = '~';
	keyshift['\\'] = '|';

	menubound[K_ESCAPE] = true;
	for (i = 0; i < 12; i++)
		menubound[K_F1+i] = true;

	memset (key_repeats, 0, sizeof(key_repeats));

// bind our reserved keys
	Key_SetBinding ('`', "toggleconsole");
	Key_SetBinding ('~', "toggleconsole");
	Key_SetBinding (K_PAUSE, "pause");
	keyreserved['`'] = true;
	keyreserved['~'] = true;
	keyreserved[K_KP_NUMLOCK] = true;
	keyreserved[K_PAUSE] = true;

// register our functions
	Cmd_AddCommand ("bind",Key_Bind_f);
	Cmd_AddCommand ("unbind",Key_Unbind_f);
	Cmd_AddCommand ("unbindall",Key_Unbindall_f);
}

/*
===================
Key_Event

Called by the system between frames for both key up and key down events
Should NOT be called during an interrupt!
===================
*/
void Key_Event (int key, qboolean down)
{
	char	*kb;
	char	cmd[1024];

	keydown[key] = down;

	if (!down)
		key_repeats[key] = 0;

	key_lastpress = key;
	key_count++;
	if (key_count <= 0)
		return;		// just catching keys for Con_NotifyBox

// update auto-repeat status
	if (down)
	{
		/* Pause key doesn't generate a scancode when released,
		 * never increment its auto-repeat status.
		 */
		if (key != K_PAUSE && key != K_KP_NUMLOCK)
			key_repeats[key]++;
#if 0
		if (key != K_BACKSPACE && key != K_PGUP && key != K_PGDN &&
					key_repeats[key] > 1)
			return;	// ignore most autorepeats
#endif
		if (key_repeats[key] > 1)
		{
			if (key_dest == key_game && !con_forcedup)
				return;	// ignore autorepeats in game mode
		}
		else if (key >= 200 && !keybindings[key])
			Con_Printf ("%s is unbound, hit F4 to set.\n", Key_KeynumToString(key));
	}

	if (key == K_SHIFT)
		shift_down = down;

// handle escape specialy, so the user can never unbind it
	if (key == K_ESCAPE)
	{
		if (!down)
			return;
		switch (key_dest)
		{
		case key_message:
			Key_Message (key);
			break;
		case key_menu:
			M_Keydown (key);
			break;
		case key_menubind:
			M_Keybind (key);
			break;
		case key_game:
		case key_console:
			M_ToggleMenu_f ();
			break;
		default:
			Sys_Error ("Bad key_dest");
		}
		return;
	}

// key up events only generate commands if the game key binding is
// a button command (leading + sign).  These will occur even in console mode,
// to keep the character from continuing an action started before a console
// switch.  Button commands include the kenum as a parameter, so multiple
// downs can be matched with ups
	if (!down)
	{
		kb = keybindings[key];
		if (kb && kb[0] == '+')
		{
			sprintf (cmd, "-%s %i\n", kb+1, key);
			Cbuf_AddText (cmd);
		}
		if (keyshift[key] != key)
		{
			kb = keybindings[keyshift[key]];
			if (kb && kb[0] == '+')
			{
				sprintf (cmd, "-%s %i\n", kb+1, key);
				Cbuf_AddText (cmd);
			}
		}
		return;
	}

// during demo playback, most keys bring up the main menu
	if (cls.demoplayback && down && consolekeys[key] && key_dest == key_game)
	{
		M_ToggleMenu_f ();
		return;
	}

// if not a consolekey, send to the interpreter no matter what mode is
	if (((key_dest & key_menu) && menubound[key]) ||
	    (key_dest == key_console && !consolekeys[key]) ||
	    (key_dest == key_game && (!con_forcedup || !consolekeys[key])))
	{
		kb = keybindings[key];
		if (kb)
		{
			if (kb[0] == '+')
			{	// button commands add keynum as a parm
				sprintf (cmd, "%s %i\n", kb, key);
				Cbuf_AddText (cmd);
			}
			else
			{
				Cbuf_AddText (kb);
				Cbuf_AddText ("\n");
			}
		}
		return;
	}

	if (!down)
		return;		// other systems only care about key down events

	if (shift_down)
		key = keyshift[key];

	switch (key_dest)
	{
	case key_message:
		Key_Message (key);
		break;
	case key_menu:
		M_Keydown (key);
		break;
	case key_menubind:
		M_Keybind (key);
		break;
	case key_game:
	case key_console:
		Key_Console (key);
		break;
	default:
		Sys_Error ("Bad key_dest");
	}
}

/*
===================
Key_ClearStates
===================
*/
void Key_ClearStates (void)
{
	int	i;

	for (i = 0; i < 256; i++)
	{
		if (keydown[i])
			Key_Event (i, false);
	}
}

qboolean Key_IsGameKey (void)
{
	return ((key_dest == key_game && !con_forcedup) || (key_dest == key_menubind));
}

keydest_t Key_GetDest (void)
{
	return key_dest;
}

void Key_SetDest (keydest_t dest)
{
	key_dest = dest;
	if ((key_gamekey = Key_IsGameKey()) != prev_gamekey)
	{
		prev_gamekey = key_gamekey;
		Key_ClearStates();
	}
}

