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

// lighting.c

#include "light.h"

#include "work.h"

/*

NOTES
-----

*/

float		scaledist = 1.0;
float		scalecos = 0.5;
float		rangescale = 0.5;

byte		*filebase, *file_p, *file_end;

dmodel_t	*bspmodel;
int			bspfileface;	// next surface to dispatch

vec3_t	bsp_origin;

qboolean	extrasamples;

vec_t cutoff = 1.0;

float noise = 0.0; // SerpLord - add 3D noise

qboolean iklite = false; // SerpLord - emulate IKLITE
	// (attenuation based on negative "angle" key)

float		minlights[MAX_MAP_FACES];


byte *GetFileSpace (int size)
{
	byte	*buf;
	
	LOCK;
	file_p = (byte *)(((long)file_p + 3)&~3);
	buf = file_p;
	file_p += size;
	UNLOCK;
	if (file_p > file_end)
		Error ("GetFileSpace: overrun");
	return buf;
}


void LightThread (void *junk)
{
	int			i;

	while (1)
	{
		LOCK;
		i = bspfileface++;
		UNLOCK;
		if (i >= numfaces)
			return;

		LightFace (i);

		NextWork();
	}
}

/*
=============
LightWorld
=============
*/
void LightWorld (void)
{
	filebase = file_p = dlightdata;
	file_end = filebase + MAX_MAP_LIGHTING;

	printf("%5i faces\n",numfaces);
	InitWork(numfaces,1);

	RunThreadsOn (LightThread);

	DoneWork();

	lightdatasize = file_p - filebase;
	
	printf ("lightdatasize: %i\n", lightdatasize);
}


/*
========
main

light modelfile
========
*/
int main (int argc, char **argv)
{
	int		i;
	double		start, end;
	char		source[1024];

	printf ("----- LightFaces ----\n");

	for (i=1 ; i<argc ; i++)
	{
		if (!strcmp(argv[i],"-threads"))
		{
			numthreads = atoi (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-extra"))
		{
			extrasamples = true;
			printf ("extra sampling enabled\n");
		}
		else if (!strcmp(argv[i],"-dist"))
		{
			scaledist = atof (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-range"))
		{
			rangescale = atof (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-cutoff"))
		{
			cutoff = atof(argv[++i]);
		}
		else if (!strcmp(argv[i],"-noise"))
		{
			// SerpLord - add 3D noise
			noise = atof(argv[++i]);
		}
		else if (!strcmp(argv[i],"-iklite"))
		{
			// SerpLord - emulate IKLITE
			// (attenuation based on negative "angle" key)
			iklite = true;
			printf ("IKLITE emulation enabled\n");
		}
		else if (argv[i][0] == '-')
			Error ("Unknown option \"%s\"", argv[i]);
		else
			break;
	}

	if (i != argc - 1)
		Error ("usage: light [-threads num] [-extra] [-cutoff value] [-noise value] [-iklite] bspfile");

	InitThreads ();

	start = I_FloatTime ();

	strcpy (source, argv[i]);
	StripExtension (source);
	DefaultExtension (source, ".bsp");
	
	LoadBSPFile (source);
	LoadEntities ();
		
	MakeTnodes (&dmodels[0]);

	LightWorld ();

	WriteEntitiesToString ();	
	WriteBSPFile (source);

	end = I_FloatTime ();
	printf ("%5.1f seconds elapsed\n", end-start);
	
	return 0;
}

