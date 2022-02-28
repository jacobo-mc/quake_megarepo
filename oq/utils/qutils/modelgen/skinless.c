/*
Skinless - generates base frames from .mdl models

Copyright (C) 2000  Seth Galbraith

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
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

Seth Galbraith
"The Serpent Lord"
http://www.planetquake.com/simitar
sgalbrai@krl.org
*/

#include <stdio.h>

#define INCLUDELIBS
#include "modelgen.h"

int convert (char * in, char * out)
{
	FILE			* i, * o;
	int				t, v, x, y, z, skin, numgroupskins;
	mdl_t			mdl;
	dtriangle_t		* triangles;
	stvert_t		* stverts;
	aliasskintype_t	skintype;

	printf ("Input  File Name: %s\n", in);
	printf ("Output File Name: %s\n", out);

// load the mdl

	if (!(i = fopen (in,  "rb")))
	{
		printf ("ERROR: can't open input file %s", in);
		return 1;
	}

	fread (&mdl, sizeof(mdl), 1, i);

	if (mdl.ident != IDPOLYHEADER)
	{
		printf ("ERROR: %s does not appear to be a .mdl file", in);
		fclose (i);
		return 1;
	}
	if (mdl.version != ALIAS_VERSION)
	{
		printf ("ERROR: %s has the wrong version number", in);
		fclose (i);
		return 1;
	}

	// skip through the skins section

	for (skin = 0; skin < mdl.numskins; skin++)
	{
		fread (&skintype, sizeof (skintype), 1, i);
		if (skintype == ALIAS_SKIN_SINGLE)
			fseek (i, mdl.skinwidth * mdl.skinheight, SEEK_CUR);
		else if (skintype == ALIAS_SKIN_GROUP)
		{
			fread (&numgroupskins, sizeof (numgroupskins), 1, i);
			fseek (i,
				numgroupskins * (sizeof (float) + mdl.skinwidth * mdl.skinheight),
				SEEK_CUR);
		}
		else
		{
			printf ("ERROR: skin %i has unknown skintype %i", skin, skintype);
			fclose (i);
			return 1;
		}
	}

	// read the skin vertices

	if (!(stverts = malloc (mdl.numverts * sizeof (stvert_t))))
	{
		printf ("ERROR: failed to allocate %i skin vertices", mdl.numverts);
		fclose (i);
		return 1;
	}
	fread (stverts, sizeof (stvert_t), mdl.numverts, i);

	// read the triangles

	if (!(triangles = malloc (mdl.numtris * sizeof (dtriangle_t))))
	{
		printf ("ERROR: failed to allocate %i triangles", mdl.numtris);
		free (stverts);
		fclose (i);
		return 1;
	}
	fread (triangles, sizeof (dtriangle_t), mdl.numtris, i);

	fclose (i);

// write the base frame

	if (!(o = fopen (out, "wa")))
	{
		printf ("ERROR: can't open output file %s", out);
		free (triangles);
		free (stverts);
		return 1;
	}

	fprintf (o, "version 1.3\n");
	fprintf (o, "distance 20.3961\n");
	fprintf (o, "_camera _camera0\n");
	fprintf (o, "  size 0 0 0\n");
	fprintf (o, "  extra -1.33 0 1\n");
	fprintf (o, "  scale 0 0 0\n");
	fprintf (o, "  rotate 0 1 0\n");
	fprintf (o, "  move 0 4 20\n");
	fprintf (o, "_light _light0\n");
	fprintf (o, "  size 1 1 1\n");
	fprintf (o, "  extra -20 35 34\n");
	fprintf (o, "  scale 1 1 1\n");
	fprintf (o, "  move -20 35 34\n");
	fprintf (o, "_light _light1\n");
	fprintf (o, "  size 1 1 1\n");
	fprintf (o, "  extra 0 0 24\n");
	fprintf (o, "  scale 1 1 1\n");
	fprintf (o, "  move 0 0 24\n");
	fprintf (o, "points frame\n");
	fprintf (o, "3\n");

	// write base frame triangles

	for (t = 0; t < mdl.numtris; t++)
	{
		fprintf (o, "F");
		for (v = 0; v < 3; v++)
		{
			// depth based on vertex number to ensure proper connectivity and smoothing
			y = triangles[t].vertindex[v];

			x = stverts[triangles[t].vertindex[v]].s;
			z = stverts[triangles[t].vertindex[v]].t * -1;

			// seam vertices on back triangles must be shifted to the right side
			if (stverts[triangles[t].vertindex[v]].onseam && !triangles[t].facesfront)
				x += mdl.skinwidth / 2;

			fprintf (o, " %i %i %i", y, z, x);
		}
		fprintf (o, "\n");
	}
	fprintf (o, "end\n");
	fprintf (o, "end\n");

	fclose (o);

	free (triangles);
	free (stverts);

	return 0;
}

int help ()
{
	printf ("USAGE: skinless [options] <file> [more options and/or files]\n");
	printf ("OPTIONS:\n");
	printf ("        -o [string] : output filename (NOTE: affects only the next input file)\n");

	return 1;
}

int main (int argc, char ** argv)
{
	int i, c;

	char   outfile [100];

	printf ("skinless - base frame generator\n");
	printf ("Copyright (C) 2001  Seth Galbraith\n");

	if (argc < 2) {help (); return 1;}

	for (i=1; i < argc; i++)
	{
		outfile[0] = '\0';
		while (argv[i][0] == '-')
		{
			if (i + 2 > argc)
			{
				if (i + 3 > argc) printf ("ERROR: option '%s %s' not followed by a filename.\n",
				                  argv[i], argv[i + 1]);
				else              printf ("ERROR: option '%s' not followed by a value.\n",
				                  argv[i]);
				help ();
				return 1;
			}
			switch (argv[i][1])
			{
				case 'o' :	for (c=0; c < 95 && argv[i + 1][c] && argv[i + 1][c] != '.'; c++)
								outfile[c] = argv[i + 1][c];
							sprintf (outfile + c, ".cad");
							break;
				default  :	printf ("ERROR: unrecognized option '%s'.\n", argv[i]);
							help ();
							return 1;
			}
			i += 2;
		}
		if (outfile[0] == '\0')
		{
			for (c=0; c < 95 && argv[i][c] && argv[i][c] != '.'; c++)
				outfile[c] = argv[i][c];
			sprintf (outfile + c, ".cad");
		}
		convert (argv[i], outfile);
	}
	return 0;
}
