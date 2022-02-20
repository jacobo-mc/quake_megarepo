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

#ifndef MODEL_H
#define MODEL_H

#include <assert.h>
#include <stdlib.h>
#include <string.h>

/* Use the GCC builtin ffsl function */
#ifndef ffsl
#define ffsl __builtin_ffsl
#endif

#ifdef GLQUAKE
#ifdef APPLE_OPENGL
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif
#endif

#include "bspfile.h"
#include "modelgen.h"
#include "spritegn.h"
#include "zone.h"

#ifdef NQ_HACK
#include "quakedef.h"
#endif
#ifdef QW_HACK
#include "bothdefs.h"
#endif

#ifdef GLQUAKE
/* Embed in struct for stricter type checking of texture id usage */
typedef struct texture_id { uint32_t id; } texture_id_t;
#define invalid_texture_id ((texture_id_t){0})
static inline qboolean TextureIsValid(texture_id_t texture) { return texture.id != 0; }
static inline qboolean TexturesAreSame(texture_id_t t1, texture_id_t t2) { return t1.id == t2.id; }
#endif

typedef enum {
    depthchain_head,
    depthchain_alias,
    depthchain_sprite,
    depthchain_bmodel_static,
    depthchain_bmodel_transformed,
    depthchain_bmodel_instanced,
} depthchain_type_t;

struct entity_s;
typedef struct depthchain_s {
    int key;                 // depth base key for sorting (depth value squared)
    depthchain_type_t type;  // different entry types that require different rendering calls
    byte alpha;              // alpha value for the surface
    struct entity_s *entity; // pointer back to the entity for surface transform
    struct depthchain_s *prev, *next; // TODO: this can probably be a singley linked list?
} depthchain_t;

/*

d*_t structures are on-disk representations
m*_t structures are in-memory

*/

// entity effects
#define ENT_EF_BRIGHTFIELD (1 << 0)
#define ENT_EF_MUZZLEFLASH (1 << 1)
#define ENT_EF_BRIGHTLIGHT (1 << 2)
#define ENT_EF_DIMLIGHT    (1 << 3)
#define ENT_EF_FLAG1       (1 << 4)
#define ENT_EF_FLAG2       (1 << 5)
#define ENT_EF_BLUE        (1 << 6)
#define ENT_EF_RED         (1 << 7)

/*
==============================================================================

BRUSH MODELS

==============================================================================
*/


//
// in memory representation
//
// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct {
    vec3_t position;
} mvertex_t;

typedef struct texture_s {
    unsigned texturenum;
    unsigned width, height;
#ifdef GLQUAKE
    int mark;
    texture_id_t gl_texturenum;
    union {
        texture_id_t gl_texturenum_alpha;      // for sky texture
        texture_id_t gl_texturenum_fullbright; // mask texture for fullbrights
        struct {
            texture_id_t gl_warpimage;
            int gl_warpimagesize;
        };
    };
#endif
    // Texture frames animate a 5 frames-per-second
    // So, a frame 'tick' is 0.2 seconds
    int anim_total;		        // total ticks in sequence (0 = no animation)
    int anim_min, anim_max;	        // ticks for this frame min <= tick < max
    struct texture_s *anim_next;        // next frame in the animation sequence
    struct texture_s *alternate_anims;  // bmodels in frame 1 use these
    unsigned offsets[MIPLEVELS];        // four mip maps stored
    char name[16];
} texture_t;

// If these SURF_* flags change, update in asm_draw.h also
#define SURF_PLANEBACK          (1 <<  1)
#define SURF_DRAWSKY            (1 <<  2)
#define SURF_DRAWSPRITE         (1 <<  3)
#define SURF_DRAWTURB           (1 <<  4)
#define SURF_DRAWTILED          (1 <<  5)
#define SURF_DRAWBACKGROUND     (1 <<  6)
#define SURF_DRAWFENCE          (1 <<  7)

/* Flag different types for independent alpha values */
#define SURF_DRAWWATER          (1 <<  8)
#define SURF_DRAWSLIME          (1 <<  9)
#define SURF_DRAWLAVA           (1 << 10)
#define SURF_DRAWTELE           (1 << 11)
#define SURF_DRAWENTALPHA       (1 << 12)

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct {
    unsigned int v[2];
    unsigned int cachededgeoffset;
} medge_t;

typedef struct {
    float vecs[2][4];
    float mipadjust;
    texture_t *texture;
    int flags;
} mtexinfo_t;

#ifdef GLQUAKE
#define	VERTEXSIZE	7
typedef struct glpoly_s {
    int numverts;
    float verts[0][VERTEXSIZE];	// variable sized (xyz s1t1 s2t2)
} glpoly_t;
#endif

typedef struct msurface_s {
    int visframe;	// should be drawn when node is crossed
    int clipflags;	// flags for clipping against frustum
    vec3_t mins;	// bounding box for frustum culling
    vec3_t maxs;

    mplane_t *plane;
    int flags;

    int firstedge;	// look up in model->surfedges[], negative numbers
    int numedges;	// are backwards edges

#ifdef GLQUAKE
    // TODO: optimise data type sizes here
    int light_s;	// gl lightmap coordinates
    int light_t;
    int lightmapblock;
    int material;
    int buffer_offset;

    int cached_light[MAXLIGHTMAPS];	// values currently used in lightmap
    qboolean cached_dlight;     // true if dynamic light in cache

    struct msurface_s *chain;   // Material chain for drawing
    depthchain_t depthchain;    // Depth chain for translucent surface sorting
#else
// surface generation data
    struct surfcache_s *cachespots[MIPLEVELS];
#endif

    short texturemins[2];
    short extents[2];

    mtexinfo_t *texinfo;

// lighting info
    int dlightframe;
    unsigned dlightbits;

    byte styles[MAXLIGHTMAPS];
    byte *samples;		// [numstyles*surfsize]
} msurface_t;

void DepthChain_AddEntity(depthchain_t *head, struct entity_s *entity, depthchain_type_t type);
void DepthChain_Init(depthchain_t *head); // Init the empty depthchain

#ifdef GLQUAKE
static inline msurface_t *
DepthChain_Surf(depthchain_t *entry)
{
    return container_of(entry, msurface_t, depthchain);
}
void DepthChain_AddSurf(depthchain_t *head, struct entity_s *entity, msurface_t *surf, depthchain_type_t type);
#endif

/*
 * foreach_surf_lightstyle()
 *   Iterator for lightmaps on a surface
 *     msurface_t *s => the surface
 *     int n         => lightmap number
 */
#define foreach_surf_lightstyle(s, n) \
	for ((n) = 0; (n) < MAXLIGHTMAPS && (s)->styles[n] != 255; (n)++)

typedef struct mnode_s {
// common with leaf
    int contents;		// 0, to differentiate from leafs
    int visframe;		// node needs to be traversed if current
    int clipflags;		// frustum plane clip flags

    vec3_t mins;		// for bounding box culling
    vec3_t maxs;

    struct mnode_s *parent;

// node specific
    mplane_t *plane;
    struct mnode_s *children[2];

    unsigned int firstsurface;
    unsigned int numsurfaces;
} mnode_t;

/* forward decls; can't include render.h/glquake.h */
struct efrag_s;
struct entity_s;

typedef struct mleaf_s {
// common with node
    int contents;		// wil be a negative contents number
    int visframe;		// node needs to be traversed if current
    int clipflags;		// frustum plane clip flags

    vec3_t mins;		// for bounding box culling
    vec3_t maxs;

    struct mnode_s *parent;

// leaf specific
    byte *compressed_vis;
    struct efrag_s *efrags;

    msurface_t **firstmarksurface;
    int nummarksurfaces;
    int key;			// BSP sequence number for leaf's contents
    byte ambient_sound_level[NUM_AMBIENTS];
} mleaf_t;

// !!! if this is changed, it must be changed in asm_i386.h too !!!
typedef struct {
    const mclipnode_t *clipnodes;
    const mplane_t *planes;
    int firstclipnode;
    int lastclipnode;
    vec3_t clip_mins;
    vec3_t clip_maxs;
} hull_t;

/*
==============================================================================

SPRITE MODELS

==============================================================================
*/


// FIXME: shorten these?
typedef struct mspriteframe_s {
    int width;
    int height;
    float up, down, left, right;
    byte rdata[];	/* Renderer data, variable sized */
} mspriteframe_t;

/*
 * Renderer provides this function to specify the amount of space it needs for
 * a sprite frame with given pixel count
 */
int R_SpriteDataSize(int numpixels);

/*
 * Renderer provides this function to translate and store the raw sprite data
 * from the model file as needed.
 */
struct model_s;
void R_SpriteDataStore(const struct model_s *model, mspriteframe_t *frame, const char *modelname,
		       int framenum, byte *pixels);

typedef struct {
    int numframes;
    float *intervals;
    mspriteframe_t *frames[];	/* variable sized */
} mspritegroup_t;

typedef struct {
    spriteframetype_t type;
    union {
	mspriteframe_t *frame;
	mspritegroup_t *group;
    } frame;
} mspriteframedesc_t;

typedef struct {
    int type;
    int maxwidth;
    int maxheight;
    int numframes;
    float beamlength;		// remove?
    mspriteframedesc_t frames[];	/* variable sized */
} msprite_t;

/*
==============================================================================

ALIAS MODELS

Alias models are position independent, so the cache manager can move them.
==============================================================================
*/

typedef struct {
    int firstpose;
    int numposes;
    trivertx_t bboxmin;
    trivertx_t bboxmax;
    int frame;
    char name[16];
} maliasframedesc_t;

typedef struct {
    int firstframe;
    int numframes;
} maliasskindesc_t;

// !!! if this is changed, it must be changed in asm_draw.h too !!!
typedef struct mtriangle_s {
    int facesfront;
    int vertindex[3];
} mtriangle_t;

typedef struct {
    vec3_t scale;
    vec3_t scale_origin;
    int numskins;
    int skindesc;
    int skinintervals;
    int skindata;
    int skinwidth;
    int skinheight;
    int numverts;
    int numtris;
    int numframes;
    float size;
    int numposes;
    int poseintervals;
    int posedata;	// (numposes * numverts) trivertx_t
    maliasframedesc_t frames[];	// variable sized
} aliashdr_t;

#ifdef GLQUAKE

typedef struct {
    float s;
    float t;
} texcoord_t;

typedef struct {
    uint16_t texturewidth;   // Actual texture width after uploading
    uint16_t textureheight;  //  (may be scaled up to power-of-two boundary)
    int indices;             // Offset to indices for drawing
    int texcoords;           // Offset to texcoords
    int textures;            // Offset to GLuint texture handles
    int numtextures;         // Total number of textures (including skingroups)
    int lightnormalindex;    // Offset to lightnormalindex data
    union {
        GLuint all[3];
        struct {
            GLuint index;
            GLuint texcoord;
            GLuint vertex;
        };
    } buffers;
    aliashdr_t ahdr; // Must be last, alias model data follows directly.
} gl_aliashdr_t;

static inline gl_aliashdr_t *
GL_Aliashdr(aliashdr_t *h)
{
    return container_of(h, gl_aliashdr_t, ahdr);
}

#else

typedef struct {
    int stverts;
    int triangles;
    aliashdr_t ahdr;
} sw_aliashdr_t;

static inline sw_aliashdr_t *
SW_Aliashdr(aliashdr_t *h)
{
    return container_of(h, sw_aliashdr_t, ahdr);
}

#endif

#define	MAXALIASVERTS	2048
#define	MAXALIASFRAMES	512
#define	MAXALIASTRIS	4096

//===================================================================

//
// Whole model
//

typedef enum { mod_brush, mod_sprite, mod_alias } modtype_t;

#define MOD_EF_ROCKET   (1 << 0) // leave a trail
#define MOD_EF_GRENADE  (1 << 1) // leave a trail
#define MOD_EF_GIB      (1 << 2) // leave a trail
#define MOD_EF_ROTATE   (1 << 3) // rotate (bonus items)
#define MOD_EF_TRACER   (1 << 4) // green split trail
#define MOD_EF_ZOMGIB   (1 << 5) // small blood trail
#define MOD_EF_TRACER2  (1 << 6) // orange split trail + rotate
#define MOD_EF_TRACER3  (1 << 7) // purple trail

typedef struct model_s {
    char name[MAX_QPATH];
    struct model_s *next;

    modtype_t type;
    int numframes;
    synctype_t synctype;

    int flags;

//
// volume occupied by the model graphics
//
    vec3_t mins, maxs; // Unrotated bounding box
    float xy_radius;   // Bounding radius in the xy plane (zero pitch/roll)
    float radius;      // Bounding radius under arbitrary rotation

    depthchain_t depthchain;  // For depth sorting translucent sprite/alias models
//
// additional model data
//
    cache_user_t cache;		// only access through Mod_Extradata

} model_t;

/*
 * Brush (BSP) model
 */
typedef struct brushmodel_s {
    struct brushmodel_s *next;
    struct brushmodel_s *parent; // Submodels have the world as a parent model
    model_t model;

    int firstmodelsurface;
    int nummodelsurfaces;

    int numsubmodels;
    dmodel_t *submodels;

    int numplanes;
    mplane_t *planes;

    int numleafs;		// number of visible leafs, not counting 0
    mleaf_t *leafs;

    int numvertexes;
    mvertex_t *vertexes;

    int numedges;
    medge_t *edges;

    int numnodes;
    mnode_t *nodes;

    int numtexinfo;
    mtexinfo_t *texinfo;

    int numsurfaces;
    msurface_t *surfaces;

    int numsurfedges;
    int *surfedges;

    int numclipnodes;
    mclipnode_t *clipnodes;

    int nummarksurfaces;
    msurface_t **marksurfaces;

    hull_t hulls[MAX_MAP_HULLS];

    int numtextures;
    texture_t **textures;

#ifdef QW_HACK
    unsigned checksum;		// for world models only
    unsigned checksum2;		// for world models only
#endif

    byte *visdata;
    byte *lightdata;
    char *entities;
} brushmodel_t;

static inline const brushmodel_t *
ConstBrushModel(const model_t *model)
{
    assert(model && model->type == mod_brush);
    return const_container_of(model, brushmodel_t, model);
}

static inline brushmodel_t *
BrushModel(model_t *model)
{
    assert(model && model->type == mod_brush);
    return container_of(model, brushmodel_t, model);
}

/* Brush model loader structures */
typedef struct brush_loader {
    int (*Padding)(void);
    void (*LoadLighting)(brushmodel_t *brushmodel, dheader_t *header);
    void (*PostProcess)(brushmodel_t *brushmodel);

    // Number of bytes per sample in the loaded lightmap data
    int lightmap_sample_bytes;
} brush_loader_t;

/* Alias model loader structures */
typedef struct {
    mtriangle_t *triangles;
    stvert_t *stverts;
} alias_meshdata_t;

typedef struct {
    int numposes;
    const trivertx_t **verts;
} alias_posedata_t;

typedef struct {
    int numskins;
    byte **data;
} alias_skindata_t;

typedef struct alias_loader {
    int (*Padding)(void);
    void (*LoadSkinData)(model_t *, aliashdr_t *, const alias_skindata_t *);
    void (*LoadMeshData)(const model_t *, aliashdr_t *hdr,
			 const alias_meshdata_t *, const alias_posedata_t *);
    void (*CacheDestructor)(cache_user_t *);
} alias_loader_t;

//============================================================================

void Mod_AddCommands();
void Mod_Init(const alias_loader_t *alias_loader, const brush_loader_t *brush_loader);

void *Mod_AllocName(int size, const char *name); /* Internal helper */
#ifndef SERVERONLY
void Mod_InitAliasCache(void);
void Mod_ClearAlias(void);
model_t *Mod_NewAliasModel(void);
model_t *Mod_FindAliasName(const char *name);
const model_t *Mod_AliasCache(void);
const model_t *Mod_AliasOverflow(void);
#endif
void Mod_ClearAll(void);
model_t *Mod_ForName(const char *name, qboolean crash);
aliashdr_t *Mod_Extradata(model_t *model);	// handles caching
void Mod_TouchModel(const char *name);
void Mod_Print(void);

#ifdef GLQUAKE
void GL_LoadSpriteTextures(const model_t *model);
void Mod_ReloadTextures();
#endif

extern brushmodel_t *loaded_brushmodels;

/*
 * PVS/PHS information
 */
typedef unsigned long leafblock_t;
typedef struct {
    int numleafs;
    leafblock_t bits[]; /* Variable Sized */
} leafbits_t;

mleaf_t *Mod_PointInLeaf(const brushmodel_t *model, const vec3_t point);
const leafbits_t *Mod_LeafPVS(const brushmodel_t *model, const mleaf_t *leaf);
const leafbits_t *Mod_FatPVS(const brushmodel_t *model, const vec3_t point);

int __ERRORLONGSIZE(void); /* to generate an error at link time */
#define QBYTESHIFT(x) ((x) == 8 ? 6 : ((x) == 4 ? 5 : __ERRORLONGSIZE() ))
#define LEAFSHIFT QBYTESHIFT(sizeof(leafblock_t))
#define LEAFMASK  ((sizeof(leafblock_t) << 3) - 1UL)

static inline qboolean
Mod_TestLeafBit(const leafbits_t *bits, int leafnum)
{
    return !!(bits->bits[leafnum >> LEAFSHIFT] & (1UL << (leafnum & LEAFMASK)));
}

static inline size_t
Mod_LeafbitsSize(int numleafs)
{
    return offsetof(leafbits_t, bits[(numleafs + LEAFMASK) >> LEAFSHIFT]);
}

static inline int
Mod_NextLeafBit(const leafbits_t *leafbits, int leafnum, leafblock_t *check)
{
    int bit;

    if (!*check) {
	leafnum += (1 << LEAFSHIFT);
	leafnum &= ~LEAFMASK;
	if (leafnum < leafbits->numleafs)
	    *check = leafbits->bits[leafnum >> LEAFSHIFT];
	while (!*check) {
	    leafnum += (1 << LEAFSHIFT);
	    if (leafnum < leafbits->numleafs)
		*check = leafbits->bits[leafnum >> LEAFSHIFT];
	    else
		return leafbits->numleafs;
	}
    }

    bit = ffsl(*check) - 1;
    leafnum = (leafnum & ~LEAFMASK) + bit;
    *check &= ~(1UL << bit);

    return leafnum;
}

/*
 * Macro to iterate over just the ones in the leaf bit array
 */
#define foreach_leafbit(leafbits, leafnum, check) \
    for (	check = 0, leafnum = Mod_NextLeafBit(leafbits, -1, &check); \
		leafnum < leafbits->numleafs;				    \
		leafnum = Mod_NextLeafBit(leafbits, leafnum, &check) )

/* 'OR' the bits of src into dst */
void Mod_AddLeafBits(leafbits_t *dst, const leafbits_t *src);

#ifdef SERVERONLY
/* Slightly faster counting of sparse sets for QWSV */
int Mod_CountLeafBits(const leafbits_t *leafbits);
#endif

/* Helper to just copy out unprocessed data from the lump */
void *Mod_LoadBytes(brushmodel_t *brushmodel, dheader_t *header, int lumpnum);

void Mod_LoadAliasModel(const alias_loader_t *loader, model_t *model,
			void *buffer, size_t buffersize);
void Mod_LoadSpriteModel(model_t *model, const void *buffer);

const mspriteframe_t *Mod_GetSpriteFrame(const struct entity_s *entity,
					 const msprite_t *sprite, float time);

int Mod_FindInterval(const float *intervals, int numintervals, float time);

/*
 * Create a tiny hull structure for a given bounding box
 */
typedef struct {
    hull_t hull;
    mplane_t planes[6];
} boxhull_t;

void Mod_CreateBoxhull(const vec3_t mins, const vec3_t maxs,
		       boxhull_t *boxhull);


int Mod_HullPointContents(const hull_t *hull, int nodenum, const vec3_t point);


typedef struct {
    qboolean allsolid;		// if true, plane is not valid
    qboolean startsolid;	// if true, the initial point was in a solid area
    qboolean inopen, inwater;
    float fraction;		// time completed, 1.0 = didn't hit anything
    vec3_t endpos;		// final position
    mplane_t plane;		// surface normal at impact
} trace_t;

qboolean Mod_TraceHull(const hull_t *hull, int nodenum,
		       const vec3_t p1, const vec3_t p2,
		       trace_t *trace);

// TODO: move this somewhere more appropriate...
void QPal_CreateTranslucencyTable(byte transtable[65536], const byte palette[768], float alpha);

#endif /* MODEL_H */
