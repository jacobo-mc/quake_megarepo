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

#ifndef R_LOCAL_H
#define R_LOCAL_H

// r_local.h -- private refresh defs

#ifdef GLQUAKE
#error "Shouldn't be including this file in GLQuake!"
#endif

#include "client.h"
#include "model.h"
#include "r_shared.h"

#define ALIAS_BASE_SIZE_RATIO	(1.0 / 11.0)
				// normalizing factor so player model works out
				// to about 1 pixel per triangle

#define BMODEL_FULLY_CLIPPED	(0x10)
				// value returned by R_BmodelCheckBBox ()
				// if bbox is trivially rejected

//===========================================================================
// clipped bmodel edges

typedef struct bedge_s {
    mvertex_t *v[2];
    struct bedge_s *pnext;
} bedge_t;

typedef struct {
    float fv[3];		// viewspace x, y
} auxvert_t;

//===========================================================================

extern cvar_t r_draworder;
extern cvar_t r_speeds;
extern cvar_t r_graphheight;
extern cvar_t r_clearcolor;
extern cvar_t r_waterwarp;
extern cvar_t r_fullbright;
extern cvar_t r_drawentities;
extern cvar_t r_drawflat;
extern cvar_t r_ambient;

#define XCENTERING	(1.0 / 2.0)
#define YCENTERING	(1.0 / 2.0)

#define CLIP_EPSILON		0.001

#define BACKFACE_EPSILON	0.01

//===========================================================================

#define	DIST_NOT_SET	98765

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct clipplane_s {
    mplane_t plane;
    struct clipplane_s *next;
    byte leftedge;
    byte rightedge;
    byte reserved[2];
} clipplane_t;

extern clipplane_t view_clipplanes[4];

//=============================================================================

void R_RenderWorld(void);

//=============================================================================

extern mplane_t screenedge[4];
extern vec3_t r_origin;
extern vec3_t r_entorigin;
extern int r_visframecount;

//=============================================================================

//
// current entity info
//

void R_DrawSprite(const entity_t *e);
void R_RenderFace(const entity_t *e, msurface_t *fa, int clipflags);
void R_RenderBmodelFace(const entity_t *e, bedge_t *pedges, msurface_t *psurf);
void R_TransformPlane(mplane_t *p, float *normal, float *dist);
void R_TransformFrustum(void);
void R_SetSkyFrame(void);
void R_DrawSurfaceBlock16(void);
void R_DrawSurfaceBlock8(void);

#ifdef USE_X86_ASM

void R_DrawSurfaceBlock8_mip0(void);
void R_DrawSurfaceBlock8_mip1(void);
void R_DrawSurfaceBlock8_mip2(void);
void R_DrawSurfaceBlock8_mip3(void);

#endif

void R_GenSkyTile(void *pdest);
void R_GenSkyTile16(void *pdest);
void R_Surf8Patch(void);
void R_Surf16Patch(void);
void R_DrawSubmodelPolygons(const entity_t *entity, int clipflags);
void R_DrawSolidClippedSubmodelPolygons(const entity_t *entity);

typedef struct {
    int found;
    int lines[MAXHEIGHT + 1];
} scanflags_t;

void R_ScanEdges(int drawflags, scanflags_t *scanflags);

void R_AddPolygonEdges(emitpoint_t *pverts, int numverts, int miplevel);
surf_t *R_GetSurf(void);
void R_AliasDrawModel(entity_t *e);
void R_BeginEdgeFrame(void);

#ifdef USE_X86_ASM
void R_InsertNewEdges(edge_t *edgestoadd, edge_t *edgelist);
void R_StepActiveU(edge_t *pedge);
void R_RemoveEdges(edge_t *pedge);
#endif

extern void R_Surf8Start(void);
extern void R_Surf8End(void);
extern void R_Surf16Start(void);
extern void R_Surf16End(void);
extern void R_EdgeCodeStart(void);
extern void R_EdgeCodeEnd(void);

extern void R_RotateBmodel(const entity_t *e);

extern int c_faceclip;
extern int r_polycount;

// !!! if this is changed, it must be changed in asm_draw.h too !!!
#define	NEAR_CLIP	0.01

extern int ubasestep, errorterm, erroradjustup, erroradjustdown;

extern fixed16_t sadjust, tadjust;
extern fixed16_t bbextents, bbextentt;

#define MAXBVERTINDEXES	1000	// new clipped vertices when clipping bmodels
				// to the world BSP
extern mvertex_t *r_ptverts, *r_ptvertsmax;

extern vec3_t sbaseaxis[3], tbaseaxis[3];

extern int r_currentkey;
extern int r_currentbkey;

//=========================================================
// Alias models
//=========================================================

#define MAXALIASVERTS		2048	// TODO: tune this
#define ALIAS_Z_CLIP_PLANE	5

extern int numverts;
extern int a_skinwidth;
extern int numtriangles;
extern float leftclip, topclip, rightclip, bottomclip;
extern int r_acliptype;
extern float r_avertexnormals[][3];

//=========================================================
// turbulence stuff

#define	TURB_SURF_AMP	8*0x10000
#define	TURB_SCREEN_AMP	3
#define	TURB_SPEED	20

//=========================================================
// particle stuff

void R_DrawParticles(void);
void R_InitParticles(void);
void R_ClearParticles(void);
void R_ReadPointFile_f(void);
void R_SurfacePatch(void);

extern int r_amodels_drawn;
extern edge_t *auxedges;
extern surf_t *auxsurfaces;
extern edge_t *saveedges;
extern surf_t *savesurfs;
extern edge_t *r_edges, *edge_p, *edge_max;

extern edge_t *newedges[MAXHEIGHT];
extern edge_t *removeedges[MAXHEIGHT];

extern int screenwidth;

// FIXME: make stack vars when debugging done
extern edge_t edge_head;
extern edge_t edge_tail;
extern edge_t edge_aftertail;
extern int r_bmodelactive;

extern float aliasxscale, aliasyscale, aliasxcenter, aliasycenter;
extern float r_aliastransition, r_resfudge;

extern qboolean r_surfaces_overflow;
extern qboolean r_edges_overflow;
extern int r_maxvalidedgeoffset;

void R_AliasClipTriangle(mtriangle_t *ptri, finalvert_t *pfinalverts, auxvert_t *pauxverts);
void R_AliasProjectFinalVert(finalvert_t *fv, auxvert_t *av);
void R_Alias_clip_top(const finalvert_t *pfv0, const finalvert_t *pfv1, finalvert_t *out);
void R_Alias_clip_bottom(const finalvert_t *pfv0, const finalvert_t *pfv1, finalvert_t *out);
void R_Alias_clip_left(const finalvert_t *pfv0, const finalvert_t *pfv1, finalvert_t *out);
void R_Alias_clip_right(const finalvert_t *pfv0, const finalvert_t *pfv1, finalvert_t *out);

extern float r_time1;
extern float dp_time1, dp_time2, db_time1, db_time2, rw_time1, rw_time2;
extern float se_time1, se_time2, de_time1, de_time2, dv_time1, dv_time2;
extern cshift_t cshift_water;
extern qboolean r_viewchanged;

extern mleaf_t *r_viewleaf, *r_oldviewleaf;

extern vec3_t r_emins, r_emaxs;
extern mnode_t *r_pefragtopnode;
extern int r_clipflags;
extern int r_dlightframecount;

void R_StoreEfrags(efrag_t **ppefrag);
void R_TimeRefresh_f(void);
void R_TimeGraph(void);
void R_PrintAliasStats(void);
void R_PrintTimes(void);
void R_PrintDSpeeds(void);
void R_AnimateLight(void);
void R_SetupFrame(void);
void R_cshift_f(void);
void R_EmitEdge(mvertex_t *pv0, mvertex_t *pv1);
void R_ClipEdge(mvertex_t *pv0, mvertex_t *pv1, clipplane_t *clip);
void R_SplitEntityOnNode2(mnode_t *node);
void R_MarkLights(dlight_t *light, int bit, mnode_t *node);

/*
 * Light Sampling
 */
typedef struct {
    const msurface_t *surf;
    float s;
    float t;
} surf_lightpoint_t;

qboolean R_LightSurfPoint(const vec3_t point, surf_lightpoint_t *lightpoint);
int R_LightPoint(const vec3_t point);

#endif /* R_LOCAL_H */
