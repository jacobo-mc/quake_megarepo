/*
	vulkan_texuture.c

	Quake specific Vulkan texuture manager

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

#include "QF/alloc.h"
#include "QF/cvar.h"
#include "QF/dstring.h"
#include "QF/hash.h"
#include "QF/image.h"
#include "QF/mathlib.h"
#include "QF/quakefs.h"
#include "QF/render.h"
#include "QF/sys.h"
#include "QF/va.h"
#include "QF/Vulkan/qf_vid.h"
#include "QF/Vulkan/qf_texture.h"
#include "QF/Vulkan/barrier.h"
#include "QF/Vulkan/buffer.h"
#include "QF/Vulkan/command.h"
#include "QF/Vulkan/debug.h"
#include "QF/Vulkan/descriptor.h"
#include "QF/Vulkan/device.h"
#include "QF/Vulkan/image.h"
#include "QF/Vulkan/instance.h"
#include "QF/Vulkan/scrap.h"
#include "QF/Vulkan/staging.h"

#include "r_scrap.h"
#include "vid_vulkan.h"

void
Vulkan_ExpandPalette (byte *dst, const byte *src, const byte *palette,
					  int alpha, int count)
{
	if (alpha > 1) {
		while (count-- > 0) {
			int         pix = *src++;
			const byte *col = palette + pix * 4;
			*dst++ = *col++;
			*dst++ = *col++;
			*dst++ = *col++;
			*dst++ = *col++;
		}
	} else if (alpha) {
		while (count-- > 0) {
			byte        pix = *src++;
			const byte *col = palette + pix * 3;
			*dst++ = *col++;
			*dst++ = *col++;
			*dst++ = *col++;
			*dst++ = 0xff;
		}
	} else {
		while (count-- > 0) {
			byte        pix = *src++;
			const byte *col = palette + pix * 3;
			*dst++ = *col++;
			*dst++ = *col++;
			*dst++ = *col++;
		}
	}
}

static int
tex_format (const tex_t *tex, VkFormat *format, int *bpp)
{
	switch (tex->format) {
		case tex_l:
		case tex_a:
			*format = VK_FORMAT_R8_UNORM;
			*bpp = 1;
			return 1;
		case tex_la:
			*format = VK_FORMAT_R8G8_UNORM;
			*bpp = 2;
			return 1;
		case tex_palette:
			if (!tex->palette) {
				return 0;
			}
			*format = VK_FORMAT_R8G8B8A8_UNORM;
			*bpp = 4;
			return 1;
		case tex_rgb:
			*format = VK_FORMAT_R8G8B8A8_UNORM;
			*bpp = 4;
			return 1;
		case tex_rgba:
			*format = VK_FORMAT_R8G8B8A8_UNORM;
			*bpp = 4;
			return 1;
		case tex_frgba:
			*format = VK_FORMAT_R32G32B32A32_SFLOAT;
			*bpp = 16;
			return 1;
	}
	return 0;
}

static size_t
stage_tex_data (qfv_packet_t *packet, tex_t *tex, int bpp)
{
	size_t      texels = tex->width * tex->height;
	byte       *tex_data = QFV_PacketExtend (packet, bpp * texels);

	if (tex->format == tex_palette) {
		Vulkan_ExpandPalette (tex_data, tex->data, tex->palette, 1, texels);
	} else {
		if (tex->format == 3) {
			byte       *in = tex->data;
			byte       *out = tex_data;
			while (texels-- > 0) {
				*out++ = *in++;
				*out++ = *in++;
				*out++ = *in++;
				*out++ = 255;
			}
		} else {
			memcpy (tex_data, tex->data, bpp * texels);
		}
	}
	return tex_data - (byte *) packet->stage->data;
}

qfv_tex_t *
Vulkan_LoadTex (vulkan_ctx_t *ctx, tex_t *tex, int mip, const char *name)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	int         bpp;
	VkFormat    format;

	if (!tex_format (tex, &format, &bpp)) {
		return 0;
	}

	if (mip) {
		mip = QFV_MipLevels (tex->width, tex->height);
	} else {
		mip = 1;
	}

	//qfv_devfuncs_t *dfunc = device->funcs;
	//FIXME this whole thing is ineffiecient, especially for small textures
	qfv_tex_t  *qtex = malloc (sizeof (qfv_tex_t));

	VkExtent3D  extent = { tex->width, tex->height, 1 };
	qtex->image = QFV_CreateImage (device, 0, VK_IMAGE_TYPE_2D, format, extent,
								   mip, 1, VK_SAMPLE_COUNT_1_BIT,
								   VK_IMAGE_USAGE_TRANSFER_DST_BIT
								   | VK_IMAGE_USAGE_TRANSFER_SRC_BIT
								   | VK_IMAGE_USAGE_SAMPLED_BIT);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_IMAGE, qtex->image,
						 va (ctx->va_ctx, "image:%s", name));
	qtex->memory = QFV_AllocImageMemory (device, qtex->image,
										 VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
										 0, 0);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_DEVICE_MEMORY, qtex->memory,
						 va (ctx->va_ctx, "memory:%s", name));
	QFV_BindImageMemory (device, qtex->image, qtex->memory, 0);
	qtex->view = QFV_CreateImageView (device, qtex->image,
									  VK_IMAGE_VIEW_TYPE_2D,
									  VK_FORMAT_R8G8B8A8_UNORM,
									  VK_IMAGE_ASPECT_COLOR_BIT);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_IMAGE_VIEW, qtex->view,
						 va (ctx->va_ctx, "iview:%s", name));

	qfv_packet_t *packet = QFV_PacketAcquire (ctx->staging);
	stage_tex_data (packet, tex, bpp);

	qfv_imagebarrier_t ib = imageBarriers[qfv_LT_Undefined_to_TransferDst];
	ib.barrier.image = qtex->image;
	ib.barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
	dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
								 0, 0, 0, 0, 0,
								 1, &ib.barrier);
	VkBufferImageCopy copy = {
		packet->offset, 0, 0,
		{VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
		{0, 0, 0}, {tex->width, tex->height, 1},
	};
	dfunc->vkCmdCopyBufferToImage (packet->cmd, packet->stage->buffer,
								   qtex->image,
								   VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
								   1, &copy);
	if (mip == 1) {
		ib = imageBarriers[qfv_LT_TransferDst_to_ShaderReadOnly];
		ib.barrier.image = qtex->image;
		dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
									 0, 0, 0, 0, 0,
									 1, &ib.barrier);
	} else {
		QFV_GenerateMipMaps (device, packet->cmd, qtex->image,
							 mip, tex->width, tex->height, 1);
	}
	QFV_PacketSubmit (packet);
	return qtex;
}

static qfv_tex_t *
create_cubetex (vulkan_ctx_t *ctx, int size, VkFormat format,
				const char *name)
{
	qfv_device_t *device = ctx->device;

	qfv_tex_t  *qtex = malloc (sizeof (qfv_tex_t));

	VkExtent3D  extent = { size, size, 1 };
	qtex->image = QFV_CreateImage (device, 1, VK_IMAGE_TYPE_2D, format, extent,
								   1, 1, VK_SAMPLE_COUNT_1_BIT,
								   VK_IMAGE_USAGE_SAMPLED_BIT
								   | VK_IMAGE_USAGE_TRANSFER_DST_BIT);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_IMAGE, qtex->image,
						 va (ctx->va_ctx, "image:envmap:%s", name));
	qtex->memory = QFV_AllocImageMemory (device, qtex->image,
										 VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
										 0, 0);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_DEVICE_MEMORY, qtex->memory,
						 va (ctx->va_ctx, "memory:%s", name));
	QFV_BindImageMemory (device, qtex->image, qtex->memory, 0);
	qtex->view = QFV_CreateImageView (device, qtex->image,
									  VK_IMAGE_VIEW_TYPE_CUBE, format,
									  VK_IMAGE_ASPECT_COLOR_BIT);
	QFV_duSetObjectName (device, VK_OBJECT_TYPE_IMAGE_VIEW, qtex->view,
						 va (ctx->va_ctx, "iview:envmap:%s", name));

	return qtex;
}

qfv_tex_t *
Vulkan_LoadEnvMap (vulkan_ctx_t *ctx, tex_t *tex, const char *name)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	int         bpp;
	VkFormat    format;

	static int env_coords[][2] = {
		{2, 0},	// right
		{0, 0}, // left
		{1, 1}, // top
		{0, 1}, // bottom
		{2, 1}, // front
		{1, 0}, // back
	};

	if (!tex_format (tex, &format, &bpp)) {
		return 0;
	}
	if (tex->height * 3 != tex->width * 2) {
		return 0;
	}

	int size = tex->height / 2;
	qfv_tex_t  *qtex = create_cubetex (ctx, size, format, name);

	qfv_packet_t *packet = QFV_PacketAcquire (ctx->staging);
	stage_tex_data (packet, tex, bpp);

	qfv_imagebarrier_t ib = imageBarriers[qfv_LT_Undefined_to_TransferDst];
	ib.barrier.image = qtex->image;
	ib.barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
	ib.barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
	dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
								 0, 0, 0, 0, 0,
								 1, &ib.barrier);

	VkBufferImageCopy copy[6] = {
		{
			0, tex->width, 0,
			{VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
			{0, 0, 0}, {size, size, 1},
		},
	};
	for (int i = 0; i < 6; i++) {
		int     x = env_coords[i][0] * size;
		int     y = env_coords[i][1] * size;
		int offset = x + y * tex->width;
		copy[i] = copy[0];
		copy[i].bufferOffset = packet->offset + bpp * offset;
		copy[i].imageSubresource.baseArrayLayer = i;
	}
	dfunc->vkCmdCopyBufferToImage (packet->cmd, packet->stage->buffer,
								   qtex->image,
								   VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
								   6, copy);
	ib = imageBarriers[qfv_LT_TransferDst_to_ShaderReadOnly];
	ib.barrier.image = qtex->image;
	ib.barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
	ib.barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
	dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
								 0, 0, 0, 0, 0,
								 1, &ib.barrier);
	QFV_PacketSubmit (packet);
	return qtex;
}

qfv_tex_t *
Vulkan_LoadEnvSides (vulkan_ctx_t *ctx, tex_t **tex, const char *name)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	int         bpp;
	VkFormat    format;

	if (!tex_format (tex[0], &format, &bpp)) {
		return 0;
	}
	if (tex[0]->height != tex[0]->width) {
		return 0;
	}
	for (int i = 1; i < 6; i++) {
		if (tex[i]->format != tex[0]->format
			|| tex[i]->width != tex[0]->width
			|| tex[i]->height != tex[0]->height) {
			return 0;
		}
	}

	int size = tex[0]->height;
	qfv_tex_t  *qtex = create_cubetex (ctx, size, format, name);

	qfv_packet_t *packet = QFV_PacketAcquire (ctx->staging);

	qfv_imagebarrier_t ib = imageBarriers[qfv_LT_Undefined_to_TransferDst];
	ib.barrier.image = qtex->image;
	ib.barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
	ib.barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
	dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
								 0, 0, 0, 0, 0,
								 1, &ib.barrier);

	VkBufferImageCopy copy[6] = {
		{
			0, 0, 0,
			{VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
			{0, 0, 0}, {size, size, 1},
		},
	};
	for (int i = 0; i < 6; i++) {
		copy[i] = copy[0];
		copy[i].bufferOffset = stage_tex_data (packet, tex[i], bpp);
		copy[i].imageSubresource.baseArrayLayer = i;
	}
	dfunc->vkCmdCopyBufferToImage (packet->cmd, packet->stage->buffer,
								   qtex->image,
								   VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
								   6, copy);
	ib = imageBarriers[qfv_LT_TransferDst_to_ShaderReadOnly];
	ib.barrier.image = qtex->image;
	ib.barrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
	ib.barrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
	dfunc->vkCmdPipelineBarrier (packet->cmd, ib.srcStages, ib.dstStages,
								 0, 0, 0, 0, 0,
								 1, &ib.barrier);
	QFV_PacketSubmit (packet);
	return qtex;
}

VkImageView
Vulkan_TexImageView (qfv_tex_t *tex)
{
	return tex->view;
}

void
Vulkan_UnloadTex (vulkan_ctx_t *ctx, qfv_tex_t *tex)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;

	if (tex->view) {
		dfunc->vkDestroyImageView (device->dev, tex->view, 0);
	}
	if (tex->image) {
		dfunc->vkDestroyImage (device->dev, tex->image, 0);
	}
	if (tex->memory) {
		dfunc->vkFreeMemory (device->dev, tex->memory, 0);
	}
	free (tex);
}

static byte black_data[] = {0, 0, 0, 0};
static byte white_data[] = {255, 255, 255, 255};
static byte magenta_data[] = {255, 0, 255, 255};
static tex_t default_black_tex = {1, 1, tex_rgba, 1, 0, black_data};
static tex_t default_white_tex = {1, 1, tex_rgba, 1, 0, white_data};
static tex_t default_magenta_tex = {1, 1, tex_rgba, 1, 0, magenta_data};

void
Vulkan_Texture_Init (vulkan_ctx_t *ctx)
{
	qfvPushDebug (ctx, "texture init");

	texturectx_t   *tctx = calloc (1, sizeof (texturectx_t));
	ctx->texture_context = tctx;

	tctx->pool = Vulkan_CreateDescriptorPool (ctx, "texture_pool");
	tctx->setLayout = Vulkan_CreateDescriptorSetLayout (ctx, "texture_set");

	ctx->default_black = Vulkan_LoadTex (ctx, &default_black_tex, 1,
										 "default_black");
	ctx->default_white = Vulkan_LoadTex (ctx, &default_white_tex, 1,
										 "default_white");
	ctx->default_magenta = Vulkan_LoadTex (ctx, &default_magenta_tex, 1,
										   "default_magenta");
	qfv_tex_t  *tex;
	tex = ctx->default_magenta_array = malloc (sizeof (qfv_tex_t));
	tex->memory = 0;
	tex->image = 0;
	tex->view = QFV_CreateImageView (ctx->device, ctx->default_magenta->image,
									 VK_IMAGE_VIEW_TYPE_2D_ARRAY,
									 VK_FORMAT_R8G8B8A8_UNORM,
									 VK_IMAGE_ASPECT_COLOR_BIT);
	qfvPopDebug (ctx);
}

void
Vulkan_Texture_Shutdown (vulkan_ctx_t *ctx)
{
	Vulkan_UnloadTex (ctx, ctx->default_black);
	Vulkan_UnloadTex (ctx, ctx->default_white);
	Vulkan_UnloadTex (ctx, ctx->default_magenta);
	Vulkan_UnloadTex (ctx, ctx->default_magenta_array);
}

static VkDescriptorImageInfo base_image_info = {
	.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
};
static VkWriteDescriptorSet base_image_write = {
	.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
	.dstBinding = 0,
	.descriptorCount = 1,
	.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
};

VkDescriptorSet
Vulkan_CreateCombinedImageSampler (vulkan_ctx_t *ctx, VkImageView view,
								   VkSampler sampler)
{
	qfvPushDebug (ctx, "Vulkan_CreateCombinedImageSampler");

	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	texturectx_t *tctx = ctx->texture_context;

	//FIXME kinda dumb
	__auto_type layouts = QFV_AllocDescriptorSetLayoutSet (1, alloca);
	for (size_t i = 0; i < layouts->size; i++) {
		layouts->a[i] = tctx->setLayout;
	}
	__auto_type sets = QFV_AllocateDescriptorSet (device, tctx->pool, layouts);
	VkDescriptorSet descriptor = sets->a[0];
	free (sets);

	VkDescriptorImageInfo imageInfo[1];
	imageInfo[0] = base_image_info;
	imageInfo[0].sampler = sampler;
	imageInfo[0].imageView = view;

	VkWriteDescriptorSet write[1];
	write[0] = base_image_write;
	write[0].dstSet = descriptor;
	write[0].pImageInfo = imageInfo;
	dfunc->vkUpdateDescriptorSets (device->dev, 1, write, 0, 0);

	qfvPopDebug (ctx);

	return descriptor;
}

VkDescriptorSet
Vulkan_CreateTextureDescriptor (vulkan_ctx_t *ctx, qfv_tex_t *tex,
								VkSampler sampler)
{
	return Vulkan_CreateCombinedImageSampler (ctx, tex->view, sampler);
}

void
Vulkan_FreeTexture (vulkan_ctx_t *ctx, VkDescriptorSet texture)
{
	qfv_device_t *device = ctx->device;
	qfv_devfuncs_t *dfunc = device->funcs;
	texturectx_t *tctx = ctx->texture_context;

	dfunc->vkFreeDescriptorSets (device->dev, tctx->pool, 1, &texture);
}
