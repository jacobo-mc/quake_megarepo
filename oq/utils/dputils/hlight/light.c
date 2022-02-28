// lighting.c

#include "light.h"

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
// LordHavoc
qboolean	ignorefalloff;
vec_t		lh_globalfalloff;
qboolean	nocolor;

float		minlight;
//float		minlights[MAX_MAP_FACES];


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
	int			i, j, k;
	float		l;
	
	j = -1;
	l = 100.0 / numfaces;
	while (1)
	{
		LOCK;
		i = bspfileface++;
		k = (int) ((float) i * l);
		if (k != j)
			printf ("\rprogress: %d%% (%d of %d faces)", j, i, numfaces);
		j = k;
		UNLOCK;
		if (i >= numfaces)
			return;
		
		LightFace (i);
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

	RunThreadsOn (LightThread);

	lightdatasize = file_p - filebase;
	
	printf ("\nlightdatasize: %i\n", lightdatasize);
}

FILE	*litfile; // used in lightface to write to extended light file

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
	char		litfilename[1024];

// LordHavoc
	printf ("hlight 1.02 by LordHavoc\n");
	printf ("based on id Software's quake light utility source code\n");
	lh_globalfalloff = 1.0f/65536.0f;

	for (i=1 ; i<argc ; i++)
	{
		if (!strcmp(argv[i],"-minlight"))
		{
			minlight = atof (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-threads"))
		{
			numthreads = atoi (argv[i+1]);
			i++;
			printf("using %i threads\n", numthreads);
		}
		else if (!strcmp(argv[i],"-extra"))
		{
			extrasamples = true;
			printf ("extra sampling enabled\n");
		}
// LordHavoc
		else if (!strcmp(argv[i],"-ignorefalloff"))
		{
			ignorefalloff = true;
			printf ("per light falloff settings disabled\n");
		}
		else if (!strcmp(argv[i],"-falloff"))
		{
			lh_globalfalloff = atof (argv[i+1]);
			printf("scaling falloff values by %f\n", lh_globalfalloff);
			lh_globalfalloff *= lh_globalfalloff * (1.0f/65536.0f);
			i++;
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
		else if (!strcmp(argv[i],"-nocolor"))
		{
			printf(".lit file output disabled\n");
			nocolor = true;
		}
		else if (argv[i][0] == '-')
			Error ("Unknown option \"%s\"", argv[i]);
		else
			break;
	}

// LordHavoc
	if (i != argc - 1)
		Error ("\
usage: hlight [-threads num] [-extra] [-ignorefalloff] [-dist num] [-range num] [-nocolor] bspfile\n\
LordHavoc's hlight util based on id Software's quake light utility source code\n\
(different light falloff calculation, for more interesting lighting, now also has colored lighting!)\n\
Quick usage notes for entities: (place these in key/value pairs)\n\
wait - falloff rate (1.0 default, 0.5 = bigger radius, 2 = smaller)\n\
_color - 3 values (red green blue), specifies color of light, the scale of the numbers does not matter (\"1 3 2.5\" is identical to \"1000 3000 2500\")\n\
What the options do:\n\
-minlight num  sets minimum light level, any places darker than this are raised to it\n\
-threads num   how many threads to execute at once (useful on multiple CPU machines)\n\
-extra         antialiased lighting (takes upto four times as long, higher quality)\n\
-ignorefalloff disables the per light falloff settings (\"wait\" key changes how focused a light is - 0.5 would be double the area, 2.0 would be half the area)\n\
-falloff num   the global falloff scale (scales all lights)\n\
-dist num      changes lighting scale of all things\n\
-range num     changes brightness of all lights (without affecting size)\n\
-nocolor       does not write out the external .lit colored lighting file\n\
");

	printf ("----- LightFaces ----\n");

	InitThreads ();

	start = I_FloatTime ();

	strcpy (source, argv[i]);
	StripExtension (source);
	if (!nocolor)
		strcpy (litfilename, source);
	DefaultExtension (source, ".bsp");
	if (!nocolor)
	{
		DefaultExtension (litfilename, ".lit");
		litfile = fopen(litfilename, "wb");
		// LordHavoc: write out the QLIT header
		fputc('Q', litfile);
		fputc('L', litfile);
		fputc('I', litfile);
		fputc('T', litfile);
		fputc(1, litfile);
		fputc(0, litfile);
		fputc(0, litfile);
		fputc(0, litfile);
	}
	
	LoadBSPFile (source);
	LoadEntities ();
		
	MakeTnodes (&dmodels[0]);

	LightWorld ();

	WriteEntitiesToString ();	
	WriteBSPFile (source);
	if (!nocolor)
	if (litfile)
		fclose(litfile);

	end = I_FloatTime ();
	printf ("%5.1f seconds elapsed\n", end-start);
	
	return 0;
}

