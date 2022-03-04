/*
	vid_common_vulkan.c

	Common Vulkan video driver functions

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

#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif

#ifdef HAVE_MATH_H
# include <math.h>
#endif

#include "QF/cvar.h"
#include "QF/sys.h"
#include "QF/va.h"
#include "QF/vid.h"
#include "QF/Vulkan/qf_matrices.h"
#include "QF/Vulkan/barrier.h"
#include "QF/Vulkan/buffer.h"
#include "QF/Vulkan/debug.h"
#include "QF/Vulkan/descriptor.h"
#include "QF/Vulkan/device.h"
#include "QF/Vulkan/instance.h"
#include "QF/Vulkan/projection.h"
#include "QF/Vulkan/renderpass.h"
#include "QF/Vulkan/staging.h"
#include "QF/ui/view.h"

#include "r_internal.h"
#include "vid_vulkan.h"

#include "util.h"

static void
setup_view (vulkan_ctx_t *ctx)
{
	mat4f_t     view;
	static mat4f_t z_up = {
		{ 0, 0, -1, 0},
		{-1, 0,  0, 0},
		{ 0, 1,  0, 0},
		{ 0, 0,  0, 1},
	};
	vec4f_t     offset = { 0, 0, 0, 1 };

	/*x = r_refdef.vrect.x;
	y = (vid.height - (r_refdef.vrect.y + r_refdef.vrect.height));
	w = r_refdef.vrect.width;
	h = r_refdef.vrect.height;
	qfeglViewport (x, y, w, h);*/

	mat4fquat (view, qconjf (r_refdef.viewrotation));
	mmulf (view, z_up, view);
	offset = -r_refdef.viewposition;
	offset[3] = 1;
	view[3] = mvmulf (view, offset);
	Vulkan_SetViewMatrix (ctx, view);
}

void
Vulkan_SetViewMatrix (vulkan_ctx_t *ctx, mat4f_t view)
{
	__auto_type mctx = ctx->matrix_context;

	if (memcmp (mctx->matrices.View, view, sizeof (mat4f_t))) {
		memcpy (mctx->matrices.View, view, sizeof (mat4f_t));
		mctx->dirty = mctx->frames.size;
	}
}

void
Vulkan_Matrix_Draw (qfv_renderframe_t *rFrame)
{
	vulkan_ctx_t *ctx = rFrame->vulkan_ctx;
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;

	__auto_type mctx = ctx->matrix_context;
	__auto_type mframe = &mctx->frames.a[ctx->curFrame];

	setup_view (ctx);

	if (mctx->dirty <= 0) {
		mctx->dirty = 0;
		return;
	}

	mctx->dirty--;

	qfv_packet_t *packet = QFV_PacketAcquire (mctx->stage);
	qfv_matrix_buffer_t *m = QFV_PacketExtend (packet, sizeof (*m));
	*m = mctx->matrices;

	qfv_bufferbarrier_t bb = bufferBarriers[qfv_BB_Unknown_to_TransferWrite];		bb.barrier.buffer = mframe->buffer;
	bb.barrier.size = packet->length;

	dfunc->vkCmdPipelineBarrier (packet->cmd, bb.srcStages, bb.dstStages,
								 0, 0, 0, 1, &bb.barrier, 0, 0);

	VkBufferCopy copy_region = { packet->offset, 0, packet->length };
	dfunc->vkCmdCopyBuffer (packet->cmd, mctx->stage->buffer,
							mframe->buffer, 1, &copy_region);

	bb = bufferBarriers[qfv_LT_TransferDst_to_ShaderReadOnly];
	bb.barrier.buffer = mframe->buffer;
	bb.barrier.size = packet->length;

	dfunc->vkCmdPipelineBarrier (packet->cmd, bb.srcStages, bb.dstStages,
								 0, 0, 0, 1, &bb.barrier, 0, 0);

	QFV_PacketSubmit (packet);
}

void
Vulkan_CalcProjectionMatrices (vulkan_ctx_t *ctx)
{
	__auto_type mctx = ctx->matrix_context;
	__auto_type mat = &mctx->matrices;

	int width = vid.conview->xlen;
	int height = vid.conview->ylen;
	QFV_Orthographic (mat->Projection2d, 0, width, 0, height, 0, 99999);

	float       aspect = (float) r_refdef.vrect.width / r_refdef.vrect.height;
	QFV_Perspective (mat->Projection3d, r_refdef.fov_y, aspect);
#if 0
	Sys_MaskPrintf (SYS_vulkan, "ortho:\n");
	Sys_MaskPrintf (SYS_vulkan, "   [[%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection2d + 0));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection2d + 4));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection2d + 8));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g]]\n",
					QuatExpand (mat->Projection2d + 12));
	Sys_MaskPrintf (SYS_vulkan, "presp:\n");
	Sys_MaskPrintf (SYS_vulkan, "   [[%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection3d + 0));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection3d + 4));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g],\n",
					QuatExpand (mat->Projection3d + 8));
	Sys_MaskPrintf (SYS_vulkan, "    [%g, %g, %g, %g]]\n",
					QuatExpand (mat->Projection3d + 12));
#endif
	mctx->dirty = mctx->frames.size;
}

void
Vulkan_Matrix_Init (vulkan_ctx_t *ctx)
{
	qfvPushDebug (ctx, "matrix init");
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;

	matrixctx_t *mctx = calloc (1, sizeof (matrixctx_t));
	ctx->matrix_context = mctx;

	size_t      frames = ctx->frames.size;
	DARRAY_INIT (&mctx->frames, frames);
	DARRAY_RESIZE (&mctx->frames, frames);
	mctx->frames.grow = 0;

	//__auto_type cmdBuffers = QFV_AllocCommandBufferSet (frames, alloca);
	//QFV_AllocateCommandBuffers (device, ctx->cmdpool, 1, cmdBuffers);

	mctx->pool = Vulkan_CreateDescriptorPool (ctx, "matrix_pool");
	mctx->setLayout = Vulkan_CreateDescriptorSetLayout (ctx, "matrix_set");
	__auto_type layouts = QFV_AllocDescriptorSetLayoutSet (frames, alloca);
	for (size_t i = 0; i < layouts->size; i++) {
		layouts->a[i] = mctx->setLayout;
	}

	for (size_t i = 0; i < frames; i++) {
		__auto_type mframe = &mctx->frames.a[i];
		//mframe->cmd = cmdBuffers->a[i];
		mframe->buffer = QFV_CreateBuffer (device, sizeof (qfv_matrix_buffer_t),
										   VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT
										   | VK_BUFFER_USAGE_TRANSFER_DST_BIT);
		QFV_duSetObjectName (device, VK_OBJECT_TYPE_BUFFER,
							 mframe->buffer, va (ctx->va_ctx,
												 "buffer:matrices:%zd", i));
	}

	VkMemoryRequirements req;
	//offset = (offset + req.alignment - 1) & ~(req.alignment - 1);
	dfunc->vkGetBufferMemoryRequirements (device->dev,
										  mctx->frames.a[0].buffer, &req);
	mctx->memory = QFV_AllocBufferMemory (device, mctx->frames.a[0].buffer,
										  VK_MEMORY_PROPERTY_HOST_CACHED_BIT,
										  frames * req.size, 0);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_DEVICE_MEMORY,
						 mctx->memory, "memory:matrices");

	__auto_type sets = QFV_AllocateDescriptorSet (device, mctx->pool, layouts);
	for (size_t i = 0; i < frames; i++) {
		__auto_type mframe = &mctx->frames.a[i];
		QFV_BindBufferMemory (device, mframe->buffer, mctx->memory,
							  i * req.size);

		mframe->descriptors = sets->a[i];
		VkDescriptorBufferInfo bufferInfo = {
			mframe->buffer, 0, VK_WHOLE_SIZE
		};
		VkWriteDescriptorSet write[] = {
			{ VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET, 0,
			  mframe->descriptors, 0, 0, 1,
			  VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
			  0, &bufferInfo, 0 },
		};
		dfunc->vkUpdateDescriptorSets (device->dev, 1, write, 0, 0);
	}
	free (sets);

	mat4fidentity (mctx->matrices.Projection3d);
	mat4fidentity (mctx->matrices.View);
	mat4fidentity (mctx->matrices.Sky);
	mat4fidentity (mctx->matrices.Projection2d);
	mctx->dirty = mctx->frames.size;

	mctx->stage = QFV_CreateStagingBuffer (device, "matrix",
										frames * sizeof (qfv_matrix_buffer_t),
										ctx->cmdpool);

	qfvPopDebug (ctx);
}

void
Vulkan_Matrix_Shutdown (vulkan_ctx_t *ctx)
{
	qfvPushDebug (ctx, "matrix shutdown");
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;

	__auto_type mctx = ctx->matrix_context;

	QFV_DestroyStagingBuffer (mctx->stage);

	for (size_t i = 0; i < mctx->frames.size; i++) {
		__auto_type mframe = &mctx->frames.a[i];
		dfunc->vkDestroyBuffer (device->dev, mframe->buffer, 0);
	}
	dfunc->vkFreeMemory (device->dev, mctx->memory, 0);
	qfvPopDebug (ctx);
}

VkDescriptorSet
Vulkan_Matrix_Descriptors (vulkan_ctx_t *ctx, int frame)
{
	__auto_type mctx = ctx->matrix_context;
	return mctx->frames.a[frame].descriptors;
}
