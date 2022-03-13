#version 430

#ezquake-definitions

in vec2 TextureCoord;
out vec4 frag_colour;

layout(binding = 0) uniform sampler2D base;
#ifdef EZ_POSTPROCESS_OVERLAY
layout(binding = 1) uniform sampler2D overlay;
#endif // EZ_POSTPROCESS_OVERLAY

vec4 sampleBase(void)
{
	return texture(base, TextureCoord);
}

#ifdef EZ_POSTPROCESS_OVERLAY
vec4 sampleOverlay(void)
{
	return texture(overlay, TextureCoord);
}
#endif // EZ_POSTPROCESS_OVERLAY

void main()
{
	vec4 result = sampleBase();
#ifdef EZ_POSTPROCESS_TONEMAP
	result.r = result.r / (result.r + 1);
	result.g = result.g / (result.g + 1);
	result.b = result.b / (result.b + 1);
#endif
#ifdef EZ_POSTPROCESS_OVERLAY
	vec4 add = sampleOverlay();
	result *= 1 - add.a;
	result += add;
#endif

#ifdef EZ_POSTPROCESS_PALETTE
	// apply blend & contrast
	result = vec4((result.rgb * v_blend.a + v_blend.rgb) * contrast, 1);

	// apply gamma
	result = vec4(pow(result.rgb, vec3(gamma)), 1);
#endif

	frag_colour = result;
}
