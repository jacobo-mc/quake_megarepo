/*
mesh2map - triangle mesh to map convertor

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
	int flags;        // don't know what this is for
	int vertices [3]; // indices to the 3 vertices of this triangle
	int normals  [3]; // indices to the normals for shading the triangle
	int group;        // index of the smoothing group this triangle belongs to
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

typedef struct material_s
{
	char  name   [256];
	float ambient  [4];
	float diffuse  [4];
	float specular [4];
	float emissive [4];
	float shininess;
	float transparency;
	char * diffuse_texture;
	char * alpha_texture;
} material_t;

static int clean_up (mesh_t * m, int count)
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

int get_normal (triangle_t * t, vertex_t * v, normal_t * n)
{
	float abx,aby,abz, bcx,bcy,bcz, length;

	abx = v[t->vertices[1]].x - v[t->vertices[0]].x;
	aby = v[t->vertices[1]].y - v[t->vertices[0]].y;
	abz = v[t->vertices[1]].z - v[t->vertices[0]].z;

	bcx = v[t->vertices[2]].x - v[t->vertices[1]].x;
	bcy = v[t->vertices[2]].y - v[t->vertices[1]].y;
	bcz = v[t->vertices[2]].z - v[t->vertices[1]].z;

	// cross product

    n->x = aby * bcz - abz * bcy;
    n->y = abz * bcx - abx * bcz;
    n->z = abx * bcy - aby * bcx;

	// normalize

	length = sqrt (n->x * n->x + n->y * n->y + n->z * n->z);

	if (length == 0) return 1;

	n->x /= length;
	n->y /= length;
	n->z /= length;

	return 0;
}

static int write_brush (mesh_t * m, int count, FILE * o, float thickness,
	int mesh_a, int triangle_a, material_t * materials, double tolerance)
{
	int edge_a, edge_b, triangle_b, mesh_b, tx_flags = 0;
	double x, y, z, length, angle_a, angle_b, bc_slope, bc_intercept;
	vertex_t vertex_a[2], vertex_b[2], a, b, c;
	normal_t normal_a, normal_b, ortho, u, v;
	triangle_t * ta, * tb;

	tolerance *= 3.1415926535897932384626433832795 / 180.0; // convert to radians

	fprintf (o, " {\n");

	ta = m[mesh_a].t + triangle_a;

	// adjust vertices to UV coordinates

	a.x = m[mesh_a].v[ta->vertices[2]].x;
	a.y = m[mesh_a].v[ta->vertices[2]].y;
	a.z = m[mesh_a].v[ta->vertices[2]].z;
	a.u = m[mesh_a].v[ta->vertices[2]].u * 128;
	a.v = m[mesh_a].v[ta->vertices[2]].v * 128;

	b.x = m[mesh_a].v[ta->vertices[1]].x;
	b.y = m[mesh_a].v[ta->vertices[1]].y;
	b.z = m[mesh_a].v[ta->vertices[1]].z;
	b.u = m[mesh_a].v[ta->vertices[1]].u * 128;
	b.v = m[mesh_a].v[ta->vertices[1]].v * 128;

	c.x = m[mesh_a].v[ta->vertices[0]].x;
	c.y = m[mesh_a].v[ta->vertices[0]].y;
	c.z = m[mesh_a].v[ta->vertices[0]].z;
	c.u = m[mesh_a].v[ta->vertices[0]].u * 128;
	c.v = m[mesh_a].v[ta->vertices[0]].v * 128;

	// normalized U axis vector in 3D space
	u.x = b.x - a.x;   u.y = b.y - a.y;   u.z = b.z - a.z;
	if ((length = sqrt (u.x * u.x + u.y * u.y + u.z * u.z)) != 0)
		{ u.x /= length;   u.y /= length;   u.z /= length; }

	// normalized V axis vector in 3D space
	v.x = c.x - a.x;   v.y = c.y - a.y;   v.z = c.z - a.z;
	if ((length = sqrt (v.x * v.x + v.y * v.y + v.z * v.z)) != 0)
		{ v.x /= length;   v.y /= length;   v.z /= length; }

	if ((fabs (b.u - a.u) > 0.01 || fabs (b.v - a.v) > 0.01) &&
		(fabs (c.u - b.u) > 0.01 || fabs (c.v - b.v) > 0.01) &&
		(fabs (a.u - c.u) > 0.01 || fabs (a.v - c.v) > 0.01))
	{
		// compare the texture coordinates:
		// if they are clockwise, set tx_flags to 1
		// if they are counter-clockwise, set tx_flags to 3
		// if they are on a straight line, leave tx_flags at 0

		if (c.u - b.u != 0)
		{
			bc_slope = (c.v - b.v) / (c.u - b.u);
			bc_intercept = b.v - bc_slope * b.u;
			length = a.v - (bc_slope * a.u + bc_intercept);

			if (b.u > c.u) // C is left of B so clockwise if A is above
			{
				if (length > 0) tx_flags = 1;
				if (length < 0) tx_flags = 3;
			}
			else // B is left of C so clockwise if A is below 
			{
				if (length < 0) tx_flags = 1;
				if (length > 0) tx_flags = 3;
			}
		}
		else
		{
			// B and C vertices are vertically aligned on the texture
			// but if A is on the "wrong" side of that vertical line
			// then it needs to be flipped

			if (b.v > c.v) // B is above C so clockwise if A is left
			{
				if (a.u < b.u) tx_flags = 1;
				if (a.u > b.u) tx_flags = 3;
			}
			else // C is above B so clockwise if A is right
			{
				if (a.u > b.u) tx_flags = 1;
				if (a.u < b.u) tx_flags = 3;
			}
		}
	}

	if (tx_flags != 0)
	{
		// use threepoints texture alignment system

		a.x += u.x * a.u;   a.y += u.y * a.u;   a.z += u.z * a.u;
		a.x += v.x * a.v;   a.y += v.y * a.v;   a.z += v.z * a.v;
		b.x += u.x * b.u;   b.y += u.y * b.u;   b.z += u.z * b.u;
		b.x += v.x * b.v;   b.y += v.y * b.v;   b.z += v.z * b.v;
		c.x += u.x * c.u;   c.y += u.y * c.u;   c.z += u.z * c.u;
		c.x += v.x * c.v;   c.y += v.y * c.v;   c.z += v.z * c.v;
	}

	if (tx_flags == 3)
	{
		// texture coordinates are counter-clockwise so add vectors AB and AC to A
		// to put it at the opposite corner of the texture parallelogram

		a.x += u.x * (b.u - a.u);   a.y += u.y * (b.u - a.u);   a.z += u.z * (b.u - a.u);
		a.x += v.x * (b.v - a.v);   a.y += v.y * (b.v - a.v);   a.z += v.z * (b.v - a.v);
		a.x += u.x * (c.u - a.u);   a.y += u.y * (c.u - a.u);   a.z += u.z * (c.u - a.u);
		a.x += v.x * (c.v - a.v);   a.y += v.y * (c.v - a.v);   a.z += v.z * (c.v - a.v);
	}

	// write front plane

	if (tx_flags == 0)
		fprintf (o, "  ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) %s 0 0 0 1 1\n",
			a.x, a.y, a.z,   b.x, b.y, b.z,   c.x, c.y, c.z,
			(materials == NULL) ? materials[m[mesh_a].material].name : "wall9_8");
	else
		fprintf (o, "  ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) %s 0 0 0 1 1 //TX%i\n",
			a.x, a.y, a.z,   b.x, b.y, b.z,   c.x, c.y, c.z,
			(materials == NULL) ? materials[m[mesh_a].material].name : "wall9_8",
			tx_flags);

	get_normal (ta, m[mesh_a].v, &normal_a);

	for (edge_a = 0; edge_a < 3; edge_a++)
	{
		x = normal_b.x = normal_a.x;
		y = normal_b.y = normal_a.y;
		z = normal_b.z = normal_a.z;

		vertex_a[0].x = m[mesh_a].v[ta->vertices[(edge_a + 0) % 3]].x;
		vertex_a[0].y = m[mesh_a].v[ta->vertices[(edge_a + 0) % 3]].y;
		vertex_a[0].z = m[mesh_a].v[ta->vertices[(edge_a + 0) % 3]].z;

		vertex_a[1].x = m[mesh_a].v[ta->vertices[(edge_a + 1) % 3]].x;
		vertex_a[1].y = m[mesh_a].v[ta->vertices[(edge_a + 1) % 3]].y;
		vertex_a[1].z = m[mesh_a].v[ta->vertices[(edge_a + 1) % 3]].z;

		for (mesh_b = 0; mesh_b < count; mesh_b++)
			for (triangle_b = 0; triangle_b < m[mesh_b].triangles; triangle_b++)
				for (edge_b = 0; edge_b < 3; edge_b++)
				{
					tb = m[mesh_b].t + triangle_b;

					vertex_b[0].x = m[mesh_b].v[tb->vertices[(edge_b + 0) % 3]].x;
					vertex_b[0].y = m[mesh_b].v[tb->vertices[(edge_b + 0) % 3]].y;
					vertex_b[0].z = m[mesh_b].v[tb->vertices[(edge_b + 0) % 3]].z;

					vertex_b[1].x = m[mesh_b].v[tb->vertices[(edge_b + 1) % 3]].x;
					vertex_b[1].y = m[mesh_b].v[tb->vertices[(edge_b + 1) % 3]].y;
					vertex_b[1].z = m[mesh_b].v[tb->vertices[(edge_b + 1) % 3]].z;

					if (fabs (vertex_b[0].x - vertex_a[1].x) < 0.01 &&
						fabs (vertex_b[0].y - vertex_a[1].y) < 0.01 &&
						fabs (vertex_b[0].z - vertex_a[1].z) < 0.01 &&

						fabs (vertex_b[1].x - vertex_a[0].x) < 0.01 &&
						fabs (vertex_b[1].y - vertex_a[0].y) < 0.01 &&
						fabs (vertex_b[1].z - vertex_a[0].z) < 0.01 &&

						(mesh_a != mesh_b || triangle_a != triangle_b))
					{
						get_normal (m[mesh_b].t + triangle_b, m[mesh_b].v, &normal_b);

						x += normal_b.x;
						y += normal_b.y;
						z += normal_b.z;

						if ((length = sqrt (x*x + y*y + z*z)) > 0)
						{
							x /= length;
							y /= length;
							z /= length;
						}
					}
				} // for (edge_b ...

		// can the vertex be snapped to an orthogonal angle?

		ortho.x = 0;
		ortho.y = 0;
		ortho.z = 0;

		length = sqrt (0.5);

		if      (x >  length) ortho.x =  1.0;
		else if (x < -length) ortho.x = -1.0;
		else if (y >  length) ortho.y =  1.0;
		else if (y < -length) ortho.y = -1.0;
		else if (z >  length) ortho.z =  1.0;
		else if (z < -length) ortho.z = -1.0;

		length = sqrt (
			(normal_a.x - ortho.x) * (normal_a.x - ortho.x) +
			(normal_a.y - ortho.y) * (normal_a.y - ortho.y) +
			(normal_a.z - ortho.z) * (normal_a.z - ortho.z));

		angle_a = 2.0 * asin (0.5 * length);

		length = sqrt (
			(normal_b.x - ortho.x) * (normal_b.x - ortho.x) +
			(normal_b.y - ortho.y) * (normal_b.y - ortho.y) +
			(normal_b.z - ortho.z) * (normal_b.z - ortho.z));

		angle_b = 2.0 * asin (0.5 * length);

		if (angle_a < tolerance && angle_b < tolerance)
		{
			x = ortho.x;
			y = ortho.y;
			z = ortho.z;
		}

		// write edge plane

		fprintf (o, "  ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) black 0 0 0 1 1\n",
			vertex_a[0].x, vertex_a[0].y, vertex_a[0].z,
			vertex_a[1].x, vertex_a[1].y, vertex_a[1].z,

			vertex_a[1].x - x * thickness,
			vertex_a[1].y - y * thickness,
			vertex_a[1].z - z * thickness);

	} // for (edge_a ...

	ortho.x = 0;
	ortho.y = 0;
	ortho.z = 0;

	length = sqrt (0.5);

	if      (normal_a.x >  length) ortho.x =  1.0;
	else if (normal_a.x < -length) ortho.x = -1.0;
	else if (normal_a.y >  length) ortho.y =  1.0;
	else if (normal_a.y < -length) ortho.y = -1.0;
	else if (normal_a.z >  length) ortho.z =  1.0;
	else if (normal_a.z < -length) ortho.z = -1.0;

	length = sqrt (
		(normal_a.x - ortho.x) * (normal_a.x - ortho.x) +
		(normal_a.y - ortho.y) * (normal_a.y - ortho.y) +
		(normal_a.z - ortho.z) * (normal_a.z - ortho.z));

	angle_a = 2.0 * asin (0.5 * length);

	if (angle_a < tolerance && angle_b < tolerance)
	{
		normal_a.x = ortho.x;
		normal_a.y = ortho.y;
		normal_a.z = ortho.z;
	}

	// write back plane

	fprintf (o, "  ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) ( %.8f %.8f %.8f ) black 0 0 0 1 1\n",
		m[mesh_a].v[ta->vertices[0]].x - normal_a.x * thickness,
		m[mesh_a].v[ta->vertices[0]].y - normal_a.y * thickness,
		m[mesh_a].v[ta->vertices[0]].z - normal_a.z * thickness,

		m[mesh_a].v[ta->vertices[1]].x - normal_a.x * thickness,
		m[mesh_a].v[ta->vertices[1]].y - normal_a.y * thickness,
		m[mesh_a].v[ta->vertices[1]].z - normal_a.z * thickness,

		m[mesh_a].v[ta->vertices[2]].x - normal_a.x * thickness,
		m[mesh_a].v[ta->vertices[2]].y - normal_a.y * thickness,
		m[mesh_a].v[ta->vertices[2]].z - normal_a.z * thickness);

	fprintf (o, " }\n");
	return 0;
}

int convert (char * in, char * out, float thickness, double tolerance)
{
	FILE * i, * o;
	char str [256], tok [256];
	int j = 0, k = 0, meshes = 0, count = 0, material_count, mesh_a, triangle_a;
	mesh_t * m = NULL;
	material_t * materials = NULL;

	printf ("Input  File Name: %s\n", in);
	printf ("Output File Name: %s\n", out);

	i = fopen (in,  "ra");

	if (fgets (str, 255, i) == NULL)
	{
		printf ("ERROR: could not read first line of %s\n", in);
		fclose (i);
		return 1;
	}
	if (strcmp (str, "// MilkShape 3D ASCII\n") != 0)
	{
		printf ("ERROR: first line of input file should be:\n");
		printf ("// MilkShape 3D ASCII\n");
		printf ("Instead it was:\n%s\n", str);
		fclose (i);
		return 1;
	}

	// read lines up to Meshes section

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
				return 1;
			}
			break;
		}
	}

	if (meshes == 0)
	{
		printf ("ERROR: no meshes found in `%s'\n", in);
		fclose (i);
		return 1;
	}

	// read meshes

	while (fgets (str, 255, i) != NULL)
	{
		if (str[0] != '\"') break;

		// read mesh name

		sscanf (str, "\"%[^\"]\" %i %i", tok, &(m[count].flags), &(m[count].material));
		m[count].name = malloc (sizeof (char) * (strlen (tok) + 1));
		if (m[count].name == NULL)
		{
			printf ("ERROR: not enough memory for mesh name '%s_outline'\n", tok);
			fclose (i);
			clean_up (m, count + 1);
			return 1;
		}
		sprintf (m[count].name, "%s", tok);

		// read vertices

		if (fgets (str, 255, i) == NULL) break;
		sscanf (str, "%i", &(m[count].vertices));
		m[count].v = malloc (sizeof (vertex_t) * m[count].vertices);
		if (m[count].v == NULL)
		{
			printf ("ERROR: not enough memory for %i vertices\n", m[count].vertices);
			fclose (i);
			clean_up (m, count + 1);
			return 1;
		}
		for (j = 0; j < m[count].vertices; j++)
		{
			if (fgets (str, 255, i) == NULL)
			{
				printf ("ERROR: could not read %i vertices\n", m[count].vertices);
				fclose (i);
				clean_up (m, count + 1);
				return 1;
			}
			sscanf (str, "%i %f %f %f %f %f %i",
				&(m[count].v[j].flags),
				&(m[count].v[j].x), &(m[count].v[j].y), &(m[count].v[j].z),
				&(m[count].v[j].u), &(m[count].v[j].v),
				&(m[count].v[j].bone));
		}

		// don't use normals

		if (fgets (str, 255, i) == NULL) break;
		sscanf (str, "%i", &(m[count].normals));
		for (j = 0; j < m[count].normals; j++)
		{
			if (fgets (str, 255, i) == NULL)
			{
				printf ("ERROR: could not read %i normals\n", m[count].normals);
				fclose (i);
				clean_up (m, count + 1);
				return 1;
			}
		}

		// read triangles

		if (fgets (str, 255, i) == NULL) break;
		sscanf (str, "%i", &(m[count].triangles));
		m[count].t = malloc (sizeof (triangle_t) * m[count].triangles);
		if (m[count].t == NULL)
		{
			printf ("ERROR: not enough memory for %i triangles\n", m[count].triangles);
			fclose (i);
			clean_up (m, count + 1);
			return 1;
		}
		for (j = 0; j < m[count].triangles; j++)
		{
			if (fgets (str, 255, i) == NULL)
			{
				printf ("ERROR: could not read %i triangles\n", m[count].triangles);
				fclose (i);
				clean_up (m, count + 1);
				return 1;
			}
			sscanf (str, "%i %i %i %i %i %i %i %i",
				&(m[count].t[j].flags),

				&(m[count].t[j].vertices[0]),
				&(m[count].t[j].vertices[1]),
				&(m[count].t[j].vertices[2]),

				&(m[count].t[j].normals[0]),
				&(m[count].t[j].normals[1]),
				&(m[count].t[j].normals[2]),

				&(m[count].t[j].group));
		}
		count++;
    }

	// Copy lines after Meshes section

	while (fgets (str, 255, i) != NULL)
	{
		sscanf (str, "%s %i", tok, &material_count);
		if (strcmp (tok, "Materials:") == 0)
		{
			// read materials

			materials = malloc (material_count * sizeof (material_t));
			if (materials == NULL)
			{
				printf ("ERROR: could not allocate %i materials\n", material_count);
				fclose (i);
				clean_up (m, count + 1);
				return 1;
			}
			for (j = 0; j < material_count; j++)
			{
				// read material name

				if (fgets (str, 255, i) == NULL)
				{
					printf ("ERROR: could not read %i materials\n", material_count);
					fclose (i);
					clean_up (m, count + 1);
					return 1;
				}
				sscanf (str, "\"%[^\"]\"", materials[j].name);

				// read the other eight material lines

				for (k = 0; k < 8; k++)
				{
					if (fgets (str, 255, i) == NULL)
					{
						printf ("ERROR: material '%s' is incomplete\n", materials[j].name);
						if (j == material_count - 1) break;
						fclose (i);
						clean_up (m, count + 1);
						return 1;
					}
				}
			}
			break;
		}
	}

	fclose (i);

	if (count > 0)
	{
		o = fopen (out, "wa");

		fprintf (o, "{\n");
		fprintf (o, " \"classname\" \"worldspawn\"\n");
		fprintf (o, " \"message\" \"No Name\"\n");
		fprintf (o, " \"worldtype\" \"0\"\n");

		for (mesh_a = 0; mesh_a < count; mesh_a++)
			for (triangle_a = 0; triangle_a < m[mesh_a].triangles; triangle_a++)
				write_brush (m, count, o, thickness, mesh_a, triangle_a, materials, tolerance);

		fprintf (o, "}\n");
		fprintf (o, "{\n");
		fprintf (o, " \"classname\" \"info_player_start\"\n");
		fprintf (o, " \"origin\" \"0 0 0\"\n");
		fprintf (o, " \"angle\" \"360\"\n");
		fprintf (o, "}\n");

		fclose (o);
	}

	clean_up (m, count);
	return 0;
}

int help ()
{
	printf ("USAGE: mesh2map [options] <file> [more options and/or files]\n");
	printf ("OPTIONS:\n");
	printf ("        -o [string] : output filename (NOTE: affects only the next input file)\n");
	printf ("        -t [float]  : thickness (default = 16)\n");
	printf ("        -a [float]  : axis alignment tolerance in degrees (default = 45)\n");

	return 1;
}

int main (int argc, char ** argv)
{
	int i, c;

	char   outfile [100];
	float  thickness = 16;
	double tolerance = 45;

	printf ("mesh2map - triangle mesh to map convertor\n");
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
							sprintf (outfile + c, ".map");
							break;
				case 't' :	thickness = atof (argv[i + 1]); break;
				case 'a' :  tolerance = atof (argv[i + 1]); break;
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
		convert (argv[i], outfile, thickness, tolerance);
	}
	return 0;
}
