#version 450

layout (set = 1, binding = 0) uniform sampler2DArray Skin;

layout (push_constant) uniform PushConstants {
	layout (offset = 68)
	uint        colorA;
	uint        colorB;
	vec4        base_color;
	vec4        fog;
};

layout (location = 0) in vec2 st;
layout (location = 1) in vec4 position;
layout (location = 2) in vec3 normal;

layout (location = 0) out vec4 frag_color;
layout (location = 1) out vec4 frag_emission;
layout (location = 2) out vec4 frag_normal;
layout (location = 3) out vec4 frag_position;

void
main (void)
{
	vec4        c;
	vec4        e;
	int         i;
	vec3        light = vec3 (0);
	c = texture (Skin, vec3 (st, 0)) * base_color;
	c += texture (Skin, vec3 (st, 1)) * unpackUnorm4x8(colorA);
	c += texture (Skin, vec3 (st, 2)) * unpackUnorm4x8(colorB);
	e = texture (Skin, vec3 (st, 3));

	frag_color = c;
	frag_emission = e;
	frag_normal = vec4(normal, 1);
	frag_position = position;
}
