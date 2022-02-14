!!ver 110
!!permu FOG
!!permu BUMP
!!permu LIGHTSTYLED
!!permu REFLECTCUBEMASK
!!samps diffuse

!!samps lightmap
!!samps =LIGHTSTYLED lightmap1 lightmap2 lightmap3

!!samps =BUMP normalmap

// envmaps only
!!samps =REFLECTCUBEMASK reflectmask reflectcube

!!permu FAKESHADOWS
!!cvardf r_glsl_pcf
!!samps =FAKESHADOWS shadowmap

#include "sys/defs.h"

varying vec2 tex_c;

varying vec2 lm0;

#ifdef LIGHTSTYLED
varying vec2 lm1, lm2, lm3;
#endif

#ifdef FAKESHADOWS
	varying vec4 vtexprojcoord;
#endif

/* CUBEMAPS ONLY */
#ifdef REFLECTCUBEMASK
	varying vec3 eyevector;
	varying mat3 invsurface;
#endif

#ifdef VERTEX_SHADER
	void lightmapped_init(void)
	{
		lm0 = v_lmcoord;
	#ifdef LIGHTSTYLED
		lm1 = v_lmcoord2;
		lm2 = v_lmcoord3;
		lm3 = v_lmcoord4;
	#endif
	}

	void main ()
	{
		lightmapped_init();
		tex_c = v_texcoord;
		gl_Position = ftetransform();

	/* CUBEMAPS ONLY */
	#ifdef REFLECTCUBEMASK
		invsurface = mat3(v_svector, v_tvector, v_normal);

		vec3 eyeminusvertex = e_eyepos - v_position.xyz;
		eyevector.x = dot(eyeminusvertex, v_svector.xyz);
		eyevector.y = dot(eyeminusvertex, v_tvector.xyz);
		eyevector.z = dot(eyeminusvertex, v_normal.xyz);
	#endif

	#ifdef FAKESHADOWS
		vtexprojcoord = (l_cubematrix*vec4(v_position.xyz, 1.0));
	#endif
	}
#endif

#ifdef FRAGMENT_SHADER
	#include "sys/fog.h"
	
#ifdef FAKESHADOWS
	#include "sys/pcf.h"
#endif

	#ifdef LIGHTSTYLED
		#define LIGHTMAP0 texture2D(s_lightmap0, lm0).rgb
		#define LIGHTMAP1 texture2D(s_lightmap1, lm1).rgb
		#define LIGHTMAP2 texture2D(s_lightmap2, lm2).rgb
		#define LIGHTMAP3 texture2D(s_lightmap3, lm3).rgb
	#else
		#define LIGHTMAP texture2D(s_lightmap, lm0).rgb 
	#endif

	vec3 lightmap_fragment()
	{
		vec3 lightmaps;

#ifdef LIGHTSTYLED
		lightmaps  = LIGHTMAP0 * e_lmscale[0].rgb;
		lightmaps += LIGHTMAP1 * e_lmscale[1].rgb;
		lightmaps += LIGHTMAP2 * e_lmscale[2].rgb;
		lightmaps += LIGHTMAP3 * e_lmscale[3].rgb;
#else
		lightmaps  = LIGHTMAP * e_lmscale.rgb;
#endif

		/* the light we're getting is always too bright */
		lightmaps *= 0.75;

		/* clamp at 1.5 */
		if (lightmaps.r > 1.5)
			lightmaps.r = 1.5;
		if (lightmaps.g > 1.5)
			lightmaps.g = 1.5;
		if (lightmaps.b > 1.5)
			lightmaps.b = 1.5;

		return lightmaps;
	}

	void main (void)
	{
		vec4 diffuse_f;

		diffuse_f = texture2D(s_diffuse, tex_c);

#ifdef MASKLT
		if (diffuse_f.a < float(MASK))
			discard;
#endif

#ifdef FAKESHADOWS
		diffuse_f.rgb *= ShadowmapFilter(s_shadowmap, vtexprojcoord);
#endif

		/* deluxemapping isn't working on Source BSP yet */
		diffuse_f.rgb *= lightmap_fragment();

/* CUBEMAPS ONLY */
#ifdef REFLECTCUBEMASK
	/* We currently only use the normal/bumpmap for cubemap warping. move this block out once we do proper radiosity normalmapping */
	#ifdef BUMP
		/* Source's normalmaps are in the DX format where the green channel is flipped */
		vec4 normal_f = texture2D(s_normalmap, tex_c);
		normal_f.g *= -1.0;
		normal_f.rgb = normalize(normal_f.rgb - 0.5);
	#else
		vec4 normal_f = vec4(0.0,0.0,1.0,0.0);
	#endif

	#if defined(ENVFROMMASK)
		/* We have a dedicated reflectmask */
		#define refl texture2D(s_reflectmask, tex_c).r
	#else
		/* when ENVFROMBASE is set or a normal isn't present, we're getting the reflectivity info from the diffusemap's alpha channel */
		#if defined(ENVFROMBASE) || !defined(BUMP)
			#define refl 1.0 - diffuse_f.a
		#else
			#define refl normal_f.a * 0.5
		#endif
	#endif

		vec3 cube_c = reflect(normalize(-eyevector), normal_f.rgb);
		cube_c = cube_c.x * invsurface[0] + cube_c.y * invsurface[1] + cube_c.z * invsurface[2];
		cube_c = (m_model * vec4(cube_c.xyz, 0.0)).xyz;
		diffuse_f.rgb += (textureCube(s_reflectcube, cube_c).rgb * vec3(refl,refl,refl));
#endif

		gl_FragColor = fog4(diffuse_f);
	}
#endif
