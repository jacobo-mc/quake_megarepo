/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// r_main.c

#include <stdint.h>

#include "cmd.h"
#include "console.h"
#include "protocol.h"
#include "quakedef.h"
#include "r_local.h"
#include "r_shared.h"
#include "sbar.h"
#include "screen.h"
#include "sound.h"
#include "sys.h"
#include "view.h"

static int r_maphighhunkmark;

void *colormap;
float r_time1;

qboolean r_recursiveaffinetriangles = true;

int r_pixbytes = 1;
float r_aliasuvscale = 1.0;
qboolean r_surfaces_overflow;
qboolean r_edges_overflow;

edge_t *saveedges;
surf_t *savesurfs;

qboolean r_dowarp, r_viewchanged;

int c_surf;

byte *r_warpbuffer;

static byte *r_stack_start;

entity_t r_worldentity;

//
// view origin
//
vec3_t vup, base_vup;
vec3_t vpn, base_vpn;
vec3_t vright, base_vright;
vec3_t r_origin;

//
// screen size info
//
refdef_t r_refdef;
float xcenter, ycenter;
float xscale, yscale;
float xscaleinv, yscaleinv;
float xscaleshrink, yscaleshrink;
float aliasxscale, aliasyscale, aliasxcenter, aliasycenter;

float pixelAspect;
static float screenAspect;
static float verticalFieldOfView;
static float xOrigin, yOrigin;

mplane_t screenedge[4];

//
// refresh flags
//
int r_framecount = 1;		// so frame counts initialized to 0 don't match
int r_visframecount;
int r_polycount;
int r_drawnpolycount;

mleaf_t *r_viewleaf, *r_oldviewleaf;

texture_t *r_notexture_mip;

float r_aliastransition, r_resfudge;

int d_lightstylevalue[256];	// 8.8 fraction of base light value

float dp_time1, dp_time2, db_time1, db_time2, rw_time1, rw_time2;
float se_time1, se_time2, de_time1, de_time2, dv_time1, dv_time2;

cvar_t r_draworder = { "r_draworder", "0" };
cvar_t r_speeds = { "r_speeds", "0" };
cvar_t r_graphheight = { "r_graphheight", "15" };
cvar_t r_clearcolor = { "r_clearcolor", "2" };
cvar_t r_waterwarp = { "r_waterwarp", "1" };
cvar_t r_drawentities = { "r_drawentities", "1" };
cvar_t r_drawviewmodel = { "r_drawviewmodel", "1" };
cvar_t r_drawflat = { "r_drawflat", "0" };
cvar_t r_ambient = { "r_ambient", "0" };

cvar_t r_lockpvs = { "r_lockpvs", "0" };
cvar_t r_lockfrustum = { "r_lockfrustum", "0" };

cvar_t r_fullbright = {
    .name = "r_fullbright",
    .string = "0",
    .flags = CVAR_DEVELOPER
};

#ifdef QW_HACK
cvar_t r_netgraph = { "r_netgraph", "0" };
static cvar_t r_zgraph = { "r_zgraph", "0" };
#endif

static cvar_t r_timegraph = { "r_timegraph", "0" };
static cvar_t r_aliasstats = { "r_polymodelstats", "0" };
static cvar_t r_dspeeds = { "r_dspeeds", "0" };
static cvar_t r_maxsurfs = { "r_maxsurfs", stringify(MINSURFACES) };
static cvar_t r_maxedges = { "r_maxedges", stringify(MINEDGES) };
static cvar_t r_aliastransbase = { "r_aliastransbase", "200" };
static cvar_t r_aliastransadj = { "r_aliastransadj", "100" };

/*
==================
R_InitTextures
==================
*/
void
R_InitTextures(void)
{
    int x, y, m;
    byte *dest;

// create a simple checkerboard texture for the default
    r_notexture_mip =
	Hunk_AllocName(sizeof(texture_t) + 16 * 16 + 8 * 8 + 4 * 4 + 2 * 2,
		       "notexture");

    r_notexture_mip->width = r_notexture_mip->height = 16;
    r_notexture_mip->offsets[0] = sizeof(texture_t);
    r_notexture_mip->offsets[1] = r_notexture_mip->offsets[0] + 16 * 16;
    r_notexture_mip->offsets[2] = r_notexture_mip->offsets[1] + 8 * 8;
    r_notexture_mip->offsets[3] = r_notexture_mip->offsets[2] + 4 * 4;

    for (m = 0; m < 4; m++) {
	dest = (byte *)r_notexture_mip + r_notexture_mip->offsets[m];
	for (y = 0; y < (16 >> m); y++) {
	    for (x = 0; x < (16 >> m); x++) {
		if ((y < (8 >> m)) ^ (x < (8 >> m)))
		    *dest++ = 0;
		else
		    *dest++ = 0xff;
	    }
	}
    }
}


/*
================
R_InitTurb
================
*/
static void
R_InitTurb(void)
{
    int i;

    for (i = 0; i < TURB_TABLE_SIZE; ++i) {
	sintable[i]    = TURB_SURF_AMP   + sin(i * 3.14159 * 2 / TURB_CYCLE) * TURB_SURF_AMP;
	intsintable[i] = TURB_SCREEN_AMP + sin(i * 3.14159 * 2 / TURB_CYCLE) * TURB_SCREEN_AMP;
    }
}

void
R_AddCommands()
{
    Cmd_AddCommand("timerefresh", R_TimeRefresh_f);
    Cmd_AddCommand("pointfile", R_ReadPointFile_f);
}

void
R_RegisterVariables()
{
    Cvar_RegisterVariable(&r_draworder);
    Cvar_RegisterVariable(&r_speeds);
    Cvar_RegisterVariable(&r_graphheight);
    Cvar_RegisterVariable(&r_clearcolor);
    Cvar_RegisterVariable(&r_waterwarp);
    Cvar_RegisterVariable(&r_drawentities);
    Cvar_RegisterVariable(&r_drawviewmodel);
    Cvar_RegisterVariable(&r_drawflat);
    Cvar_RegisterVariable(&r_ambient);

    Cvar_RegisterVariable(&r_lerpmodels);
    Cvar_RegisterVariable(&r_lerpmove);
    Cvar_RegisterVariable(&r_lockpvs);
    Cvar_RegisterVariable(&r_lockfrustum);

    Cvar_RegisterVariable(&r_fullbright);

    Cvar_RegisterVariable(&r_timegraph);
    Cvar_RegisterVariable(&r_aliasstats);
    Cvar_RegisterVariable(&r_dspeeds);
    Cvar_RegisterVariable(&r_maxsurfs);
    Cvar_RegisterVariable(&r_maxedges);
    Cvar_RegisterVariable(&r_aliastransbase);
    Cvar_RegisterVariable(&r_aliastransadj);

#ifdef QW_HACK
    Cvar_RegisterVariable(&r_netgraph);
    Cvar_RegisterVariable(&r_zgraph);
#endif

    Cvar_RegisterVariable(&r_wateralpha);
    Cvar_RegisterVariable(&r_slimealpha);
    Cvar_RegisterVariable(&r_lavaalpha);
    Cvar_RegisterVariable(&r_telealpha);

    Cvar_RegisterVariable(&r_particle_scale);

    D_RegisterVariables();
}


/*
===============
R_Init
===============
*/
void
R_Init(void)
{
    int dummy;

    // get stack position so we can guess if we are going to overflow
    r_stack_start = (byte *)&dummy;

    R_InitTurb();

    view_clipplanes[0].leftedge = true;
    view_clipplanes[1].rightedge = true;
    view_clipplanes[1].leftedge = view_clipplanes[2].leftedge = view_clipplanes[3].leftedge = false;
    view_clipplanes[0].rightedge = view_clipplanes[2].rightedge = view_clipplanes[3].rightedge = false;

    r_refdef.xOrigin = XCENTERING;
    r_refdef.yOrigin = YCENTERING;

    R_InitParticles();
    R_InitTranslationTable();

    D_Init();
}

static void
R_PatchSurfaceBlockCode()
{
#ifdef USE_X86_ASM
    if (r_pixbytes == 1) {
	colormap = vid.colormap;
	Sys_MakeCodeWriteable(R_Surf8Start, R_Surf8End);
	R_Surf8Patch();
        Sys_MakeCodeUnwriteable(R_Surf8Start, R_Surf8End);
    } else {
	colormap = vid.colormap16;
	Sys_MakeCodeWriteable(R_Surf16Start, R_Surf16End);
	R_Surf16Patch();
	Sys_MakeCodeUnwriteable(R_Surf16Start, R_Surf16End);
    }
#endif
}

static void
R_PatchEdgeSortingCode()
{
#ifdef USE_X86_ASM
    Sys_MakeCodeWriteable(R_EdgeCodeStart, R_EdgeCodeEnd);
    R_SurfacePatch();
    Sys_MakeCodeUnwriteable(R_EdgeCodeStart, R_EdgeCodeEnd);
#endif
}

static void
R_HunkAllocSurfaces()
{
    auxsurfaces = Hunk_HighAllocName(CACHE_PAD_ARRAY(r_numsurfaces, surf_t) * sizeof(surf_t), "surfaces");
    auxsurfaces = CACHE_ALIGN_PTR(auxsurfaces);

    surfaces = auxsurfaces;
    surf_max = &surfaces[r_numsurfaces];
    surfaces--;

    R_PatchEdgeSortingCode();
}

static void
R_HunkAllocEdges()
{
    auxedges = Hunk_HighAllocName(CACHE_PAD_ARRAY(r_numedges, edge_t) * sizeof(edge_t), "edges");
    auxedges = CACHE_ALIGN_PTR(auxedges);
}

/*
===============
R_NewMap
===============
*/
void
R_NewMap(void)
{
    int i;

    memset(&r_worldentity, 0, sizeof(r_worldentity));
    r_worldentity.model = &cl.worldmodel->model;

// clear out efrags in case the level hasn't been reloaded
// FIXME: is this one short?
    for (i = 0; i < cl.worldmodel->numleafs; i++)
	cl.worldmodel->leafs[i].efrags = NULL;

    r_viewleaf = NULL;
    R_ClearParticles();

    /* Edge rendering resources */
    r_numsurfaces = qmax((int)r_maxsurfs.value, MINSURFACES);
    r_numedges = qmax((int)r_maxedges.value, MINEDGES);

    /* brushmodel clipping */
    r_numbclipverts = MIN_STACK_BMODEL_VERTS;
    r_numbclipedges = MIN_STACK_BMODEL_EDGES;

    r_viewchanged = false;

    Alpha_NewMap();

    Hunk_FreeToHighMark(r_maphighhunkmark);
    R_AllocSurfEdges(false);
}

void
R_AllocSurfEdges(qboolean nostack)
{
    r_maphighhunkmark = Hunk_HighMark();

    auxsurfaces = NULL;
    if (r_numsurfaces > MAXSTACKSURFACES || nostack)
        R_HunkAllocSurfaces();

    auxedges = NULL;
    if (r_numedges > MAXSTACKEDGES || nostack)
        R_HunkAllocEdges();

    /* extra space for saving surfs/edges for translucent surface rendering */
    savesurfs = Hunk_HighAllocName(CACHE_PAD_ARRAY(r_numsurfaces, surf_t) * sizeof(surf_t), "savesurf");
    savesurfs = CACHE_ALIGN_PTR(savesurfs);
    saveedges = Hunk_HighAllocName(CACHE_PAD_ARRAY(r_numedges, edge_t) * sizeof(edge_t), "saveedge");
    saveedges = CACHE_ALIGN_PTR(saveedges);
}


/*
===============
R_SetVrect
===============
*/
void
R_SetVrect(const vrect_t *in, vrect_t *out, int lineadj)
{
    int h;
    float size;
    qboolean full;

    if (scr_scale != 1.0f) {
        lineadj = SCR_Scale(lineadj);
    }

    full = (scr_viewsize.value >= 100.0f);
    size = qmin(scr_viewsize.value + 10.0f, 100.0f);  // 90 is full width but sbar height filled

    /* Hide the status bar during intermission */
    if (cl.intermission) {
	full = true;
	size = 100.0;
	lineadj = 0;
    }
    size /= 100.0;

    if (full)
	h = in->height;
    else
	h = in->height - lineadj;

    out->width = in->width * size;
    if (out->width < 96) {
	size = 96.0 / in->width;
	out->width = 96;	// min for icons
    }
    out->width &= ~7;

    out->height = in->height * size;
    if (!full) {
	if (out->height > in->height - lineadj)
	    out->height = in->height - lineadj;
    } else if (out->height > in->height)
	out->height = in->height;
    out->height &= ~1;

    out->x = (in->width - out->width) / 2;
    if (full)
	out->y = 0;
    else
	out->y = (h - out->height) / 2;
}


/*
===============
R_ViewChanged

Called every time the vid structure or r_refdef changes.
Guaranteed to be called before the first refresh
===============
*/
void
R_ViewChanged(const vrect_t *vrect, int lineadj, float aspect)
{
    int i;
    float res_scale;

    r_viewchanged = true;

    R_SetVrect(vrect, &r_refdef.vrect, lineadj);

    r_refdef.horizontalFieldOfView  = 2.0 * tan(r_refdef.fov_x / 360 * M_PI);
    r_refdef.fvrectx                = (float)r_refdef.vrect.x;
    r_refdef.fvrectx_adj            = (float)r_refdef.vrect.x - 0.5;
    r_refdef.vrect_x_adj_shift20    = (r_refdef.vrect.x << 20) + (1 << 19) - 1;
    r_refdef.fvrecty                = (float)r_refdef.vrect.y;
    r_refdef.fvrecty_adj            = (float)r_refdef.vrect.y - 0.5;
    r_refdef.vrectright             = r_refdef.vrect.x + r_refdef.vrect.width;
    r_refdef.vrectright_adj_shift20 = (r_refdef.vrectright << 20) + (1 << 19) - 1;
    r_refdef.fvrectright            = (float)r_refdef.vrectright;
    r_refdef.fvrectright_adj        = (float)r_refdef.vrectright - 0.5;
    r_refdef.vrectrightedge         = (float)r_refdef.vrectright - 0.99;
    r_refdef.vrectbottom            = r_refdef.vrect.y + r_refdef.vrect.height;
    r_refdef.fvrectbottom           = (float)r_refdef.vrectbottom;
    r_refdef.fvrectbottom_adj       = (float)r_refdef.vrectbottom - 0.5;

    r_refdef.aliasvrect.x           = (int)(r_refdef.vrect.x * r_aliasuvscale);
    r_refdef.aliasvrect.y           = (int)(r_refdef.vrect.y * r_aliasuvscale);
    r_refdef.aliasvrect.width       = (int)(r_refdef.vrect.width * r_aliasuvscale);
    r_refdef.aliasvrect.height      = (int)(r_refdef.vrect.height * r_aliasuvscale);
    r_refdef.aliasvrectright        = r_refdef.aliasvrect.x + r_refdef.aliasvrect.width;
    r_refdef.aliasvrectbottom       = r_refdef.aliasvrect.y + r_refdef.aliasvrect.height;

    pixelAspect = aspect;
    xOrigin = r_refdef.xOrigin;
    yOrigin = r_refdef.yOrigin;

    screenAspect = r_refdef.vrect.width * pixelAspect / r_refdef.vrect.height;
// 320*200 1.0 pixelAspect = 1.6 screenAspect
// 320*240 1.0 pixelAspect = 1.3333 screenAspect
// proper 320*200 pixelAspect = 0.8333333

    verticalFieldOfView = r_refdef.horizontalFieldOfView / screenAspect;

// values for perspective projection
// if math were exact, the values would range from 0.5 to to range+0.5
// hopefully they wll be in the 0.000001 to range+.999999 and truncate
// the polygon rasterization will never render in the first row or column
// but will definately render in the [range] row and column, so adjust the
// buffer origin to get an exact edge to edge fill
    xcenter = ((float)r_refdef.vrect.width * XCENTERING) + r_refdef.vrect.x - 0.5;
    aliasxcenter = xcenter * r_aliasuvscale;
    ycenter = ((float)r_refdef.vrect.height * YCENTERING) + r_refdef.vrect.y - 0.5;
    aliasycenter = ycenter * r_aliasuvscale;

    xscale = r_refdef.vrect.width / r_refdef.horizontalFieldOfView;
    aliasxscale = xscale * r_aliasuvscale;
    xscaleinv = 1.0 / xscale;
    yscale = xscale * pixelAspect;
    aliasyscale = yscale * r_aliasuvscale;
    yscaleinv = 1.0 / yscale;
    xscaleshrink = (r_refdef.vrect.width - 6) / r_refdef.horizontalFieldOfView;
    yscaleshrink = xscaleshrink * pixelAspect;

// left side clip
    screenedge[0].normal[0] = -1.0 / (xOrigin * r_refdef.horizontalFieldOfView);
    screenedge[0].normal[1] = 0;
    screenedge[0].normal[2] = 1;
    screenedge[0].type = PLANE_ANYZ;

// right side clip
    screenedge[1].normal[0] = 1.0 / ((1.0 - xOrigin) * r_refdef.horizontalFieldOfView);
    screenedge[1].normal[1] = 0;
    screenedge[1].normal[2] = 1;
    screenedge[1].type = PLANE_ANYZ;

// top side clip
    screenedge[2].normal[0] = 0;
    screenedge[2].normal[1] = -1.0 / (yOrigin * verticalFieldOfView);
    screenedge[2].normal[2] = 1;
    screenedge[2].type = PLANE_ANYZ;

// bottom side clip
    screenedge[3].normal[0] = 0;
    screenedge[3].normal[1] = 1.0 / ((1.0 - yOrigin) * verticalFieldOfView);
    screenedge[3].normal[2] = 1;
    screenedge[3].type = PLANE_ANYZ;

    for (i = 0; i < 4; i++)
	VectorNormalize(screenedge[i].normal);

    res_scale =	sqrtf((r_refdef.vrect.width * r_refdef.vrect.height) / (320.0 * 152.0)) * (2.0 / r_refdef.horizontalFieldOfView);
    r_aliastransition = r_aliastransbase.value * res_scale;
    r_resfudge = r_aliastransadj.value * res_scale;

    R_PatchSurfaceBlockCode();
    D_ViewChanged();
}


/*
===============
R_MarkSurfaces
===============
*/
static void
R_MarkSurfaces(void)
{
    const leafbits_t *pvs;
    leafblock_t check;
    int leafnum, i;
    mleaf_t *leaf;
    mnode_t *node;
    msurface_t **mark;
    qboolean pvs_changed;

    /*
     * If the PVS hasn't changed, no need to update bsp visframes,
     * just store the efrags.
     */
    pvs_changed = (r_viewleaf != r_oldviewleaf && !r_lockpvs.value);
    if (pvs_changed) {
	r_visframecount++;
	r_oldviewleaf = r_viewleaf;
    }

    pvs = Mod_LeafPVS(cl.worldmodel, r_viewleaf);
    foreach_leafbit(pvs, leafnum, check) {
	leaf = &cl.worldmodel->leafs[leafnum + 1];
	if (leaf->efrags)
	    R_StoreEfrags(&leaf->efrags);
	if (!pvs_changed)
	    continue;

	/* Mark the surfaces */
	mark = leaf->firstmarksurface;
	for (i = 0; i < leaf->nummarksurfaces; i++) {
	    (*mark)->visframe = r_visframecount;
	    mark++;
	}

	/* Mark the leaf and all parent nodes */
	node = (mnode_t *)leaf;
	do {
	    if (node->visframe == r_visframecount)
		break;
	    node->visframe = r_visframecount;
	    node = node->parent;
	} while (node);
    }
}

/*
=============
R_CullSurfaces
=============
*/
static void
R_CullSurfaces(brushmodel_t *brushmodel, vec3_t vieworg)
{
    int i, j;
    int side;
    mnode_t *node;
    msurface_t *surf;
    mplane_t *plane;
    vec_t dist;

    node = brushmodel->nodes;
    node->clipflags = 15;

    for (;;) {
	if (node->visframe != r_visframecount)
	    goto NodeUp;

	if (node->clipflags) {
	    /* Clip the node against the frustum */
	    for (i = 0; i < 4; i++) {
		if (!(node->clipflags & (1 << i)))
		    continue;
		plane = &view_clipplanes[i].plane;
		side = BoxOnPlaneSide(node->mins, node->maxs, plane);
		if (side == PSIDE_BACK) {
		    node->clipflags = BMODEL_FULLY_CLIPPED;
		    goto NodeUp;
		}
		if (side == PSIDE_FRONT)
		    node->clipflags &= ~(1 << i);
	    }
	}

	if (node->contents < 0)
	    goto NodeUp;

	surf = brushmodel->surfaces + node->firstsurface;
	for (i = 0; i < node->numsurfaces; i++, surf++) {
	    /* Clip the surfaces against the frustum */
	    surf->clipflags = node->clipflags;
	    for (j = 0; j < 4; j++) {
		if (!(node->clipflags & (1 << j)))
		    continue;
		plane = &view_clipplanes[j].plane;
		side = BoxOnPlaneSide(surf->mins, surf->maxs, plane);
		if (side == PSIDE_BACK) {
		    surf->clipflags = BMODEL_FULLY_CLIPPED;
		    break;
		}
		if (side == PSIDE_FRONT)
		    surf->clipflags &= ~(1 << j);
	    }
	    if (j < 4)
		continue;

	    /* Cull backward facing surfs */
	    if (surf->plane->type < 3) {
		dist = vieworg[surf->plane->type] - surf->plane->dist;
	    } else {
		dist = DotProduct(vieworg, surf->plane->normal);
		dist -= surf->plane->dist;
	    }
	    if (surf->flags & SURF_PLANEBACK) {
		if (dist > -BACKFACE_EPSILON)
		    surf->clipflags = BMODEL_FULLY_CLIPPED;
	    } else {
		if (dist < BACKFACE_EPSILON)
		    surf->clipflags = BMODEL_FULLY_CLIPPED;
	    }
	}

//  DownLeft:
	/* Don't descend into solid leafs because parent links are broken */
	if (node->children[0]->contents == CONTENTS_SOLID)
	    goto DownRight;
	node->children[0]->clipflags = node->clipflags;
	node = node->children[0];
	continue;

    DownRight:
	/* Don't descent into solid leafs because parent links are broken */
	if (node->children[1]->contents == CONTENTS_SOLID)
	    goto NodeUp;
	node->children[1]->clipflags = node->clipflags;
	node = node->children[1];
	continue;

    NodeUp:
	/* If we just processed the left node, go right */
	if (node->parent && node == node->parent->children[0]) {
	    node = node->parent;
	    goto DownRight;
	}

	/* If we were on a right branch, backtrack */
	while (node->parent && node == node->parent->children[1])
	    node = node->parent;

	/* If we still have a parent, we need to cross to the right */
	if (node->parent) {
	    node = node->parent;
	    goto DownRight;
	}

	/* If no more parents, we are done */
	break;
    }
}

/*
=============
R_CullSubmodelSurfaces
=============
*/
static void
R_CullSubmodelSurfaces(const brushmodel_t *submodel, const vec3_t vieworg, int clipflags)
{
    int i, j, side;
    msurface_t *surf;
    mplane_t *plane;
    vec_t dist;

    surf = submodel->surfaces + submodel->firstmodelsurface;
    for (i = 0; i < submodel->nummodelsurfaces; i++, surf++) {
	/* Clip the surface against the frustum */
	surf->clipflags = clipflags;

	for (j = 0; j < 4; j++) {
	    if (!(surf->clipflags & (1 << j)))
		continue;
	    plane = &view_clipplanes[j].plane;
	    side = BoxOnPlaneSide(surf->mins, surf->maxs, plane);
	    if (side == PSIDE_BACK) {
		surf->clipflags = BMODEL_FULLY_CLIPPED;
		break;
	    }
	    if (side == PSIDE_FRONT)
		surf->clipflags &= ~(1 << j);
	}
	if (j < 4)
	    continue;

	/* Cull backward facing surfs */
	if (surf->plane->type < 3) {
	    dist = vieworg[surf->plane->type] - surf->plane->dist;
	} else {
	    dist = DotProduct(vieworg, surf->plane->normal);
	    dist -= surf->plane->dist;
	}
	if (surf->flags & SURF_PLANEBACK) {
	    if (dist > -BACKFACE_EPSILON)
		surf->clipflags = BMODEL_FULLY_CLIPPED;
	} else {
	    if (dist < BACKFACE_EPSILON)
		surf->clipflags = BMODEL_FULLY_CLIPPED;
	}
    }
}

int
R_LightPoint(const vec3_t point)
{
    surf_lightpoint_t lightpoint;
    qboolean hit;

    if (!cl.worldmodel->lightdata)
	return 255;

    hit = R_LightSurfPoint(point, &lightpoint);
    if (!hit)
        return 0;

    const msurface_t *surf = lightpoint.surf;
    const int surfwidth = (surf->extents[0] >> 4) + 1;
    const int surfheight = (surf->extents[1] >> 4) + 1;
    const int ds = qmin((int)floorf(lightpoint.s), surfwidth - 2);
    const int dt = qmin((int)floorf(lightpoint.t), surfheight - 2);
    const int surfbytes = surfwidth * surfheight;
    const byte *row0 = surf->samples + (dt * surfwidth + ds);
    const byte *row1 = row0 + surfwidth;
    float samples[2][2];

    /* Calculate a 2x2 sample, adding the light styles together */
    memset(samples, 0, sizeof(samples));

    int maps;
    foreach_surf_lightstyle(surf, maps) {
        const float scale = d_lightstylevalue[surf->styles[maps]] * (1.0f / 256.0f);
        samples[0][0] += row0[0] * scale;
        samples[0][1] += row0[1] * scale;
        samples[1][0] += row1[0] * scale;
        samples[1][1] += row1[1] * scale;
        row0 += surfbytes;
        row1 += surfbytes;
    }

    /* Interpolate within the 2x2 sample */
    const float dsfrac = lightpoint.s - ds;
    const float dtfrac = lightpoint.t - dt;
    float weight00 = (1.0f - dsfrac) * (1.0f - dtfrac);
    float weight01 = dsfrac * (1.0f - dtfrac);
    float weight10 = (1.0f - dsfrac) * dtfrac;
    float weight11 = dsfrac * dtfrac;

    return floorf(samples[0][0] * weight00 +
                  samples[0][1] * weight01 +
                  samples[1][0] * weight10 +
                  samples[1][1] * weight11);
}

/*
=============
R_DrawEntitiesOnList
=============
*/
static void
R_DrawEntitiesOnList(void)
{
    int i;
    entity_t *entity;

    if (!r_drawentities.value)
	return;

    for (i = 0; i < cl_numvisedicts; i++) {
	entity = cl_visedicts[i];
#ifdef NQ_HACK
	if (entity == &cl_entities[cl.viewentity])
	    continue;		// don't draw the player
#endif

        // Draw translucent entities separately
        if (entity->alpha != ENTALPHA_DEFAULT && entity->alpha != ENTALPHA_ONE)
            continue;

	switch (entity->model->type) {
	case mod_sprite:
	    VectorCopy(entity->origin, r_entorigin);
	    VectorSubtract(r_origin, r_entorigin, modelorg);
	    R_DrawSprite(entity);
	    break;

        case mod_alias:
            /*
             * Allow drawing function to set up r_entorigin and
             * modelorg internally, to properly account for lerping
             */
            R_AliasDrawModel(entity);
	    break;

	default:
	    break;
	}
    }
}

/*
=============
R_DrawEntitiesOnList_Translucent
=============
*/
static void
R_DrawEntitiesOnList_Translucent(void)
{
    int i;
    entity_t *entity;

    if (!r_drawentities.value)
	return;

    for (i = 0; i < cl_numvisedicts; i++) {
	entity = cl_visedicts[i];
#ifdef NQ_HACK
	if (entity == &cl_entities[cl.viewentity])
	    continue;		// don't draw the player
#endif

        // Draw translucent entities only
        if (entity->alpha == ENTALPHA_DEFAULT || entity->alpha == ENTALPHA_ONE)
            continue;

	switch (entity->model->type) {
	case mod_sprite:
	    VectorCopy(entity->origin, r_entorigin);
	    VectorSubtract(r_origin, r_entorigin, modelorg);
	    R_DrawSprite(entity);
	    break;

        case mod_alias:
            /*
             * Allow drawing function to set up r_entorigin and
             * modelorg internally, to properly account for lerping
             */
            R_AliasDrawModel(entity);
	    break;

	default:
	    break;
	}
    }
}

/*
=============
R_DrawViewModel
=============
*/
static void
R_DrawViewModel(void)
{
    entity_t *entity = &cl.viewent;

#ifdef NQ_HACK
    if (!r_drawviewmodel.value)
	return;
#endif
#ifdef QW_HACK
    if (!r_drawviewmodel.value || !Cam_DrawViewModel())
	return;
#endif

    if (cl.stats[STAT_HEALTH] <= 0)
	return;
    if (!entity->model)
	return;

    entity->alpha = (cl.stats[STAT_ITEMS] & IT_INVISIBILITY) ? 64 : 255;
    if (r_drawviewmodel.value < 1.0f)
        entity->alpha = qclamp((int)(((float)entity->alpha * r_drawviewmodel.value) + 0.5f), 0, 255);
    if (entity->alpha < 1)
        return;

    /* If FOV is above 90, just draw the model with a 90 degree FOV */
    if (scr_fov.value > 90) {
        SCR_CalcFOV(&r_refdef, 90);
        vrect_t rect = { 0, 0, vid.width, vid.height };
        R_ViewChanged(&rect, sb_lines_hidden, vid.aspect);
    }

    R_AliasDrawModel(entity);

    if (scr_fov.value > 90.0f) {
        SCR_CalcFOV(&r_refdef, scr_fov.value);
        vrect_t rect = { 0, 0, vid.width, vid.height };
        R_ViewChanged(&rect, sb_lines_hidden, vid.aspect);
    }
}


/*
=============
R_ModelCheckBBox
=============
*/
static int
R_ModelCheckBBox(const entity_t *e, model_t *model, const vec3_t mins, const vec3_t maxs)
{
    int i, side, clipflags;
    vec_t dist;

    clipflags = 0;

    if (e->angles[0] || e->angles[1] || e->angles[2]) {
	for (i = 0; i < 4; i++) {
	    dist = DotProduct(e->origin, view_clipplanes[i].plane.normal);
	    dist -= view_clipplanes[i].plane.dist;

	    if (dist <= -model->radius)
		return BMODEL_FULLY_CLIPPED;

	    if (dist <= model->radius)
		clipflags |= (1 << i);
	}
    } else {
	for (i = 0; i < 4; i++) {
	    side = BoxOnPlaneSide(mins, maxs, &view_clipplanes[i].plane);
	    if (side == PSIDE_BACK)
		return BMODEL_FULLY_CLIPPED;
	    if (side == PSIDE_BOTH)
		clipflags |= (1 << i);
	}
    }

    return clipflags;
}


/*
=============
R_DrawBEntitiesOnList
=============
*/
static void
R_DrawBEntitiesOnList(void)
{
    entity_t *entity;
    int i, j, clipflags;
    vec3_t oldorigin;
    model_t *model;
    brushmodel_t *brushmodel;
    vec3_t mins, maxs;

    if (!r_drawentities.value)
	return;

    VectorCopy(modelorg, oldorigin);
    r_dlightframecount = r_framecount;

    for (i = 0; i < cl_numvisedicts; i++) {
	entity = cl_visedicts[i];
	model = entity->model;
	if (model->type != mod_brush)
	    continue;

	brushmodel = BrushModel(model);

	// see if the bounding box lets us trivially reject, also sets
	// trivial accept status
	VectorAdd(entity->origin, model->mins, mins);
	VectorAdd(entity->origin, model->maxs, maxs);
	clipflags = R_ModelCheckBBox(entity, model, mins, maxs);
	if (clipflags == BMODEL_FULLY_CLIPPED)
            continue;

	// FIXME: stop transforming twice
	VectorCopy(entity->origin, r_entorigin);
	VectorSubtract(r_origin, r_entorigin, modelorg);
	R_RotateBmodel(entity);

	// calculate dynamic lighting for bmodel if it's not an
	// instanced model
        mnode_t *headnode = brushmodel->nodes + brushmodel->hulls[0].firstclipnode;
	if (brushmodel->firstmodelsurface != 0) {
	    for (j = 0; j < MAX_DLIGHTS; j++) {
		if ((cl_dlights[j].die < cl.time) || (!cl_dlights[j].radius))
		    continue;
		R_MarkLights(&cl_dlights[j], 1 << j, headnode);
	    }
	}

	r_pefragtopnode = NULL;
	VectorCopy(mins, r_emins);
	VectorCopy(maxs, r_emaxs);
	R_SplitEntityOnNode2(cl.worldmodel->nodes);
	R_CullSubmodelSurfaces(brushmodel, modelorg, clipflags);

	if (r_pefragtopnode) {
	    entity->topnode = r_pefragtopnode;

	    if (r_pefragtopnode->contents >= 0) {
		// not a leaf; has to be clipped to the world BSP
		R_DrawSolidClippedSubmodelPolygons(entity);
	    } else {
		// falls entirely in one leaf, so we just put all
		// the edges in the edge list and let 1/z sorting
		// handle drawing order
		R_DrawSubmodelPolygons(entity, clipflags);
	    }
	    entity->topnode = NULL;
	}

	// put back world rotation and frustum clipping
	// FIXME: R_RotateBmodel should just work off base_vxx
	VectorCopy(base_vpn, vpn);
	VectorCopy(base_vup, vup);
	VectorCopy(base_vright, vright);
	VectorCopy(base_modelorg, modelorg);
	VectorCopy(oldorigin, modelorg);
	R_TransformFrustum();
    }
}


/*
================
R_EdgeDrawing
================
*/
static void
R_EdgeDrawingPrepare()
{
    R_BeginEdgeFrame();

    if (r_dspeeds.value) {
	rw_time1 = Sys_DoubleTime();
    }

    R_RenderWorld();

    // Once the world is done, mark where the bmodel surfs will be starting
    bmodel_surfaces = surface_p;

    // only the world can be drawn back to front with no z reads or compares,
    // just z writes, so have the driver turn z compares on now
    D_TurnZOn();

    if (r_dspeeds.value) {
	rw_time2 = Sys_DoubleTime();
	db_time1 = rw_time2;
    }

    R_DrawBEntitiesOnList();

    if (r_dspeeds.value) {
	db_time2 = Sys_DoubleTime();
	se_time1 = db_time2;
    }

    if (!r_dspeeds.value) {
	VID_UnlockBuffer();
	S_ExtraUpdate();	// don't let sound get messed up if going slow
	VID_LockBuffer();
    }
}


/*
================
R_RenderView

r_refdef must be set before the first call
================
*/
__attribute__((noinline))
static void
R_RenderView_(void)
{
    scanflags_t scanflags;
    int numsavesurfs, numsaveedges;
    qboolean realloc, nostack;

    if (r_timegraph.value || r_speeds.value || r_dspeeds.value)
	r_time1 = Sys_DoubleTime();

    R_SetupFrame();
    R_MarkSurfaces();		// done here so we know if we're in water
    R_CullSurfaces(BrushModel(r_worldentity.model), r_refdef.vieworg);

    // make FDIV fast. This reduces timing precision after we've been running
    // for a while, so we don't do it globally.  This also sets chop mode, and
    // we do it here so that setup stuff like the refresh area calculations
    // match what's done in screen.c
    Sys_LowFPPrecision();

    if (!r_worldentity.model || !cl.worldmodel)
	Sys_Error("%s: NULL worldmodel", __func__);

    if (!r_dspeeds.value) {
	VID_UnlockBuffer();
	S_ExtraUpdate();	// don't let sound get messed up if going slow
	VID_LockBuffer();
    }

    /*
     * If we have to retry with more resources, we can't use the
     * stack again on the second and subsequent passes. May be
     * possible to go back to stack based next frame if we're still
     * below MAX_STACK_*
     */
    nostack = false;

 moar_surfedges:
    // If we ran out of surfs/edges previously, bump the limits
    realloc = false;
    if (r_edges_overflow) {
        if (r_numedges < MAX_EDGES_INCREMENT)
            r_numedges *= 2;
        else
            r_numedges += MAX_EDGES_INCREMENT;

        Con_DPrintf("edge limit bumped to %d\n", r_numedges);
        r_edges_overflow = false;
        realloc = true;
    }
    if (r_surfaces_overflow) {
        if (r_numsurfaces < MAX_SURFACES_INCREMENT)
            r_numsurfaces *= 2;
        else
            r_numsurfaces += MAX_SURFACES_INCREMENT;

        Con_DPrintf("surface limit bumped to %d\n", r_numsurfaces);
        r_surfaces_overflow = false;
        realloc = true;
    }

    // Redo hunk allocations it needed...
    if (realloc) {
        Hunk_FreeToHighMark(r_maphighhunkmark);
        R_AllocSurfEdges(nostack);
    }

    /* If we can fit edges/surfs on the stack, allocate them now */
    if (auxedges) {
        r_edges = auxedges;
    } else {
        edge_t *stackedges = alloca(CACHE_PAD_ARRAY(r_numedges, edge_t) * sizeof(edge_t));
        r_edges = CACHE_ALIGN_PTR(stackedges);
    }
    if (auxsurfaces) {
        surfaces = auxsurfaces - 1;
    } else {
        surf_t *stacksurfs = alloca(CACHE_PAD_ARRAY(r_numsurfaces, surf_t) * sizeof(surf_t));
        surfaces = CACHE_ALIGN_PTR(stacksurfs);
        surf_max = &surfaces[r_numsurfaces];
	// surface 0 doesn't really exist; it's just a dummy because index 0
	// is used to indicate no edge attached to surface
        surfaces--;
        R_PatchEdgeSortingCode();
    }

    R_EdgeDrawingPrepare();

    if (r_edges_overflow || r_surfaces_overflow) {
        nostack = true;
        goto moar_surfedges;
    }

    /* Save a copy of the sorted surfs/edges for special surface passes */
    numsavesurfs = surface_p - (surfaces + 1);
    memcpy(savesurfs, surfaces + 1, numsavesurfs * sizeof(*surfaces));
    numsaveedges = edge_p - r_edges;
    memcpy(saveedges, r_edges, numsaveedges * sizeof(*r_edges));

    /* Draw the world (zero flags) and collect scanline flags for special surfaces */
    memset(&scanflags, 0, sizeof(scanflags));
    R_ScanEdges(0, &scanflags);

    /* Now draw fence(mask) surfaces over the top */
    if (scanflags.found & SURF_DRAWFENCE) {
        memcpy(surfaces + 1, savesurfs, numsavesurfs * sizeof(*surfaces));
        memcpy(r_edges, saveedges, numsaveedges * sizeof(*r_edges));
        R_ScanEdges(SURF_DRAWFENCE, &scanflags);
    }

    if (!r_dspeeds.value) {
	VID_UnlockBuffer();
	S_ExtraUpdate();	// don't let sound get messed up if going slow
	VID_LockBuffer();
    }

    if (r_dspeeds.value) {
	se_time2 = Sys_DoubleTime();
	de_time1 = se_time2;
    }

    R_DrawEntitiesOnList();

    if (r_dspeeds.value) {
	de_time2 = Sys_DoubleTime();
	dv_time1 = de_time2;
    }

    R_DrawViewModel();

    if (r_dspeeds.value) {
	dv_time2 = Sys_DoubleTime();
	dp_time1 = Sys_DoubleTime();
    }

    R_DrawParticles();

    /* Now translucent brush models */
    if (scanflags.found & (r_surfalpha_flags | SURF_DRAWENTALPHA)) {
        memcpy(surfaces + 1, savesurfs, numsavesurfs * sizeof(*surfaces));
        memcpy(r_edges, saveedges, numsaveedges * sizeof(*r_edges));
        VectorCopy(r_origin, modelorg);
        R_ScanEdges(r_surfalpha_flags | SURF_DRAWENTALPHA, &scanflags);
    }

    /* Now translucent aliasmodels/sprites */
    R_DrawEntitiesOnList_Translucent();

    if (r_dspeeds.value)
	dp_time2 = Sys_DoubleTime();

    if (r_dowarp)
	D_WarpScreen();

    V_SetContentsColor(r_viewleaf->contents);

    if (r_timegraph.value)
	R_TimeGraph();

#ifdef QW_HACK
    if (r_netgraph.value)
	R_NetGraph();

    if (r_zgraph.value)
	R_ZGraph();
#endif

    if (r_aliasstats.value)
	R_PrintAliasStats();

    if (r_speeds.value)
	R_PrintTimes();

    if (r_dspeeds.value)
	R_PrintDSpeeds();

    // back to high floating-point precision
    Sys_HighFPPrecision();
}

void
R_RenderView(void)
{
    int dummy;

    if (Hunk_LowMark() & 3)
	Sys_Error("Hunk is missaligned");

    if ((intptr_t)(&dummy) & 3)
	Sys_Error("Stack is missaligned");

    if ((intptr_t)(&r_warpbuffer) & 3)
	Sys_Error("Globals are missaligned");

    R_RenderView_();
}
