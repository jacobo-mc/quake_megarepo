/*
Copyright (C) 2018 ezQuake team

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

// vk_physical_devices.c

#ifdef RENDERER_OPTION_VULKAN

#include <vulkan/vulkan.h>
#include "quakedef.h"

#include <SDL.h>
#include <SDL_vulkan.h>

#include "vk_local.h"

static const char* validationLayers[] = { "VK_LAYER_LUNARG_standard_validation" };
static const char* requiredDeviceExtensions[] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };

static void VK_PhysicalDeviceQueryQueueFamilies(VkPhysicalDevice device, VkSurfaceKHR surface, int* graphics_queue_index, int* compute_queue_index, int* present_queue_index)
{
	uint32_t queue_families_count;
	VkQueueFamilyProperties* queue_family_properties;
	uint32_t j;

	vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_families_count, NULL);
	queue_family_properties = Q_malloc(sizeof(VkQueueFamilyProperties) * queue_families_count);
	vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_families_count, queue_family_properties);

	*graphics_queue_index = *compute_queue_index = *present_queue_index = -1;
	for (j = 0; j < queue_families_count; ++j) {
		if (queue_family_properties[j].queueCount > 0) {
			if (queue_family_properties[j].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
				*graphics_queue_index = j;

				if (surface != VK_NULL_HANDLE) {
					VkBool32 present_supported;

					if (vkGetPhysicalDeviceSurfaceSupportKHR(device, j, surface, &present_supported) == VK_SUCCESS && present_supported) {
						*present_queue_index = j;
					}
				}
			}
			else if (queue_family_properties[j].queueFlags & VK_QUEUE_COMPUTE_BIT) {
				*compute_queue_index = j;
			}
		}
	}

	Q_free(queue_family_properties);
}

static qbool VK_PhysicalDeviceSupportsRequiredExtensions(VkPhysicalDevice device)
{
	// 
	uint32_t count;
	VkExtensionProperties* properties;
	uint32_t foundCount = 0;
	uint32_t i, j;

	vkEnumerateDeviceExtensionProperties(device, NULL, &count, NULL);
	properties = Q_malloc(count * sizeof(VkExtensionProperties));
	vkEnumerateDeviceExtensionProperties(device, NULL, &count, properties);

	for (i = 0; i < count; ++i) {
		for (j = 0; j < sizeof(requiredDeviceExtensions) / sizeof(requiredDeviceExtensions[0]); ++j) {
			if (!strcmp(properties[i].extensionName, requiredDeviceExtensions[j])) {
				++foundCount;
				break;
			}
		}
	}
	Q_free(properties);

	return (foundCount == sizeof(requiredDeviceExtensions) / sizeof(requiredDeviceExtensions[0]));
}

static qbool VK_PhysicalDeviceBestPresentationMode(VkPhysicalDevice device, VkSurfaceKHR surface, VkPresentModeKHR* best)
{
	extern cvar_t r_swapInterval;
	VkPresentModeKHR preferredModes[] = {
		VK_PRESENT_MODE_MAILBOX_KHR,       // triple buffered
		VK_PRESENT_MODE_IMMEDIATE_KHR,     // tearing
		VK_PRESENT_MODE_FIFO_RELAXED_KHR,
		VK_PRESENT_MODE_FIFO_KHR
	};
	VkPresentModeKHR* presentationModes;
	uint32_t count;
	uint32_t i, j;

	// This is guaranteed to be supported
	if (r_swapInterval.integer) {
		*best = VK_PRESENT_MODE_FIFO_KHR;
		return true;
	}

	if (vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &count, NULL) != VK_SUCCESS) {
		return false;
	}

	presentationModes = Q_malloc(count * sizeof(presentationModes[0]));
	if (vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &count, presentationModes) != VK_SUCCESS) {
		Q_free(presentationModes);
		return false;
	}

	for (i = 0; i < sizeof(preferredModes) / sizeof(preferredModes[0]); ++i) {
		for (j = 0; j < count; ++j) {
			if (preferredModes[i] == presentationModes[j]) {
				Q_free(presentationModes);
				*best = preferredModes[i];
				return true;
			}
		}
	}

	Q_free(presentationModes);
	*best = VK_PRESENT_MODE_FIFO_KHR;
	return true;
}

static qbool VK_PhysicalDeviceSwapChainCompatible(VkPhysicalDevice device, VkSurfaceKHR surface, VkSurfaceFormatKHR* preferred_format, VkSurfaceCapabilitiesKHR* capabilities)
{
	extern cvar_t vid_gammacorrection;
	uint32_t num_formats;
	VkSurfaceFormatKHR* formats;
	VkColorSpaceKHR req_color_space = (vid_gammacorrection.integer ? VK_COLOR_SPACE_SRGB_NONLINEAR_KHR : VK_COLOR_SPACE_PASS_THROUGH_EXT);

	if (vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, capabilities) != VK_SUCCESS) {
		return false;
	}

	if (vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &num_formats, NULL) != VK_SUCCESS || num_formats == 0) {
		return false;
	}
	formats = Q_malloc(num_formats * sizeof(formats[0]));
	if (vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &num_formats, formats) != VK_SUCCESS) {
		Q_free(formats);
		return false;
	}

	if (num_formats == 1 && formats[0].format == VK_FORMAT_UNDEFINED) {
		// Special case: no preferred format
		preferred_format->colorSpace = req_color_space;
		preferred_format->format = VK_FORMAT_B8G8R8A8_UNORM;
	}
	else {
		// Find optimal format.... FIXME (what are we really doing here?)
		uint32_t i;

		for (i = 0; i < num_formats; ++i) {
			if (formats[i].format == VK_FORMAT_B8G8R8A8_UNORM && formats[i].colorSpace == req_color_space) {
				preferred_format->colorSpace = req_color_space;
				preferred_format->format = VK_FORMAT_B8G8R8A8_UNORM;
				break;
			}
		}

		if (i >= num_formats) {
			preferred_format->colorSpace = formats[0].colorSpace;
			preferred_format->format = formats[0].format;
		}
	}
	Q_free(formats);
	return true;
}

qbool VK_SelectPhysicalDevice(VkInstance instance, VkSurfaceKHR surface)
{
	uint32_t deviceCount = 0;
	VkResult result;
	VkPhysicalDevice* physicalDevices;
	uint32_t i;

	result = vkEnumeratePhysicalDevices(instance, &deviceCount, NULL);
	if (result != VK_SUCCESS) {
		Con_Printf("vulkan: enumerating physical devices failed\n");
		return false;
	}
	physicalDevices = Q_malloc(deviceCount * sizeof(VkPhysicalDevice));
	result = vkEnumeratePhysicalDevices(instance, &deviceCount, physicalDevices);
	if (result != VK_SUCCESS) {
		Q_free(physicalDevices);
		return false;
	}

	vk_options.physicalDevice = VK_NULL_HANDLE;
	for (i = 0; i < deviceCount; ++i) {
		VkPhysicalDeviceFeatures features;
		VkPhysicalDeviceProperties properties;
		VkPresentModeKHR best_presentation_mode;
		qbool new_best = true;
		int graphics_queue_index = -1;
		int compute_queue_index = -1;
		int present_queue_index = -1;
		VkSurfaceFormatKHR preferred_format;
		VkSurfaceCapabilitiesKHR capabilities;

		vkGetPhysicalDeviceProperties(physicalDevices[i], &properties);
		Con_Printf("Device %d: %s\n", i, properties.deviceName);

		if (!VK_PhysicalDeviceSupportsRequiredExtensions(physicalDevices[i])) {
			continue;
		}

		// Must support graphics queues
		VK_PhysicalDeviceQueryQueueFamilies(physicalDevices[i], surface, &graphics_queue_index, &compute_queue_index, &present_queue_index);
		if (graphics_queue_index < 0) {
			continue;
		}

		if (!VK_PhysicalDeviceSwapChainCompatible(physicalDevices[i], surface, &preferred_format, &capabilities)) {
			continue;
		}

		if (!VK_PhysicalDeviceBestPresentationMode(physicalDevices[i], surface, &best_presentation_mode)) {
			continue;
		}

		if (vk_options.physicalDevice != VK_NULL_HANDLE) {
			// Score?  Or cvar...
			/*
			vkGetPhysicalDeviceFeatures(physicalDevices[i], &features);

			if (properties.deviceType == )
			physicalDevices[i]*/
			new_best = false;
		}

		if (new_best) {
			vk_options.physicalDevice = physicalDevices[i];
			memcpy(&vk_options.physicalDeviceFeatures, &features, sizeof(vk_options.physicalDeviceFeatures));
			memcpy(&vk_options.physicalDeviceProperties, &properties, sizeof(vk_options.physicalDeviceProperties));
			vk_options.physicalDeviceGraphicsQueueFamilyIndex = graphics_queue_index;
			vk_options.physicalDeviceComputeQueueFamilyIndex = compute_queue_index;
			vk_options.physicalDevicePresentQueueFamilyIndex = present_queue_index;
			vk_options.physicalDevicePresentationMode = best_presentation_mode;
			vk_options.physicalDeviceSurfaceFormat = preferred_format;
			vk_options.physicalDeviceSurfaceCapabilities = capabilities;
		}
	}

	Q_free(physicalDevices);
	if (vk_options.physicalDevice == VK_NULL_HANDLE) {
		Com_Printf("No appropriate device found :(\n");
		return false;
	}

	Com_Printf("Selected device: %s\n", vk_options.physicalDeviceProperties.deviceName);

	return true;
}

uint32_t VK_PhysicalDeviceGraphicsQueueFamilyIndex(void)
{
	assert(vk_options.physicalDevice != VK_NULL_HANDLE);

	return vk_options.physicalDeviceGraphicsQueueFamilyIndex;
}

uint32_t VK_PhysicalDeviceComputeQueueFamilyIndex(void)
{
	assert(vk_options.physicalDevice != VK_NULL_HANDLE);

	return vk_options.physicalDeviceComputeQueueFamilyIndex;
}

uint32_t VK_PhysicalDevicePresentQueueFamilyIndex(void)
{
	assert(vk_options.physicalDevice != VK_NULL_HANDLE);

	return vk_options.physicalDevicePresentQueueFamilyIndex;
}

static qbool VK_AddDeviceValidationLayers(VkDeviceCreateInfo* createInfo)
{
	VkLayerProperties* availableLayers = NULL;

	createInfo->enabledLayerCount = 0;
	if (COM_CheckParm(cmdline_param_developer_mode)) {
		unsigned int layerCount, j;
		int i;
		qbool available = true;
		VkResult result;

		result = vkEnumerateInstanceLayerProperties(&layerCount, NULL);
		if (result != VK_SUCCESS) {
			return false;
		}

		availableLayers = Q_malloc(sizeof(availableLayers[0]) * layerCount);
		result = vkEnumerateInstanceLayerProperties(&layerCount, availableLayers);
		if (result != VK_SUCCESS) {
			Q_free(availableLayers);
			return false;
		}
		for (i = 0; i < sizeof(validationLayers) / sizeof(validationLayers[0]); ++i) {
			qbool found = false;
			for (j = 0; j < layerCount && !found; ++j) {
				found |= !strcmp(availableLayers[j].layerName, validationLayers[i]);
			}
			available &= found;
		}
		Q_free(availableLayers);

		if (available) {
			createInfo->ppEnabledLayerNames = validationLayers;
			createInfo->enabledLayerCount = sizeof(validationLayers) / sizeof(validationLayers[0]);
			return true;
		}
	}

	return false;
}

qbool VK_CreateLogicalDevice(VkInstance instance)
{
	VkDeviceQueueCreateInfo queueInfos[2] = { { 0 } };
	VkDeviceCreateInfo deviceInfo = { 0 };
	VkPhysicalDeviceFeatures deviceFeatures = { 0 };
	float priorities[] = { 1.0f };
	uint32_t queueCount = 0;

	queueInfos[0].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
	queueInfos[0].queueFamilyIndex = VK_PhysicalDeviceGraphicsQueueFamilyIndex();
	queueInfos[0].queueCount = sizeof(priorities) / sizeof(priorities[0]);
	queueInfos[0].pQueuePriorities = priorities;
	++queueCount;

	if (VK_PhysicalDeviceGraphicsQueueFamilyIndex() != VK_PhysicalDevicePresentQueueFamilyIndex()) {
		queueInfos[queueCount].sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
		queueInfos[queueCount].queueFamilyIndex = VK_PhysicalDevicePresentQueueFamilyIndex();
		queueInfos[queueCount].queueCount = sizeof(priorities) / sizeof(priorities[0]);
		queueInfos[queueCount].pQueuePriorities = priorities;
		++queueCount;
	}

	deviceInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
	deviceInfo.pQueueCreateInfos = queueInfos;
	deviceInfo.queueCreateInfoCount = sizeof(queueInfos) / sizeof(queueInfos[0]);
	deviceInfo.pEnabledFeatures = &deviceFeatures;

	deviceInfo.enabledExtensionCount = 0;
	VK_AddDeviceValidationLayers(&deviceInfo);

	vk_options.logicalDevice = VK_NULL_HANDLE;
	if (vkCreateDevice(vk_options.physicalDevice, &deviceInfo, NULL, &vk_options.logicalDevice) != VK_SUCCESS) {
		Con_Printf("vkCreateDevice() failed\n");
		return false;
	}

	vkGetDeviceQueue(vk_options.logicalDevice, VK_PhysicalDeviceGraphicsQueueFamilyIndex(), 0, &vk_options.graphicsQueue);
	if (VK_PhysicalDeviceGraphicsQueueFamilyIndex() != VK_PhysicalDevicePresentQueueFamilyIndex()) {
		vkGetDeviceQueue(vk_options.logicalDevice, VK_PhysicalDevicePresentQueueFamilyIndex(), 0, &vk_options.presentQueue);
	}
	else {
		vk_options.presentQueue = vk_options.graphicsQueue;
	}

	return true;
}

#endif // RENDERER_OPTION_VULKAN
