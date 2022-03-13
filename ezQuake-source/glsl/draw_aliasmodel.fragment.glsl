#version 430

#ezquake-definitions

uniform int mode;

#ifdef DRAW_CAUSTIC_TEXTURES
layout(binding=SAMPLER_CAUSTIC_TEXTURE) uniform sampler2D causticsTex;
#endif
layout(binding=SAMPLER_MATERIAL_TEXTURE_START) uniform sampler2D samplers[SAMPLER_COUNT];

in vec2 fsTextureCoord;
in vec2 fsAltTextureCoord;
#ifdef EZQ_ALIASMODEL_FLATSHADING
flat in vec4 fsBaseColor;
#else
in vec4 fsBaseColor;
#endif
flat in int fsFlags;
flat in int fsTextureEnabled;
flat in int fsMaterialSampler;
flat in float fsMinLumaMix;

out vec4 frag_colour;

void main()
{
	frag_colour = vec4(0, 0, 0, 1);

	if (mode != EZQ_ALIAS_MODE_OUTLINES) {
		vec4 tex = texture(samplers[fsMaterialSampler], fsTextureCoord.st);
		vec4 altTex = texture(samplers[fsMaterialSampler], fsAltTextureCoord.st);
#ifdef DRAW_CAUSTIC_TEXTURES
		vec4 caustic = texture(
			causticsTex,
			vec2(
				// Using multipler of 3 here - not in other caustics logic but range
				//   isn't enough otherwise, effect too subtle
				(fsTextureCoord.s + sin(0.465 * (time + fsTextureCoord.t))) * 3 * -0.1234375,
				(fsTextureCoord.t + sin(0.465 * (time + fsTextureCoord.s))) * 3 * -0.1234375
			)
		);
#endif

		if (mode == EZQ_ALIAS_MODE_SHELLS) {
			vec4 color1 = vec4(
				shell_base_level1 + ((fsFlags & AMF_SHELLMODEL_RED) != 0 ? shell_effect_level1 : 0),
				shell_base_level1 + ((fsFlags & AMF_SHELLMODEL_GREEN) != 0 ? shell_effect_level1 : 0),
				shell_base_level1 + ((fsFlags & AMF_SHELLMODEL_BLUE) != 0 ? shell_effect_level1 : 0),
				0
			);
			vec4 color2 = vec4(
				shell_base_level2 + ((fsFlags & AMF_SHELLMODEL_RED) != 0 ? shell_effect_level2 : 0),
				shell_base_level2 + ((fsFlags & AMF_SHELLMODEL_GREEN) != 0 ? shell_effect_level2 : 0),
				shell_base_level2 + ((fsFlags & AMF_SHELLMODEL_BLUE) != 0 ? shell_effect_level2 : 0),
				0
			);

			frag_colour = shell_alpha * color1 * tex + shell_alpha * color2 * altTex;
		}
		else {
			frag_colour = fsBaseColor;
			if (fsTextureEnabled != 0) {
				frag_colour = vec4(mix(tex.rgb, tex.rgb * fsBaseColor.rgb, max(fsMinLumaMix, tex.a)), fsBaseColor.a);
			}

#ifdef DRAW_CAUSTIC_TEXTURES
			if ((fsFlags & AMF_CAUSTICS) == AMF_CAUSTICS) {
				// FIXME: Do proper GL_DECAL etc
				frag_colour = vec4(caustic.rgb * frag_colour.rgb * 1.8, frag_colour.a);
			}
#endif
		}
	}
}
