#version 450

layout (set = 1, binding = 0) uniform sampler2DArray Texture;

layout (push_constant) uniform PushConstants {
	layout (offset = 64)
	vec4        fog;
	float       time;
};

layout (location = 0) in vec4 tl_st;
layout (location = 1) in vec3 direction;

layout (location = 0) out vec4 frag_color;

const float PI = 3.14159265;
const float SPEED = 20.0;
const float CYCLE = 128.0;
const float FACTOR = PI * 2.0 / CYCLE;
const vec2 BIAS = vec2 (1.0, 1.0);
const float SCALE = 8.0;

vec2
warp_st (vec2 st, float time)
{
	vec2        angle = st.ts * CYCLE / 2.0;
	vec2        phase = vec2 (time, time) * SPEED;
	return st + (sin ((angle + phase) * FACTOR) + BIAS) / SCALE;
}

vec4
fogBlend (vec4 color)
{
	float       az = fog.a * gl_FragCoord.z / gl_FragCoord.w;
	vec3        fog_color = fog.rgb;
	float       fog_factor = exp (-az * az);

	return vec4 (mix (fog_color.rgb, color.rgb, fog_factor), color.a);
}

void
main (void)
{
	vec4        c = vec4 (0);
	vec4        e;
	vec3        t_st = vec3 (warp_st (tl_st.xy, time), 0);
	vec3        e_st = vec3 (warp_st (tl_st.xy, time), 1);

	c = texture (Texture, t_st);
	e = texture (Texture, e_st);
	frag_color = c + e;//fogBlend (c);
}
