#include "QF/mathlib.h"

extern void gl_overbright_f (struct cvar_s *cvar);

extern struct cvar_s     *cl_crossx;
extern struct cvar_s     *cl_crossy;
extern struct cvar_s     *cl_verstring;
extern struct cvar_s     *crosshair;
extern struct cvar_s     *crosshaircolor;
extern quat_t crosshair_color;

extern struct cvar_s     *d_mipcap;
extern struct cvar_s     *d_mipscale;

extern struct cvar_s     *gl_affinemodels;
extern struct cvar_s	 *gl_anisotropy;
extern struct cvar_s     *gl_clear;
extern struct cvar_s     *gl_conspin;
extern struct cvar_s     *gl_constretch;
extern struct cvar_s     *gl_dlight_polyblend;
extern struct cvar_s     *gl_dlight_smooth;
extern struct cvar_s     *gl_fb_bmodels;
extern struct cvar_s     *gl_fb_models;
extern struct cvar_s     *gl_finish;
extern struct cvar_s     *gl_keeptjunctions;
extern struct cvar_s     *gl_lerp_anim;
extern struct cvar_s     *gl_lightmap_align;
extern struct cvar_s     *gl_lightmap_subimage;
extern struct cvar_s     *gl_max_size;
extern struct cvar_s     *gl_multitexture;
extern struct cvar_s     *gl_nocolors;
extern struct cvar_s	 *gl_overbright;
extern struct cvar_s     *gl_particle_mip;
extern struct cvar_s     *gl_particle_size;
extern struct cvar_s     *gl_picmip;
extern struct cvar_s     *gl_playermip;
extern struct cvar_s     *gl_reporttjunctions;
extern struct cvar_s     *gl_sky_clip;
extern struct cvar_s     *gl_sky_debug;
extern struct cvar_s     *gl_sky_divide;
extern struct cvar_s     *gl_sky_multipass;
extern struct cvar_s	 *gl_tessellate;
extern struct cvar_s     *gl_texsort;
extern struct cvar_s	 *gl_textures_bgra;
extern struct cvar_s     *gl_triplebuffer;
extern struct cvar_s     *gl_vector_light;

extern struct cvar_s     *r_aliasstats;
extern struct cvar_s     *r_aliastransadj;
extern struct cvar_s     *r_aliastransbase;
extern struct cvar_s     *r_ambient;
extern struct cvar_s     *r_clearcolor;
extern struct cvar_s     *r_dlight_lightmap;
extern struct cvar_s     *r_drawentities;
extern struct cvar_s     *r_drawexplosions;
extern struct cvar_s     *r_drawflat;
extern struct cvar_s     *r_drawviewmodel;
extern struct cvar_s     *r_dspeeds;
extern struct cvar_s     *r_dynamic;
extern struct cvar_s	 *r_explosionclip;
extern struct cvar_s     *r_farclip;
extern struct cvar_s     *r_firecolor;
extern struct cvar_s     *r_flatlightstyles;
extern struct cvar_s     *r_fullbright;
extern struct cvar_s     *r_graphheight;
extern struct cvar_s     *r_lightmap;
extern struct cvar_s     *r_lightmap_components;
extern struct cvar_s     *r_maxedges;
extern struct cvar_s     *r_maxsurfs;
extern struct cvar_s     *r_mirroralpha;
extern struct cvar_s     *r_nearclip;
extern struct cvar_s     *r_norefresh;
extern struct cvar_s     *r_novis;
extern struct cvar_s     *r_numedges;
extern struct cvar_s     *r_numsurfs;
extern struct cvar_s     *r_particles;
extern struct cvar_s     *r_particles_max;
extern struct cvar_s     *r_particles_nearclip;
extern struct cvar_s     *r_reportedgeout;
extern struct cvar_s     *r_reportsurfout;
extern struct cvar_s     *r_shadows;
extern struct cvar_s     *r_skyname;
extern struct cvar_s     *r_speeds;
extern struct cvar_s     *r_timegraph;
extern struct cvar_s     *r_wateralpha;
extern struct cvar_s     *r_waterripple;
extern struct cvar_s     *r_waterwarp;
extern struct cvar_s     *r_zgraph;

extern struct cvar_s     *scr_consize;
extern struct cvar_s     *scr_conspeed;
extern struct cvar_s     *scr_fov;
extern struct cvar_s     *scr_fisheye;
extern struct cvar_s     *scr_fviews;
extern struct cvar_s     *scr_ffov;
extern struct cvar_s     *scr_showpause;
extern struct cvar_s     *scr_showram;
extern struct cvar_s     *scr_showturtle;
extern struct cvar_s     *scr_viewsize;
