/* outside.c
 * Copyright (C) 1996-1997  Id Software, Inc.
 * Copyright (C) 1997-1998  Raven Software Corp.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "q_stdinc.h"
#include "compiler.h"
#include "arch_def.h"
#include "cmdlib.h"
#include "mathlib.h"
#include "bspfile.h"
#include "bsp5.h"


static int		outleafs;

/*
===========
PointInLeaf
===========
*/
static node_t *PointInLeaf (node_t *node, vec3_t point)
{
	double	d;

	if (node->contents)
		return node;

	d = DotProduct (planes[node->planenum].normal, point) - planes[node->planenum]. dist;

	if (d > 0)
		return PointInLeaf (node->children[0], point);

	return PointInLeaf (node->children[1], point);
}

/*
===========
PlaceOccupant
===========
*/
static qboolean PlaceOccupant (int num, vec3_t point, node_t *headnode)
{
	node_t	*n;

	n = PointInLeaf (headnode, point);
	if (n->contents == CONTENTS_SOLID)
		return false;
	n->occupied = num;
	return true;
}


/*
==============
MarkLeakTrail
==============
*/
static portal_t	*prevleaknode;
static FILE	*leakfile;
static void MarkLeakTrail (portal_t *n2)
{
	int		i, j;
	vec3_t	p1, p2, dir;
	float	len;
	portal_t	*n1;

	if (hullnum)
		return;

	n1 = prevleaknode;
	prevleaknode = n2;

	if (!n1)
		return;

	VectorCopy (n2->winding->points[0], p1);
	for (i = 1 ; i < n2->winding->numpoints ; i++)
	{
		for (j = 0 ; j < 3 ; j++)
			p1[j] = (p1[j] + n2->winding->points[i][j]) / 2;
	}

	VectorCopy (n1->winding->points[0], p2);
	for (i = 1 ; i < n1->winding->numpoints ; i++)
	{
		for (j = 0 ; j < 3 ; j++)
			p2[j] = (p2[j] + n1->winding->points[i][j]) / 2;
	}

	VectorSubtract (p2, p1, dir);
	len = VectorLength (dir);
	VectorNormalize (dir);

	while (len > 2)
	{
		fprintf (leakfile,"%f %f %f\n", p1[0], p1[1], p1[2]);
		for (i = 0 ; i < 3 ; i++)
			p1[i] += dir[i]*2;
		len -= 2;
	}
}

/*
==================
RecursiveFillOutside

If fill is false, just check, don't fill
Returns true if an occupied leaf is reached
==================
*/
static int		hit_occupied;
static int		backdraw;
static qboolean RecursiveFillOutside (node_t *l, qboolean fill)
{
	portal_t	*p;
	int			s;
	int			original_contents;

	if (l->contents == CONTENTS_SOLID)
		return false;

	if (l->valid == valid)
		return false;

	l->valid = valid;

// Some people have been intentionaly putting lights inside sky volumes,
// so I have to fail the check now that I am testing
	if (l->occupied && l->contents != CONTENTS_SKY)
	{
		hit_occupied = l->occupied;
		//drawflag = true;
		backdraw = 4000;
		Draw_ClearWindow ();
		DrawLeaf (l, 2);
		return true;
	}

// fill it and it's neighbors
	original_contents = l->contents;
	if (fill)
		l->contents = CONTENTS_SOLID;
	outleafs++;

	for (p = l->portals ; p ; )
	{
		s = (p->nodes[0] == l);

	// flood fill into skys, but not back out
		if (original_contents != CONTENTS_SKY || p->nodes[s]->contents == CONTENTS_SKY )
		{
			if (RecursiveFillOutside (p->nodes[s], fill) )
			{	// leaked, so stop filling
				if (backdraw-- > 0)
				{
					MarkLeakTrail (p);
					DrawLeaf (l, 2);
				}
				return true;
			}
		}
		p = p->next[!s];
	}

	return false;
}

/*
==================
ClearOutFaces

==================
*/
static void ClearOutFaces (node_t *node)
{
	face_t	**fp;

	if (node->planenum != -1)
	{
		ClearOutFaces (node->children[0]);
		ClearOutFaces (node->children[1]);
		return;
	}
	if (node->contents != CONTENTS_SOLID)
		return;

	for (fp = node->markfaces ; *fp ; fp++)
	{
	// mark all the original faces that are removed
		(*fp)->numpoints = 0;
	}
	node->faces = NULL;
}


//=============================================================================

/*
===========
FillOutside

===========
*/
qboolean FillOutside (node_t *node)
{
	int			s;
	double		*v;
	int			i;
	qboolean	inside;

	qprintf ("----- FillOutside ----\n");

	if (nofill)
	{
		printf ("skipped\n");
		return false;
	}

	inside = false;
	for (i = 1 ; i < num_entities ; i++)
	{
		if (!VectorCompare(entities[i].origin, vec3_origin))
		{
			if (PlaceOccupant (i, entities[i].origin, node))
				inside = true;
		}
	}

	if (!inside)
	{
		printf ("Hullnum %i: No entities in empty space -- no filling performed\n", hullnum);
		return false;
	}

	s = !(outside_node.portals->nodes[1] == &outside_node);

// first check to see if an occupied leaf is hit
	outleafs = 0;
	valid++;

	prevleaknode = NULL;

	if (!hullnum)
	{
		leakfile = fopen (pointfilename, "w");
		if (!leakfile)
			COM_Error ("Couldn't open %s\n", pointfilename);
	}

	if (RecursiveFillOutside (outside_node.portals->nodes[s], false))
	{
		v = entities[hit_occupied].origin;
		qprintf ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
		qprintf ("reached occupant at: (%4.0f,%4.0f,%4.0f)\n", v[0], v[1], v[2]);
		qprintf ("no filling performed\n");
		if (!hullnum)
			fclose (leakfile);
		qprintf ("leak file written to %s\n", pointfilename);
		qprintf ("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
		return false;
	}
	if (!hullnum)
		fclose (leakfile);

// now go back and fill things in
	valid++;
	RecursiveFillOutside (outside_node.portals->nodes[s], true);

// remove faces from filled in leafs
	ClearOutFaces (node);

	qprintf ("%4i outleafs\n", outleafs);
	return true;
}

