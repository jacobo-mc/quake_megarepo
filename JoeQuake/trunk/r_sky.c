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
// r_sky.c

#include "quakedef.h"
#include "r_local.h"
#include "d_local.h"

float	skyshift;

byte	*r_skysource;
int	r_skymade;

// TODO: clean up these routines

byte	bottomsky[128*131];
byte	bottommask[128*131];
byte	newsky[128*256];	// newsky and topsky both pack in here, 128 bytes
				// of newsky on the left of each scan, 128 bytes
				// of topsky on the right, because the low-level
				// drawers need 256-byte scan widths

/*
=============
R_InitSky

A sky texture is 256*128, with the right side being a masked overlay
==============
*/
void R_InitSky (miptex_t *mt)
{
	int	i, j;
	byte	*src;

	src = (byte *)mt + mt->offsets[0];

	for (i=0 ; i<128 ; i++)
	{
		for (j=0 ; j<128 ; j++)
		{
			newsky[(i*256)+j+128] = src[i*256+j+128];
		}
	}

	for (i=0 ; i<128 ; i++)
	{
		for (j=0 ; j<131 ; j++)
		{
			if (src[i*256+(j&0x7F)])
			{
				bottomsky[(i*131)+j] = src[i*256+(j&0x7F)];
				bottommask[(i*131)+j] = 0;
			}
			else
			{
				bottomsky[(i*131)+j] = 0;
				bottommask[(i*131)+j] = 0xff;
			}
		}
	}

	r_skysource = newsky;
}

/*
=================
R_MakeSky
=================
*/
void R_MakeSky (void)
{
	int		x, y, ofs, baseofs, xshift, yshift;
	unsigned	*pnewsky;
	static int	xlast = -1, ylast = -1;

	xshift = yshift = skyshift;

	if ((xshift == xlast) && (yshift == ylast))
		return;

	xlast = xshift;
	ylast = yshift;

	pnewsky = (unsigned *)&newsky[0];

	for (y=0 ; y<SKYSIZE ; y++)
	{
		baseofs = ((y + yshift) & SKYMASK) * 131;

// FIXME: clean this up
#if UNALIGNED_OK
		for (x=0 ; x<SKYSIZE ; x += 4)
		{
			ofs = baseofs + ((x + xshift) & SKYMASK);

		// PORT: unaligned dword access to bottommask and bottomsky

			*pnewsky = (*(pnewsky + (128 / sizeof (unsigned))) & *(unsigned *)&bottommask[ofs]) | *(unsigned *)&bottomsky[ofs];
			pnewsky++;
		}
#else
		for (x=0 ; x<SKYSIZE ; x++)
		{
			ofs = baseofs + ((x + xshift) & SKYMASK);

			*(byte *)pnewsky = (*((byte *)pnewsky + 128) & *(byte *)&bottommask[ofs]) | *(byte *)&bottomsky[ofs];
			pnewsky = (unsigned *)((byte *)pnewsky + 1);
		}
#endif

		pnewsky += 128 / sizeof (unsigned);
	}

	r_skymade = 1;
}

#define	SKYSPEED1	8
#define	SKYSPEED2	2

/*
=============
R_SetSkyFrame
==============
*/
void R_SetSkyFrame (void)
{
	int	g, s1, s2;
	float	temp, skytime;

	g = GreatestCommonDivisor (SKYSPEED1, SKYSPEED2);
	s1 = SKYSPEED1 / g;
	s2 = SKYSPEED2 / g;
	temp = SKYSIZE * s1 * s2;

	skytime = cl.time - ((int)(cl.time / temp) * temp);
	skyshift = skytime * SKYSPEED1;	

	r_skymade = 0;
}
