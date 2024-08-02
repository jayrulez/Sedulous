using System;
using System.Diagnostics;
using Bulkan;
using Sedulous.RHI;
using Sedulous.Foundation;
using Sedulous.Foundation.Utilities;
using Sedulous.Platform;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represents a native swapchain object on Vulkan.
/// </summary>
public class VKSwapChain : SwapChain
{
	internal VkSwapchainKHR vkSwapChain;

	internal VkSurfaceKHR vkSurface;

	internal VkSurfaceFormatKHR vkSurfaceFormat;

	internal VkSwapchainCreateInfoKHR swapchainInfo;

	private VkQueue vkPresentQueue;

	private int32 currentBackBufferIndex;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SWAPCHAIN_KHR, vkSwapChain.Handle, name);
		}
	}

	/// <summary>
	/// Gets or sets the active backbuffer index.
	/// </summary>
	public int32 CurrentBackBufferIndex
	{
		get
		{
			return currentBackBufferIndex;
		}
		set
		{
			currentBackBufferIndex = value;
			(base.FrameBuffer as VKSwapChainFrameBuffer).CurrentBackBufferIndex = value;
		}
	}

	/// <inheritdoc />
	public override bool VerticalSync
	{
		get
		{
			return base.VerticalSync;
		}
		set
		{
			if (base.VerticalSync != value)
			{
				base.VerticalSync = value;
				CreateSwapChain();
				AcquireNextImage();
			}
		}
	}

	/// <summary>
	/// Create a ANativeWindows surface.
	/// </summary>
	/// <param name="jniEnv">The jni environment pointer.</param>
	/// <param name="surface">The native surface pointer.</param>
	/// <returns>A new ANativeWindows surface.</returns>
	//[Import("android.so")]
	//public static extern void* ANativeWindow_fromSurface(void* jniEnv, void* surface);

	/// <inheritdoc />
	public override Texture GetCurrentFramebufferTexture()
	{
		return (base.FrameBuffer as VKSwapChainFrameBuffer).ColorTargets[0].Texture;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKSwapChain" /> class.
	/// </summary>
	/// <param name="context">Graphics Context.</param>
	/// <param name="description">SwapChain description.</param>
	public this(GraphicsContext context, SwapChainDescription description)
	{
		GraphicsContext = context;
		vkContext = context as VKGraphicsContext;
		base.SwapChainDescription = description;
		CreateSurface();
		CreateSwapChain();
		AcquireNextImage();
	}

	private void CreateSurface()
	{
		if (vkSurface != VkSurfaceKHR.Null)
		{
			VulkanNative.vkDestroySurfaceKHR(vkContext.VkInstance, vkSurface, null);
			vkSurface = VkSurfaceKHR.Null;
		}
		PlatformType platform = OperatingSystemHelper.GetCurrentPlatfom();
		VkSurfaceKHR newSurface = VkSurfaceKHR.Null;
		switch (platform)
		{
		case PlatformType.Windows:
		{
			VkWin32SurfaceCreateInfoKHR windowsSurfaceInfo = default(VkWin32SurfaceCreateInfoKHR);
			windowsSurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
			windowsSurfaceInfo.hwnd = base.SwapChainDescription.SurfaceInfo.Win32.Hwnd;
			windowsSurfaceInfo.hinstance = (void*)(int)System.Windows.GetModuleHandleA(null);
			VulkanNative.vkCreateWin32SurfaceKHR(vkContext.VkInstance, &windowsSurfaceInfo, null, &newSurface);
			break;
		}
		case PlatformType.Linux:
			if (base.SwapChainDescription.SurfaceInfo.Type == .Wayland)
			{
				VkWaylandSurfaceCreateInfoKHR wayLandSurfaceInfo = default(VkWaylandSurfaceCreateInfoKHR);
				wayLandSurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR;
				wayLandSurfaceInfo.display = base.SwapChainDescription.SurfaceInfo.Wayland.Display;
				wayLandSurfaceInfo.surface = base.SwapChainDescription.SurfaceInfo.Wayland.Surface;
				VulkanNative.vkCreateWaylandSurfaceKHR(vkContext.VkInstance, &wayLandSurfaceInfo, null, &newSurface);
			}
			else
			{
				VkXlibSurfaceCreateInfoKHR x11SurfaceInfo = default(VkXlibSurfaceCreateInfoKHR);
				x11SurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
				x11SurfaceInfo.dpy = base.SwapChainDescription.SurfaceInfo.X11.Display;
				x11SurfaceInfo.window = (void*)(int)base.SwapChainDescription.SurfaceInfo.X11.Window;
				VulkanNative.vkCreateXlibSurfaceKHR(vkContext.VkInstance, &x11SurfaceInfo, null, &newSurface);
			}
			break;
		case PlatformType.Android:
		{
			/*void* aNativeWindow = ANativeWindow_fromSurface(base.SwapChainDescription.SurfaceInfo.Android.JNIEnv, base.SwapChainDescription.SurfaceInfo.Android.Surface);
			VkAndroidSurfaceCreateInfoKHR androidSurfaceInfo = default(VkAndroidSurfaceCreateInfoKHR);
			androidSurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR;
			androidSurfaceInfo.window = aNativeWindow;
			VulkanNative.vkCreateAndroidSurfaceKHR(vkContext.VkInstance, &androidSurfaceInfo, null, &newSurface);*/
			break;
		}
		case PlatformType.MacOS:
		{
			VkMacOSSurfaceCreateInfoMVK macOSSurfaceInfo = default(VkMacOSSurfaceCreateInfoMVK);
			macOSSurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK;
			macOSSurfaceInfo.pView = (void*)base.SwapChainDescription.SurfaceInfo.MetalMacOS.CAMetalLayer;
			VulkanNative.vkCreateMacOSSurfaceMVK(vkContext.VkInstance, &macOSSurfaceInfo, null, &newSurface);
			break;
		}
		case PlatformType.iOS:
		{
			VkIOSSurfaceCreateInfoMVK iOSSurfaceInfo = default(VkIOSSurfaceCreateInfoMVK);
			iOSSurfaceInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK;
			iOSSurfaceInfo.pView = (void*)base.SwapChainDescription.SurfaceInfo.MetalIOS.View;
			VulkanNative.vkCreateIOSSurfaceMVK(vkContext.VkInstance, &iOSSurfaceInfo, null, &newSurface);
			break;
		}
		default:
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "Invalid OperationSystem.");
			break;
		}
		vkSurface = newSurface;
	}

	private void CreateSwapChain()
	{
		DestroySwapChain();
		VkSurfaceCapabilitiesKHR capabilities = default(VkSurfaceCapabilitiesKHR);
		VulkanNative.vkGetPhysicalDeviceSurfaceCapabilitiesKHR(vkContext.VkPhysicalDevice, vkSurface, &capabilities);
		uint32 surfaceFormatCount = 0;
		VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(vkContext.VkPhysicalDevice, vkSurface, &surfaceFormatCount, null);
		VkSurfaceFormatKHR* formats = scope VkSurfaceFormatKHR[(int32)surfaceFormatCount]*;
		VulkanNative.vkGetPhysicalDeviceSurfaceFormatsKHR(vkContext.VkPhysicalDevice, vkSurface, &surfaceFormatCount, formats);
		uint32 presentModeCount = 0;
		VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(vkContext.VkPhysicalDevice, vkSurface, &presentModeCount, null);
		VkPresentModeKHR* presentModes = scope VkPresentModeKHR[(int32)presentModeCount]*;
		VulkanNative.vkGetPhysicalDeviceSurfacePresentModesKHR(vkContext.VkPhysicalDevice, vkSurface, &presentModeCount, presentModes);
		vkSurfaceFormat = ChooseSwapSurfaceFormat(formats, (int32)surfaceFormatCount);
		VkPresentModeKHR presentMode = ChooseSwapPresentMode(presentModes, (int32)presentModeCount);
		VkExtent2D extent = ChooseSwapExtent(capabilities, base.SwapChainDescription.Width, base.SwapChainDescription.Height);
		uint32 imageCount = capabilities.minImageCount + 1;
		if (capabilities.maxImageCount != 0)
		{
			imageCount = Math.Min(imageCount, capabilities.maxImageCount);
		}
		VkCompositeAlphaFlagsKHR compositeAlpha = (capabilities.supportedCompositeAlpha.HasFlag(VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR) ? VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR : VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR);
		VkSwapchainCreateInfoKHR vkSwapchainInfo = default(VkSwapchainCreateInfoKHR);
		vkSwapchainInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
		vkSwapchainInfo.minImageCount = imageCount;
		vkSwapchainInfo.imageFormat = vkSurfaceFormat.format;
		vkSwapchainInfo.imageColorSpace = vkSurfaceFormat.colorSpace;
		vkSwapchainInfo.imageExtent = extent;
		vkSwapchainInfo.imageArrayLayers = 1;
		vkSwapchainInfo.imageUsage = VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
		vkSwapchainInfo.preTransform = VkSurfaceTransformFlagsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
		vkSwapchainInfo.compositeAlpha = compositeAlpha;
		vkSwapchainInfo.presentMode = presentMode;
		vkSwapchainInfo.surface = vkSurface;
		vkSwapchainInfo.clipped = true;
		vkContext.QueueIndices = VKQueueFamilyIndices.FindQueueFamilies(vkContext, vkContext.VkPhysicalDevice, vkSurface);
		uint32 graphicsQueueIndex = (uint32)vkContext.QueueIndices.GraphicsFamily;
		uint32 presentQueueIndex = (uint32)vkContext.QueueIndices.Presentfamily;
		uint32* queueFamilices = scope uint32[2]* (graphicsQueueIndex, presentQueueIndex);
		if (graphicsQueueIndex != presentQueueIndex)
		{
			vkSwapchainInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
			vkSwapchainInfo.queueFamilyIndexCount = 2;
			vkSwapchainInfo.pQueueFamilyIndices = queueFamilices;
		}
		else
		{
			vkSwapchainInfo.imageSharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
			vkSwapchainInfo.queueFamilyIndexCount = 0;
		}
		swapchainInfo = vkSwapchainInfo;
		VkSwapchainKHR newSwapchain = default(VkSwapchainKHR);
		VulkanNative.vkCreateSwapchainKHR(vkContext.VkDevice, &vkSwapchainInfo, null, &newSwapchain);
		vkSwapChain = newSwapchain;
		if (vkPresentQueue == VkQueue.Null)
		{
			VkQueue newQueue = default(VkQueue);
			VulkanNative.vkGetDeviceQueue(vkContext.VkDevice, presentQueueIndex, 0, &newQueue);
			vkPresentQueue = newQueue;
		}
		VKSwapChainFrameBuffer frameBuffer = new VKSwapChainFrameBuffer(GraphicsContext as VKGraphicsContext, this);
		if (base.FrameBuffer != null)
		{
			frameBuffer.IntermediateBufferAssociated = base.FrameBuffer.IntermediateBufferAssociated;
		}
		base.FrameBuffer = frameBuffer;
	}

	private void DestroySwapChain()
	{
		if (vkSwapChain != VkSwapchainKHR.Null)
		{
			VulkanNative.vkDestroySwapchainKHR(vkContext.VkDevice, vkSwapChain, null);
			vkSwapChain = VkSwapchainKHR.Null;

			if(base.FrameBuffer != null)
			{
				base.FrameBuffer.Dispose();
				delete base.FrameBuffer;
				base.FrameBuffer = null;
			}
		}
	}

	/// <inheritdoc />
	public override void RefreshSurfaceInfo(SurfaceInfo surfaceInfo)
	{
		SwapChainDescription copyDescription = base.SwapChainDescription;
		copyDescription.SurfaceInfo = surfaceInfo;
		base.SwapChainDescription = copyDescription;
		VulkanNative.vkDeviceWaitIdle(vkContext.VkDevice);
		DestroySwapChain();
		CreateSurface();
		CreateSwapChain();
		AcquireNextImage();
	}

	/// <inheritdoc />
	public override void ResizeSwapChain(uint32 width, uint32 height)
	{
		SwapChainDescription copyDescription = base.SwapChainDescription;
		copyDescription.Width = width;
		copyDescription.Height = height;
		base.SwapChainDescription = copyDescription;
		CreateSwapChain();
		AcquireNextImage();
	}

	/// <inheritdoc />
	public override void Present()
	{
		VkSwapchainKHR swapchain = vkSwapChain;
		uint32 imageIndex = (uint32)currentBackBufferIndex;
		VkPresentInfoKHR presentInfo = default(VkPresentInfoKHR);
		presentInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
		presentInfo.pNext = null;
		presentInfo.swapchainCount = 1;
		presentInfo.pSwapchains = &swapchain;
		presentInfo.pImageIndices = &imageIndex;
		VkResult result = VulkanNative.vkQueuePresentKHR(vkPresentQueue, &presentInfo);
		if(!(result == .VK_ERROR_OUT_OF_DATE_KHR || result == .VK_SUBOPTIMAL_KHR))
		{
			AcquireNextImage();
		}
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	private void AcquireNextImage()
	{
		uint32 imageIndex = (uint32)currentBackBufferIndex;
		VulkanNative.vkAcquireNextImageKHR(vkContext.VkDevice, vkSwapChain, uint64.MaxValue, VkSemaphore.Null, vkContext.vkImageAvailableFence, &imageIndex);
		CurrentBackBufferIndex = (int32)imageIndex;
		VkFence fence = vkContext.vkImageAvailableFence;
		VulkanNative.vkWaitForFences(vkContext.VkDevice, 1, &fence, true, uint64.MaxValue);
		VulkanNative.vkResetFences(vkContext.VkDevice, 1, &fence);
	}

	private VkSurfaceFormatKHR ChooseSwapSurfaceFormat(VkSurfaceFormatKHR* formats, int32 length)
	{
		if (length == 1 && formats.format == VkFormat.VK_FORMAT_UNDEFINED)
		{
			VkSurfaceFormatKHR result = default(VkSurfaceFormatKHR);
			result.format = VkFormat.VK_FORMAT_B8G8R8A8_UNORM;
			result.colorSpace = VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
			return result;
		}
		for (int32 i = 0; i < length; i++)
		{
			VkSurfaceFormatKHR availableFormat = formats[i];
			if (availableFormat.format == base.SwapChainDescription.ColorTargetFormat.ToVulkan(depthFormat: false) && availableFormat.colorSpace == VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
			{
				return availableFormat;
			}
		}
		return *formats;
	}

	private VkPresentModeKHR ChooseSwapPresentMode(VkPresentModeKHR* presentModes, int32 length)
	{
		VkPresentModeKHR bestMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;
		if (VerticalSync)
		{
			if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR))
			{
				bestMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR;
			}
		}
		else if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR))
		{
			bestMode = VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR;
		}
		else if (Contains(presentModes, length, VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR))
		{
			bestMode = VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR;
		}
		return bestMode;
	}

	private bool Contains(VkPresentModeKHR* allPresents, int32 length, VkPresentModeKHR presentMode)
	{
		for (int32 i = 0; i < length; i++)
		{
			if (allPresents[i] == presentMode)
			{
				return true;
			}
		}
		return false;
	}

	private VkExtent2D ChooseSwapExtent(VkSurfaceCapabilitiesKHR capabilities, uint32 width, uint32 height)
	{
		if (capabilities.currentExtent.width != uint32.MaxValue)
		{
			return capabilities.currentExtent;
		}
		VkExtent2D result = default(VkExtent2D);
		result.width = Clamp(width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width);
		result.height = Clamp(height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height);
		return result;
	}

	/// <summary>
	/// Clamp a uint32 value.
	/// </summary>
	/// <param name="value">Value to clamp.</param>
	/// <param name="min">Min value range.</param>
	/// <param name="max">Max value range.</param>
	/// <returns>clamped value.</returns>
	private uint32 Clamp(uint32 value, uint32 min, uint32 max)
	{
		if (value <= min)
		{
			return min;
		}
		if (value >= max)
		{
			return max;
		}
		return value;
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				if(base.FrameBuffer != null){
					base.FrameBuffer.Dispose();
					delete base.FrameBuffer;
					base.FrameBuffer = null;
				}
				VulkanNative.vkDestroySwapchainKHR(vkContext.VkDevice, vkSwapChain, null);
				VulkanNative.vkDestroySurfaceKHR(vkContext.VkInstance, vkSurface, null);
			}
			disposed = true;
		}
	}
}
