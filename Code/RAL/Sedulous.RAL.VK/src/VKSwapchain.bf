using Bulkan;
using System.Collections;
using Sedulous.Platform;
using System;
namespace Sedulous.RAL.VK;

class VKSwapchain : Swapchain
{
	private VKCommandQueue m_command_queue;
	private VKDevice m_device;
	private VkSurfaceKHR m_surface;
	private VkFormat m_swapchain_color_format = VkFormat.VK_FORMAT_UNDEFINED;
	private VkSwapchainKHR m_swapchain;
	private List<Resource> m_back_buffers;
	private uint32 m_frame_index = 0;
	private VkSemaphore m_image_available_semaphore;
	private VkSemaphore m_rendering_finished_semaphore;
	private CommandList m_command_list;
	private Fence m_fence;

	public this(VKCommandQueue command_queue,
		SurfaceInfo surfaceInfo,
		uint32 width,
		uint32 height,
		uint32 frame_count,
		bool vsync)
	{
		m_command_queue = command_queue;
		m_device = command_queue.GetDevice();

		VKAdapter adapter = m_device.GetAdapter();
		VKInstance instance = adapter.GetInstance();

		if (surfaceInfo.Type == .Win32)
		{
			VkWin32SurfaceCreateInfoKHR surface_desc = .() { sType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR };
			surface_desc.hinstance = (void*)(int)System.Windows.GetModuleHandleA(null);
			surface_desc.hwnd = surfaceInfo.Win32.Hwnd;
			VulkanNative.vkCreateWin32SurfaceKHR(instance.GetInstance(), &surface_desc, null, &m_surface);
		} else if (surfaceInfo.Type == .MetalMacOS)
		{
			VkMetalSurfaceCreateInfoEXT surface_desc = .() { sType = .VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT };
			surface_desc.pLayer = surfaceInfo.MetalMacOS.CAMetalLayer;
			VulkanNative.vkCreateMetalSurfaceEXT(instance.GetInstance(), &surface_desc, null, &m_surface);
		} else if (surfaceInfo.Type == .Xcb)
		{
			VkXcbSurfaceCreateInfoKHR surface_desc = .() { sType = .VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR };
			surface_desc.connection = surfaceInfo.Xcb.connection;
			surface_desc.window = (void*)(int)surfaceInfo.Xcb.Window;
			VulkanNative.vkCreateXcbSurfaceKHR(instance.GetInstance(), &surface_desc, null, &m_surface);
		} else
		{
			Runtime.NotImplemented();
		}

		VkColorSpaceKHR color_space = .();

		uint32 surfaceFormatCount = 0;
		VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(adapter.GetPhysicalDevice(), m_surface, &surfaceFormatCount, null);
		VkSurfaceFormatKHR[] surface_formats = scope .[surfaceFormatCount];
		VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(adapter.GetPhysicalDevice(), m_surface, &surfaceFormatCount, surface_formats.Ptr);

		for (var surface in surface_formats)
		{
			if (!((Format)surface.format).IsSRGB())
			{
				m_swapchain_color_format = surface.format;
				color_space = surface.colorSpace;
				break;
			}
		}
		Runtime.Assert(m_swapchain_color_format != VkFormat.eUndefined);

		VkSurfaceCapabilitiesKHR surface_capabilities = .();
		VkResult result = VulkanNative.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(adapter.GetPhysicalDevice(), m_surface, &surface_capabilities);
		Runtime.Assert(result == .VK_SUCCESS);

		Runtime.Assert(surface_capabilities.currentExtent.width == width);
		Runtime.Assert(surface_capabilities.currentExtent.height == height);

		VkBool32 is_supported_surface = VulkanNative.VK_FALSE;
		VulkanNative.vkGetPhysicalDeviceSurfaceSupportKHR(adapter.GetPhysicalDevice(), m_command_queue.GetQueueFamilyIndex(), m_surface, &is_supported_surface);
		Runtime.Assert(is_supported_surface);

		uint32 presentModeCount = 0;
		VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(adapter.GetPhysicalDevice(), m_surface, &presentModeCount, null);
		VkPresentModeKHR[] modes = scope .[presentModeCount];
		VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(adapter.GetPhysicalDevice(), m_surface, &presentModeCount, modes.Ptr);

		VkSwapchainCreateInfoKHR swap_chain_create_info = .() { sType = .VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR };
		swap_chain_create_info.surface = m_surface;
		swap_chain_create_info.minImageCount = frame_count;
		swap_chain_create_info.imageFormat = m_swapchain_color_format;
		swap_chain_create_info.imageColorSpace = color_space;
		swap_chain_create_info.imageExtent = VkExtent2D(width, height);
		swap_chain_create_info.imageArrayLayers = 1;
		swap_chain_create_info.imageUsage = VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;
		swap_chain_create_info.imageSharingMode = VkSharingMode.eExclusive;
		swap_chain_create_info.preTransform = VkSurfaceTransformFlagsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
		swap_chain_create_info.compositeAlpha = VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
		if (vsync)
		{
			if (modes.Contains(VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR))
			{
				swap_chain_create_info.presentMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR;
			} else
			{
				swap_chain_create_info.presentMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;
			}
		} else
		{
			if (modes.Contains(VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR))
			{
				swap_chain_create_info.presentMode = VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR;
			} else
			{
				swap_chain_create_info.presentMode = VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR;
			}
		}
		swap_chain_create_info.clipped = true;

		VulkanNative.vkCreateSwapchainKHR(m_device.GetDevice(), &swap_chain_create_info, null, &m_swapchain);

		uint32 imageCount = 0;
		VulkanNative.vkGetSwapchainImagesKHR(m_device.GetDevice(), m_swapchain, &imageCount, null);
		VkImage[] m_images = scope .[imageCount];
		VulkanNative.vkGetSwapchainImagesKHR(m_device.GetDevice(), m_swapchain, &imageCount, m_images.Ptr);

		m_command_list = m_device.CreateCommandList(CommandListType.kGraphics);
		for (uint32 i = 0; i < frame_count; ++i)
		{
			VKResource res = new VKResource(m_device);
			res.format = GetFormat();
			res.image.res = m_images[i];
			res.image.format = m_swapchain_color_format;
			res.image.size = VkExtent2D(1 * width, 1 * height);
			res.resource_type = ResourceType.kTexture;
			res.is_back_buffer = true;
			m_command_list.ResourceBarrier(scope ResourceBarrierDesc[](.() { resource = res, state_before = ResourceState.kUndefined, state_after = ResourceState.kPresent }));
			res.SetInitialState(ResourceState.kPresent);
			m_back_buffers.Add(res);
		}
		m_command_list.Close();

		VkSemaphoreCreateInfo semaphore_create_info = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
		VulkanNative.vkCreateSemaphore(m_device.GetDevice(), &semaphore_create_info, null, &m_image_available_semaphore);
		VulkanNative.vkCreateSemaphore(m_device.GetDevice(), &semaphore_create_info, null, &m_rendering_finished_semaphore);
		m_fence = m_device.CreateFence(0);
		command_queue.ExecuteCommandLists(scope CommandList[](m_command_list));
		command_queue.Signal(m_fence, 1);
	}

	public ~this()
	{
		m_fence.Wait(1);
	}

	public override Format GetFormat()
	{
		return (Format)m_swapchain_color_format;
	}

	public override Resource GetBackBuffer(uint32 buffer)
	{
		return m_back_buffers[buffer];
	}

	public override uint32 NextImage(in Fence fence, uint64 signal_value)
	{
		var signal_value;
		VulkanNative.vkAcquireNextImageKHR(m_device.GetDevice(), m_swapchain, uint64.MaxValue, m_image_available_semaphore, .Null, &m_frame_index);

		var vk_fence = fence.As<VKTimelineSemaphore>();
		uint64 tmp = uint64.MaxValue;
		VkTimelineSemaphoreSubmitInfo timeline_info = .() { sType = .VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO };
		timeline_info.waitSemaphoreValueCount = 1;
		timeline_info.pWaitSemaphoreValues = &tmp;
		timeline_info.signalSemaphoreValueCount = 1;
		timeline_info.pSignalSemaphoreValues = &signal_value;
		VkSubmitInfo signal_submit_info = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		signal_submit_info.pNext = &timeline_info;
		signal_submit_info.waitSemaphoreCount = 1;
		signal_submit_info.pWaitSemaphores = &m_image_available_semaphore;
		VkPipelineStageFlags waitDstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
		signal_submit_info.pWaitDstStageMask = &waitDstStageMask;
		signal_submit_info.signalSemaphoreCount = 1;
		var timelineSemaphore = vk_fence.GetFence();
		signal_submit_info.pSignalSemaphores = &timelineSemaphore;
		VulkanNative.vkQueueSubmit(m_command_queue.GetQueue(), 1, &signal_submit_info, .Null);

		return m_frame_index;
	}

	public override void Present(in Fence fence, uint64 wait_value)
	{
		var wait_value;
		var vk_fence = fence.As<VKTimelineSemaphore>();
		uint64 tmp = uint64.MaxValue;
		VkTimelineSemaphoreSubmitInfo timeline_info = .() { sType = .VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO };
		timeline_info.waitSemaphoreValueCount = 1;
		timeline_info.pWaitSemaphoreValues = &wait_value;
		timeline_info.signalSemaphoreValueCount = 1;
		timeline_info.pSignalSemaphoreValues = &tmp;
		VkSubmitInfo signal_submit_info = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		signal_submit_info.pNext = &timeline_info;
		signal_submit_info.waitSemaphoreCount = 1;
		var timelineSemaphore = vk_fence.GetFence();
		signal_submit_info.pWaitSemaphores = &timelineSemaphore;
		VkPipelineStageFlags waitDstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT;
		signal_submit_info.pWaitDstStageMask = &waitDstStageMask;
		signal_submit_info.signalSemaphoreCount = 1;
		signal_submit_info.pSignalSemaphores = &m_rendering_finished_semaphore;
		VulkanNative.vkQueueSubmit(m_command_queue.GetQueue(), 1, &signal_submit_info, .Null);

		VkPresentInfoKHR present_info = .() { sType = .VK_STRUCTURE_TYPE_PRESENT_INFO_KHR };
		present_info.swapchainCount = 1;
		present_info.pSwapchains = &m_swapchain;
		present_info.pImageIndices = &m_frame_index;
		present_info.waitSemaphoreCount = 1;
		present_info.pWaitSemaphores = &m_rendering_finished_semaphore;
		VulkanNative.vkQueuePresentKHR(m_command_queue.GetQueue(), &present_info);
	}
}