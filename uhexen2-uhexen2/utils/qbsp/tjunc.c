/* tjunc.c
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


typedef struct wvert_s
{
	double	t;
	struct wvert_s *prev, *next;
} wvert_t;

typedef struct wedge_s
{
	struct wedge_s *next;
	vec3_t	dir;
	vec3_t	origin;
	wvert_t	head;
} wedge_t;

static int		numwedges, numwverts;
static int		tjuncs;
static int		tjuncfaces;

#define	MAXWVERTS	0x20000
#define	MAXWEDGES	0x10000

static wvert_t	wverts[MAXWVERTS];
static wedge_t	wedges[MAXWEDGES];

#if 0	/* no users */
void PrintFace (face_t *f)
{
	int		i;

	for (i = 0 ; i < f->numpoints ; i++)
		printf ("(%5.2f, %5.2f, %5.2f)\n", f->pts[i][0], f->pts[i][1], f->pts[i][2]);
}
#endif

//============================================================================

#define	NUM_HASH	1024

static	wedge_t	*wedge_hash[NUM_HASH];
static	vec3_t	hash_min, hash_scale;

static void InitHash (vec3_t mins, vec3_t maxs)
{
	vec3_t	size;
	double	volume;
	double	scale;
	int		newsize[2];

	VectorCopy (mins, hash_min);
	VectorSubtract (maxs, mins, size);
	memset (wedge_hash, 0, sizeof(wedge_hash));

	volume = size[0]*size[1];

	scale = sqrt(volume / NUM_HASH);

	newsize[0] = size[0] / scale;
	newsize[1] = size[1] / scale;

	hash_scale[0] = newsize[0] / size[0];
	hash_scale[1] = newsize[1] / size[1];
	hash_scale[2] = newsize[1];
}

static unsigned int HashVec (vec3_t vec)
{
	unsigned int	h;

	h = hash_scale[0] * (vec[0] - hash_min[0]) * hash_scale[2]
				+ hash_scale[1] * (vec[1] - hash_min[1]);
	if ( h >= NUM_HASH)
		return NUM_HASH - 1;
	return h;
}

//============================================================================

static void CanonicalVector (vec3_t vec)
{
	VectorNormalize (vec);
	if (vec[0] > EQUAL_EPSILON)
		return;
	else if (vec[0] < -EQUAL_EPSILON)
	{
		VectorNegate (vec, vec);
		return;
	}
	else
		vec[0] = 0;

	if (vec[1] > EQUAL_EPSILON)
		return;
	else if (vec[1] < -EQUAL_EPSILON)
	{
		VectorNegate (vec, vec);
		return;
	}
	else
		vec[1] = 0;

	if (vec[2] > EQUAL_EPSILON)
		return;
	else if (vec[2] < -EQUAL_EPSILON)
	{
		VectorNegate (vec, vec);
		return;
	}
	else
		vec[2] = 0;
	COM_Error ("%s: degenerate", __thisfunc__);
}

static wedge_t *FindEdge (vec3_t p1, vec3_t p2, double *t1, double *t2)
{
	vec3_t	origin;
	vec3_t	dir;
	wedge_t	*w;
	double	temp;
	int		h;

	VectorSubtract (p2, p1, dir);
	CanonicalVector (dir);

	*t1 = DotProduct (p1, dir);
	*t2 = DotProduct (p2, dir);

	VectorMA (p1, -*t1, dir, origin);

	if (*t1 > *t2)
	{
		temp = *t1;
		*t1 = *t2;
		*t2 = temp;
	}

	h = HashVec (origin);

	for (w = wedge_hash[h] ; w ; w = w->next)
	{
		temp = w->origin[0] - origin[0];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;
		temp = w->origin[1] - origin[1];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;
		temp = w->origin[2] - origin[2];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;

		temp = w->dir[0] - dir[0];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;
		temp = w->dir[1] - dir[1];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;
		temp = w->dir[2] - dir[2];
		if (temp < -EQUAL_EPSILON || temp > EQUAL_EPSILON)
			continue;

		return w;
	}

	if (numwedges == MAXWEDGES)
		COM_Error ("%s: numwedges == MAXWEDGES", __thisfunc__);
	w = &wedges[numwedges];
	numwedges++;

	w->next = wedge_hash[h];
	wedge_hash[h] = w;

	VectorCopy (origin, w->origin);
	VectorCopy (dir, w->dir);
	w->head.next = w->head.prev = &w->head;
	w->head.t = 99999;
	return w;
}


/*
===============
AddVert

===============
*/
#define	T_EPSILON	0.01

static void AddVert (wedge_t *w, double t)
{
	wvert_t	*v, *newv;

	v = w->head.next;
	do
	{
		if (fabs(v->t - t) < T_EPSILON)
			return;
		if (v->t > t)
			break;
		v = v->next;
	} while (1);

// insert a new wvert before v
	if (numwverts == MAXWVERTS)
		COM_Error ("%s: numwverts == MAXWVERTS", __thisfunc__);

	newv = &wverts[numwverts];
	numwverts++;

	newv->t = t;
	newv->next = v;
	newv->prev = v->prev;
	v->prev->next = newv;
	v->prev = newv;
}


/*
===============
AddEdge

===============
*/
static void AddEdge (vec3_t p1, vec3_t p2)
{
	wedge_t	*w;
	double	t1, t2;

	w = FindEdge(p1, p2, &t1, &t2);
	AddVert (w, t1);
	AddVert (w, t2);
}

/*
===============
AddFaceEdges

===============
*/
static void AddFaceEdges (face_t *f)
{
	int		i, j;

	for (i = 0 ; i < f->numpoints ; i++)
	{
		j = (i + 1) % f->numpoints;
		AddEdge (f->pts[i], f->pts[j]);
	}
}


//============================================================================

// a specially allocated face that can hold hundreds of edges if needed
static byte	superfacebuf[8192];
static face_t	*superface = (face_t *)superfacebuf;
static face_t	*newlist;

static void FixFaceEdges (face_t *f);

static void SplitFaceForTjunc (face_t *f, face_t *original)
{
	int			i;
	face_t		*newf, *chain;
	vec3_t		dir, test;
	double		v;
	int			firstcorner, lastcorner;

	chain = NULL;
	do
	{
		if (f->numpoints <= MAXPOINTS)
		{	// the face is now small enough without more cutting
			// so copy it back to the original
			*original = *f;
			original->original = chain;
			original->next = newlist;
			newlist = original;
			return;
		}

		tjuncfaces++;

restart:
	// find the last corner
		VectorSubtract (f->pts[f->numpoints-1], f->pts[0], dir);
		VectorNormalize (dir);
		for (lastcorner = f->numpoints-1 ; lastcorner > 0 ; lastcorner--)
		{
			VectorSubtract (f->pts[lastcorner-1], f->pts[lastcorner], test);
			VectorNormalize (test);
			v = DotProduct (test, dir);
			if (v < 0.9999 || v > 1.00001)
			{
				break;
			}
		}

	// find the first corner
		VectorSubtract (f->pts[1], f->pts[0], dir);
		VectorNormalize (dir);
		for (firstcorner = 1 ; firstcorner < f->numpoints-1 ; firstcorner++)
		{
			VectorSubtract (f->pts[firstcorner+1], f->pts[firstcorner], test);
			VectorNormalize (test);
			v = DotProduct (test, dir);
			if (v < 0.9999 || v > 1.00001)
			{
				break;
			}
		}

		if (firstcorner+2 >= MAXPOINTS)
		{
		// rotate the point winding
			VectorCopy (f->pts[0], test);
			for (i = 1 ; i < f->numpoints ; i++)
			{
				VectorCopy (f->pts[i], f->pts[i-1]);
			}
			VectorCopy (test, f->pts[f->numpoints-1]);
			goto restart;
		}

	// cut off as big a piece as possible, less than MAXPOINTS, and not
	// past lastcorner

		newf = NewFaceFromFace (f);
		if (f->original)
			COM_Error ("%s: f->original", __thisfunc__);

		newf->original = chain;
		chain = newf;
		newf->next = newlist;
		newlist = newf;
		if (f->numpoints - firstcorner <= MAXPOINTS)
			newf->numpoints = firstcorner+2;
		else if (lastcorner+2 < MAXPOINTS && f->numpoints - lastcorner <= MAXPOINTS)
			newf->numpoints = lastcorner+2;
		else
			newf->numpoints = MAXPOINTS;

		for (i = 0 ; i < newf->numpoints ; i++)
		{
			VectorCopy (f->pts[i], newf->pts[i]);
		}

		for (i = newf->numpoints-1 ; i < f->numpoints ; i++)
		{
			VectorCopy (f->pts[i], f->pts[i-(newf->numpoints-2)]);
		}
		f->numpoints -= (newf->numpoints-2);
	} while (1);
}


/*
===============
FixFaceEdges

===============
*/
static void FixFaceEdges (face_t *f)
{
	int		i, j, k;
	wedge_t	*w;
	wvert_t	*v;
	double	t1, t2;

	*superface = *f;

restart:
	for (i = 0 ; i < superface->numpoints ; i++)
	{
		j = (i + 1) % superface->numpoints;

		w = FindEdge (superface->pts[i], superface->pts[j], &t1, &t2);

		for (v = w->head.next ; v->t < t1 + T_EPSILON ; v = v->next)
		{
		}

		if (v->t < t2-T_EPSILON)
		{
			tjuncs++;
		// insert a new vertex here
			for (k = superface->numpoints ; k > j ; k--)
			{
				VectorCopy (superface->pts[k-1], superface->pts[k]);
			}
			VectorMA (w->origin, v->t, w->dir, superface->pts[j]);
			superface->numpoints++;
			goto restart;
		}
	}

	if (superface->numpoints <= MAXPOINTS)
	{
		*f = *superface;
		f->next = newlist;
		newlist = f;
		return;
	}

// the face needs to be split into multiple faces because of too many edges

	SplitFaceForTjunc (superface, f);
}


//============================================================================

static void tjunc_find_r (node_t *node)
{
	face_t	*f;

	if (node->planenum == PLANENUM_LEAF)
		return;

	for (f = node->faces ; f ; f = f->next)
		AddFaceEdges (f);

	tjunc_find_r (node->children[0]);
	tjunc_find_r (node->children[1]);
}

static void tjunc_fix_r (node_t *node)
{
	face_t	*f, *next;

	if (node->planenum == PLANENUM_LEAF)
		return;

	newlist = NULL;

	for (f = node->faces ; f ; f = next)
	{
		next = f->next;
		FixFaceEdges (f);
	}

	node->faces = newlist;

	tjunc_fix_r (node->children[0]);
	tjunc_fix_r (node->children[1]);
}

/*
===========
tjunc

===========
*/
void tjunc (node_t *headnode)
{
	vec3_t	maxs, mins;
	int		i;

	qprintf ("---- tjunc ----\n");

	if (notjunc)
		return;

//
// identify all points on common edges
//

// origin points won't always be inside the map, so extend the hash area
	for (i = 0 ; i < 3 ; i++)
	{
		if ( fabs(brushset->maxs[i]) > fabs(brushset->mins[i]) )
			maxs[i] = fabs(brushset->maxs[i]);
		else
			maxs[i] = fabs(brushset->mins[i]);
	}
	VectorNegate (maxs, mins);

	InitHash (mins, maxs);

	numwedges = numwverts = 0;

	tjunc_find_r (headnode);

	qprintf ("%i world edges  %i edge points\n", numwedges, numwverts);

//
// add extra vertexes on edges where needed
//
	tjuncs = tjuncfaces = 0;

	tjunc_fix_r (headnode);

	qprintf ("%i edges added by tjunctions\n", tjuncs);
	qprintf ("%i faces added by tjunctions\n", tjuncfaces);
}

