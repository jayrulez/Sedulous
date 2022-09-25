using Bulkan;
using System.Collections;
using System;
namespace NRI.Vulkan;

class SwapChainVK : SwapChain
{
	private Result CreateSurface(SwapChainDesc swapChainDesc)
	{
		VkResult result;

#if true //VK_USE_PLATFORM_WIN32_KHR
		if (swapChainDesc.windowSystemType == WindowSystemType.WINDOWS)
		{
			VkWin32SurfaceCreateInfoKHR win32SurfaceInfo = .();
			win32SurfaceInfo.sType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
			win32SurfaceInfo.hwnd = swapChainDesc.window.windows.hwnd;

			result = VulkanNative.vkCreateWin32SurfaceKHR(m_Device, &win32SurfaceInfo, m_Device.GetAllocationCallbacks(), &m_Surface);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a surface: vkCreateWin32SurfaceKHR returned {0}.", (int32)result);

			return Result.SUCCESS;
		}
#endif
#if VK_USE_PLATFORM_METAL_EXT
		if (swapChainDesc.windowSystemType == WindowSystemType.METAL)
		{
			VkMetalSurfaceCreateInfoEXT metalSurfaceCreateInfo = .();
			metalSurfaceCreateInfo.sType = .VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT;
			metalSurfaceCreateInfo.pLayer = (CAMetalLayer*)swapChainDesc.window.metal.caMetalLayer;

			result = VulkanNative.vkCreateMetalSurfaceEXT(m_Device, &metalSurfaceCreateInfo, m_Device.GetAllocationCallbacks(), &m_Surface);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a surface: vkCreateMetalSurfaceEXT returned {0}.", (int32)result);

			return Result.SUCCESS;
		}
#endif
#if VK_USE_PLATFORM_XLIB_KHR
		if (swapChainDesc.windowSystemType == WindowSystemType.X11)
		{
			VkXlibSurfaceCreateInfoKHR xlibSurfaceInfo = .();
			xlibSurfaceInfo.sType = .VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
			xlibSurfaceInfo.dpy = swapChainDesc.window.x11.dpy;
			xlibSurfaceInfo.window = (void*)(int)swapChainDesc.window.x11.window;

			result = VulkanNative.vkCreateXlibSurfaceKHR(m_Device, &xlibSurfaceInfo, m_Device.GetAllocationCallbacks(), &m_Surface);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a surface: vkCreateXlibSurfaceKHR returned {0}.", (int32)result);

			return Result.SUCCESS;
		}
#endif
#if VK_USE_PLATFORM_WAYLAND_KHR
		if (swapChainDesc.windowSystemType == WindowSystemType.WAYLAND)
		{
			VkWaylandSurfaceCreateInfoKHR waylandSurfaceInfo = .();
			waylandSurfaceInfo.sType = .VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR;
			waylandSurfaceInfo.display = swapChainDesc.window.wayland.display;
			waylandSurfaceInfo.surface = swapChainDesc.window.wayland.surface;

			result = VulkanNative.vkCreateWaylandSurfaceKHR(m_Device, &waylandSurfaceInfo, m_Device.GetAllocationCallbacks(), &m_Surface);

			RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
				"Can't create a surface: vkCreateWaylandSurfaceKHR returned {0}.", (int32)result);

			return Result.SUCCESS;
		}
#endif

		return Result.UNSUPPORTED;
	}

	private VkSwapchainKHR m_Handle = .Null;
	private CommandQueueVK m_CommandQueue = null;
	private uint32 m_TextureIndex = uint32.MaxValue;
	private VkSurfaceKHR m_Surface = .Null;
	private List<TextureVK> m_Textures;
	private Format m_Format = Format.UNKNOWN;
	private DeviceVK m_Device;

	public this(DeviceVK device)
	{
		m_Device = device;

		m_Textures = Allocate!<List<TextureVK>>(m_Device.GetAllocator());
	}

	public ~this()
	{
		for (int i = 0; i < m_Textures.Count; i++)
		{
			m_Textures[i].ClearHandle();
			Deallocate!(m_Device.GetAllocator(), m_Textures[i]);
		}
		m_Textures.Clear();
		Deallocate!(m_Device.GetAllocator(), m_Textures);

		if (m_Handle != .Null)
			VulkanNative.vkDestroySwapchainKHR(m_Device, m_Handle, m_Device.GetAllocationCallbacks());

		if (m_Surface != .Null)
			VulkanNative.vkDestroySurfaceKHR(m_Device, m_Surface, m_Device.GetAllocationCallbacks());
	}

	public DeviceVK GetDevice() => m_Device;

	public Result Create(SwapChainDesc swapChainDesc)
	{
		m_CommandQueue = (CommandQueueVK)swapChainDesc.commandQueue;
		{
			readonly Result result = CreateSurface(swapChainDesc);
			if (result != Result.SUCCESS)
				return result;
		}

		VkBool32 supported = .False;
		VulkanNative.vkGetPhysicalDeviceSurfaceSupportKHR(m_Device, m_CommandQueue.GetFamilyIndex(), m_Surface, &supported);

		if (supported == .False)
		{
			REPORT_ERROR(m_Device.GetLogger(), "The specified surface is not supported by the physical device.");
			return Result.UNSUPPORTED;
		}

		VkSurfaceCapabilitiesKHR capabilites = .();
		VkResult result = VulkanNative.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(m_Device, m_Surface, &capabilites);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't get physical device surface capabilities: vkGetPhysicalDeviceSurfaceCapabilitiesKHR returned {0}.", (int32)result);

		readonly bool isWidthValid = swapChainDesc.width >= capabilites.minImageExtent.width &&
			swapChainDesc.width <= capabilites.maxImageExtent.width;
		readonly bool isHeightValid = swapChainDesc.height >= capabilites.minImageExtent.height &&
			swapChainDesc.height <= capabilites.maxImageExtent.height;

		if (!isWidthValid || !isHeightValid)
		{
			REPORT_ERROR(m_Device.GetLogger(), "Invalid SwapChainVK buffer size.");
			return Result.INVALID_ARGUMENT;
		}

		uint32 formatNum = 0;
		result = VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(m_Device, m_Surface, &formatNum, null);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't get physical device surface formats: vkGetPhysicalDeviceSurfaceFormatsKHR returned {0}.", (int32)result);

		VkSurfaceFormatKHR* surfaceFormats = STACK_ALLOC!<VkSurfaceFormatKHR>(formatNum);
		result = VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(m_Device, m_Surface, &formatNum, surfaceFormats);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't get physical device surface formats: vkGetPhysicalDeviceSurfaceFormatsKHR returned {0}.", (int32)result);

		VkSurfaceFormatKHR surfaceFormat = .();

		surfaceFormat = surfaceFormats[0];
		m_Format = ConvertVKFormatToNRI(surfaceFormat.format);

		uint32 presentModeNum = 0;
		result = VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(m_Device, m_Surface, &presentModeNum, null);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't get supported present modes for the surface: vkGetPhysicalDeviceSurfacePresentModesKHR returned {0}.", (int32)result);

		VkPresentModeKHR* presentModes = STACK_ALLOC!<VkPresentModeKHR>(presentModeNum);
		result = VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(m_Device, m_Surface, &presentModeNum, presentModes);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't get supported present modes for the surface: vkGetPhysicalDeviceSurfacePresentModesKHR returned {0}.", (int32)result);

		// Both of these modes use v-sync for preseting, but FIFO blocks execution
		VkPresentModeKHR desiredPresentMode = swapChainDesc.verticalSyncInterval > 0 ? .VK_PRESENT_MODE_FIFO_KHR : .VK_PRESENT_MODE_MAILBOX_KHR;

		supported = false;
		for (uint32 i = 0; i < presentModeNum && !supported; i++)
			supported = desiredPresentMode == presentModes[i];

		if (!supported)
		{
			REPORT_WARNING(m_Device.GetLogger(),
				"The present mode is not supported. Using the first mode from the list of supported modes. (Mode: %d)", (int32)desiredPresentMode);

			desiredPresentMode = presentModes[0];
		}

		/*readonly*/ uint32 familyIndex = m_CommandQueue.GetFamilyIndex();
		readonly uint32 minImageNum = Math.Max<uint32>(capabilites.minImageCount, swapChainDesc.textureNum);

		/*readonly*/ VkSwapchainCreateInfoKHR swapchainInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
				pNext = null,
				flags = (VkSwapchainCreateFlagsKHR)0,
				surface =  m_Surface,
				minImageCount = minImageNum,
				imageFormat = surfaceFormat.format,
				imageColorSpace = surfaceFormat.colorSpace,
				imageExtent = .() { width = swapChainDesc.width, height = swapChainDesc.height },
				imageArrayLayers = 1,
				imageUsage = .VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | .VK_IMAGE_USAGE_TRANSFER_DST_BIT | .VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
				imageSharingMode = .VK_SHARING_MODE_EXCLUSIVE,
				queueFamilyIndexCount = 1,
				pQueueFamilyIndices = &familyIndex,
				preTransform = .VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR,
				compositeAlpha = .VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
				presentMode = desiredPresentMode,
				clipped = VulkanNative.VK_FALSE,
				oldSwapchain = .Null
			};

		result = VulkanNative.vkCreateSwapchainKHR(m_Device, &swapchainInfo, m_Device.GetAllocationCallbacks(), &m_Handle);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a swapchain: vkCreateSwapchainKHR returned {0}.", (int32)result);

		uint32 imageNum = 0;
		VulkanNative.vkGetSwapchainImagesKHR(m_Device, m_Handle, &imageNum, null);

		VkImage* imageHandles = STACK_ALLOC!<VkImage>(imageNum);
		VulkanNative.vkGetSwapchainImagesKHR(m_Device, m_Handle, &imageNum, imageHandles);

		m_Textures.Resize(imageNum);
		for (uint32 i = 0; i < imageNum; i++)
		{
			TextureVK texture = Allocate!<TextureVK>(m_Device.GetAllocator(), m_Device);
			readonly VkExtent3D extent = .() { width = swapchainInfo.imageExtent.width, height = swapchainInfo.imageExtent.height, depth = 1 };
			texture.Create(imageHandles[i], .VK_IMAGE_ASPECT_COLOR_BIT, .VK_IMAGE_TYPE_2D, extent, m_Format);
			m_Textures[i] = texture;
		}

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_SURFACE_KHR, (uint64)m_Surface, name);
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_SWAPCHAIN_KHR, (uint64)m_Handle, name);
	}

	public Texture* GetTextures(ref uint32 textureNum, ref Format format)
	{
		textureNum = (uint32)m_Textures.Count;
		format = m_Format;
		return (Texture*)m_Textures.Ptr;
	}

	public uint32 AcquireNextTexture(ref QueueSemaphore textureReadyForRender)
	{
		const uint64 timeout = 5000000000; // 5 seconds
		m_TextureIndex = uint32.MaxValue;

		readonly VkResult result = VulkanNative.vkAcquireNextImageKHR(m_Device, m_Handle, timeout, *(QueueSemaphoreVK*)&textureReadyForRender,
			.Null, &m_TextureIndex);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, m_TextureIndex,
			"Can't acquire the next texture of the swapchain: vkAcquireNextImageKHR returned {0}.", (int32)result);

		return m_TextureIndex;
	}

	public Result Present(QueueSemaphore textureReadyForPresent)
	{
	/*readonly*/ VkSemaphore semaphore = (QueueSemaphoreVK)textureReadyForPresent;

		VkResult presentRes = .VK_SUCCESS;

	/*readonly*/ VkPresentInfoKHR info = .()
			{
				sType = .VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
				pNext = null,
				waitSemaphoreCount = 1,
				pWaitSemaphores = &semaphore,
				swapchainCount = 1,
				pSwapchains = &m_Handle,
				pImageIndices = &m_TextureIndex,
				pResults = &presentRes
			};

		readonly VkResult result = VulkanNative.vkQueuePresentKHR(m_CommandQueue, &info);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't present the swapchain: vkQueuePresentKHR returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public Result SetHdrMetadata(HdrMetadata hdrMetadata)
	{
		if (VulkanNative.[Friend]vkSetHdrMetadataEXT_ptr == null)
			return Result.UNSUPPORTED;

		/*readonly*/ VkHdrMetadataEXT data = .()
			{
				sType = .VK_STRUCTURE_TYPE_HDR_METADATA_EXT,
				pNext = null,
				displayPrimaryRed = .() { x = hdrMetadata.displayPrimaryRed[0], y = hdrMetadata.displayPrimaryRed[1] },
				displayPrimaryGreen = .() { x = hdrMetadata.displayPrimaryGreen[0], y = hdrMetadata.displayPrimaryGreen[1] },
				displayPrimaryBlue = .() { x = hdrMetadata.displayPrimaryBlue[0], y = hdrMetadata.displayPrimaryBlue[1] },
				whitePoint = .() { x = hdrMetadata.whitePoint[0], y = hdrMetadata.whitePoint[1] },
				maxLuminance = hdrMetadata.luminanceMax,
				minLuminance = hdrMetadata.luminanceMin,
				maxContentLightLevel = hdrMetadata.contentLightLevelMax,
				maxFrameAverageLightLevel = hdrMetadata.frameAverageLightLevelMax
			};

		VulkanNative.vkSetHdrMetadataEXT(m_Device, 1, &m_Handle, &data);
		return Result.SUCCESS;
	}
}