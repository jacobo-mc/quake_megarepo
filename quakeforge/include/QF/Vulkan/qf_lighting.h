/*
	qf_lighting.h

	Vulkan lighting pass

	Copyright (C) 2021 Bill Currie <bill@taniwha.org>

	Author: Bill Currie <bill@taniwha.org>
	Date: 2021/2/23

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
#ifndef __QF_Vulkan_qf_lighting_h
#define __QF_Vulkan_qf_lighting_h

#include "QF/darray.h"
#include "QF/model.h"
#include "QF/modelgen.h"
#include "QF/Vulkan/qf_vid.h"
#include "QF/Vulkan/command.h"
#include "QF/Vulkan/image.h"
#include "QF/simd/types.h"

typedef struct qfv_light_s {
	vec3_t      color;
	int         data;
	vec3_t      position;
	float       light;
	vec3_t      direction;
	float       cone;
} qfv_light_t;

typedef struct qfv_lightset_s DARRAY_TYPE (qfv_light_t) qfv_lightset_t;
typedef struct qfv_lightleafset_s DARRAY_TYPE (int) qfv_lightintset_t;
typedef struct qfv_lightvisset_s DARRAY_TYPE (byte) qfv_lightvisset_t;
typedef struct qfv_lightmatset_s DARRAY_TYPE (mat4f_t) qfv_lightmatset_t;

#define MaxLights   256

#define StyleMask   0x07f
#define ModelMask   0x380
#define ShadowMask  0xc00

#define LM_LINEAR   (0 << 7)	// light - dist (or radius + dist if -ve)
#define LM_INVERSE  (1 << 7)	// distFactor1 * light / dist
#define LM_INVERSE2 (2 << 7)	// distFactor2 * light / (dist * dist)
#define LM_INFINITE (3 << 7)	// light
#define LM_AMBIENT  (4 << 7)	// light
#define LM_INVERSE3 (5 << 7)	// distFactor2 * light / (dist + distFactor2)**2

#define ST_NONE     (0 << 10)	// no shadows
#define ST_PLANE    (1 << 10)	// single plane shadow map (small spotlight)
#define ST_CASCADE  (2 << 10)	// cascaded shadow maps
#define ST_CUBE     (3 << 10)	// cubemap (omni, large spotlight)

#define NumStyles 64

typedef struct qfv_light_buffer_s {
	float       intensity[NumStyles + 4];
	float       distFactor1;
	float       distFactor2;
	int         lightCount;
	qfv_light_t lights[MaxLights] __attribute__((aligned(16)));
	mat4f_t     shadowMat[MaxLights];
	vec4f_t     shadowCascade[MaxLights];
} qfv_light_buffer_t;

#define LIGHTING_BUFFER_INFOS 1
#define LIGHTING_ATTACH_INFOS 5
#define LIGHTING_SHADOW_INFOS MaxLights
#define LIGHTING_DESCRIPTORS (LIGHTING_BUFFER_INFOS + LIGHTING_ATTACH_INFOS + 1)

typedef struct lightingframe_s {
	VkCommandBuffer cmd;
	VkBuffer    light_buffer;
	VkDescriptorBufferInfo bufferInfo[LIGHTING_BUFFER_INFOS];
	VkDescriptorImageInfo attachInfo[LIGHTING_ATTACH_INFOS];
	VkDescriptorImageInfo shadowInfo[LIGHTING_SHADOW_INFOS];
	union {
		VkWriteDescriptorSet descriptors[LIGHTING_DESCRIPTORS];
		struct {
			VkWriteDescriptorSet bufferWrite[LIGHTING_BUFFER_INFOS];
			VkWriteDescriptorSet attachWrite[LIGHTING_ATTACH_INFOS];
			VkWriteDescriptorSet shadowWrite;
		};
	};
	// A fat PVS of leafs visible from visible leafs so hidden lights can
	// illuminate the leafs visible to the player
	struct set_s *pvs;
	struct mleaf_s *leaf;	// the last leaf used to generate the pvs
	qfv_lightvisset_t lightvis;
} lightingframe_t;

typedef struct lightingframeset_s
    DARRAY_TYPE (lightingframe_t) lightingframeset_t;

typedef struct lightingctx_s {
	lightingframeset_t frames;
	VkPipeline   pipeline;
	VkPipelineLayout layout;
	VkSampler    sampler;
	VkDeviceMemory light_memory;
	VkDeviceMemory shadow_memory;
	qfv_lightset_t lights;
	qfv_lightintset_t lightleafs;
	qfv_lightmatset_t lightmats;
	qfv_imageset_t lightimages;
	qfv_lightintset_t lightlayers;
	qfv_imageviewset_t lightviews;
	struct set_s *sun_pvs;
} lightingctx_t;

struct vulkan_ctx_s;
struct qfv_renderframe_s;

void Vulkan_Lighting_Init (struct vulkan_ctx_s *ctx);
void Vulkan_Lighting_Shutdown (struct vulkan_ctx_s *ctx);
void Vulkan_Lighting_Draw (struct qfv_renderframe_s *rFrame);
void Vulkan_LoadLights (model_t *model, const char *entity_data,
						struct vulkan_ctx_s *ctx);

#endif//__QF_Vulkan_qf_lighting_h
