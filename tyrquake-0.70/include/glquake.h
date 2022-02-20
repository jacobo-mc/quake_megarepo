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

#ifndef GLQUAKE_H
#define GLQUAKE_H

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef APPLE_OPENGL
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#ifdef _WIN32
#include <GL/glext.h>
#endif

#include "client.h"
#include "model.h"
#include "gl_model.h"
#include "protocol.h"
#include "qpic.h"

#ifndef APIENTRY
#define APIENTRY
#endif

typedef union glmatrix {
    float m16[16];
    float m4x4[4][4];
    struct {
        float _11, _12, _13, _14;
        float _21, _22, _23, _24;
        float _31, _32, _33, _34;
        float _41, _42, _43, _44;
    };
} glmatrix_t;

void GL_CreateProjectionMatrix(glmatrix_t *matrix, float fov_x, float fov_y);
void GL_BeginRendering(int *x, int *y, int *width, int *height);
void GL_EndRendering(void);

/* Multitexture compatibilty for old GL headers */
#ifndef GL_VERSION_1_2
#define GL_TEXTURE0_ARB 0x84C0
#define GL_TEXTURE1_ARB 0x84C1
#define GL_TEXTURE2_ARB 0x84C2
#endif
#ifndef GL_VERSION_1_3
#define GL_MAX_TEXTURE_UNITS GL_MAX_TEXTURE_UNITS_ARB
#define GL_TEXTURE0 GL_TEXTURE0_ARB
#define GL_TEXTURE1 GL_TEXTURE1_ARB
#define GL_TEXTURE2 GL_TEXTURE2_ARB
#define GL_NUM_COMPRESSED_TEXTURE_FORMATS 0x86A2
#define GL_COMPRESSED_TEXTURE_FORMATS     0x86A3
#endif

#ifndef GL_EXT_texture_compression_s3tc
#define GL_EXT_texture_compression_s3tc 1
#define GL_COMPRESSED_RGB_S3TC_DXT1_EXT   0x83F0
#define GL_COMPRESSED_RGBA_S3TC_DXT1_EXT  0x83F1
#define GL_COMPRESSED_RGBA_S3TC_DXT3_EXT  0x83F2
#define GL_COMPRESSED_RGBA_S3TC_DXT5_EXT  0x83F3
#endif /* GL_EXT_texture_compression_s3tc */


#ifndef GL_EXT_texture_filter_anisotropic
#define GL_EXT_texture_filter_anisotropic 1
#define GL_TEXTURE_MAX_ANISOTROPY_EXT     0x84FE
#define GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT 0x84FF
#endif /* GL_EXT_texture_filter_anisotropic */

#ifndef GL_VERSION_4_6
#define GL_TEXTURE_MAX_ANISOTROPY     GL_TEXTURE_MAX_ANISOTROPY_EXT
#define GL_MAX_TEXTURE_MAX_ANISOTROPY GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT
#endif

extern float gldepthmin, gldepthmax;

#define gl_solid_format GL_RGB
#define gl_alpha_format GL_RGBA
#define gl_lightmap_format GL_RGBA
#define gl_lightmap_bytes 4

typedef struct {
    texture_id_t base;            // The base texture
    texture_id_t fullbright;      // Fullbright mask texture, or zero if none
} qgltexture_t;

typedef struct {
    qboolean is_scrap;
    union {
        texture_id_t texture;
        int scrapnum;
    };
    float sl, tl, sh, th;
    qpic8_t pic;
} glpic_t;

void GL_FreeTextures();

void GL_Upload8(texture_id_t texture, qpic8_t *pic);
void GL_Upload8_Alpha(texture_id_t texture, qpic8_t *pic, byte alpha);
void GL_Upload32(texture_id_t texture, qpic32_t *pic);
void GL_Upload8_Translate(texture_id_t texture, qpic8_t *pic, const byte *translation);

texture_id_t GL_LoadTexture8(const model_t *owner, const char *name, qpic8_t *pic, enum texture_type type);
texture_id_t GL_LoadTexture8_Alpha(const model_t *owner, const char *name, qpic8_t *pic, enum texture_type type, byte alpha);
texture_id_t GL_LoadTexture8_GLPic(const model_t *owner, const char *name, glpic_t *glpic);
texture_id_t GL_AllocTexture8(const model_t *owner, const char *name, const qpic8_t *pic, enum texture_type type);
texture_id_t GL_AllocTexture32(const model_t *owner, const char *name, const qpic32_t *pic, enum texture_type type);
void GL_SelectTMU(GLenum);

void GL_DisownTextures(const model_t *owner);

extern int glx, gly, glwidth, glheight;

// r_local.h -- private refresh defs

#define ALIAS_BASE_SIZE_RATIO	(1.0 / 11.0)
				// normalizing factor so player model works
				// out to about 1 pixel per triangle
#define	MAX_LBM_HEIGHT	480

#define SKYSHIFT	7
#define	SKYSIZE		(1 << SKYSHIFT)
#define SKYMASK		(SKYSIZE - 1)

#define BACKFACE_EPSILON	0.01

/* There isn't really a limit on the width/height of the video buffer under OpenGL */
#define MAXWIDTH 100000
#define MAXHEIGHT 100000
#define MINWIDTH 320
#define MINHEIGHT 200

/*
 * Water warping paramters - not actually used in GLQuake, but they
 * are filled out in the global vid struct
 */
#define WARP_WIDTH 320
#define WARP_HEIGHT 200
#define WARP_IMAGE_SIZE 128
#define WARP_RENDER_TEXTURE_SIZE 512

void R_TimeRefresh_f(void);
void R_ReadPointFile_f(void);

typedef enum {
    pt_static, pt_grav, pt_slowgrav, pt_fire, pt_explode, pt_explode2,
    pt_blob, pt_blob2
} ptype_t;

// !!! if this is changed, it must be changed in d_ifacea.h too !!!
typedef struct particle_s {
// driver-usable fields
    vec3_t org;
    float color;
// drivers never touch the following fields
    struct particle_s *next;
    vec3_t vel;
    float ramp;
    float die;
    ptype_t type;
} particle_t;


//====================================================


extern entity_t r_worldentity;
extern qboolean r_cache_thrash;	// compatability
extern vec3_t r_entorigin;
extern int r_visframecount;	// ??? what difs?
extern int r_framecount;
extern int c_brush_polys;
extern int c_lightmaps_uploaded;
extern int gl_draw_calls;
extern int gl_verts_submitted;
extern int gl_indices_submitted;
extern int gl_full_buffers;

//
// view origin
//
extern vec3_t vup;
extern vec3_t vpn;
extern vec3_t vright;
extern vec3_t r_origin;

//
// screen size info
//
extern refdef_t r_refdef;
extern mleaf_t *r_viewleaf, *r_oldviewleaf;
extern texture_t *r_notexture_mip;
extern int d_lightstylevalue[256];	// 8.8 fraction of base light value

extern qboolean envmap;
extern texture_id_t particletexture;
extern texture_id_t charset_texture;

/*
 * We'll be keeping the skin textures around for now, so flag whether
 * the fullbright texture applies to the currently active skin or not
 */
typedef struct {
    qgltexture_t texture;
    qboolean fullbright;
} playertexture_t;
extern playertexture_t playertextures[MAX_CLIENTS];

extern cvar_t r_norefresh;
extern cvar_t r_drawentities;
extern cvar_t r_drawworld;
extern cvar_t r_drawviewmodel;
extern cvar_t r_speeds;
extern cvar_t r_waterwarp;
extern cvar_t r_fullbright;
extern cvar_t r_lightmap;
extern cvar_t r_mirroralpha;

extern cvar_t r_dynamic;
extern cvar_t r_novis;

extern cvar_t gl_poly;
extern cvar_t gl_texsort;
extern cvar_t gl_smoothmodels;
extern cvar_t gl_affinemodels;
extern cvar_t gl_polyblend;
extern cvar_t gl_keeptjunctions;
extern cvar_t gl_reporttjunctions;
extern cvar_t gl_nocolors;
extern cvar_t gl_zfix;
extern cvar_t gl_finish;
extern cvar_t gl_fullbrights;
extern cvar_t gl_farclip;
extern cvar_t gl_picmip;
extern cvar_t gl_overbright;
extern cvar_t gl_overbright_models;
void GL_Overbright_f(cvar_t *cvar);

extern cvar_t _gl_allowgammafallback;
extern cvar_t _gl_drawhull;

#ifdef NQ_HACK
extern cvar_t gl_doubleeyes;
#endif

#ifdef QW_HACK
extern cvar_t r_netgraph;
void R_NetGraph(void);
void R_ResetNetGraphTexture(void);
#endif

extern int gl_num_texture_units;

extern int mirrortexturenum;	// quake texturenum, not gltexturenum
extern qboolean mirror;
extern mplane_t *mirror_plane;

extern float r_world_matrix[16];

void GL_Init();
void GL_Shutdown();
void GL_ReloadTextures();

void GL_Textures_AddCommands();
void GL_Textures_RegisterVariables();
void GL_Textures_Init();

void GL_FrameMemoryStats();

void R_TranslatePlayerSkin(int playernum);
void GL_Bind(texture_id_t texture_id);

/*
 * ARB multitexture function pointers
 *  glClientActiveTexture is supposed to be part of OpenGL 1.1 but it
 *  isn't in the Windows OpenGL 1.1 lib for linking, so we need to
 *  load that dynamically.
 */
typedef void (APIENTRY *lpMultiTexFUNC) (GLenum, GLfloat, GLfloat);
typedef void (APIENTRY *lpActiveTextureFUNC) (GLenum);
typedef void (APIENTRY *lpClientStateFUNC) (GLenum);
typedef void (APIENTRY *lpGenerateMipmapFUNC) (GLenum);
typedef void (APIENTRY *lpBooleanFUNC) (GLboolean);

extern lpActiveTextureFUNC qglActiveTextureARB;
extern lpClientStateFUNC qglClientActiveTexture;
extern lpGenerateMipmapFUNC qglGenerateMipmap;
extern void (*qglTexParameterGenerateMipmap)(GLboolean auto_mipmap);
extern void (APIENTRY *qglDrawRangeElements)(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices);

/* Texture Compression */
extern void (APIENTRY *qglCompressedTexImage2D)(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data);

/* Buffer Objects */
extern void (APIENTRY *qglBindBuffer)(GLenum target, GLuint buffer);
extern void (APIENTRY *qglDeleteBuffers)(GLsizei n, const GLuint *buffers);
extern void (APIENTRY *qglGenBuffers)(GLsizei n, GLuint *buffers);
extern void (APIENTRY *qglBufferData)(GLenum target, GLsizeiptr size, const void *data, GLenum usage);
extern void (APIENTRY *qglBufferSubData)(GLenum target, GLintptr offset, GLsizeiptr size, const void *data);
extern void *(APIENTRY *qglMapBuffer)(GLenum target, GLenum access);
extern GLboolean (APIENTRY *qglUnmapBuffer)(GLenum target);
extern GLboolean (APIENTRY *qglIsBuffer)(GLuint buffer);

/* Vertex Programs */
extern void (APIENTRY *qglProgramString)(GLenum target, GLenum format, GLsizei len, const void *string);
extern void (APIENTRY *qglBindProgram)(GLenum target, GLuint program);
extern void (APIENTRY *qglDeletePrograms)(GLsizei n, const GLuint *programs);
extern void (APIENTRY *qglGenPrograms)(GLsizei n, GLuint *programs);
extern void (APIENTRY *qglProgramEnvParameter4f)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
extern void (APIENTRY *qglProgramEnvParameter4fv)(GLenum target, GLuint index, const GLfloat *params);
extern void (APIENTRY *qglProgramLocalParameter4f)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
extern void (APIENTRY *qglProgramLocalParameter4fv)(GLenum target, GLuint index, const GLfloat *params);
extern void (APIENTRY *qglGetProgramiv)(GLenum target, GLenum pname, GLint *params);
extern void (APIENTRY *qglGetProgramString)(GLenum target, GLenum pname, void *string);
extern void (APIENTRY *qglEnableVertexAttribArray)(GLuint index);
extern void (APIENTRY *qglDisableVertexAttribArray)(GLuint index);
extern void (APIENTRY *qglVertexAttribPointer)(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer);
extern GLboolean (APIENTRY *qglIsProgram)(GLuint program);

/* TEMPORARY HACK */
struct vertex_programs {
    union {
        GLuint handles[3];
        struct {
            GLuint alias_lerp;
            GLuint alias_nolerp;
            GLuint warp;
        };
    };
};
struct fragment_programs {
    union {
        GLuint handles[2];
        struct {
            GLuint warp;
            GLuint warp_fog;
        };
    };
};

extern const char warp_vp_text[];
extern const char warp_fp_text[];
extern const char warp_fog_fp_text[];
extern texture_id_t r_warp_lookup_table;

extern struct vertex_programs vp;
extern struct fragment_programs fp;
extern void GL_InitVertexPrograms();
extern void GL_InitFragmentPrograms();

extern qboolean gl_npotable;
extern qboolean gl_mtexable;
extern qboolean gl_texture_env_combine;
extern qboolean gl_buffer_objects_enabled;
extern qboolean gl_vertex_program_enabled;
extern qboolean gl_fragment_program_enabled;
extern qboolean gl_texture_compression_enabled;
extern qboolean gl_anisotropy_enabled;

extern float gl_anisotropy_max;

qboolean GL_ExtensionCheck_String(const char *extension, const char *search);
qboolean GL_ExtensionCheck(const char *extension);
void GL_ParseVersionString(const char *version);
void *GL_GetProcAddress(const char *name);
void GL_ExtensionCheck_NPoT(void);
void GL_ExtensionCheck_MultiTexture(void);
void GL_ExtensionCheck_Combine(void);
void GL_ExtensionCheck_GenerateMipmaps();
void GL_ExtensionCheck_BufferObjects();
void GL_ExtensionCheck_VertexProgram();
void GL_ExtensionCheck_FragmentProgram();
void GL_ExtensionCheck_RangeElements();
void GL_ExtensionCheck_TextureCompression();
void GL_ExtensionCheck_Anisotropy();
void GL_ExtensionCheck_FramebufferObject();
void GL_DisableMultitexture(void);
void GL_EnableMultitexture(void);

//
// gl_warp.c
//
extern cvar_t r_warpspeed;
extern cvar_t r_warpfactor;
extern cvar_t r_warpscale;
extern cvar_t r_waterquality;
void R_UpdateWarpTextures();
void GL_CreateWarpTableTexture();

//
// gl_draw.c
//
#define TRANSPARENT_COLOR 0xFF
void GL_Set2D(void);
void Draw_ReloadPicTextures();
void Draw_ResetPicTextures();

//
// gl_rmain.c
//
qboolean R_CullBox(const vec3_t mins, const vec3_t maxs);
void R_RotateForEntity(const vec3_t origin, const vec3_t angles);
void R_ResetPlayerTextures(void);

/*
 * The renderer supplies callbacks to the model loader
 */
const alias_loader_t *R_AliasModelLoader(void);
const brush_loader_t *R_BrushModelLoader(void);

//
// gl_rlight.c
//
void R_MarkLights(dlight_t *light, int bit, mnode_t *node);
void R_AnimateLight(void);

/*
 * Light Sampling
 */
typedef struct {
    const msurface_t *surf;
    float s;
    float t;
} surf_lightpoint_t;

qboolean R_LightSurfPoint(const vec3_t point, surf_lightpoint_t *lightpoint);

//
// gl_refrag.c
//
void R_StoreEfrags(efrag_t **ppefrag);

//
// gl_mesh.c
//
void GL_LoadAliasMeshData(const model_t *m, aliashdr_t *hdr,
			  const alias_meshdata_t *meshdata,
			  const alias_posedata_t *posedata);
void GL_LoadAliasSkinTextures(const model_t *model, aliashdr_t *aliashdr);
void GL_UploadAliasMeshData(aliashdr_t *hdr);

//
// gl_rmisc.c
//
void R_InitParticleTexture(void);
void GL_LoadNoTexture();

//
// gl_rsurf.c
//
void R_DrawDynamicBrushModel(entity_t *entity);
void R_PrepareWorldMaterialChains();
void R_DrawWorld(void);
void R_DrawWorldHull(void); /* Quick hack for now... */
void R_DrawTranslucentChain(entity_t *entity, materialchain_t *materialchain, float alpha);
void R_DrawInstancedTranslucentBmodel(entity_t *entity);
void GL_BuildLightmaps();
void GL_UploadLightmaps(const model_t *model, const glbrushmodel_resource_t *resources);

//
// gl_sky.c
//
extern cvar_t r_sky_quality;
extern cvar_t r_fastsky;
extern cvar_t r_skyalpha;
extern texture_t skytextures[6];
extern char map_skyboxname[256];
extern float map_skyfog;
extern vec3_t skyflatcolor;
void Sky_NewMap();
void Sky_AddCommands();
void Sky_RegisterVariables();
void Sky_InitBounds(float mins[6][2], float maxs[6][2]);
void Sky_AddPolyToSkyboxBounds(const vec7_t *verts, int numverts, float mins[6][2], float maxs[6][2]);
qboolean Sky_LoadSkyboxTextures(const char *skyboxname);

//
// tga.c
//
qpic32_t *TGA_LoadHunkFile(const char *filename, const char *hunkname);

//
// pcx.c
//
qpic32_t *PCX_LoadHunkFile(const char *filename, const char *hunkname);

//
// r_part.c
//
extern float r_avertexnormals[][3];

//
// gl_draw.c
//
void Draw_InitGLTextures(void);

//
// gl_fog.c
//
void Fog_AddCommands();
void Fog_RegisterVariables();
void Fog_Init();
void Fog_SetupGL();
void Fog_EnableGlobalFog();
void Fog_DisableGlobalFog();
void Fog_StartBlend();
void Fog_StopBlend();
void Fog_ParseServerMessage();
void Fog_NewMap();

const float *Fog_GetColor();
float Fog_GetDensity();

#endif /* GLQUAKE_H */
