/*
	buildnum.c

	build number function

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif

#include <stdlib.h>

#include "buildnum.h"

static const char *date = __DATE__;						// Was "Dec 21 1999"
static const char *mon[12] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
							   "Aug", "Sep", "Oct", "Nov", "Dec" };
static const char mond[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };


/* returns days since Dec 21 1999 */
VISIBLE int
build_number (void)
{
	int			m = 0;
	int			d = 0;
	int			y = 0;
	static int  b = 0;

	if (b != 0)
		return b;

	for (m = 0; m < 11; m++) {
		if (strncasecmp (&date[0], mon[m], 3) == 0)
			break;
		d += mond[m];
	}

	d += atoi (&date[4]) - 1;

	y = atoi (&date[7]) - 1900;

	b = d + (int) ((y - 1) * 365.25);

	if (((y % 4) == 0) && m > 1) {
		b += 1;
	}

	b -= 36148;											// Dec 21 1999

	return b;
}
