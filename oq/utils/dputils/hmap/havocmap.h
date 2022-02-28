
// havocmap.h

#ifndef HAVOCMAP_H
#define HAVOCMAP_H

#include <math.h>
#include "cmdlib.h"
#include "mathlib.h"
#include "bspfile.h"

typedef struct
{
  vec3_t	normal;
  vec_t	dist;
  int		type;
} plane_t;

//#define	MAX_FACES		16
#define	MAX_FACES		32
typedef struct mface_s
{
	struct mface_s	*next;
	plane_t			plane;
	int				texinfo;
} mface_t;

typedef struct mbrush_s
{
	struct mbrush_s	*next;
	mface_t *faces;
} mbrush_t;

typedef struct epair_s
{
	struct epair_s	*next;
	char	*key;
	char	*value;
} epair_t;

typedef struct entity_s
{
	char	classname[64];
	vec3_t	origin;
	float	angle;
	int		light;
	// LordHavoc: added falloff (smaller fractions = bigger light area) and color
	float	falloff;
	float	color[3];
	int		style;
	char	target[32];
	char	targetname[32];
	mbrush_t		*brushes;
	struct epair_s	*epairs;
	struct entity_s	*targetent;
} entity_t;

extern	int			nummapbrushes;
extern	mbrush_t	mapbrushes[MAX_MAP_BRUSHES];

extern	int			num_entities;
extern	entity_t	entities[MAX_MAP_ENTITIES];

extern	int			nummiptex;
extern	char		miptex[MAX_MAP_TEXINFO][16];

void 	LoadMapFile (char *filename);

int		FindMiptex (char *name);

void	PrintEntity (entity_t *ent);
char 	*ValueForKey (entity_t *ent, char *key);
void	SetKeyValue (entity_t *ent, char *key, char *value);
float	FloatForKey (entity_t *ent, char *key);
void 	GetVectorForKey (entity_t *ent, char *key, vec3_t vec);

void	WriteEntitiesToString (void);

#define NUM_WADS        21

#define	ON_EPSILON	0.05
#define	BOGUS_RANGE	18000

// the exact bounding box of the brushes is expanded some for the headnode
// volume.  is this still needed?
#define	SIDESPACE	24

//============================================================================


typedef struct
{
	qboolean	original;			// don't free, it's part of the portal
	int		numpoints;
	vec3_t	points[8];			// variable sized
} winding_t;

#define MAX_POINTS_ON_WINDING	64

winding_t *BaseWindingForPlane (plane_t *p);
void CheckWinding (winding_t *w);
winding_t	*qbsp_NewWinding (int points);
void		qbsp_FreeWinding (winding_t *w);
winding_t	*CopyWinding (winding_t *w);
winding_t	*qbsp_ClipWinding (winding_t *in, plane_t *split, qboolean keepon);
void PlaneFromWinding (winding_t *w, plane_t *plane);
void	DivideWinding (winding_t *in, plane_t *split, winding_t **front, winding_t **back);

//============================================================================
 
#define	MAXEDGES			32
#define	MAXPOINTS			28		// don't let a base face get past this
// because it can be split more later

typedef struct visfacet_s
{
  struct visfacet_s	*next;
	
  int				planenum;
  int				planeside;	// which side is the front of the face
  int				texturenum;
  int				contents[2];	// 0 = front side

  struct visfacet_s	*original;		// face on node
  int				outputnumber;		// only valid for original faces after
  // write surfaces
  int				numpoints;
  vec3_t			pts[MAXEDGES];		// FIXME: change to use winding_t
  int				edges[MAXEDGES];
} face_t;


typedef struct surface_s
{
  struct surface_s	*next;
  struct surface_s	*original;	// before BSP cuts it up
  int			planenum;
  int			outputplanenum;		// only valid after WriteSurfacePlanes
  vec3_t		mins, maxs;
  qboolean		onnode;				// true if surface has already been used
  // as a splitting node
  face_t		*faces;	// links to all the faces on either side of the surf
} surface_t;


//
// there is a node_t structure for every node and leaf in the bsp tree
//
#define	PLANENUM_LEAF		-1

typedef struct node_s
{
  vec3_t			mins,maxs;		// bounding volume, not just points inside

  // information for decision nodes	
  int				planenum;		// -1 = leaf node	
  int				outputplanenum;	// only valid after WriteNodePlanes
  int				firstface;		// decision node only
  int				numfaces;		// decision node only
  struct node_s		*children[2];	// only valid for decision nodes
  face_t			*faces;			// decision nodes only, list for both sides
	
  // information for leafs
  int				contents;		// leaf nodes (0 for decision nodes)
  face_t			**markfaces;	// leaf nodes only, point to node faces
  struct portal_s	*portals;
  int				visleafnum;		// -1 = solid
  int				valid;			// for flood filling
  int				occupied;		// light number in leaf for outside filling
} node_t;

//=============================================================================

// brush.c

#define	NUM_HULLS		2				// normal and +16

#define	NUM_CONTENTS	2				// solid and water

typedef struct brush_s
{
  struct brush_s	*next;
  vec3_t			mins, maxs;
  face_t			*faces;
  int				contents;
} brush_t;

typedef struct
{
  vec3_t		mins, maxs;
  brush_t		*brushes;		// NULL terminated list
} brushset_t;

extern	int			numbrushplanes;
extern	plane_t		planes[MAX_MAP_PLANES];

brushset_t *Brush_LoadEntity (entity_t *ent, int hullnum);
int	PlaneTypeForNormal (vec3_t normal);
int	FindPlane (plane_t *dplane, int *side);

//=============================================================================

// csg4.c

// build surfaces is also used by GatherNodeFaces
extern	face_t	*validfaces[MAX_MAP_PLANES];
surface_t *BuildSurfaces (void);

face_t *NewFaceFromFace (face_t *in);
surface_t *CSGFaces (brushset_t *bs);
void SplitFace (face_t *in, plane_t *split, face_t **front, face_t **back);

//=============================================================================

// solidbsp.c

void DivideFacet (face_t *in, plane_t *split, face_t **front, face_t **back);
void CalcSurfaceInfo (surface_t *surf);
void SubdivideFace (face_t *f, face_t **prevptr);
node_t *SolidBSP (surface_t *surfhead, qboolean midsplit);

//=============================================================================

// merge.c

void MergePlaneFaces (surface_t *plane);
face_t *MergeFaceToList (face_t *face, face_t *list);
face_t *FreeMergeListScraps (face_t *merged);
void MergeAll (surface_t *surfhead);

//=============================================================================

// surfaces.c

extern	int		c_cornerverts;
extern	int		c_tryedges;
extern	face_t		*edgefaces[MAX_MAP_EDGES][2];

extern	int		firstmodeledge;
extern	int		firstmodelface;

void SubdivideFaces (surface_t *surfhead);

surface_t *GatherNodeFaces (node_t *headnode);

void MakeFaceEdges (node_t *headnode);

//=============================================================================

// portals.c

typedef enum {stat_none, stat_working, stat_done} vstatus_t;
typedef struct portal_s
{
	int			planenum;
	struct node_s	*nodes[2];		// [0] = front side of planenum
	struct portal_s	*next[2];	

	plane_t		plane;	// normal pointing into neighbor
	int			leaf;	// neighbor
	winding_t	*winding;
	vstatus_t	status;
	byte		*visbits;
	byte		*mightsee;
	int			nummightsee;
	int			numcansee;
} portal_t;

extern	node_t	outside_node;		// portals outside the world face this

void PortalizeWorld (node_t *headnode);
void WritePortalfile (node_t *headnode);
void FreeAllPortals (node_t *node);

//=============================================================================

// region.c

void GrowNodeRegions (node_t *headnode);

//=============================================================================

// tjunc.c

void tjunc (node_t *headnode);

//=============================================================================

// writebsp.c

void WriteNodePlanes (node_t *headnode);
void WriteClipNodes (node_t *headnode);
void WriteDrawNodes (node_t *headnode);

void BumpModel (int hullnum);
int FindFinalPlane (dplane_t *p);

void BeginBSPFile (void);
void FinishBSPFile (void);

//=============================================================================

// draw.c

void Draw_ClearBounds (void);
void Draw_AddToBounds (vec3_t v);
void Draw_DrawFace (face_t *f);
void Draw_ClearWindow (void);
void Draw_SetRed (void);
void Draw_SetGrey (void);
void Draw_SetBlack (void);
void DrawPoint (vec3_t v);

void Draw_SetColor (int c);
void SetColor (int c);
void DrawPortal (portal_t *p);
void DrawLeaf (node_t *l, int color);
void DrawBrush (brush_t *b);

void DrawWinding (winding_t *w);
void DrawTri (vec3_t p1, vec3_t p2, vec3_t p3);

//=============================================================================

// outside.c

qboolean FillOutside (node_t *node);

//=============================================================================

extern	qboolean nofill;
extern	qboolean	verbose;

extern	int		subdivide_size;

extern	int		hullnum;

extern	brushset_t	*brushset;

void qprintf (char *fmt, ...);	// only prints if verbose

extern	int		valid;

extern	char	portfilename[1024];
extern	char	bspfilename[1024];
extern	char	pointfilename[1024];

extern	qboolean	worldmodel;


// misc functions

face_t *AllocFace (void);
void FreeFace (face_t *f);

portal_t *AllocPortal (void);
void FreePortal (portal_t *p);

surface_t *AllocSurface (void);
void FreeSurface (surface_t *s);

node_t *AllocNode (void);
struct brush_s *AllocBrush (void);

//=============================================================================

// vis

#define	MAX_PORTALS	32768

#define	PORTALFILE	"PRT1"

#define MAX_POINTS_ON_WINDING	64

winding_t	*winding_NewWinding (int points);
void		winding_FreeWinding (winding_t *w);
winding_t	*winding_ClipWinding (winding_t *in, plane_t *split, qboolean keepon);
winding_t	*CopyWinding (winding_t *w);

typedef struct seperating_plane_s
{
	struct seperating_plane_s *next;
	plane_t		plane;		// from portal is on positive side
} sep_t;


typedef struct passage_s
{
	struct passage_s	*next;
	int			from, to;		// leaf numbers
	sep_t				*planes;
} passage_t;


#define	MAX_PORTALS_ON_LEAF		128
typedef struct leaf_s
{
	int			numportals;
	passage_t	*passages;
	portal_t	*portals[MAX_PORTALS_ON_LEAF];
} leaf_t;

	
typedef struct pstack_s
{
	struct pstack_s	*next;
	leaf_t		*leaf;
	portal_t	*portal;	// portal exiting
	winding_t	*source, *pass;
	plane_t		portalplane;
	byte		*mightsee;		// bit string
} pstack_t;

typedef struct
{
	byte		*leafvis;		// bit string
	portal_t	*base;
	pstack_t	pstack_head;
} threaddata_t;


extern	int			numportals;
extern	int			portalleafs;

extern	portal_t	*portals;
extern	leaf_t		*leafs;

extern	int			c_portaltest, c_portalpass, c_portalcheck;
extern	int			c_portalskip, c_leafskip;
extern	int			c_vistest, c_mighttest;
extern	int			c_chains;

extern	byte	*vismap, *vismap_p, *vismap_end;	// past visfile

extern	qboolean		showgetleaf;
extern	int			testlevel;

extern	byte		*uncompressed;
extern	int			bitbytes;
extern	int			bitlongs;


void LeafFlow (int leafnum);
void BasePortalVis (void);

void PortalFlow (portal_t *p);

void CalcAmbientSounds (void);

//===============================================================================

// light

#define DEFAULTLIGHTLEVEL	300
#define DEFAULTFALLOFF	1.0f

char 	*ValueForKey (entity_t *ent, char *key);
void 	SetKeyValue (entity_t *ent, char *key, char *value);
float	FloatForKey (entity_t *ent, char *key);
void 	GetVectorForKey (entity_t *ent, char *key, vec3_t vec);

//void LoadEntities (void);
void WriteEntitiesToString (void);

#define	MAXLIGHTS			1024

void LoadNodes (char *file);
qboolean TestLine (vec3_t start, vec3_t stop);

void LightFace (int surfnum);
void LightLeaf (dleaf_t *leaf);

void MakeTnodes (dmodel_t *bm);

extern	float		scaledist;
extern	float		scalecos;
extern	float		rangescale;

extern	int		c_culldistplane, c_proper;

byte *GetFileSpace (int size);
extern	byte		*filebase;

extern	vec3_t	bsp_origin;
extern	vec3_t	bsp_xvector;
extern	vec3_t	bsp_yvector;

void TransformSample (vec3_t in, vec3_t out);
void RotateSample (vec3_t in, vec3_t out);

extern	qboolean	extrasamples;
extern	qboolean	ignorefalloff;
extern	vec_t	lh_globalfalloff;

//extern	float		minlights[MAX_MAP_FACES];
extern	float	minlight;

#endif