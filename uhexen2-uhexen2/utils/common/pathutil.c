/* pathutil.c -- filename handling utilities
 * Copyright (C) 1996-1997 Id Software, Inc.
 * Copyright (C) 2005-2012 O.Sezer <sezero@users.sourceforge.net>
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

// HEADER FILES ------------------------------------------------------------

#include "q_stdinc.h"
#include "compiler.h"
#include "arch_def.h"
#include "pathutil.h"
#include "cmdlib.h"
#include "filenames.h"

// MACROS ------------------------------------------------------------------

// TYPES -------------------------------------------------------------------

// EXTERNAL FUNCTION PROTOTYPES --------------------------------------------

// PUBLIC FUNCTION PROTOTYPES ----------------------------------------------

// PRIVATE FUNCTION PROTOTYPES ---------------------------------------------

// EXTERNAL DATA DECLARATIONS ----------------------------------------------

// PUBLIC DATA DEFINITIONS -------------------------------------------------

// PRIVATE DATA DEFINITIONS ------------------------------------------------

// CODE --------------------------------------------------------------------

void DefaultExtension (char *path, const char *extension, size_t len)
{
	char	*src;
//
// if path doesn't have a .EXT, append extension
// (extension should include the .)
//
	if (!*path)
		return;
	src = path + strlen(path) - 1;

	while (!IS_DIR_SEPARATOR(*src) && src != path)
	{
		if (*src == '.')
			return;		// it has an extension
		src--;
	}

	qerr_strlcat(__thisfunc__, __LINE__, path, extension, len);
}

void DefaultPath (char *path, const char *basepath, size_t len)
{
	char	temp[MAX_OSPATH];

	if (IS_ABSOLUTE_PATH(path))
		return;

	qerr_strlcpy(__thisfunc__, __LINE__, temp, path, sizeof(temp));
	qerr_strlcpy(__thisfunc__, __LINE__, path, basepath, len);
	qerr_strlcat(__thisfunc__, __LINE__, path, temp, len);
}

void StripFilename (char *path)
{
	int		length;

	length = (int)strlen(path) - 1;
	while (length > 0 && !IS_DIR_SEPARATOR(path[length]))
		length--;
	if (length >= 0)
		path[length] = 0;
}

void StripExtension (char *path)
{
	int		length;

	length = (int)strlen(path) - 1;
	while (length > 0 && path[length] != '.')
	{
		length--;
		if (IS_DIR_SEPARATOR(path[length]))
			return;		/* no extension */
	}
	if (length > 0)
		path[length] = 0;
}

/*
====================
Extract file parts
// FIXME: should include the slash, otherwise backing to
// an empty path will be wrong when appending a slash
====================
*/
void ExtractFilePath (const char *in, char *out, size_t outsize)
{
	const char	*src;
	size_t		len;

	src = in + strlen(in) - 1;
	if (src <= in)
	{
		*out = '\0';
		return;
	}

	while (src != in && !IS_DIR_SEPARATOR(src[-1]))
		src--;

	len = src - in;
	if (len >= outsize)
		len = outsize - 1;
	memcpy (out, in, len);
	out[len] = '\0';
}

void ExtractFileBase (const char *in, char *out, size_t outsize)
{
	const char	*src;

	src = in + strlen(in) - 1;
	if (src <= in)
	{
		*out = '\0';
		return;
	}

	while (src != in && !IS_DIR_SEPARATOR(src[-1]))
		src--;
	while (*src && *src != '.' && outsize)
	{
		if (--outsize)
			*out++ = *src++;
	}
	*out = '\0';
}

const char *FileGetExtension (const char *in)
{
	const char	*src;
	size_t		len;

	len = strlen(in);
	if (len < 2)	/* nothing meaningful */
		return "";

	src = in + len - 1;
	while (src != in && src[-1] != '.')
		src--;
	if (src == in || FIND_FIRST_DIRSEP(src) != NULL)
		return "";	/* no extension, or parent directory has a dot */

	return src;
}

void ExtractFileExtension (const char *in, char *out, size_t outsize)
{
	const char *ext = FileGetExtension (in);
	if (! *ext)
		*out = '\0';
	else
		q_strlcpy (out, ext, outsize);
}
