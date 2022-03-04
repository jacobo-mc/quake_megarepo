/*
	vulkan_particles.c

	Quake specific Vulkan particle manager

	Copyright (C) 2021      Bill Currie <bill@taniwha.org>

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
#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_MATH_H
# include <math.h>
#endif
#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif

#include "QF/cvar.h"
#include "QF/render.h"
#include "QF/va.h"

#include "QF/plugin/vid_render.h"

#include "QF/Vulkan/qf_vid.h" //FIXME header issues
#include "QF/Vulkan/buffer.h"
#include "QF/Vulkan/debug.h"
#include "QF/Vulkan/device.h"
#include "QF/Vulkan/instance.h"
#include "QF/Vulkan/staging.h"
#include "QF/Vulkan/qf_particles.h"

#include "r_internal.h"
#include "vid_vulkan.h"

//FIXME make dynamic
#define MaxParticles 2048

static const char * __attribute__((used)) particle_pass_names[] = {
	"draw",
};

void
Vulkan_DrawParticles (vulkan_ctx_t *ctx)
{
}

static void
create_buffers (vulkan_ctx_t *ctx)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	particlectx_t *pctx = ctx->particle_context;
	size_t      size = 0;
	size_t      mp = MaxParticles;

	VkMemoryRequirements stReq, parmReq, sysReq;
	for (size_t i = 0; i < pctx->frames.size; i++) {
		__auto_type pframe = &pctx->frames.a[i];
		pframe->state
			= QFV_CreateBuffer (device, sizeof (qfv_particle_t) * mp,
								VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
								| VK_BUFFER_USAGE_VERTEX_BUFFER_BIT);
		pframe->params
			= QFV_CreateBuffer (device, sizeof (qfv_particle_t) * mp,
								VK_BUFFER_USAGE_STORAGE_BUFFER_BIT);
		pframe->system
			= QFV_CreateBuffer (device, sizeof (qfv_particle_t) * mp,
								VK_BUFFER_USAGE_STORAGE_BUFFER_BIT
								| VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT);
		dfunc->vkGetBufferMemoryRequirements (device->dev, pframe->state,
											  &stReq);
		dfunc->vkGetBufferMemoryRequirements (device->dev, pframe->params,
											  &parmReq);
		dfunc->vkGetBufferMemoryRequirements (device->dev, pframe->system,
											  &sysReq);
		size = QFV_NextOffset (size + stReq.size, &stReq);
		size = QFV_NextOffset (size + parmReq.size, &parmReq);
		size = QFV_NextOffset (size + sysReq.size, &sysReq);
	}
	size_t      stageSize = (size / pctx->frames.size)*(pctx->frames.size + 1);
	pctx->stage = QFV_CreateStagingBuffer (device, "particles", stageSize,
										   ctx->cmdpool);
	pctx->memory = QFV_AllocBufferMemory (device, pctx->frames.a[0].state,
										  VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
										  size, 0);
	size_t      offset = 0;
	for (size_t i = 0; i < pctx->frames.size; i++) {
		__auto_type pframe = &pctx->frames.a[i];
		QFV_BindBufferMemory (device, pframe->state, pctx->memory, offset);
		offset = QFV_NextOffset (offset + stReq.size, &parmReq);
		QFV_BindBufferMemory (device, pframe->params, pctx->memory, offset);
		offset = QFV_NextOffset (offset + parmReq.size, &sysReq);
		QFV_BindBufferMemory (device, pframe->system, pctx->memory, offset);
		offset = QFV_NextOffset (offset + sysReq.size, &stReq);
	}
}

void
Vulkan_Particles_Init (vulkan_ctx_t *ctx)
{
	qfv_device_t *device = ctx->device;

	qfvPushDebug (ctx, "particles init");

	particlectx_t *pctx = calloc (1, sizeof (particlectx_t));
	ctx->particle_context = pctx;

	size_t      frames = ctx->frames.size;
	DARRAY_INIT (&pctx->frames, frames);
	DARRAY_RESIZE (&pctx->frames, frames);
	pctx->frames.grow = 0;

	pctx->physics = Vulkan_CreateComputePipeline (ctx, "partphysics");
	pctx->update = Vulkan_CreateComputePipeline (ctx, "partupdate");
	pctx->draw = Vulkan_CreateGraphicsPipeline (ctx, "partdraw");
	pctx->physics_layout = Vulkan_CreatePipelineLayout (ctx,
														"partphysics_layout");
	pctx->update_layout = Vulkan_CreatePipelineLayout (ctx,
													   "partupdate_layout");
	pctx->draw_layout = Vulkan_CreatePipelineLayout (ctx, "partdraw_layout");

	pctx->pool = Vulkan_CreateDescriptorPool (ctx, "particle_pool");
	pctx->setLayout = Vulkan_CreateDescriptorSetLayout (ctx, "particle_set");

	for (size_t i = 0; i < frames; i++) {
		__auto_type pframe = &pctx->frames.a[i];

		DARRAY_INIT (&pframe->cmdSet, QFV_particleNumPasses);
		DARRAY_RESIZE (&pframe->cmdSet, QFV_particleNumPasses);
		pframe->cmdSet.grow = 0;

		QFV_AllocateCommandBuffers (device, ctx->cmdpool, 1, &pframe->cmdSet);

		for (int j = 0; j < QFV_particleNumPasses; j++) {
			QFV_duSetObjectName (device, VK_OBJECT_TYPE_COMMAND_BUFFER,
								 pframe->cmdSet.a[j],
								 va (ctx->va_ctx, "cmd:particle:%zd:%s", i,
									 particle_pass_names[j]));
		}
	}
	create_buffers (ctx);
	qfvPopDebug (ctx);
}

void
Vulkan_Particles_Shutdown (vulkan_ctx_t *ctx)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	particlectx_t *pctx = ctx->particle_context;

	for (size_t i = 0; i < pctx->frames.size; i++) {
		__auto_type pframe = &pctx->frames.a[i];
		free (pframe->cmdSet.a);
		dfunc->vkDestroyBuffer (device->dev, pframe->state, 0);
		dfunc->vkDestroyBuffer (device->dev, pframe->params, 0);
		dfunc->vkDestroyBuffer (device->dev, pframe->system, 0);
	}
	dfunc->vkFreeMemory (device->dev, pctx->memory, 0);
	QFV_DestroyStagingBuffer (pctx->stage);

	dfunc->vkDestroyPipeline (device->dev, pctx->physics, 0);
	dfunc->vkDestroyPipeline (device->dev, pctx->update, 0);
	dfunc->vkDestroyPipeline (device->dev, pctx->draw, 0);
	free (pctx->frames.a);
	free (pctx);
}

psystem_t *__attribute__((pure))//FIXME?
Vulkan_ParticleSystem (vulkan_ctx_t *ctx)
{
	return &ctx->particle_context->psystem;	//FIXME support more
}
