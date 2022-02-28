/*
toon - 3D cartoon outline generator

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

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct vertex_s
{
    int flags;      // don't know what this is for
	float x, y, z;  // 3D position of the vertex
    float u, v;     // texture coordinate of the vertex
    int bone;       // index of the bone connected to this vertex
} vertex_t;

typedef struct normal_s
{
	float x;
	float y;
	float z;
} normal_t;

typedef struct triangle_s
{
	int flags;       // don't know what this is for
	int v1, v2, v3;  // indices to the 3 vertices of this triangle
	int n1, n2, n3;  // indices to the normals for shading the triangle
	int group;       // index of the smoothing group this triangle belongs to
} triangle_t;

typedef struct mesh_s
{
	char * name;
	int flags;
	int material;
	int vertices;
	int normals;
	int triangles;
	vertex_t   * v;
	normal_t   * n;
	triangle_t * t;
} mesh_t;

int clean_up (mesh_t * m, int count)
{
	int j = 0;
	if (count > 0 && m == NULL) return 1;
	for (j = 0; j < count; j++)
	{
		if (m[j].name != NULL) free (m[j].name);
		if (m[j].v != NULL) free (m[j].v);
		if (m[j].n != NULL) free (m[j].n);
		if (m[j].t != NULL) free (m[j].t);
	}
	if (m != NULL) free (m);
	return 0;
}

int write_outline_mesh (mesh_t * m, int count, FILE * o, float thickness)
{
	int i, j, meshnum, vertnum, trinum;
	float ax,ay,az, bx,by,bz, cx,cy,cz, abx,aby,abz, bcx,bcy,bcz, x,y,z, length;

	for (i = 0; i < count; i++)
	{
		fprintf (o, "\"%s_outline\" %i %i\n", m[i].name, m[i].flags, 0);

		// write vertices

		fprintf (o, "%i\n", m[i].vertices);
		for (j = 0; j < m[i].vertices; j++)
		{
			// find all vertices in every mesh with the same 3D coordinates

			for (meshnum = 0; meshnum < count; meshnum++)
				for (vertnum = 0; vertnum < m[meshnum].vertices; vertnum++)
					if (fabs (m[meshnum].v[vertnum].x - m[i].v[j].x) < 0.01f &&
						fabs (m[meshnum].v[vertnum].y - m[i].v[j].y) < 0.01f &&
						fabs (m[meshnum].v[vertnum].z - m[i].v[j].z) < 0.01f)
					{
						// find every triangle that uses this vertex

						for (trinum = 0; trinum < m[meshnum].triangles; trinum++)
							if (m[meshnum].t[trinum].v1 == vertnum ||
								m[meshnum].t[trinum].v2 == vertnum ||
								m[meshnum].t[trinum].v3 == vertnum)
							{
								// add the triangle normal

								ax = m[meshnum].v[m[meshnum].t[trinum].v1].x;
								ay = m[meshnum].v[m[meshnum].t[trinum].v1].y;
								az = m[meshnum].v[m[meshnum].t[trinum].v1].z;

								bx = m[meshnum].v[m[meshnum].t[trinum].v2].x;
								by = m[meshnum].v[m[meshnum].t[trinum].v2].y;
								bz = m[meshnum].v[m[meshnum].t[trinum].v2].z;

								cx = m[meshnum].v[m[meshnum].t[trinum].v3].x;
								cy = m[meshnum].v[m[meshnum].t[trinum].v3].y;
								cz = m[meshnum].v[m[meshnum].t[trinum].v3].z;

								abx = bx - ax;  aby = by - ay;  abz = bz - az;
								bcx = cx - bx;  bcy = cy - by;  bcz = cz - bz;

								// cross product

							    x = aby * bcz - abz * bcy;
							    y = abz * bcx - abx * bcz;
							    z = abx * bcy - aby * bcx;

								// normalize

								length = sqrt (x*x + y*y + z*z);

							    m[i].n[j].x += x / length;
							    m[i].n[j].y += y / length;
							    m[i].n[j].z += z / length;
							}
					}

			// normalize the sum of all adjacent triangle normals

			x = m[i].n[j].x;  y = m[i].n[j].y;  z = m[i].n[j].z;
			length = sqrt (x*x + y*y + z*z);
		    m[i].n[j].x /= length;
		    m[i].n[j].y /= length;
		    m[i].n[j].z /= length;

			// write vertices thickened by translating along normals

			fprintf (o, "%i %f %f %f %f %f %i\n",
				m[i].v[j].flags,
				m[i].v[j].x + m[i].n[j].x * thickness,
				m[i].v[j].y + m[i].n[j].y * thickness,
				m[i].v[j].z + m[i].n[j].z * thickness,
				0.0f, 0.0f,
				m[i].v[j].bone);
		}

		// write outline normals, one for each vertex

		fprintf (o, "%i\n", m[i].vertices);
		for (j = 0; j < m[i].vertices; j++)
			fprintf (o, "%f %f %f\n", m[i].n[j].x, m[i].n[j].y, m[i].n[j].z);

		// write outline triangles

		fprintf (o, "%i\n", m[i].triangles);
		for (j = 0; j < m[i].triangles; j++)
		{
			fprintf (o, "%i %i %i %i %i %i %i %i\n",
				m[i].t[j].flags,
				m[i].t[j].v1, m[i].t[j].v3, m[i].t[j].v2,
				m[i].t[j].v1, m[i].t[j].v3, m[i].t[j].v2,
				m[i].t[j].group);
		}
	}
	return 0;
}

int convert (char * in, char * out, float thickness)
{
	FILE * i, * o;
	char str [256], tok [256];
	int j = 0, k = 0, meshes = 0, count = 0;
	mesh_t * m = NULL;

	printf ("Input  File Name: %s\n", in);
	printf ("Output File Name: %s\n", out);

	i = fopen (in,  "ra");
	o = fopen (out, "wa");

	if (fgets (str, 255, i) == NULL)
	{
		printf ("ERROR: could not read first line of %s\n", in);
		fclose (i);
		fclose (o);
		return 1;
	}
	if (strcmp (str, "// MilkShape 3D ASCII\n") != 0)
	{
		printf ("ERROR: first line of input file should be:\n");
		printf ("// MilkShape 3D ASCII\n");
		printf ("Instead it was:\n%s\n", str);
		fclose (i);
		fclose (o);
		return 1;
	}
	fprintf (o, "// MilkShape 3D ASCII\n");


	// Copy lines up to Meshes section

	while (fgets (str, 255, i) != NULL)
	{
		sscanf (str, "%s %i", tok, &meshes);
		if (strcmp (tok, "Meshes:") == 0)
		{
			m = malloc (meshes * sizeof (mesh_t));
			if (m == NULL)
			{
				printf ("ERROR: not enough memory for %i meshes\n", meshes);
				fclose (i);
				fclose (o);
				return 1;
			}
			fprintf (o, "Meshes: %i\n", 2 * meshes);
			break;
		}
		fprintf (o, str);
	}

	if (meshes == 0)
	{
		printf ("ERROR: no meshes found in `%s'\n", in);
		fclose (i);
		fclose (o);
		return 1;
	}

	// Add outlines to Meshes

	while (fgets (str, 255, i) != NULL)
	{
		if (str[0] == '\"')
		{
			sscanf (str, "\"%[^\"]\" %i %i", tok, &(m[count].flags), &(m[count].material));
			m[count].name = malloc (sizeof (char) * (strlen (tok) + 1));
			if (m[count].name == NULL)
			{
				printf ("ERROR: not enough memory for mesh name '%s_outline'\n", tok);
				fclose (i);
				fclose (o);
                clean_up (m, count + 1);
				return 1;
			}
            sprintf (m[count].name, "%s", tok);
			fprintf (o, "\"%s\" %i %i\n", m[count].name, m[count].flags, m[count].material + 1);

			// read vertices

			if (fgets (str, 255, i) == NULL) break;
			fprintf (o, str);
			sscanf (str, "%i", &(m[count].vertices));
			m[count].v = malloc (sizeof (vertex_t) * m[count].vertices);
			if (m[count].v == NULL)
			{
				printf ("ERROR: not enough memory for %i vertices\n", m[count].vertices);
				fclose (i);
				fclose (o);
				clean_up (m, count + 1);
				return 1;
			}
			for (j = 0; j < m[count].vertices; j++)
			{
				if (fgets (str, 255, i) == NULL)
				{
					printf ("ERROR: could not read %i vertices\n", m[count].vertices);
					fclose (i);
					fclose (o);
					clean_up (m, count + 1);
					return 1;
				}
				fprintf (o, str);
				sscanf (str, "%i %f %f %f %f %f %i",
					&(m[count].v[j].flags),
					&(m[count].v[j].x), &(m[count].v[j].y), &(m[count].v[j].z),
					&(m[count].v[j].u), &(m[count].v[j].v),
					&(m[count].v[j].bone));
			}

			// initialize normals, don't use the normals from the file.

			if (fgets (str, 255, i) == NULL) break;
			fprintf (o, str);
			sscanf (str, "%i", &(m[count].normals));
			m[count].n = malloc (sizeof (normal_t) * m[count].vertices);
			if (m[count].n == NULL)
			{
				printf ("ERROR: not enough memory for %i normals\n", m[count].vertices);
				fclose (i);
				fclose (o);
				clean_up (m, count + 1);
				return 1;
			}
			for (j = 0; j < m[count].vertices; j++)
			{
				m[count].n[j].x =  0.0f;
				m[count].n[j].y =  0.0f;
				m[count].n[j].z =  0.0f;
			}
			for (j = 0; j < m[count].normals; j++)
			{
				if (fgets (str, 255, i) == NULL)
				{
					printf ("ERROR: could not read %i normals\n", m[count].normals);
					fclose (i);
					fclose (o);
					clean_up (m, count + 1);
					return 1;
				}
				fprintf (o, str);
			}

			// read triangles

			if (fgets (str, 255, i) == NULL) break;
			fprintf (o, str);
			sscanf (str, "%i", &(m[count].triangles));
			m[count].t = malloc (sizeof (triangle_t) * m[count].triangles);
			if (m[count].t == NULL)
			{
				printf ("ERROR: not enough memory for %i triangles\n", m[count].triangles);
				fclose (i);
				fclose (o);
				clean_up (m, count + 1);
				return 1;
			}
			for (j = 0; j < m[count].triangles; j++)
			{
				if (fgets (str, 255, i) == NULL)
				{
					printf ("ERROR: could not read %i triangles\n", m[count].triangles);
					fclose (i);
					fclose (o);
					clean_up (m, count + 1);
					return 1;
				}
				fprintf (o, str);
				sscanf (str, "%i %i %i %i %i %i %i %i",
					&(m[count].t[j].flags),
					&(m[count].t[j].v1), &(m[count].t[j].v2), &(m[count].t[j].v3),
					&(m[count].t[j].n1), &(m[count].t[j].n2), &(m[count].t[j].n3),
					&(m[count].t[j].group));
			}
			count++;
		}
		else
		{
			if (count > 0)
			{
				write_outline_mesh (m, count, o, thickness);
				break;
			}
			fprintf (o, str);
		}
    }

	// Copy lines after Meshes section

	while (fgets (str, 255, i) != NULL)
	{
		sscanf (str, "%s %i", tok, &k);
		if (strcmp (tok, "Materials:") == 0)
		{
			// insert new outline material
			fprintf (o, "Materials: %i\n", k + 1);
			fprintf (o, "\"Outline\"\n");
			fprintf (o, "0.000000 0.000000 0.000000 1.000000\n");
			fprintf (o, "0.000000 0.000000 0.000000 1.000000\n");
			fprintf (o, "0.000000 0.000000 0.000000 1.000000\n");
			fprintf (o, "0.000000 0.000000 0.000000 1.000000\n");
			fprintf (o, "0.000000\n");
			fprintf (o, "1.000000\n");
			fprintf (o, "\"\"\n");
			fprintf (o, "\"\"\n");
			break;
		}
		fprintf (o, str);
	}

	while (fgets (str, 255, i) != NULL) fprintf (o, str);

	fclose (i);
	fclose (o);
	clean_up (m, count);
	return 0;
}

int help ()
{
	printf ("USAGE: toon [options] <file> [more options and/or files]\n");
	printf ("OPTIONS:\n");
	printf ("        -o [string] : output filename (NOTE: affects only the next input file)\n");
	printf ("        -t [float]  : thickness (default = 1)\n");

	return 1;
}

int main (int argc, char ** argv)
{
	int i, c;
	int count = 1;

	char  outfile [100];
	float thickness = 1;

	printf ("toon - 3D cartoon outline generator\n");
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
							sprintf (outfile + c, ".txt");
							break;
				case 't' :	thickness = atof (argv[i + 1]); break;
				default  :	printf ("ERROR: unrecognized option '%s'.\n", argv[i]);
							help ();
							return 1;
			}
			i += 2;
			if (i >= argc) break;
		}
		if (i >= argc) break;
		if (outfile[0] == '\0') sprintf (outfile, "toon%i.txt", count++);
		convert (argv[i], outfile, thickness);
	}
	return 0;
}
