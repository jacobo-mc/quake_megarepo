/*
Copyright (C) 1997-2001 Id Software, Inc.

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

/**

	GL Bloom

	Ported by Cokeman, June 2007
	last edit:
	$Id: gl_bloom.c,v 1.5 2007-09-13 14:49:30 disconn3ct Exp $

*/

#ifdef RENDERER_OPTION_CLASSIC_OPENGL

// glc_bloom.c: 2D lighting post process effect (immediate-mode OpenGL only)

#include "quakedef.h"
#include "gl_model.h"
#include "gl_local.h"
#include "r_texture.h"
#include "r_matrix.h"
#include "r_renderer.h"
#include "glc_local.h"
#include "tr_types.h"

/*
==============================================================================

						LIGHT BLOOMS

==============================================================================
*/

static float Diamond8x[8][8] = {
	{0.0f, 0.0f, 0.0f, 0.1f, 0.1f, 0.0f, 0.0f, 0.0f},
	{0.0f, 0.0f, 0.2f, 0.3f, 0.3f, 0.2f, 0.0f, 0.0f},
	{0.0f, 0.2f, 0.4f, 0.6f, 0.6f, 0.4f, 0.2f, 0.0f},
	{0.1f, 0.3f, 0.6f, 0.9f, 0.9f, 0.6f, 0.3f, 0.1f},
	{0.1f, 0.3f, 0.6f, 0.9f, 0.9f, 0.6f, 0.3f, 0.1f},
	{0.0f, 0.2f, 0.4f, 0.6f, 0.6f, 0.4f, 0.2f, 0.0f},
	{0.0f, 0.0f, 0.2f, 0.3f, 0.3f, 0.2f, 0.0f, 0.0f},
	{0.0f, 0.0f, 0.0f, 0.1f, 0.1f, 0.0f, 0.0f, 0.0f} };

static float Diamond6x[6][6] = {
	{0.0f, 0.0f, 0.1f, 0.1f, 0.0f, 0.0f},
	{0.0f, 0.3f, 0.5f, 0.5f, 0.3f, 0.0f},
	{0.1f, 0.5f, 0.9f, 0.9f, 0.5f, 0.1f},
	{0.1f, 0.5f, 0.9f, 0.9f, 0.5f, 0.1f},
	{0.0f, 0.3f, 0.5f, 0.5f, 0.3f, 0.0f},
	{0.0f, 0.0f, 0.1f, 0.1f, 0.0f, 0.0f} };

static float Diamond4x[4][4] = {
	{0.3f, 0.4f, 0.4f, 0.3f},
	{0.4f, 0.9f, 0.9f, 0.4f},
	{0.4f, 0.9f, 0.9f, 0.4f},
	{0.3f, 0.4f, 0.4f, 0.3f} };

static int BLOOM_SIZE;

cvar_t      r_bloom = { "r_bloom", "0", true };
cvar_t      r_bloom_alpha = { "r_bloom_alpha", "0.5", true };
cvar_t      r_bloom_diamond_size = { "r_bloom_diamond_size", "8", true };
cvar_t      r_bloom_intensity = { "r_bloom_intensity", "1", true };
cvar_t      r_bloom_darken = { "r_bloom_darken", "3", true };
cvar_t      r_bloom_sample_size = { "r_bloom_sample_size", "256", true };
cvar_t      r_bloom_fast_sample = { "r_bloom_fast_sample", "0", true };

texture_ref r_bloomscreentexture;
texture_ref r_bloomeffecttexture;
texture_ref r_bloombackuptexture;
texture_ref r_bloomdownsamplingtexture;

static int      r_screendownsamplingtexture_size;
static int      screen_texture_width, screen_texture_height;
static int      r_screenbackuptexture_size;

// Current refdef size:
static int  curView_x;
static int  curView_y;
static int  curView_width;
static int  curView_height;

// Texture coordinates of screen data inside screentexture.
static float screenText_tcw;
static float screenText_tch;

static int  sample_width;
static int  sample_height;

// Texture coordinates of adjusted textures.
static float sampleText_tcw;
static float sampleText_tch;

// This macro is in sample size workspace coordinates.
#define GLC_Bloom_SamplePass( xpos, ypos )                         \
	GLC_Begin(GL_QUADS);                                             \
	glTexCoord2f(  0,                      sampleText_tch);        \
	GLC_Vertex2f(    xpos,                   ypos);                  \
	glTexCoord2f(  0,                      0);                     \
	GLC_Vertex2f(    xpos,                   ypos+sample_height);    \
	glTexCoord2f(  sampleText_tcw,         0);                     \
	GLC_Vertex2f(    xpos+sample_width,      ypos+sample_height);    \
	glTexCoord2f(  sampleText_tcw,         sampleText_tch);        \
	GLC_Vertex2f(    xpos+sample_width,      ypos);                  \
	GLC_End();

#define GLC_Bloom_Quad( x, y, width, height, textwidth, textheight ) \
	GLC_Begin(GL_QUADS);                                             \
	glTexCoord2f(  0,          textheight);                        \
	GLC_Vertex2f(    x,          y);                                 \
	glTexCoord2f(  0,          0);                                 \
	GLC_Vertex2f(    x,          y+height);                          \
	glTexCoord2f(  textwidth,  0);                                 \
	GLC_Vertex2f(    x+width,    y+height);                          \
	glTexCoord2f(  textwidth,  textheight);                        \
	GLC_Vertex2f(    x+width,    y);                                 \
	GLC_End();

// Meag: #define DEBUG_BLOOM, if bloom enabled and you set `developer 1`,
//   for a single frame it will output copies of the intermediate textures
//   then set developer 0 again.
#ifdef DEBUG_BLOOM
static void GLC_Bloom_DebugTexture(texture_ref tex, const char* filename)
{
	if (developer.integer) {
		int buffer_size = 4 * R_TextureWidth(tex) * R_TextureHeight(tex);
		byte* buffer = Q_malloc(buffer_size);
		scr_sshot_target_t* sshot_params = Q_malloc(sizeof(scr_sshot_target_t));

		renderer.TextureGet(tex, buffer_size, buffer, 3);

		sshot_params->buffer = buffer;
		sshot_params->freeMemory = true;
		strlcpy(sshot_params->fileName, filename, sizeof(sshot_params->fileName));
		sshot_params->format = IMAGE_JPEG;
		sshot_params->width = R_TextureWidth(tex);
		sshot_params->height = R_TextureHeight(tex);
		SCR_ScreenshotWrite(sshot_params);
	}
}
#else
#define GLC_Bloom_DebugTexture(tex, filename)
#endif

//=================
// GLC_Bloom_InitBackUpTexture
// =================
static void GLC_Bloom_InitBackUpTexture(int width, int height)
{
	unsigned char *data;

	data = (unsigned char *)Q_calloc(width * height, sizeof(int));

	r_screenbackuptexture_size = width;

	r_bloombackuptexture = R_LoadTexture("***r_bloombackuptexture***", width, height, data, 0, 4);

	Q_free(data);
}

// =================
// GLC_Bloom_InitEffectTexture
// =================
static void GLC_Bloom_InitEffectTexture(void)
{
	unsigned char *data;
	float bloomsizecheck;

	if (r_bloom_sample_size.value < 32) {
		Cvar_SetValue(&r_bloom_sample_size, 32);
	}

	// Make sure bloom size is a power of 2.
	BLOOM_SIZE = r_bloom_sample_size.value;
	bloomsizecheck = (float)BLOOM_SIZE;

	while (bloomsizecheck > 1.0f) {
		bloomsizecheck /= 2.0f;
	}

	if (bloomsizecheck != 1.0f) {
		BLOOM_SIZE = 32;

		while (BLOOM_SIZE < r_bloom_sample_size.value) {
			BLOOM_SIZE *= 2;
		}
	}

	// Make sure bloom size doesn't have stupid values.
	if (BLOOM_SIZE > screen_texture_width || BLOOM_SIZE > screen_texture_height) {
		BLOOM_SIZE = min(screen_texture_width, screen_texture_height);
	}

	if (BLOOM_SIZE != r_bloom_sample_size.value) {
		Cvar_SetValue(&r_bloom_sample_size, BLOOM_SIZE);
	}

	data = (unsigned char *)Q_calloc(BLOOM_SIZE * BLOOM_SIZE, sizeof(int));

	r_bloomeffecttexture = R_LoadTexture("***r_bloomeffecttexture***", BLOOM_SIZE, BLOOM_SIZE, data, 0, 4);

	Q_free(data);
}

// =================
// GLC_Bloom_InitTextures
// =================
static void GLC_Bloom_InitTextures(void)
{
	unsigned char *data;
	int maxtexsize = glConfig.gl_max_size_default;
	size_t size;

	// Find closer power of 2 to screen size.
	for (screen_texture_width = 1; screen_texture_width < glwidth; screen_texture_width *= 2);
	for (screen_texture_height = 1; screen_texture_height < glheight; screen_texture_height *= 2);

	// Disable blooms if we can't handle a texture of that size.
	if (screen_texture_width > maxtexsize || screen_texture_height > maxtexsize) {
		screen_texture_width = screen_texture_height = 0;
		Cvar_SetValue(&r_bloom, 0);
		Com_Printf("WARNING: 'R_InitBloomScreenTexture' too high resolution for Light Bloom. Effect disabled\n");
		return;
	}

	// Init the screen texture.
	size = screen_texture_width * screen_texture_height * sizeof(int);
	data = Q_malloc(size);
	memset(data, 255, size);

	if (!R_TextureReferenceIsValid(r_bloomscreentexture) || R_TextureWidth(r_bloomscreentexture) != screen_texture_width || R_TextureHeight(r_bloomscreentexture) != screen_texture_height) {
		if (R_TextureReferenceIsValid(r_bloomscreentexture)) {
			renderer.TextureDelete(r_bloomscreentexture);
		}
		r_bloomscreentexture = R_LoadTexture("bloom:screentexture", screen_texture_width, screen_texture_height, data, TEX_NOCOMPRESS | TEX_NOSCALE | TEX_NO_TEXTUREMODE, 4);
		renderer.TextureSetFiltering(r_bloomscreentexture, texture_minification_nearest, texture_magnification_nearest);
	}

	Q_free(data);

	// Validate bloom size and init the bloom effect texture.
	GLC_Bloom_InitEffectTexture();

	// If screensize is more than 2x the bloom effect texture, set up for stepped downsampling.
	R_TextureReferenceInvalidate(r_bloomdownsamplingtexture);
	r_screendownsamplingtexture_size = 0;
	if (glwidth > (BLOOM_SIZE * 2) && !r_bloom_fast_sample.value) {
		r_screendownsamplingtexture_size = (int)(BLOOM_SIZE * 2);
		data = Q_calloc(r_screendownsamplingtexture_size * r_screendownsamplingtexture_size, sizeof(int));
		r_bloomdownsamplingtexture = R_LoadTexture("***r_bloomdownsamplingtexture***", r_screendownsamplingtexture_size, r_screendownsamplingtexture_size, data, 0, 4);
		Q_free(data);
	}

	// Init the screen backup texture.
	if (r_screendownsamplingtexture_size) {
		GLC_Bloom_InitBackUpTexture(r_screendownsamplingtexture_size, r_screendownsamplingtexture_size);
	}
	else {
		GLC_Bloom_InitBackUpTexture(BLOOM_SIZE, BLOOM_SIZE);
	}
}

// =================
// R_InitBloomTextures
// =================
void GLC_InitBloomTextures(void)
{
	BLOOM_SIZE = 0;
	if (!r_bloom.value) {
		return;
	}

	// This came from a vid_restart, where none of the textures are valid any more.
	R_TextureReferenceInvalidate(r_bloomscreentexture);
	R_TextureReferenceInvalidate(r_bloomeffecttexture);
	R_TextureReferenceInvalidate(r_bloombackuptexture);
	R_TextureReferenceInvalidate(r_bloomdownsamplingtexture);

	GLC_Bloom_InitTextures();
}

// =================
// R_Bloom_DrawEffect
// =================
static void GLC_Bloom_DrawEffect(void)
{
	GLC_StateBeginBloomDraw(r_bloomeffecttexture);

	GLC_Begin(GL_QUADS);
	glTexCoord2f(0, sampleText_tch);
	GLC_Vertex2f(curView_x, curView_y);
	glTexCoord2f(0, 0);
	GLC_Vertex2f(curView_x, curView_y + curView_height);
	glTexCoord2f(sampleText_tcw, 0);
	GLC_Vertex2f(curView_x + curView_width, curView_y + curView_height);
	glTexCoord2f(sampleText_tcw, sampleText_tch);
	GLC_Vertex2f(curView_x + curView_width, curView_y);
	GLC_End();
}

// =================
// R_Bloom_GeneratexDiamonds
//=================
static void GLC_Bloom_GeneratexDiamonds(void)
{
	int         i, j;
	static float intensity;

	// Setup sample size workspace
	R_Viewport(0, 0, sample_width, sample_height);
	R_OrthographicProjection(0, sample_width, sample_height, 0, -10, 100);
	R_IdentityModelView();

	// Copy small scene into r_bloomeffecttexture.
	renderer.TextureUnitBind(0, r_bloomeffecttexture);
	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, sample_width, sample_height);

	// Start modifying the small scene corner.

	// Darkening passes
	if (r_bloom_darken.value) {
		R_ApplyRenderingState(r_state_postprocess_bloom_darkenpass);

		for (i = 0; i < r_bloom_darken.integer; i++) {
			GLC_Bloom_SamplePass(0, 0);
		}
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, sample_width, sample_height);
		GLC_Bloom_DebugTexture(r_bloomeffecttexture, "./qw/bloom-darkenedpass.jpg");
	}

	// Bluring passes.
	R_ApplyRenderingState(r_state_postprocess_bloom_blurpass);
	R_CustomColor(1.0f, 1.0f, 1.0f, 1.0f);

	if (r_bloom_diamond_size.value > 7 || r_bloom_diamond_size.value <= 3) {
		if (r_bloom_diamond_size.integer != 8) {
			Cvar_SetValue(&r_bloom_diamond_size, 8);
		}

		for (i = 0; i < r_bloom_diamond_size.integer; i++) {
			for (j = 0; j < r_bloom_diamond_size.integer; j++) {
				intensity = r_bloom_intensity.value * 0.3 * Diamond8x[i][j];
				if (intensity < 0.01f) {
					continue;
				}
				R_CustomColor(intensity, intensity, intensity, 1.0);
				GLC_Bloom_SamplePass(i - 4, j - 4);
			}
		}
	}
	else if (r_bloom_diamond_size.integer > 5) {
		if (r_bloom_diamond_size.integer != 6) {
			Cvar_SetValue(&r_bloom_diamond_size, 6);
		}

		for (i = 0; i < r_bloom_diamond_size.integer; i++) {
			for (j = 0; j < r_bloom_diamond_size.integer; j++) {
				intensity = r_bloom_intensity.value * 0.5 * Diamond6x[i][j];
				if (intensity < 0.01f) {
					continue;
				}
				R_CustomColor(intensity, intensity, intensity, 1.0);
				GLC_Bloom_SamplePass(i - 3, j - 3);
			}
		}
	}
	else if (r_bloom_diamond_size.value > 3) {
		if (r_bloom_diamond_size.integer != 4) {
			Cvar_SetValue(&r_bloom_diamond_size, 4);
		}

		for (i = 0; i < r_bloom_diamond_size.integer; i++) {
			for (j = 0; j < r_bloom_diamond_size.integer; j++) {
				intensity = r_bloom_intensity.value * 0.8f * Diamond4x[i][j];
				if (intensity < 0.01f) {
					continue;
				}
				R_CustomColor(intensity, intensity, intensity, 1.0);
				GLC_Bloom_SamplePass(i - 2, j - 2);
			}
		}
	}

	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, sample_width, sample_height);
	GLC_Bloom_DebugTexture(r_bloomeffecttexture, "./qw/bloom-blurred.jpg");

	// Restore full screen workspace.
	R_Viewport(0, 0, glwidth, glheight);
	R_OrthographicProjection(0, glwidth, glheight, 0, -10, 100);
	R_IdentityModelView();
}

// =================
// R_Bloom_DownsampleView
// =================
static void GLC_Bloom_DownsampleView(void)
{
	R_ApplyRenderingState(r_state_postprocess_bloom_downsample);
	R_CustomColor(1.0f, 1.0f, 1.0f, 1.0f);

	// Stepped downsample.
	if (r_screendownsamplingtexture_size) {
		int     midsample_width = r_screendownsamplingtexture_size * sampleText_tcw;
		int     midsample_height = r_screendownsamplingtexture_size * sampleText_tch;

		// Copy the screen and draw resized.
		renderer.TextureUnitBind(0, r_bloomscreentexture);
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, curView_x, glheight - (curView_y + curView_height), curView_width, curView_height);
		GLC_Bloom_Quad(0, glheight - midsample_height, midsample_width, midsample_height, screenText_tcw, screenText_tch);

		// Now copy into Downsampling (mid-sized) texture.
		renderer.TextureUnitBind(0, r_bloomdownsamplingtexture);
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, midsample_width, midsample_height);
		GLC_Bloom_DebugTexture(r_bloombackuptexture, "./qw/bloom-downsampled1.jpg");

		// Now draw again in bloom size.
		R_CustomColor(0.5f, 0.5f, 0.5f, 1.0f);
		GLC_Bloom_Quad(0, glheight - sample_height, sample_width, sample_height, sampleText_tcw, sampleText_tch);

		// Now blend the big screen texture into the bloom generation space (hoping it adds some blur).
		R_ApplyRenderingState(r_state_postprocess_bloom_downsample_blend);
		R_CustomColor(0.5f, 0.5f, 0.5f, 1.0f);
		renderer.TextureUnitBind(0, r_bloomscreentexture);
		GLC_Bloom_Quad(0, glheight - sample_height, sample_width, sample_height, screenText_tcw, screenText_tch);
	}
	else {
		// Downsample simple.
		renderer.TextureUnitBind(0, r_bloomscreentexture);
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, curView_x, glheight - (curView_y + curView_height), curView_width, curView_height);
		GLC_Bloom_DebugTexture(r_bloombackuptexture, "./qw/bloom-downsampled2.jpg");
		GLC_Bloom_Quad(0, glheight - sample_height, sample_width, sample_height, screenText_tcw, screenText_tch);
	}
}

// =================
// R_BloomBlend
// =================
void GLC_BloomBlend(void)
{
	extern vrect_t	scr_vrect;

	if (!r_bloom.value) {
		return;
	}

	if (!BLOOM_SIZE || screen_texture_width < glwidth || screen_texture_height < glheight) {
		GLC_Bloom_InitTextures();
	}

	if (screen_texture_width < BLOOM_SIZE || screen_texture_height < BLOOM_SIZE) {
		return;
	}

	// Set up full screen workspace.
	R_Viewport(0, 0, glwidth, glheight);
	R_OrthographicProjection(0, glwidth, glheight, 0, -10, 100);
	R_IdentityModelView();

	R_ApplyRenderingState(r_state_postprocess_bloom1);
	R_CustomColor(1, 1, 1, 1);

	// Setup current sizes
	curView_x = scr_vrect.x * ((float)glwidth / vid.width);
	curView_y = scr_vrect.y * ((float)glheight / vid.height);
	curView_width = scr_vrect.width * ((float)glwidth / vid.width);
	curView_height = scr_vrect.height * ((float)glheight / vid.height);
	screenText_tcw = ((float)curView_width / (float)screen_texture_width);
	screenText_tch = ((float)curView_height / (float)screen_texture_height);

	if (scr_vrect.height > scr_vrect.width) {
		sampleText_tcw = ((float)scr_vrect.width / (float)scr_vrect.height);
		sampleText_tch = 1.0f;
	}
	else {
		sampleText_tcw = 1.0f;
		sampleText_tch = ((float)scr_vrect.height / (float)scr_vrect.width);
	}

	sample_width = BLOOM_SIZE * sampleText_tcw;
	sample_height = BLOOM_SIZE * sampleText_tch;

	// Copy the screen space we'll use to work into the backup texture.
	renderer.TextureUnitBind(0, r_bloombackuptexture);
	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, r_screenbackuptexture_size * sampleText_tcw, r_screenbackuptexture_size * sampleText_tch);
	GLC_Bloom_DebugTexture(r_bloombackuptexture, "./qw/bloom-copied.jpg");

	// Create the bloom image.
	GLC_Bloom_DownsampleView();
	GLC_Bloom_GeneratexDiamonds();
	//R_Bloom_GeneratexCross();

	// Restore the screen-backup to the screen.
	GLC_Bloom_DebugTexture(r_bloombackuptexture, "./qw/bloom-restored.jpg");
	R_ApplyRenderingState(r_state_postprocess_bloom_restore);
	renderer.TextureUnitBind(0, r_bloombackuptexture);
	R_CustomColor(1, 1, 1, 1);
	GLC_Bloom_Quad(0,
		glheight - (r_screenbackuptexture_size * sampleText_tch),
		r_screenbackuptexture_size * sampleText_tcw,
		r_screenbackuptexture_size * sampleText_tch,
		sampleText_tcw,
		sampleText_tch
	);

	GLC_Bloom_DrawEffect();

#ifdef DEBUG_BLOOM
	Cvar_SetValue(&developer, 0);
#endif
}

void GLC_BloomRegisterCvars(void)
{
	Cvar_SetCurrentGroup(CVAR_GROUP_EYECANDY);
	Cvar_Register(&r_bloom);
	Cvar_Register(&r_bloom_darken);
	Cvar_Register(&r_bloom_alpha);
	Cvar_Register(&r_bloom_diamond_size);
	Cvar_Register(&r_bloom_intensity);
	Cvar_Register(&r_bloom_sample_size);
	Cvar_Register(&r_bloom_fast_sample);
	Cvar_ResetCurrentGroup();
}

#endif // #ifdef RENDERER_OPTION_CLASSIC_OPENGL

