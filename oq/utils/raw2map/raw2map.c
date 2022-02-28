/*
raw2map - raw bitmap to Quake .map terrain convertor

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
#include <math.h>
#include <strings.h>

#define FORMAT_RAW 0
#define FORMAT_TGA 1
#define FORMAT_BMP 2

typedef struct tga_header_s
{
	unsigned char whatever [18];
	unsigned char palette [256][3];
}
tga_header_t;

typedef struct tga_footer_s
{
	unsigned char whatever [521];
}
tga_footer_t;

typedef struct bmp_header_s
{
	unsigned char whatever [310];
	unsigned char palette [256][3];
}
bmp_header_t;

void write_block (FILE * f, char * tex,
	float minx, float miny, float minz, float maxx, float maxy, float maxz)
{
	fprintf(f, " {\n");
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		minx, miny, maxz,   maxx, maxy, maxz,   maxx, miny, maxz,   tex ); // TOP
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		maxx, maxy, minz,   minx, miny, minz,   maxx, miny, minz,   tex ); // BOTTOM
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		minx, miny, minz,   minx, miny, maxz,   maxx, miny, minz,   tex ); // SOUTH
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		minx, maxy, maxz,   minx, maxy, minz,   maxx, maxy, minz,   tex ); // NORTH
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		minx, miny, minz,   minx, maxy, maxz,   minx, miny, maxz,   tex ); // WEST
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) %s 0 0 0 1 1\n",
		maxx, maxy, maxz,   maxx, miny, minz,   maxx, miny, maxz,   tex ); // EAST
	fprintf(f, " }\n");
}

int write_terrain_triangle (FILE * f, float flr,
	float ax, float ay, float az,
	float bx, float by, float bz,
	float cx, float cy, float cz)
{
	if (az <= flr && bz <= flr && cz <= flr) return 1;

	fprintf(f, " {\n");
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) ground1_1 0 0 0 1 1\n",
		ax, ay, az,    bx, by, bz,       cx, cy, cz      ); // TOP
	fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) black 0 0 0 1 1\n",
		0.0f,0.0f,flr, 4096.0f,0.0f,flr, 0.0f,4096.0f,flr); // BOTTOM
	if (bz > flr || cz > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			cx, cy, cz,   bx, by, bz,    bx, by, bz - 128); // SIDE BC
	if (bz > flr || az > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			bx, by, bz,   ax, ay, az,    ax, ay, az - 128); // SIDE AB
	if (az > flr || cz > flr)
		fprintf(f, "  ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			ax, ay, az,   cx, cy, cz,    cx, cy, cz - 128); // SIDE AC
	fprintf(f, " }\n");

	return 0;
}

int write_terrain_quad (FILE * f, float flr,
	float ax, float ay, float az,
	float bx, float by, float bz,
	float cx, float cy, float cz,
	float dx, float dy, float dz)
{
	if (az <= flr && bz <= flr && cz <= flr && dz <= flr) return 1;

	fprintf(f, "  {\n");
	fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) ground1_1 0 0 0 1 1\n",
		ax, ay, az,    bx, by, bz,       cx, cy, cz      ); // TOP
	fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) black 0 0 0 1 1\n",
		0.0f,0.0f,flr, 4096.0f,0.0f,flr, 0.0f,4096.0f,flr); // BOTTOM
	if (dz > flr || cz > flr)
		fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			dx, dy, dz,   cx, cy, cz,    cx, cy, cz - 128); // SIDE CD
	if (cz > flr || bz > flr)
		fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			cx, cy, cz,   bx, by, bz,    bx, by, bz - 128); // SIDE BC
	if (bz > flr || az > flr)
		fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			bx, by, bz,   ax, ay, az,    ax, ay, az - 128); // SIDE AB
	if (az > flr || dz > flr)
		fprintf(f, "   ( %f %f %f ) ( %f %f %f ) ( %f %f %f ) rock1_2 0 0 0 1 1\n",
			ax, ay, az,   dx, dy, dz,    dx, dy, dz - 128); // SIDE AD
	fprintf(f, "  }\n");

	return 0;
}

int convert (char * in, int format, int width, char * out, float hscale, float vscale,
	float xoff, float yoff, float zoff, float floor, float ceil, float thick)
{
	FILE * f;
	unsigned char * bytes;
	int height;
	int x, y;
	int a, b, c, d;
	long size;
	float minx = 0.0, maxx = 0.0, miny = 0.0, maxy = 0.0;

	printf ("Input  File Name: %s\n", in);
	printf ("Output File Name: %s\n", out);

	f = fopen (in, "rb");

	fseek (f, 0, SEEK_END);
	size = ftell (f);
	printf ("Input  File Size: %ld\n", size);

	switch (format)
	{
		case FORMAT_BMP:
			// incorrect for many textures because of word length padding?
			size -= sizeof (bmp_header_t);
			fseek (f, sizeof (bmp_header_t), SEEK_SET);
			break;

		case FORMAT_TGA:
			size -= sizeof (tga_header_t) + sizeof (tga_footer_t);
			fseek (f, sizeof (tga_header_t), SEEK_SET);
			break;

		default:
			fseek (f, 0, SEEK_SET);
			break;
	}

	// guess width and height - FIXME:  bmp and tga contain this information!

	if (!width) width = (int) sqrt (size);
	height = size / width;
	if (height * width != size)
	{
		printf ("ERROR: size is not a multiple of width.\n");
		fclose (f);
		return 1;
	}
	if (!(bytes = (char*) malloc (width * height)))
	{
		printf ("ERROR: can't allocate %d bytes", width * height);
		fclose (f);
		return 1;
	}

	fread (bytes, width, height, f);
	fclose (f);

	f = fopen (out, "wa");

	fprintf (f, "{\n");
	fprintf (f, " \"classname\" \"worldspawn\"\n");
	fprintf (f, " \"message\" \"No Name\"\n");
	fprintf (f, " \"worldtype\" \"0\"\n");

	a = 0; b = 1; c = width; d = width + 1;

	// walls and a big hint brush filling the terrain area

	if (thick > 0)
	{
		minx = -xoff;
		miny = -yoff;
		maxx = (width  - 1) * hscale - xoff;
		maxy = (height - 1) * hscale - yoff;

		write_block (f, "hint",    minx, miny, floor, maxx, maxy, ceil); // big hint brush
		write_block (f, "sky4",    minx, miny, ceil,  maxx, maxy, ceil + thick); // ceiling
		write_block (f, "city2_1", minx, miny - thick, floor, maxx, miny, ceil); // south
		write_block (f, "city2_1", minx, maxy, floor, maxx, maxy + thick, ceil); // north
		write_block (f, "city2_1", minx - thick, miny, floor, minx, maxy, ceil); // west
		write_block (f, "city2_1", maxx, miny, floor, maxx + thick, maxy, ceil); // east
	}

	fprintf (f, "}\n"); // end of worldspawn

	// a grid of hint brushes covering each square of terrain

	if (thick > 0)
	{
		fprintf (f, " {\n");
		fprintf (f, "  \"classname\" \"am_detail\"\n");

		for (y=1; y < height; y++)
			for (x=1; x < width; x++)
				write_block (f, "hint",
					(x - 1) * hscale - xoff, (y - 1) * hscale - yoff,  floor,
					 x      * hscale - xoff,  y      * hscale - yoff,  ceil);

		fprintf (f, "}\n");
	}

	// terrain brushes

	fprintf (f, "{\n");
	fprintf (f, " \"classname\" \"am_detail\"\n");

	for (y=1; y < height; y++)
	{
		for (x=1; x < width; x++)
		{
			if (bytes[a] - bytes[b] == bytes[c] - bytes[d])
			{
				write_terrain_quad (f, floor,
					 x      * hscale - xoff, (y - 1) * hscale - yoff, bytes[b] * vscale + zoff,
					(x - 1) * hscale - xoff, (y - 1) * hscale - yoff, bytes[a] * vscale + zoff,
					(x - 1) * hscale - xoff,  y      * hscale - yoff, bytes[c] * vscale + zoff,
					 x      * hscale - xoff,  y      * hscale - yoff, bytes[d] * vscale + zoff);
			}
			else if ((x + y) % 2)
			{
				write_terrain_triangle (f, floor,
					 x      * hscale - xoff, (y - 1) * hscale - yoff, bytes[b] * vscale + zoff,
					(x - 1) * hscale - xoff, (y - 1) * hscale - yoff, bytes[a] * vscale + zoff,
					(x - 1) * hscale - xoff,  y      * hscale - yoff, bytes[c] * vscale + zoff);
				write_terrain_triangle (f, floor,
					(x - 1) * hscale - xoff,  y      * hscale - yoff, bytes[c] * vscale + zoff,
					 x      * hscale - xoff,  y      * hscale - yoff, bytes[d] * vscale + zoff,
					 x      * hscale - xoff, (y - 1) * hscale - yoff, bytes[b] * vscale + zoff);
			}
			else
			{
				write_terrain_triangle (f, floor,
					 x      * hscale - xoff, (y - 1) * hscale - yoff, bytes[b] * vscale + zoff,
					(x - 1) * hscale - xoff, (y - 1) * hscale - yoff, bytes[a] * vscale + zoff,
					 x      * hscale - xoff,  y      * hscale - yoff, bytes[d] * vscale + zoff);
				write_terrain_triangle (f, floor,
					(x - 1) * hscale - xoff,  y      * hscale - yoff, bytes[c] * vscale + zoff,
					 x      * hscale - xoff,  y      * hscale - yoff, bytes[d] * vscale + zoff,
					(x - 1) * hscale - xoff, (y - 1) * hscale - yoff, bytes[a] * vscale + zoff);
			}
			a++; b++; c++; d++;
		}
		a++; b++; c++; d++;
	}
	fprintf (f, "}\n");

	if (thick)
	{
		// player start for testing

		fprintf (f, "{\n");
		fprintf (f, " \"classname\" \"info_player_start\"\n");
		fprintf (f, " \"origin\" \"%f %f %f\"\n",
			(minx + maxx) / 2,
			(miny + maxy) / 2,
			bytes [width * height / 2 + width / 2] * vscale + zoff + 64);
		fprintf (f, " \"angle\" \"360\"\n");
		fprintf (f, "}\n");

		// light for testing

		fprintf (f, "{\n");
		fprintf (f, " \"classname\" \"light\"\n");
		fprintf (f, " \"origin\" \"%f %f %f\"\n",
			(minx + maxx) / 2,
			(miny + maxy) / 2,
			ceil);
		fprintf (f, " \"light\" \"500\"\n");
		fprintf (f, " \"_attenuation\" \"1\"\n");
		fprintf (f, " \"_radius\" \"%f\"\n",
			hscale * ((width > height) ? width : height));
		fprintf (f, "}\n");
	}
	fclose (f);
	free (bytes);
	return 0;
}

int help ()
{
	printf ("USAGE: raw2map [options] <file> [more options and/or files]\n");
	printf ("OPTIONS:\n");
	printf ("        -w [int]    : image width in pixels (default = 0)\n");
	printf ("                      if width is 0, image is assumed to be square\n");
	printf ("        -o [string] : output filename (NOTE: affects only the next input file)\n");
	printf ("                      (default = input filename but with .map extension\n");
	printf ("        -h [float]  : horizontal scale in Quake units per pixel (default = 128)\n");
	printf ("        -v [float]  : vertical   scale in Quake units per pixel (default = 4)\n");
	printf ("        -x [float]  : X offset (lattitude) in Quake units (default = 0)\n");
	printf ("        -y [float]  : Y offset (longitude) in Quake units (default = 0)\n");
	printf ("        -z [float]  : Z offset (altitude)  in Quake units (default = 0)\n");
	printf ("        -f [float]  : height of brush bottoms in Quake units\n");
	printf ("                      (default = Z offset - vertical scale)\n");
	printf ("        -c [float]  : ceiling or sky height in Quake units\n");
	printf ("                      (default = maximum terrain height + 64)\n");
	printf ("        -t [float]  : wall thickness in Quake units (default = 64)\n");
	printf ("                      (if this is 0, no wall or hint brushes will be created)\n");
	printf ("                      NOTE: -v and -z restore default floor and ceiling height\n");

	return 1;
}

int main (int argc, char ** argv)
{
	int i, c;

	int   width  = 0;
	char  outfile [100];
	float hscale = 128;
	float vscale = 4;
	float xoff   = 0;
	float yoff   = 0;
	float zoff   = 0;
	float floor  = -4;
	float ceil   = 1084;
	float thick  = 64;
	int   format = FORMAT_RAW;

	printf ("raw2map - raw bitmap to Quake .map terrain convertor\n");
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
				case 'w' :	width  = atoi (argv[i + 1]); break;
				case 'o' :	for (c=0; c < 95 && argv[i + 1][c] && argv[i + 1][c] != '.'; c++)
								outfile[c] = argv[i + 1][c];
							sprintf (outfile + c, ".map");
							break;

				case 'h' :	hscale = atof (argv[i + 1]); break;
				case 'v' :	vscale = atof (argv[i + 1]);
							floor  = zoff - vscale;
							ceil   = floor + 256 * vscale + 64;
							break;

				case 'x' :	xoff   = atof (argv[i + 1]); break;
				case 'y' :	yoff   = atof (argv[i + 1]); break;
				case 'z' :	zoff   = atof (argv[i + 1]);
							floor  = zoff - vscale;
							ceil   = floor + 256 * vscale + 64;
							break;

				case 'f' :	floor  = atof (argv[i + 1]); break;
				case 'c' :	ceil   = atof (argv[i + 1]); break;
				case 't' :	thick  = atof (argv[i + 1]); break;
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

		format = FORMAT_RAW;
		for (c=0; c < 95 && argv[i][c] && argv[i][c] != '.'; c++);
		if (strncasecmp (argv[i] + c, ".bmp", 4) == 0) format = FORMAT_BMP;
		if (strncasecmp (argv[i] + c, ".tga", 4) == 0) format = FORMAT_TGA;

		convert (argv[i], format, width, outfile, hscale, vscale, xoff, yoff, zoff, floor, ceil, thick);
	}
	return 0;
}
