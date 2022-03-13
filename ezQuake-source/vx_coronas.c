/*
Copyright (C) 2011 VULTUREIIC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "quakedef.h"
#include "gl_model.h"
#include "vx_stuff.h"
#include "glm_texture_arrays.h"
#include "r_sprite3d.h"
#include "r_state.h"

//fixme: move to header
extern float bubblecolor[NUM_DLIGHTTYPES][4];
static void CoronaStats(int change);

typedef struct corona_s
{
	vec3_t origin;
	float scale;
	float growth;
	float die;
	vec3_t color;
	float alpha;
	float fade;
	coronatype_t type;
	qbool sighted;
	qbool los; //to prevent having to trace a line twice
	int texture;
	struct corona_s* next;

	int static_entity_id;
	int client_entity_id;
} corona_t;

//Tei: original whas 256, upped so whas low (?!) for some games
#define MAX_CORONAS 300

static corona_t r_corona[MAX_CORONAS];
static corona_t* r_corona_by_tex[CORONATEX_COUNT];

#define CORONA_SCALE 130
#define CORONA_ALPHA 1

void R_UpdateCoronas(void)
{
	int i;
	corona_t *c;
	float frametime = cls.frametime;

	memset(r_corona_by_tex, 0, sizeof(r_corona_by_tex));

	CoronaStats(-CoronaCount);
	for (i = 0; i < MAX_CORONAS; i++) {
		c = &r_corona[i];

		if (c->type == C_FREE) {
			continue;
		}
		if (c->type == C_EXPLODE) {
			if (c->die < cl.time && c->texture != CORONATEX_EXPLOSIONFLASH7) {
				c->texture++;
				c->die = cl.time + 0.03;
			}
		}

		// First, check to see if it's time to die.
		if (!amf_coronas.integer || c->die < cl.time || c->scale <= 0 || c->alpha <= 0) {
			// Free this corona up.
			c->scale = 0;
			c->alpha = 0;
			c->type = C_FREE;
			c->sighted = false;
			c->client_entity_id = 0; // so can be reused
			c->static_entity_id = 0;
			continue;
		}

		CoronaStats(1);
		c->scale += c->growth * frametime;
		c->alpha += c->fade * frametime;

		c->next = r_corona_by_tex[c->texture];
		r_corona_by_tex[c->texture] = c;

		c->los = true;
		if (c->static_entity_id > 0) {
			c->los = (cl_static_entities[c->static_entity_id - 1].visframe >= r_framecount - 1);
		}
		else if (c->client_entity_id > 0) {
			c->los = (cl_entities[c->client_entity_id - 1].sequence == cl.validsequence);
		}
		if (c->los) {
			vec3_t impact = { 0,0,0 }, normal, temp;

			VectorCopy(c->origin, temp);
			if (c->type == C_FIRE) {
				temp[2] += 6;
			}
			CL_TraceLine(r_refdef.vieworg, temp, impact, normal);
			c->los = VectorCompare(impact, temp);
		}
		if (!c->los) {
			//Can't see it, so make it fade out(faster)
			c->scale = 0;
			c->alpha = 0;
		}
		else {
			if (c->type == C_FIRE) {
				c->fade = 1.5;
				c->growth = 1000;
				if (c->scale > 150) {
					c->scale = 150 + rand() % 15; //flicker when at full radius
				}
				c->alpha = min(c->alpha, 0.2f);
			}
			c->sighted = true;
		}
	}
}

//R_DrawCoronas
void R_DrawCoronas(void)
{
	vec3_t dist, up, right;
	float fdist, scale, alpha;
	corona_t *c;
	corona_texture_id tex;

	if (!amf_coronas.integer && !CoronaCount) {
		return;
	}

	if (!ISPAUSED) {
		R_UpdateCoronas();
	}

	VectorScale(vup, 1, up);//1.5
	VectorScale(vright, 1, right);

	for (tex = CORONATEX_STANDARD; tex < CORONATEX_COUNT; ++tex) {
		sprite3d_batch_id batch_id = SPRITE3D_CORONATEX_STANDARD + (tex - CORONATEX_STANDARD);
		corona_texture_t* texture = &corona_textures[tex];
		byte color[4];

		if (!r_corona_by_tex[tex]) {
			continue;
		}

		R_Sprite3DInitialiseBatch(batch_id, r_state_coronas, R_UseModernOpenGL() ? texture->array_tex : texture->texnum, texture->array_index, r_primitive_triangle_strip);

		for (c = r_corona_by_tex[tex]; c; c = c->next) {
			r_sprite3d_vert_t* vert;
			if (c->type == C_FREE) {
				continue;
			}
			if (!c->los) {
				// can't see it and
				if (!c->sighted) {
					// haven't seen it before
					continue; // don't draw it
				}
			}
			// else it will be fading out, so that's 'kay

			VectorSubtract(r_refdef.vieworg, c->origin, dist);
			fdist = VectorLength(dist);

			fdist = max(fdist, 24);
			scale = (1 - 1 / fdist) * c->scale;
			alpha = c->alpha;

			color[0] = (c->color[0] * alpha) * 255;
			color[1] = (c->color[1] * alpha) * 255;
			color[2] = (c->color[2] * alpha) * 255;
			color[3] = 0;

			vert = R_Sprite3DAddEntry(batch_id, 4);
			if (!vert) {
				break;
			}

			R_Sprite3DSetVert(
				vert++,
				// Left/Up
				c->origin[0] + up[0] * (scale / 2) + (right[0] * (scale / 2)*-1),
				c->origin[1] + up[1] * (scale / 2) + (right[1] * (scale / 2)*-1),
				c->origin[2] + up[2] * (scale / 2) + (right[2] * (scale / 2)*-1),
				0, 0, color, texture->array_index
			);
			R_Sprite3DSetVert(
				vert++,
				// Right/Up
				c->origin[0] + right[0] * (scale / 2) + up[0] * (scale / 2),
				c->origin[1] + right[1] * (scale / 2) + up[1] * (scale / 2),
				c->origin[2] + right[2] * (scale / 2) + up[2] * (scale / 2),
				texture->array_scale_s, 0, color, texture->array_index
			);
			R_Sprite3DSetVert(
				vert++,
				// Left/Down
				c->origin[0] + (right[0] * (scale / 2)*-1) + (up[0] * (scale / 2)*-1),
				c->origin[1] + (right[1] * (scale / 2)*-1) + (up[1] * (scale / 2)*-1),
				c->origin[2] + (right[2] * (scale / 2)*-1) + (up[2] * (scale / 2)*-1),
				0, texture->array_scale_t, color, texture->array_index
			);
			R_Sprite3DSetVert(
				vert++,
				// Right/Down
				c->origin[0] + right[0] * (scale / 2) + (up[0] * (scale / 2)*-1),
				c->origin[1] + right[1] * (scale / 2) + (up[1] * (scale / 2)*-1),
				c->origin[2] + right[2] * (scale / 2) + (up[2] * (scale / 2)*-1),
				texture->array_scale_s, texture->array_scale_t, color, texture->array_index
			);

			// It's sort of cheap, but lets draw a few more here to make the effect more obvious
			if (c->type == C_FLASH || c->type == C_BLUEFLASH) {
				int a;

				for (a = 0; a < 5; a++) {
					vert = R_Sprite3DAddEntry(batch_id, 4);
					if (!vert) {
						break;
					}

					R_Sprite3DSetVert(
						vert++,
						// Left/Up
						c->origin[0] + up[0] * (scale / 30) + (right[0] * (scale)*-1),
						c->origin[1] + up[1] * (scale / 30) + (right[1] * (scale)*-1),
						c->origin[2] + up[2] * (scale / 30) + (right[2] * (scale)*-1),
						0, 0, color, texture->array_index
					);
					R_Sprite3DSetVert(
						vert++,
						// Right/Up
						c->origin[0] + right[0] * (scale)+up[0] * (scale / 30),
						c->origin[1] + right[1] * (scale)+up[1] * (scale / 30),
						c->origin[2] + right[2] * (scale)+up[2] * (scale / 30),
						texture->array_scale_s, 0, color, texture->array_index
					);
					R_Sprite3DSetVert(
						vert++,
						// Left/Down
						c->origin[0] + (right[0] * (scale)*-1) + (up[0] * (scale / 30)*-1),
						c->origin[1] + (right[1] * (scale)*-1) + (up[1] * (scale / 30)*-1),
						c->origin[2] + (right[2] * (scale)*-1) + (up[2] * (scale / 30)*-1),
						0, texture->array_scale_t, color, texture->array_index
					);
					R_Sprite3DSetVert(
						vert++,
						// Right/Down
						c->origin[0] + right[0] * (scale)+(up[0] * (scale / 30)*-1),
						c->origin[1] + right[1] * (scale)+(up[1] * (scale / 30)*-1),
						c->origin[2] + right[2] * (scale)+(up[2] * (scale / 30)*-1),
						texture->array_scale_s, texture->array_scale_t, color, texture->array_index
					);
				}
			}
		}
	}
}

static void R_CoronasNewImpl(coronatype_t type, vec3_t origin, int entity_id)
{
	corona_t *c = NULL;
	int i;
	qbool corona_found = false;
	int corona_id = 0;
	customlight_t cst_lt = { 0 };

	if (ISPAUSED || !amf_coronas.integer) {
		return;
	}

	if (entity_id) {
		entity_id = bound(0, entity_id, CL_MAX_EDICTS);

		corona_id = cl_entities[entity_id - 1].corona_id;
		if (corona_id >= 0 && corona_id < MAX_CORONAS) {
			if (r_corona[corona_id].client_entity_id == entity_id) {
				c = &r_corona[corona_id];
				corona_found = true;
			}
		}
	}

	if (!c) {
		c = r_corona;
		for (i = 0; i < MAX_CORONAS; i++, c++) {
			if (c->type == C_FREE) {
				memset(c, 0, sizeof(*c));
				corona_found = true;
				break;
			}
		}
	}

	if (!corona_found) {
		//Tei: last attempt to get a valid corona to "canibalize"
		c = r_corona;
		for (i = 0; i < MAX_CORONAS; i++, c++) {
			//Search a fire corona that is about to die soon
			if ((c->type == C_FIRE) &&
				(c->die < (cl.time + 0.1f) || c->scale <= 0.1f || c->alpha <= 0.1f)
				) {
				memset(c, 0, sizeof(*c));
				corona_found = true;
				// succesfully canibalize a fire corona that whas about to die.
				break;
			}
		}
		//If can't canibalize a corona, It exit silently
		//This is the worst case scenario, and will never happend
		return;
	}

	c->sighted = false;
	VectorCopy(origin, c->origin);
	c->type = type;
	c->los = false;
	c->texture = CORONATEX_STANDARD;
	c->client_entity_id = entity_id;
	if (entity_id) {
		cl_entities[entity_id - 1].corona_id = c - r_corona;
	}

	if (type == C_FLASH || type == C_BLUEFLASH) {
		if (type == C_BLUEFLASH) {
			VectorCopy(bubblecolor[lt_blue], c->color);
		}
		else {
			dlightColorEx(r_explosionlightcolor.value, r_explosionlightcolor.string, lt_explosion, false, &cst_lt);
			if (cst_lt.type == lt_custom) {
				VectorCopy(cst_lt.color, c->color);
				VectorScale(c->color, (1.0 / 255), c->color); // cast byte to float
			}
			else {
				VectorCopy(bubblecolor[cst_lt.type], c->color);
			}
			VectorMA(c->color, 1.5, c->color, c->color);
		}
		c->scale = 600;
		c->die = cl.time + 0.2;
		c->alpha = 0.25;
		c->fade = 0;
		c->growth = -3000;
	}
	else if (type == C_SMALLFLASH) {
		c->color[0] = 1;
		c->color[1] = 0.8;
		c->color[2] = 0.3;
		c->scale = 150;
		c->die = cl.time + 0.1;
		c->alpha = 0.66;
		c->fade = 0;
		c->growth = -2000 + (rand() % 500) - 250;
	}
	else if (type == C_LIGHTNING) {
		VectorCopy(bubblecolor[lt_blue], c->color);
		c->scale = 80;
		c->die = cl.time + 0.01;
		c->alpha = 0.33;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_SMALLLIGHTNING) {
		VectorCopy(bubblecolor[lt_blue], c->color);
		c->scale = 40;
		c->die = cl.time + 0.01;
		c->alpha = 0.33;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_ROCKETLIGHT) {
		dlightColorEx(r_rocketlightcolor.value, r_rocketlightcolor.string, lt_rocket, false, &cst_lt);
		c->alpha = 1;
		if (cst_lt.type == lt_custom) {
			VectorCopy(cst_lt.color, c->color);
			VectorScale(c->color, (1.0 / 255), c->color); // cast byte to float
			c->alpha = cst_lt.alpha * (1.0 / 255);
		}
		else {
			VectorCopy(bubblecolor[cst_lt.type], c->color);
		}
		c->scale = 60;
		c->die = cl.time + 0.01;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_GREENLIGHT) {
		c->color[0] = 0;
		c->color[1] = 1;
		c->color[2] = 0;
		c->scale = 20;
		c->die = cl.time + 0.01;
		c->alpha = 0.5;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_REDLIGHT) {
		c->color[0] = 1;
		c->color[1] = 0;
		c->color[2] = 0;
		c->scale = 20;
		c->die = cl.time + 0.01;
		c->alpha = 0.5;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_BLUESPARK) {
		VectorCopy(bubblecolor[lt_blue], c->color);
		c->scale = 30;
		c->die = cl.time + 0.75;
		c->alpha = 0.5;
		c->fade = -1;
		c->growth = -60;
	}
	else if (type == C_GUNFLASH) {
		vec3_t normal, impact, vec;
		c->color[0] = c->color[1] = c->color[2] = 1;
		c->texture = CORONATEX_GUNFLASH;
		c->scale = 50;
		c->die = cl.time + 0.1;
		c->alpha = 0.66;
		c->fade = 0;
		c->growth = -500;
		//A lot of the time the message is being sent just inside of a wall or something
		//I want to move it out of the wall so we can see it
		//Mainly for the hwguy
		//Sigh, if only they knew "omg see gunshots thru wall hax"
		CL_TraceLine(r_refdef.vieworg, origin, impact, normal);
		if (!VectorCompare(origin, impact)) {
			VectorSubtract(r_refdef.vieworg, origin, vec);
			VectorNormalize(vec);
			VectorMA(origin, 2, vec, c->origin);
		}
	}
	else if (type == C_EXPLODE) {
		c->color[0] = c->color[1] = c->color[2] = 1;
		c->scale = 200;
		c->die = cl.time + 0.03;
		c->alpha = 1;
		c->growth = 0;
		c->fade = 0;
		c->texture = CORONATEX_EXPLOSIONFLASH1;
	}
	else if (type == C_WHITELIGHT) {
		c->color[0] = 1;
		c->color[1] = 1;
		c->color[2] = 1;
		c->scale = 40;
		c->die = cl.time + 1;
		c->alpha = 0.5;
		c->fade = -1;
		c->growth = -200;
	}
	else if (type == C_WIZLIGHT) {
		c->color[0] = 0;
		c->color[1] = 0.5;
		c->color[2] = 0;
		c->scale = 60;
		c->die = cl.time + 0.01;
		c->alpha = 1;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_KNIGHTLIGHT) {
		c->color[0] = 1;
		c->color[1] = 0.3;
		c->color[2] = 0;
		c->scale = 60;
		c->die = cl.time + 0.01;
		c->alpha = 1;
		c->fade = 0;
		c->growth = 0;
	}
	else if (type == C_VORELIGHT) {
		c->color[0] = 0.3;
		c->color[1] = 0;
		c->color[2] = 1;
		c->scale = 60;
		c->die = cl.time + 0.01;
		c->alpha = 1;
		c->fade = 0;
		c->growth = 0;
	}
}

void R_CoronasNew(coronatype_t type, vec3_t origin)
{
	R_CoronasNewImpl(type, origin, 0);
}

void R_CoronasEntityNew(coronatype_t type, centity_t* cent)
{
	R_CoronasNewImpl(type, cent->lerp_origin, (cent - cl_entities) + 1);
}

void InitCoronas(void)
{
	corona_t *c;
	int i;

	//VULT STATS
	CoronaCount = 0;
	CoronaCountHigh = 0;
	for (i = 0; i < MAX_CORONAS; i++) {
		c = &r_corona[i];
		c->type = C_FREE;
		c->los = false;
		c->sighted = false;
	}
}

//NewStaticLightCorona
//Throws down a permanent light at origin, and wont put another on top of it
//This needs fixing so it wont be called so often
void NewStaticLightCorona(coronatype_t type, vec3_t origin, int entity_id)
{
	corona_t* c;
	corona_t* e = NULL;
	int	      i;
	qbool     breakage = true;

	if (entity_id) {
		int corona_id = cl_static_entities[entity_id - 1].corona_id;

		if (corona_id >= 0 && corona_id < MAX_CORONAS) {
			if (r_corona[corona_id].static_entity_id == entity_id) {
				e = &r_corona[corona_id];
			}
		}
	}

	if (!e) {
		c = r_corona;
		for (i = 0; i < MAX_CORONAS; i++, c++) {
			if (!e && c->type == C_FREE) {
				e = c;
				breakage = false;
			}
			else if (entity_id && entity_id == c->static_entity_id) {
				return;
			}

			if (c->type == C_FIRE && VectorCompare(c->origin, origin)) {
				return;
			}
		}
		if (breakage) {
			//no free coronas
			return;
		}
	}

	memset(e, 0, sizeof(*e));

	e->sighted = false;
	VectorCopy(origin, e->origin);
	e->type = type;
	e->los = false;
	e->texture = CORONATEX_STANDARD;
	e->static_entity_id = entity_id;
	if (entity_id) {
		cl_static_entities[entity_id - 1].corona_id = e - r_corona;
	}

	if (type == C_FIRE) {
		e->color[0] = 0.5;
		e->color[1] = 0.2;
		e->color[2] = 0.05;
		//e->scale = 0.1;
		e->scale = 150 + rand() % 15;
		e->die = cl.time + 800;
		e->alpha = 0.2f;
		e->fade = 0.5;
		e->growth = 800;
	}
}

static void CoronaStats(int change)
{
	if (CoronaCount > CoronaCountHigh) {
		CoronaCountHigh = CoronaCount;
	}
	CoronaCount += change;
}

void VX_FlagTexturesForArray(texture_flag_t* texture_flags)
{
	corona_texture_id tex;

	for (tex = CORONATEX_STANDARD; tex < CORONATEX_COUNT; ++tex) {
		if (R_TextureReferenceIsValid(corona_textures[tex].texnum)) {
			texture_flags[corona_textures[tex].texnum.index].flags |= (1 << TEXTURETYPES_SPRITES);
		}
	}
}

void VX_ImportTextureArrayReferences(texture_flag_t* texture_flags)
{
	corona_texture_id tex;

	for (tex = CORONATEX_STANDARD; tex < CORONATEX_COUNT; ++tex) {
		if (R_TextureReferenceIsValid(corona_textures[tex].texnum)) {
			texture_array_ref_t* array_ref = &texture_flags[corona_textures[tex].texnum.index].array_ref[TEXTURETYPES_SPRITES];

			corona_textures[tex].array_tex = array_ref->ref;
			corona_textures[tex].array_index = array_ref->index;
			corona_textures[tex].array_scale_s = array_ref->scale_s;
			corona_textures[tex].array_scale_t = array_ref->scale_t;
		}
	}
}
