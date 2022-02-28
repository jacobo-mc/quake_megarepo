// bsp5.c

#include "havocmap.h"

//
// command line flags
//
qboolean nofill;
qboolean onlyents;
qboolean	verbose = true;
qboolean	allverbose;
qboolean transwater = true;

int		subdivide_size = 240;

brushset_t	*brushset;

int		valid;

char	bspfilename[1024];
char	pointfilename[1024];
char	portfilename[1024];

char	*argv0;					// changed after fork();

qboolean	worldmodel;

int		hullnum;

qboolean		fastvis;
qboolean		verbose;
int			testlevel = 4;

//===========================================================================

void qprintf (char *fmt, ...)
{
	va_list argptr;

	if (!verbose)
		return;

	va_start (argptr, fmt);
	vprintf (fmt,argptr);
	va_end (argptr);
}

/*
=================
BaseWindingForPlane
=================
*/
winding_t *BaseWindingForPlane (plane_t *p)
{
	int		i, x;
	vec_t	max, v;
	vec3_t	org, vright, vup;
	winding_t	*w;

	// find the major axis

	max = -BOGUS_RANGE;
	x = -1;
	for (i=0 ; i<3; i++)
	{
		v = fabs(p->normal[i]);
		if (v > max)
		{
			x = i;
			max = v;
		}
	}
	if (x==-1)
	Error ("BaseWindingForPlane: no axis found");

	VectorCopy (vec3_origin, vup);	
	switch (x)
	{
	case 0:
	case 1:
		vup[2] = 1;
		break;		
	case 2:
		vup[0] = 1;
		break;		
	}

	v = DotProduct (vup, p->normal);
	VectorMA (vup, -v, p->normal, vup);
	VectorNormalize (vup);

	VectorScale (p->normal, p->dist, org);

	CrossProduct (vup, p->normal, vright);

	VectorScale (vup, 8192, vup);
	VectorScale (vright, 8192, vright);

	// project a really big	axis aligned box onto the plane
	w = qbsp_NewWinding (4);

	VectorSubtract (org, vright, w->points[0]);
	VectorAdd (w->points[0], vup, w->points[0]);

	VectorAdd (org, vright, w->points[1]);
	VectorAdd (w->points[1], vup, w->points[1]);

	VectorAdd (org, vright, w->points[2]);
	VectorSubtract (w->points[2], vup, w->points[2]);

	VectorSubtract (org, vright, w->points[3]);
	VectorSubtract (w->points[3], vup, w->points[3]);

	w->numpoints = 4;

	return w;	
}



/*
==================
CheckWinding

Check for possible errors
==================
*/
void CheckWinding (winding_t *w)
{
}


/*
==================
ClipWinding

Clips the winding to the plane, returning the new winding on the positive side
Frees the input winding.
If keepon is true, an exactly on-plane winding will be saved, otherwise
it will be clipped away.
==================
*/
winding_t *qbsp_ClipWinding (winding_t *in, plane_t *split, qboolean keepon)
{
	vec_t	dists[MAX_POINTS_ON_WINDING];
	int		sides[MAX_POINTS_ON_WINDING];
	int		counts[3];
	vec_t	dot;
	int		i, j;
	vec_t	*p1, *p2;
	vec3_t	mid;
	winding_t	*neww;
	int		maxpts;

	counts[0] = counts[1] = counts[2] = 0;

// determine sides for each point
	for (i=0 ; i<in->numpoints ; i++)
	{
		dists[i] = dot = DotProduct (in->points[i], split->normal) - split->dist;
		if (dot > ON_EPSILON) sides[i] = SIDE_FRONT;
		else if (dot < -ON_EPSILON) sides[i] = SIDE_BACK;
		else sides[i] = SIDE_ON;
		counts[sides[i]]++;
	}
	sides[i] = sides[0];
	dists[i] = dists[0];

	if (keepon && !counts[0] && !counts[1])
		return in;

	if (!counts[0])
	{
		qbsp_FreeWinding (in);
		return NULL;
	}
	if (!counts[1])
		return in;

	maxpts = in->numpoints+4;	// can't use counts[0]+2 because of fp grouping errors
	neww = qbsp_NewWinding (maxpts);

	for (i=0 ; i<in->numpoints ; i++)
	{
		p1 = in->points[i];

		if (sides[i] == SIDE_ON)
		{
			VectorCopy (p1, neww->points[neww->numpoints]);
			neww->numpoints++;
			continue;
		}

		if (sides[i] == SIDE_FRONT)
		{
			VectorCopy (p1, neww->points[neww->numpoints]);
			neww->numpoints++;
		}

		if (sides[i+1] == SIDE_ON || sides[i+1] == sides[i])
			continue;

	// generate a split point
		p2 = in->points[(i+1)%in->numpoints];

		dot = dists[i] / (dists[i]-dists[i+1]);
		for (j=0 ; j<3 ; j++)
		{	// avoid round off error when possible
			if (split->normal[j] == 1)
				mid[j] = split->dist;
			else if (split->normal[j] == -1)
				mid[j] = -split->dist;
			else
				mid[j] = p1[j] + dot*(p2[j]-p1[j]);
		}

		VectorCopy (mid, neww->points[neww->numpoints]);
		neww->numpoints++;
	}

	if (neww->numpoints > maxpts)
		Error ("ClipWinding: points exceeded estimate");

	// free the original winding
	qbsp_FreeWinding (in);

	return neww;
}


/*
==================
DivideWinding

Divides a winding by a plane, producing one or two windings.  The
original winding is not damaged or freed.  If only on one side, the
returned winding will be the input winding.  If on both sides, two
new windings will be created.
==================
*/
void	DivideWinding (winding_t *in, plane_t *split, winding_t **front, winding_t **back)
{
	vec_t		dists[MAX_POINTS_ON_WINDING];
	int			sides[MAX_POINTS_ON_WINDING];
	int			counts[3];
	vec_t		dot;
	int			i, j;
	vec_t		*p1, *p2;
	vec3_t		mid;
	winding_t	*f, *b;
	int			maxpts;

	counts[0] = counts[1] = counts[2] = 0;

	// determine sides for each point
	for (i=0 ; i<in->numpoints ; i++)
	{
		dot = DotProduct (in->points[i], split->normal);
		dot -= split->dist;
		dists[i] = dot;
		if (dot > ON_EPSILON)
			sides[i] = SIDE_FRONT;
		else if (dot < -ON_EPSILON)
			sides[i] = SIDE_BACK;
		else
			sides[i] = SIDE_ON;
		counts[sides[i]]++;
	}
	sides[i] = sides[0];
	dists[i] = dists[0];

	*front = *back = NULL;

	if (!counts[0])
	{
		*back = in;
		return;
	}
	if (!counts[1])
	{
		*front = in;
		return;
	}

	maxpts = in->numpoints+4;	// can't use counts[0]+2 because
	// of fp grouping errors

	*front = f = qbsp_NewWinding (maxpts);
	*back = b = qbsp_NewWinding (maxpts);

	for (i=0 ; i<in->numpoints ; i++)
	{
		p1 = in->points[i];

		if (sides[i] == SIDE_ON)
		{
			VectorCopy (p1, f->points[f->numpoints]);
			f->numpoints++;
			VectorCopy (p1, b->points[b->numpoints]);
			b->numpoints++;
			continue;
		}

		if (sides[i] == SIDE_FRONT)
		{
			VectorCopy (p1, f->points[f->numpoints]);
			f->numpoints++;
		}
		if (sides[i] == SIDE_BACK)
		{
			VectorCopy (p1, b->points[b->numpoints]);
			b->numpoints++;
		}

		if (sides[i+1] == SIDE_ON || sides[i+1] == sides[i])
			continue;

		// generate a split point
		p2 = in->points[(i+1)%in->numpoints];

		dot = dists[i] / (dists[i]-dists[i+1]);
		for (j=0 ; j<3 ; j++)
		{	// avoid round off error when possible
			if (split->normal[j] == 1)
				mid[j] = split->dist;
			else if (split->normal[j] == -1)
				mid[j] = -split->dist;
			else
				mid[j] = p1[j] + dot*(p2[j]-p1[j]);
		}

		VectorCopy (mid, f->points[f->numpoints]);
		f->numpoints++;
		VectorCopy (mid, b->points[b->numpoints]);
		b->numpoints++;
	}

	if (f->numpoints > maxpts || b->numpoints > maxpts)
		Error ("ClipWinding: points exceeded estimate");
}


//===========================================================================

int c_activefaces, c_peakfaces;
int c_activesurfaces, c_peaksurfaces;
int c_activewindings, c_peakwindings;
int c_activeportals, c_peakportals;

void PrintMemory (void)
{
	printf ("faces   : %6i (%6i)\n", c_activefaces, c_peakfaces);
	printf ("surfaces: %6i (%6i)\n", c_activesurfaces, c_peaksurfaces);
	printf ("windings: %6i (%6i)\n", c_activewindings, c_peakwindings);
	printf ("portals : %6i (%6i)\n", c_activeportals, c_peakportals);
}

/*
==================
NewWinding
==================
*/
winding_t *qbsp_NewWinding (int points)
{
	winding_t	*w;
	int			size;

	if (points > MAX_POINTS_ON_WINDING)
		Error ("NewWinding: %i points", points);

	c_activewindings++;
	if (c_activewindings > c_peakwindings)
		c_peakwindings = c_activewindings;

	size = (int)((winding_t *)0)->points[points];
	w = malloc (size);
	memset (w, 0, size);

	return w;
}

void qbsp_FreeWinding (winding_t *w)
{
	c_activewindings--;
	free (w);
}

/*
===========
AllocFace
===========
*/
face_t *AllocFace (void)
{
	face_t	*f;

	c_activefaces++;
	if (c_activefaces > c_peakfaces)
		c_peakfaces = c_activefaces;
		
	f = malloc (sizeof(face_t));
	memset (f, 0, sizeof(face_t));
	f->planenum = -1;

	return f;
}


void FreeFace (face_t *f)
{
	c_activefaces--;
//	memset (f,0xff,sizeof(face_t));
	free (f);
}


/*
===========
AllocSurface
===========
*/
surface_t *AllocSurface (void)
{
	surface_t *s;

	s = calloc (sizeof(surface_t), 1);

	c_activesurfaces++;
	if (c_activesurfaces > c_peaksurfaces)
	c_peaksurfaces = c_activesurfaces;
		
	return s;
}

void FreeSurface (surface_t *s)
{
	c_activesurfaces--;
	free (s);
}

/*
===========
AllocPortal
===========
*/
portal_t *AllocPortal (void)
{
	portal_t *p;

	c_activeportals++;
	if (c_activeportals > c_peakportals)
		c_peakportals = c_activeportals;

	p = calloc (sizeof(portal_t), 1);

	return p;
}

void FreePortal (portal_t *p)
{
	c_activeportals--;
	free (p);
}


/*
===========
AllocNode
===========
*/
node_t *AllocNode (void)
{
	node_t	*n;

	n = malloc (sizeof(node_t));
	memset (n, 0, sizeof(node_t));

	return n;
}

/*
===========
AllocBrush
===========
*/
brush_t *AllocBrush (void)
{
	brush_t	*b;

	b = malloc (sizeof(brush_t));
	memset (b, 0, sizeof(brush_t));

	return b;
}

//===========================================================================

/*
===============
ProcessEntity
===============
*/
void ProcessEntity (int entnum)
{
	entity_t *ent;
	char	mod[80];
	surface_t	*surfs;
	node_t		*nodes;
	brushset_t	*bs;


	ent = &entities[entnum];
	if (!ent->brushes)
		return;		// non-bmodel entity

	if (entnum > 0)
	{
		worldmodel = false;
		if (entnum == 1)
			qprintf ("--- Internal Entities ---\n");
		sprintf (mod, "*%i", nummodels);
		if (verbose)
			PrintEntity (ent);

		if (hullnum == 0)
			printf ("MODEL: %s\n", mod);
		SetKeyValue (ent, "model", mod);
	}
	else
		worldmodel = true;
	//
	// take the brush_ts and clip off all overlapping and contained faces,
	// leaving a perfect skin of the model with no hidden faces
	//
	bs = Brush_LoadEntity (ent, hullnum);

	if (!bs->brushes)
	{
		PrintEntity (ent);
		Error ("Entity with no valid brushes");
	}

	brushset = bs;
	surfs = CSGFaces (bs);

	if (hullnum != 0)
	{
		nodes = SolidBSP (surfs, true);
		if (entnum == 0 && !nofill)	// assume non-world bmodels are simple
		{
			PortalizeWorld (nodes);
			if (FillOutside (nodes))
			{
				surfs = GatherNodeFaces (nodes);
				nodes = SolidBSP (surfs, false);	// make a really good tree
			}
			FreeAllPortals (nodes);
		}
		WriteNodePlanes (nodes);
		WriteClipNodes (nodes);
		BumpModel (hullnum);
	}
	else
	{
		//
		// SolidBSP generates a node tree
		//
		// if not the world, make a good tree first
		// the world is just going to make a bad tree
		// because the outside filling will force a regeneration later
		nodes = SolidBSP (surfs, entnum == 0);	

		//
		// build all the portals in the bsp tree
		// some portals are solid polygons, and some are paths to other leafs
		//
		if (entnum == 0 && !nofill)	// assume non-world bmodels are simple
		{
			PortalizeWorld (nodes);

			if (FillOutside (nodes))
			{
				FreeAllPortals (nodes);

				// get the remaining faces together into surfaces again
				surfs = GatherNodeFaces (nodes);

				// merge polygons
				MergeAll (surfs);

				// make a really good tree
				nodes = SolidBSP (surfs, false);

				// make the real portals for vis tracing
				PortalizeWorld (nodes);

				// save portal file for vis tracing
				WritePortalfile (nodes);

				// fix tjunctions
				tjunc (nodes);
			}
			FreeAllPortals (nodes);
		}

		WriteNodePlanes (nodes);
		MakeFaceEdges (nodes);
		WriteDrawNodes (nodes);
	}
}

/*
=================
UpdateEntLump
=================
*/
/*
void UpdateEntLump (void)
{
	int		m, entnum;
	char	mod[80];

	m = 1;
	for (entnum = 1 ; entnum < num_entities ; entnum++)
	{
		if (!entities[entnum].brushes)
			continue;
		sprintf (mod, "*%i", m);
		SetKeyValue (&entities[entnum], "model", mod);
		m++;
	}

	printf ("Updating entities lump...\n");
	LoadBSPFile (bspfilename);
	WriteEntitiesToString();
	WriteBSPFile (bspfilename);
}
*/

struct
{
	vec3_t normal;
	vec_t dist;
	short children[2];
}
hulldata[2][MAX_MAP_PLANES];
int hullnummodels[2];
int hullheadnodes[2][MAX_MAP_MODELS];
int hullnumclipnodes[2];

/*
=================
WriteClipHull

Write the clipping hull out to a text file so the parent process can get it
=================
*/
void WriteClipHull (void)
{
	int		h = hullnum-1;
	int		i;

	qprintf ("---- WriteClipHull ----\n");
	hullnummodels[h] = nummodels;
	for (i=0 ; i<nummodels ; i++)
		hullheadnodes[h][i] = dmodels[i].headnode[hullnum];

	hullnumclipnodes[h] = numclipnodes;

	for (i=0 ; i<numclipnodes ; i++)
	{
		VectorCopy(dplanes[dclipnodes[i].planenum].normal, hulldata[h][i].normal);
		hulldata[h][i].dist = dplanes[dclipnodes[i].planenum].dist;
		hulldata[h][i].children[0] = dclipnodes[i].children[0];
		hulldata[h][i].children[1] = dclipnodes[i].children[1];
	}
}

/*
==================
FindFinalPlane

Used to find plane index numbers for clip nodes read from child processes
==================
*/
int FindFinalPlane (dplane_t *p)
{
	int			i;

	for (i = 0;i < numplanes;i++)
		if (p->type == dplanes[i].type && p->dist == dplanes[i].dist && p->normal[0] == dplanes[i].normal[0] && p->normal[1] == dplanes[i].normal[1] && p->normal[2] == dplanes[i].normal[2])
			return i;

	// new plane
	dplanes[numplanes++] = *p;
	return numplanes - 1;
}

/*
=================
ReadClipHull

Read the files written out by the child processes
=================
*/
void ReadClipHull (int hullnum)
{
	int			h = hullnum - 1;
	int			i, n;
	int			firstclipnode;
	dplane_t	p;
	dclipnode_t	*d;
	vec3_t		norm;

	for (i=0 ; i<nummodels ; i++)
		dmodels[i].headnode[hullnum] = numclipnodes + hullheadnodes[h][i];

	n = hullnumclipnodes[h];
	firstclipnode = numclipnodes;

	for (i=0 ; i<n ; i++)
	{
		if (numclipnodes == MAX_MAP_CLIPNODES)
			Error ("ReadClipHull: MAX_MAP_CLIPNODES");
		d = &dclipnodes[numclipnodes++];

		p.normal[0] = hulldata[h][i].normal[0];
		p.normal[1] = hulldata[h][i].normal[1];
		p.normal[2] = hulldata[h][i].normal[2];
		p.dist = hulldata[h][i].dist;

		norm[0] = hulldata[h][i].normal[0]; norm[1] = hulldata[h][i].normal[1]; norm[2] = hulldata[h][i].normal[2]; 	// vec_t precision
		p.type = PlaneTypeForNormal (norm);

		d->children[0] = hulldata[h][i].children[0] >= 0 ? hulldata[h][i].children[0] + firstclipnode : hulldata[h][i].children[0];
		d->children[1] = hulldata[h][i].children[1] >= 0 ? hulldata[h][i].children[1] + firstclipnode : hulldata[h][i].children[1];
		d->planenum = FindFinalPlane (&p);
	}
}

/*
=================
CreateSingleHull

=================
*/
void CreateSingleHull (int h)
{
	int entnum;
	hullnum = h;
	numplanes = 0;
	nummodels = 0;
	numclipnodes = 0;
	// for each entity in the map file that has geometry
	verbose = true;	// print world
	for (entnum = 0 ; entnum < num_entities ; entnum++)
	{
		ProcessEntity (entnum);
		if (!allverbose)
			verbose = false;	// don't print rest of entities
	}

	if (hullnum)
		WriteClipHull();
}

/*
=================
CreateHulls

=================
*/
void CreateHulls (void)
{
	// create all the hulls sequentially
	printf ("building hulls...\n");

	CreateSingleHull (1);
	CreateSingleHull (2);
	CreateSingleHull (0);
	ReadClipHull (1);
	ReadClipHull (2);
}

FILE	*litfile; // used in lightface to write to extended light file

/*
==================
main

==================
*/
void LightWorld (void);
void LoadPortals (char *name);
void CalcVis (void);
void WriteMiptex (void);
void MatchTargets (void);

extern int originalvismapsize;
int main (int argc, char **argv)
{
	int			i;
	double		start, end, totalstart, totalend;
	char		sourcename[1024];
	char		litfilename[1024];

// LordHavoc
	printf ("hmap 1.00 by LordHavoc\n");
	printf ("based on id Software and Ritual Entertainment (Hipnotic)'s quake qbsp, light, and vis utilities\n");
	lh_globalfalloff = 1.0f/65536.0f;

	//	malloc_debug (15);

	// check command line flags
	for (i=1 ; i<argc ; i++)
	{
		if (argv[i][0] != '-')
			break;
		else if (!strcmp (argv[i],"-nowater"))
			transwater = false;
		else if (!strcmp (argv[i],"-nofill"))
			nofill = true;
		else if (!strcmp (argv[i],"-onlyents"))
			onlyents = true;
		else if (!strcmp (argv[i],"-verbose"))
			allverbose = true;
		else if (!strcmp (argv[i],"-hullnum"))
		{
			hullnum = atoi(argv[i+1]);
			i++;
		}
		else if (!strcmp (argv[i],"-subdivide"))
		{
			subdivide_size = atoi(argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-minlight"))
		{
			minlight = atof (argv[i+1]);
			i++;
		}
		else if (!strcmp(argv[i],"-ignorefalloff"))
		{
			ignorefalloff = true;
			printf ("per light falloff settings disabled\n");
		}
		else if (!strcmp(argv[i],"-falloff"))
		{
			lh_globalfalloff = atof (argv[i+1]);
			printf("scaling light falloff values by %f\n", lh_globalfalloff);
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
		else if (!strcmp(argv[i], "-fast"))
		{
			printf ("fast mode (low quality lighting, fastvis)\n");
			extrasamples = false;
			fastvis = true;
		}
		else if (!strcmp(argv[i], "-level"))
		{
			testlevel = atoi(argv[i+1]);
			printf ("testlevel = %i\n", testlevel);
			i++;
		}
		else
			Error ("hmap: Unknown option '%s'", argv[i]);
	}

	if (i != argc - 1)
		Error ("\
LordHavoc's hmap quake map compiling utility (improved qbsp/light/vis combined)\n\
current features: insane limits, optional transparent water/slime/lava (-water), colored lighting, realistic light falloff, ambient content sounds can be selectively disabled\n\
email havoc@halflife.org with feature requests/suggestions.\n\
usage: hmap [options] filename\n\
qbsp options:\n\
-nowater       disables transparent water (please don't use this)\n\
-nofill        does not fill the outside of the world, use this for ammo box models\n\
-verbose       prints unbelievable amounts of information\n\
light options:\n\
-minlight num  sets minimum light level, any places darker than this are raised to it\n\
-extra         antialiased lighting (takes upto four times as long, high quality)\n\
-ignorefalloff disables the per light falloff settings (\"wait\" key)\n\
-falloff num   the global falloff scale (scales all lights)\n\
-dist num      changes lighting scale of all things\n\
-range num     changes brightness of all lights (without affecting size)\n\
vis options:\n\
-level 0-4     sets visibility checking quality level, default: 4 (original vis used 2)\n\
-fast          very rough fast vis, for test compiles\n\
Quick usage notes for light entities: (place these in key/value pairs)\n\
wait - falloff rate (1.0 default, 0.5 = bigger radius, 2 = smaller)\n\
_color - 3 values (red green blue), specifies color of light, the scale of the numbers does not matter (\"1 3 2.5\" is identical to \"1000 3000 2500\")\n\
");

	SetQdirFromPath (argv[i]);

	// let forked processes change name for ps status
	argv0 = argv[0];

	// create destination name if not specified
	strcpy (sourcename, argv[i]);
	DefaultExtension (sourcename, ".map");

	strcpy (bspfilename, sourcename);
	StripExtension (bspfilename);
	strcat (bspfilename, ".bsp");

	strcpy (litfilename, bspfilename);
	StripExtension (litfilename);
	strcat (litfilename, ".lit");

	strcpy (portfilename, bspfilename);
	StripExtension (portfilename);
	strcat (portfilename, ".prt");

	strcpy (pointfilename, bspfilename);
	StripExtension (pointfilename);
	strcat (pointfilename, ".pts");

	remove (bspfilename);
	remove (portfilename);
	remove (pointfilename);

	// do it!
	totalstart = start = I_FloatTime ();

	// load brushes and entities
	LoadMapFile (sourcename);

	// init the tables to be shared by all models
	BeginBSPFile ();

	// create clipping hulls
	CreateHulls ();

	WriteEntitiesToString();
//	FinishBSPFile ();
	printf ("--- FinishBSPFile ---\n");
	printf ("WriteBSPFile: %s\n", bspfilename);

	WriteMiptex ();

	end = I_FloatTime ();
	printf ("qbsp: %5.1f seconds elapsed\n", end-start);
	
	printf ("---- vis ----\n");

	start = I_FloatTime ();
	
	LoadPortals (portfilename);
	
	uncompressed = malloc(bitbytes*portalleafs);
	memset (uncompressed, 0, bitbytes*portalleafs);
	
//	CalcPassages ();

	CalcVis ();

	printf ("c_chains: %i\n",c_chains);
	
	visdatasize = vismap_p - dvisdata;	
	printf ("visdatasize:%i  compressed from %i\n", visdatasize, originalvismapsize);
	
	CalcAmbientSounds ();

	end = I_FloatTime ();
	printf ("vis: %5.1f seconds elapsed\n", end-start);

	printf ("----- LightFaces ----\n");

	start = I_FloatTime ();

	litfile = fopen(litfilename, "wb");

	// QLIT version 1
	fputc('Q', litfile);fputc('L', litfile);fputc('I', litfile);fputc('T', litfile);
	fputc(1, litfile);fputc(0, litfile);fputc(0, litfile);fputc(0, litfile);

	MatchTargets();
		
	MakeTnodes (&dmodels[0]);

	LightWorld ();

	WriteEntitiesToString ();	
	if (litfile)
		fclose(litfile);

	end = I_FloatTime ();
	printf ("light: %5.1f seconds elapsed\n", end-start);
	
	WriteBSPFile (bspfilename);
	
	PrintBSPFileSizes ();

	totalend = I_FloatTime ();
	printf ("hmap: %5.1f seconds elapsed\n", totalend-totalstart);
#ifdef _DEBUG
	printf ("press a key\n");
	getchar();
#endif

	return 0;
}
