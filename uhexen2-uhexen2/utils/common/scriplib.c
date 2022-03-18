/* scriplib.c
 *
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 1997-1998  Raven Software Corp.
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

#include "q_stdinc.h"
#include "compiler.h"
#include "arch_def.h"
#include "cmdlib.h"
#include "util_io.h"
#include "scriplib.h"

/*
=============================================================================

PARSING STUFF

=============================================================================
*/

char		token[MAXTOKEN];
static void	*scriptbuffer;
static char	*script_p, *scriptend_p;
int		scriptline;
qboolean	endofscript;
static qboolean	tokenready;	// only true if UnGetToken was just called

/*
==============
LoadScriptFile

==============
*/
void LoadScriptFile (const char *filename)
{
	int		size;

	size = LoadFile (filename, &scriptbuffer);

	script_p = (char *) scriptbuffer;
	scriptend_p = script_p + size;
	scriptline = 1;
	endofscript = false;
	tokenready = false;
}


/*
==============
UnGetToken

Signals that the current token was not used, and should be reported
for the next GetToken.  Note that

	GetToken (true);
	UnGetToken ();
	GetToken (false);

could cross a line boundary.
==============
*/
void UnGetToken (void)
{
	tokenready = true;
}


/*
==============
GetToken
==============
*/
qboolean GetToken (qboolean crossline)
{
	char	*token_p;

	if (tokenready)		// is a token already waiting?
	{
		tokenready = false;
		return true;
	}

	if (script_p >= scriptend_p)
	{
		if (!crossline)
			COM_Error ("Line %i is incomplete\n",scriptline);
		endofscript = true;
		return false;
	}

//
// skip space
//
skipspace:
	while (*script_p <= 32)
	{
		if (script_p >= scriptend_p)
		{
			if (!crossline)
				COM_Error ("Line %i is incomplete\n",scriptline);
			endofscript = true;
			return true;
		}
		if (*script_p++ == '\n')
		{
			if (!crossline)
				COM_Error ("Line %i is incomplete\n",scriptline);
			scriptline++;
		}
	}

	if (script_p >= scriptend_p)
	{
		if (!crossline)
			COM_Error ("Line %i is incomplete\n",scriptline);
		endofscript = true;
		return true;
	}

	if (*script_p == ';' || *script_p == '#')	// semicolon is comment field
	{							// also make # a comment field
		if (!crossline)
			COM_Error ("Line %i is incomplete\n",scriptline);

		while (*script_p++ != '\n')
		{
			if (script_p >= scriptend_p)
			{
				endofscript = true;
				return false;
			}
		}
		goto skipspace;
	}

//
// copy token
//
	token_p = token;

	while ( *script_p > 32 && *script_p != ';')
	{
		*token_p++ = *script_p++;
		if (script_p == scriptend_p)
			break;
		if (token_p == &token[MAXTOKEN])
			COM_Error ("Token too large on line %i\n",scriptline);
	}

	*token_p = 0;
	return true;
}


/*
==============
TokenAvailable

Returns true if there is another token on the line
==============
*/
qboolean TokenAvailable (void)
{
	char	*search_p;

	search_p = script_p;

	if (search_p >= scriptend_p)
		return false;

	while ( *search_p <= 32)
	{
		if (*search_p == '\n')
			return false;
		search_p++;
		if (search_p == scriptend_p)
			return false;
	}

	if (*search_p == ';')
		return false;

	return true;
}
