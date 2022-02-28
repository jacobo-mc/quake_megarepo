/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

//
// cadlib.c: library for loading triangles from a Breeze Designer .cad file
//

#include <stdio.h>
#include "cmdlib.h"
#include "mathlib.h"
#include "trilib.h"
#include "cadlib.h"

void CAD_LoadTriangleList (char *filename, triangle_t **pptri, int *numtriangles)
{
	FILE        *input;
	char        str[256];
	int         i;
	triangle_t	*ptri;

//
// open input file
//
	if ((input = fopen (filename, "ra")) == 0)
	{
		fprintf (stderr, "reader: could not open file '%s'\n", filename);
		exit (0);
	}

//
// count triangles
//
	*numtriangles = 0;
	for (i = 0; i < MAXTRIANGLES; i++)
	{
		if (fgets (str, 255, input) == NULL) break;
		if (str[0] != 'F' || str[1] != ' ') continue;
		(*numtriangles)++;
	}
	fseek (input, 0, SEEK_SET);

//
// allocate triangles
//
	ptri = malloc (*numtriangles * sizeof(triangle_t));
	*pptri = ptri;

//
// read triangles
//
	for (i = 0; i < *numtriangles; i++)
	{
		if (fgets (str, 255, input) == NULL) break;
		if (str[0] != 'F' || str[1] != ' ') {i--; continue;}
		sscanf (str, "F %f %f %f %f %f %f %f %f %f",
			&ptri->verts[0][1], &ptri->verts[0][2], &ptri->verts[0][0],
			&ptri->verts[1][1], &ptri->verts[1][2], &ptri->verts[1][0],
			&ptri->verts[2][1], &ptri->verts[2][2], &ptri->verts[2][0]);

		ptri->verts[0][1] *= -1;
		ptri->verts[1][1] *= -1;
		ptri->verts[2][1] *= -1;

		ptri++;
	}

	fclose (input);
}
