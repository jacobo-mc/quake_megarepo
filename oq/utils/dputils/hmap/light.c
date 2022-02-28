// lighting.c

#include "havocmap.h"

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

qboolean	extrasamples = true; // LordHavoc: default to high quality lighting
// LordHavoc
qboolean	ignorefalloff;
vec_t		lh_globalfalloff;

float		minlight;


byte *GetFileSpace (int size)
{
	byte	*buf;
	
	file_p = (byte *)(((long)file_p + 3)&~3);
	buf = file_p;
	file_p += size;
	if (file_p > file_end)
		Error ("GetFileSpace: overrun");
	return buf;
}

/*
=============
LightWorld
=============
*/
void LightWorld (void)
{
	int			i, j, k;
	long		lightstarttime;
	filebase = file_p = dlightdata;
	file_end = filebase + MAX_MAP_LIGHTING;
	lightstarttime = time(NULL);

	k = 1;
	j = numfaces * k / 100;
	for (i = 0;i < numfaces;i++)
	{
		if (i >= j)
		{
			printf ("\rface   %5i of %5i (%3i%%), estimated time left: %5i ", i, numfaces, k, i ? (numfaces-i)*(time(NULL)-lightstarttime)/i : 0);
			j = numfaces * k++ / 100;
		}
		
		LightFace (i);
	}

	lightdatasize = file_p - filebase;
	
	printf ("\n%5i faces done\nlightdatasize: %i\n", numfaces, lightdatasize);
}
