/*
tri2map - raw triangle to Quake .map terrain convertor

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
#include <stdlib.h>
#include <string.h>

int write_terrain_triangle (FILE * f, float flr, float quark,
	float ax, float ay, float az,
	float bx, float by, float bz,
	float cx, float cy, float cz)
{
	if (az <= flr && bz <= flr && cz <= flr) return 1;

	fprintf(f, " {\n");

	if (bz > flr || cz > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			cx, cy, cz,   bx, by, bz,    bx, by, bz - 128); // SIDE BC
	if (bz > flr || az > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			bx, by, bz,   ax, ay, az,    ax, ay, az - 128); // SIDE AB
	if (az > flr || cz > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			ax, ay, az,   cx, cy, cz,    cx, cy, cz - 128); // SIDE AC

	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) black 0 0 0 1 1\n",
		0.0f,0.0f,flr, 4096.0f,0.0f,flr, 0.0f,4096.0f,flr); // BOTTOM

	if (quark)
	{
		bx = (bx - ax) * 128.0f / quark + ax;
		by = (by - ay) * 128.0f / quark + ay;
		bz = (bz - az) * 128.0f / quark + az;
		cx = (cx - ax) * 128.0f / quark + ax;
		cy = (cy - ay) * 128.0f / quark + ay;
		cz = (cz - az) * 128.0f / quark + az;
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) ground1_1 0 0 0 1 1 //TX1\n",
			ax, ay, az,   bx, by, bz,   cx, cy, cz   ); // TOP
	}
	else fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) ground1_1 0 0 0 1 1\n",
			ax, ay, az,   bx, by, bz,   cx, cy, cz   ); // TOP

	fprintf(f, " }\n");

	return 0;
}

int convert (char * in, char * out, float hscale, float vscale,
	float xoff, float yoff, float zoff, float floor, float quark)
{
	FILE * i, * o;
	int length, type = 0;
	char str [256];
	float ax,ay,az, bx,by,bz, cx,cy,cz;

	printf ("Input  File Name: %s\n", in);
	printf ("Output File Name: %s\n", out);

	length = strlen (in);

	if (length < 5) type = 0;
	else if (strcmp (in + (length - 4), ".raw") == 0) type = 1;
	else if (strcmp (in + (length - 4), ".cad") == 0) type = 2;

	if (type == 0)
	{
		printf ("ERROR: input file type should be .raw or .cad\n");
		return 1;
	}

	i = fopen (in,  "ra");
	o = fopen (out, "wa");

	fprintf (o, "{\n");
	fprintf (o, " \"classname\" \"worldspawn\"\n");
	fprintf (o, " \"message\" \"No Name\"\n");
	fprintf (o, " \"worldtype\" \"0\"\n");

	while (1)
	{
		if (fgets (str, 255, i) == NULL) break;
		if (type == 1)
		{
			if (strlen (str) < 5) continue;
			sscanf (str, "%f %f %f %f %f %f %f %f %f",
				&ax,&az,&ay, &bx,&bz,&by, &cx,&cz,&cy);
			ax *= -1;  bx *= -1;  cx *= -1;
			ay *= -1;  by *= -1;  cy *= -1;
		}
		if (type == 2)
		{
			if (str[0] != 'F' || str[1] != ' ') continue;
			sscanf (str, "F %f %f %f %f %f %f %f %f %f",
				&ay,&az,&ax, &by,&bz,&bx, &cy,&cz,&cx);
			ay *= -1;  by *= -1;  cy *= -1;
		}
		write_terrain_triangle (o, floor, quark,
			ax * hscale + xoff, ay * hscale + yoff, az * vscale + zoff,
			bx * hscale + xoff, by * hscale + yoff, bz * vscale + zoff,
			cx * hscale + xoff, cy * hscale + yoff, cz * vscale + zoff);
	}

	fprintf (o, "}\n");
	fprintf (o, "{\n");
	fprintf (o, " \"classname\" \"info_player_start\"\n");
	fprintf (o, " \"origin\" \"0 0 0\"\n");
	fprintf (o, " \"angle\" \"360\"\n");
	fprintf (o, "}\n");

	fclose (i);
	fclose (o);

	return 0;
}

int help ()
{
	printf ("USAGE: tri2map [options] <file> [more options and/or files]\n");
	printf ("OPTIONS:\n");
	printf ("        -o [string] : output filename (NOTE: affects only the next input file)\n");
	printf ("                      (default = input filename but with .map extension\n");
	printf ("        -h [float]  : horizontal scale (default = 64)\n");
	printf ("        -v [float]  : vertical   scale (default = 64)\n");
	printf ("        -s [float]  : sets both horizontal and vertical scale (default = 64)\n");
	printf ("        -x [float]  : X offset (lattitude) in Quake units (default = 0)\n");
	printf ("        -y [float]  : Y offset (longitude) in Quake units (default = 0)\n");
	printf ("        -z [float]  : Z offset (altitude)  in Quake units (default = 0)\n");
	printf ("        -f [float]  : height of brush bottoms in Quake units (default = -4096)\n");
	printf ("        -q [float]  : use Quake Army Knife (QuArK)'s \"three points\"\n");
	printf ("                      texture alignment system to fit textures on faces\n");
	printf ("                      this float value is the number of texture pixels\n");
	printf ("                      to stretch along each edge of the triangles\n");

	return 1;
}

int main (int argc, char ** argv)
{
	int i, c;

	char  outfile [100];
	float hscale = 64;
	float vscale = 64;
	float xoff   = 0;
	float yoff   = 0;
	float zoff   = 0;
	float floor  = -4096;
	float quark  = 0;

	printf ("tri2map - raw triangle to Quake .map terrain convertor\n");
	printf ("Copyright (C) 2000  Seth Galbraith\n");

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
							sprintf (outfile + c, ".map");
							break;
				case 'h' :	hscale = atof (argv[i + 1]); break;
				case 'v' :	vscale = atof (argv[i + 1]); break;
				case 's' :  hscale = atof (argv[i + 1]); vscale = hscale; break;
				case 'x' :	xoff   = atof (argv[i + 1]); break;
				case 'y' :	yoff   = atof (argv[i + 1]); break;
				case 'z' :	zoff   = atof (argv[i + 1]); break;
				case 'f' :	floor  = atof (argv[i + 1]); break;
				case 'q' :	quark  = atof (argv[i + 1]); break;
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
			sprintf (outfile + c, ".map");
		}
		convert (argv[i], outfile, hscale, vscale, xoff, yoff, zoff, floor, quark);
	}
	return 0;
}
