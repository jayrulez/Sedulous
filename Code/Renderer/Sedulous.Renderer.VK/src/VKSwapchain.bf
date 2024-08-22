using Sedulous.Renderer.VK.Internal;
using System;
using System.Collections;
using Bulkan;
using Bulkan.Utilities;
using static Bulkan.VulkanNative;
/****************************************************************************
 Copyright (c) 2021-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

namespace Sedulous.Renderer.VK;

class CCVKSwapchain : Swapchain
{
	public const bool ENABLE_PRE_ROTATION = true;

	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
		_preRotationEnabled = ENABLE_PRE_ROTATION;
	}

	public ~this()
	{
		destroy();
	}

	[Inline] public CCVKGPUSwapchain gpuSwapchain() { return _gpuSwapchain; }

	public bool checkSwapchainStatus(uint32 width = 0, uint32 height = 0)
	{
		uint32 newWidth = width;
		uint32 newHeight = height;
		uint32 imageCount = 0;
		/*if (_xr != null) {
			newWidth = ((CCVKTexture)_colorTexture).[Friend]_info.width;
			newHeight = ((CCVKTexture)_colorTexture).[Friend]_info.height;
			// xr double eyes need six images
			List<VkImage> vkImagesLeft = scope .();
			List<VkImage> vkImagesRight = scope .();
			_xr.getXRSwapchainVkImages(vkImagesLeft, (uint32)XREye.LEFT);
			_xr.getXRSwapchainVkImages(vkImagesRight, (uint32)XREye.RIGHT);
			_gpuSwapchain.swapchainImages.Resize(vkImagesLeft.Count + vkImagesRight.Count);
			_gpuSwapchain.swapchainImages.Clear();
			// 0-1-2
			_gpuSwapchain.swapchainImages.insert(_gpuSwapchain.swapchainImages.end(), vkImagesLeft.begin(), vkImagesLeft.end());
			// 3-4-5
			_gpuSwapchain.swapchainImages.insert(_gpuSwapchain.swapchainImages.end(), vkImagesRight.begin(), vkImagesRight.end());

			imageCount = (uint32)_gpuSwapchain.swapchainImages.Count;
			_gpuSwapchain.createInfo.imageExtent.width = newWidth;
			_gpuSwapchain.createInfo.imageExtent.height = newHeight;
			var gpuDevice = CCVKDevice.getInstance().gpuDevice();
			gpuDevice.curBackBufferIndex = 0;
			_gpuSwapchain.curImageIndex = 0;
			CCVKDevice.getInstance().updateBackBufferCount(imageCount);
			CCVKDevice.getInstance().waitAllFences();
			CC_LOG_INFO("Resizing surface: %dx%d, surface rotation: %d degrees", newWidth, newHeight, (uint32)_transform) * 90;
		}
		else*/
		{
			if (_gpuSwapchain.vkSurface == .Null)
			{ // vkSurface will be set to .Null after call doDestroySurface
				return false;
			}
			var gpuDevice = CCVKDevice.getInstance().gpuDevice();
			var gpuContext = CCVKDevice.getInstance().gpuContext();

			VkSurfaceCapabilitiesKHR surfaceCapabilities = .();
			VK_CHECK!(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &surfaceCapabilities));

			// surfaceCapabilities.currentExtent seems to remain the same
			// during any size/orientation change events on android devices
			// so we prefer the system input (oriented size) here
			newWidth = width != 0 ? width : surfaceCapabilities.currentExtent.width;
			newHeight = height != 0 ? height : surfaceCapabilities.currentExtent.height;

			if (_gpuSwapchain.createInfo.imageExtent.width == newWidth &&
				_gpuSwapchain.createInfo.imageExtent.height == newHeight && _gpuSwapchain.lastPresentResult == .VK_SUCCESS)
			{
				return true;
			}

			if (newWidth == (uint32) - 1)
			{
				_gpuSwapchain.createInfo.imageExtent.width = _colorTexture.getWidth();
				_gpuSwapchain.createInfo.imageExtent.height = _colorTexture.getHeight();
			}
			else
			{
				_gpuSwapchain.createInfo.imageExtent.width = newWidth;
				_gpuSwapchain.createInfo.imageExtent.height = newHeight;
			}

			if (newWidth == 0 || newHeight == 0)
			{
				_gpuSwapchain.lastPresentResult = .VK_NOT_READY;
				return false;
			}

			_gpuSwapchain.createInfo.surface = _gpuSwapchain.vkSurface;
			_gpuSwapchain.createInfo.oldSwapchain = _gpuSwapchain.vkSwapchain;

			WriteInfo("Resizing surface: {}x{}", newWidth, newHeight);

			CCVKDevice.getInstance().waitAllFences();

			VkSwapchainKHR vkSwapchain = .Null;
			VK_CHECK!(vkCreateSwapchainKHR(gpuDevice.vkDevice, &_gpuSwapchain.createInfo, null, &vkSwapchain));

			destroySwapchain(gpuDevice);

			_gpuSwapchain.vkSwapchain = vkSwapchain;

			VK_CHECK!(vkGetSwapchainImagesKHR(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain, &imageCount, null));
			CCVKDevice.getInstance().updateBackBufferCount(imageCount);
			_gpuSwapchain.swapchainImages.Resize(imageCount);
			VK_CHECK!(vkGetSwapchainImagesKHR(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain, &imageCount, _gpuSwapchain.swapchainImages.Ptr));
		}
		++_generation;

		// should skip size check, since the old swapchain has already been destroyed
		((CCVKTexture)_colorTexture).[Friend]_info.width = 1;
		((CCVKTexture)_depthStencilTexture).[Friend]_info.width = 1;
		_colorTexture.resize(newWidth, newHeight);
		_depthStencilTexture.resize(newWidth, newHeight);

		bool hasStencil = GFX_FORMAT_INFOS[(uint32)_depthStencilTexture.getFormat()].hasStencil;
		List<VkImageMemoryBarrier> barriers = scope .()..Resize(imageCount * 2, VkImageMemoryBarrier());
		VkPipelineStageFlags srcStageMask = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
		VkPipelineStageFlags dstStageMask = .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
		ThsvsImageBarrier tempBarrier = .();
		tempBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
		tempBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
		tempBarrier.subresourceRange.levelCount = VK_REMAINING_MIP_LEVELS;
		tempBarrier.subresourceRange.layerCount = VK_REMAINING_ARRAY_LAYERS;
		VkPipelineStageFlags tempSrcStageMask = 0;
		VkPipelineStageFlags tempDstStageMask = 0;
		var colorGPUTexture = ((CCVKTexture)_colorTexture).gpuTexture();
		var depthStencilGPUTexture = ((CCVKTexture)_depthStencilTexture).gpuTexture();
		for (uint32 i = 0U; i < imageCount; i++)
		{
			tempBarrier.nextAccessCount = 1;
			tempBarrier.pNextAccesses = getAccessType(AccessFlagBit.PRESENT);
			tempBarrier.image = _gpuSwapchain.swapchainImages[i];
			tempBarrier.subresourceRange.aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
			thsvsGetVulkanImageMemoryBarrier(tempBarrier, &tempSrcStageMask, &tempDstStageMask, &barriers[i]);
			srcStageMask |= tempSrcStageMask;
			dstStageMask |= tempDstStageMask;

			tempBarrier.nextAccessCount = 1;
			tempBarrier.pNextAccesses = getAccessType(AccessFlagBit.DEPTH_STENCIL_ATTACHMENT_WRITE);
			tempBarrier.image = depthStencilGPUTexture.swapchainVkImages[i];
			tempBarrier.subresourceRange.aspectMask = hasStencil ? .VK_IMAGE_ASPECT_DEPTH_BIT | .VK_IMAGE_ASPECT_STENCIL_BIT : .VK_IMAGE_ASPECT_DEPTH_BIT;
			thsvsGetVulkanImageMemoryBarrier(tempBarrier, &tempSrcStageMask, &tempDstStageMask, &barriers[imageCount + i]);
			srcStageMask |= tempSrcStageMask;
			dstStageMask |= tempDstStageMask;
		}
		CCVKDevice.getInstance().gpuTransportHub().checkIn(
			scope [&] (gpuCommandBuffer) =>
			{
				vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer, srcStageMask, dstStageMask, 0, 0, null, 0, null,
					(uint32)barriers.Count, barriers.Ptr);
			},
			true); // submit immediately

		colorGPUTexture.currentAccessTypes..Clear().Resize(1, .THSVS_ACCESS_PRESENT);
		depthStencilGPUTexture.currentAccessTypes..Clear().Resize(1, .THSVS_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ);

		_gpuSwapchain.lastPresentResult = .VK_SUCCESS;

		// Android Game Frame Pacing:swappy
/*#if CC_SWAPPY_ENABLED

var gpuDevice = CCVKDevice.getInstance().gpuDevice();
		const var gpuContext = CCVKDevice.getInstance().gpuContext();
		int32 fps = cc.BasePlatform.getPlatform().getFps();

		uint64 frameRefreshIntervalNS;
		var platform = (AndroidPlatform*)cc.BasePlatform.getPlatform();
		var window = CC_GET_SYSTEM_WINDOW(_windowId);
		void* windowHandle = reinterpret_cast<void*>(window.getWindowHandle());
		SwappyVk_initAndGetRefreshCycleDuration((JNIEnv*)platform.getEnv(),
			(jobject)platform.getActivity(),
			gpuContext.physicalDevice,
			gpuDevice.vkDevice,
			_gpuSwapchain.vkSwapchain,
			&frameRefreshIntervalNS);
		SwappyVk_setSwapIntervalNS(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain, fps ? 1000000000L / fps : frameRefreshIntervalNS);
		SwappyVk_setWindow(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain, (ANativeWindow*)windowHandle);
		#endif*/

		return true;
	}

	protected override void doInit(in SwapchainInfo info)
	{
			/*_xr = CC_GET_XR_INTERFACE();
			if (_xr) {
				_xr.updateXRSwapchainTypedID(getTypedID());
			}*/
		var gpuDevice = CCVKDevice.getInstance().gpuDevice();
		var gpuContext = CCVKDevice.getInstance().gpuContext();
		_gpuSwapchain = new CCVKGPUSwapchain();
		gpuDevice.swapchains.Add(_gpuSwapchain);

		createVkSurface();

			///////////////////// Parameter Selection /////////////////////

		uint32 queueFamilyPropertiesCount = (uint32)gpuContext.queueFamilyProperties.Count;
		_gpuSwapchain.queueFamilyPresentables.Resize(queueFamilyPropertiesCount);
		for (uint32 propertyIndex = 0U; propertyIndex < queueFamilyPropertiesCount; propertyIndex++)
		{
				//if (_xr) {
				//	_gpuSwapchain.queueFamilyPresentables[propertyIndex] = true;
				//}
				//else {
			vkGetPhysicalDeviceSurfaceSupportKHR(gpuContext.physicalDevice, propertyIndex,
				_gpuSwapchain.vkSurface, &_gpuSwapchain.queueFamilyPresentables[propertyIndex]);
				//}
		}

			// find other possible queues if not presentable
		var queue = ((CCVKQueue)CCVKDevice.getInstance().getQueue());
		if (!_gpuSwapchain.queueFamilyPresentables[queue.gpuQueue().queueFamilyIndex])
		{
			var indices = ref queue.gpuQueue().possibleQueueFamilyIndices;
			indices.RemoveAll(scope [&] (i) =>
				{
					return !_gpuSwapchain.queueFamilyPresentables[i];
				});
			Runtime.Assert(!_gpuSwapchain.queueFamilyPresentables.IsEmpty);
			cmdFuncCCVKGetDeviceQueue(CCVKDevice.getInstance(), queue.gpuQueue());
		}

		Format colorFmt = Format.BGRA8;
		Format depthStencilFmt = Format.DEPTH_STENCIL;

		if (_gpuSwapchain.vkSurface != .Null)
		{
			VkSurfaceCapabilitiesKHR surfaceCapabilities = .();
			vkGetPhysicalDeviceSurfaceCapabilitiesKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &surfaceCapabilities);

			uint32 surfaceFormatCount = 0U;
			VK_CHECK!(vkGetPhysicalDeviceSurfaceFormatsKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &surfaceFormatCount, null));
			List<VkSurfaceFormatKHR> surfaceFormats = scope .()..Resize(surfaceFormatCount);
			VK_CHECK!(vkGetPhysicalDeviceSurfaceFormatsKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &surfaceFormatCount, surfaceFormats.Ptr));

			uint32 presentModeCount = 0U;
			VK_CHECK!(vkGetPhysicalDeviceSurfacePresentModesKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &presentModeCount, null));
			List<VkPresentModeKHR> presentModes = scope .()..Resize(presentModeCount);
			VK_CHECK!(vkGetPhysicalDeviceSurfacePresentModesKHR(gpuContext.physicalDevice, _gpuSwapchain.vkSurface, &presentModeCount, presentModes.Ptr));

			VkFormat colorFormat = .VK_FORMAT_B8G8R8A8_UNORM;
			VkColorSpaceKHR colorSpace = .VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
			// If the surface format list only includes one entry with VK_FORMAT_UNDEFINED,
			// there is no preferred format, so we assume VK_FORMAT_B8G8R8A8_UNORM
			if ((surfaceFormatCount == 1) && (surfaceFormats[0].format == .VK_FORMAT_UNDEFINED))
			{
				colorFormat = .VK_FORMAT_B8G8R8A8_UNORM;
				colorSpace = surfaceFormats[0].colorSpace;
			}
			else
			{
				// iterate over the list of available surface format and
				// check for the presence of VK_FORMAT_B8G8R8A8_UNORM
				bool imageFormatFound = false;
				for (ref VkSurfaceFormatKHR surfaceFormat in ref surfaceFormats)
				{
					if (surfaceFormat.format == .VK_FORMAT_B8G8R8A8_UNORM)
					{
						colorFormat = surfaceFormat.format;
						colorSpace = surfaceFormat.colorSpace;
						imageFormatFound = true;
						break;
					}
				}

				// in case VK_FORMAT_B8G8R8A8_UNORM is not available
				// select the first available color format
				if (!imageFormatFound)
				{
					colorFormat = surfaceFormats[0].format;
					colorSpace = surfaceFormats[0].colorSpace;
					switch (colorFormat) {
					case .VK_FORMAT_R8G8B8A8_UNORM: colorFmt = Format.RGBA8; break;
					case .VK_FORMAT_R8G8B8A8_SRGB: colorFmt = Format.SRGB8_A8; break;
					case .VK_FORMAT_R5G6B5_UNORM_PACK16: colorFmt = Format.R5G6B5; break;
					default:
						Runtime.Assert(false);
						break;
					}
				}
			}

			// Select a present mode for the swapchain

			List<VkPresentModeKHR> presentModePriorityList = scope .();

			switch (_vsyncMode) {
			case VsyncMode.OFF: presentModePriorityList.AddRange(scope List<VkPresentModeKHR>() { .VK_PRESENT_MODE_IMMEDIATE_KHR, .VK_PRESENT_MODE_FIFO_KHR }); break;
			case VsyncMode.ON: presentModePriorityList.AddRange(scope List<VkPresentModeKHR>() { .VK_PRESENT_MODE_FIFO_KHR }); break;
			case VsyncMode.RELAXED: presentModePriorityList.AddRange(scope List<VkPresentModeKHR>() { .VK_PRESENT_MODE_FIFO_RELAXED_KHR, .VK_PRESENT_MODE_FIFO_KHR }); break;
			case VsyncMode.MAILBOX: presentModePriorityList.AddRange(scope List<VkPresentModeKHR>() { .VK_PRESENT_MODE_MAILBOX_KHR, .VK_PRESENT_MODE_FIFO_KHR }); break;
			case VsyncMode.HALF: presentModePriorityList.AddRange(scope List<VkPresentModeKHR>() { .VK_PRESENT_MODE_FIFO_KHR }); break; // no easy fallback
			}

			VkPresentModeKHR swapchainPresentMode = .VK_PRESENT_MODE_FIFO_KHR;

			// UNASSIGNED-BestPractices-vkCreateSwapchainKHR-swapchain-presentmode-not-fifo
/*#if !defined(VK_USE_PLATFORM_ANDROID_KHR)
	for (VkPresentModeKHR presentMode : presentModePriorityList) {
				if (std.find(presentModes.begin(), presentModes.end(), presentMode) != presentModes.end()) {
					swapchainPresentMode = presentMode;
					break;
				}
			}
			#endif*/

			// Determine the number of images
			uint32 desiredNumberOfSwapchainImages = Math.Max(gpuDevice.backBufferCount, surfaceCapabilities.minImageCount);

			VkExtent2D imageExtent = .(1U, 1U);

			// Find a supported composite alpha format (not all devices support alpha opaque)
			VkCompositeAlphaFlagsKHR compositeAlpha = .VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
			// Simply select the first composite alpha format available
			List<VkCompositeAlphaFlagsKHR> compositeAlphaFlags = scope .()
				{
					.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
					.VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR,
					.VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR,
					.VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR
				};
			for (VkCompositeAlphaFlagsKHR compositeAlphaFlag in compositeAlphaFlags)
			{
				if (surfaceCapabilities.supportedCompositeAlpha & compositeAlphaFlag != 0)
				{
					compositeAlpha = compositeAlphaFlag;
					break;
				}
			}
			VkImageUsageFlags imageUsage = .VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
			// Enable transfer source on swap chain images if supported
			if (surfaceCapabilities.supportedUsageFlags & .VK_IMAGE_USAGE_TRANSFER_SRC_BIT != 0)
			{
				imageUsage |= .VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
			}

			// Enable transfer destination on swap chain images if supported
			if (surfaceCapabilities.supportedUsageFlags & .VK_IMAGE_USAGE_TRANSFER_DST_BIT != 0)
			{
				imageUsage |= .VK_IMAGE_USAGE_TRANSFER_DST_BIT;
			}

			_gpuSwapchain.createInfo.surface = _gpuSwapchain.vkSurface;
			_gpuSwapchain.createInfo.minImageCount = desiredNumberOfSwapchainImages;
			_gpuSwapchain.createInfo.imageFormat = colorFormat;
			_gpuSwapchain.createInfo.imageColorSpace = colorSpace;
			_gpuSwapchain.createInfo.imageExtent = imageExtent;
			_gpuSwapchain.createInfo.imageUsage = imageUsage;
			_gpuSwapchain.createInfo.imageArrayLayers = 1;
			_gpuSwapchain.createInfo.preTransform = VkSurfaceTransformFlagsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
			_gpuSwapchain.createInfo.compositeAlpha = compositeAlpha;
			_gpuSwapchain.createInfo.presentMode = swapchainPresentMode;
			_gpuSwapchain.createInfo.clipped = VK_TRUE; // Setting clipped to VK_TRUE allows the implementation to discard rendering outside of the surface area
		}
			///////////////////// Texture Creation /////////////////////
		var width = (uint32)info.width;
		var height = (uint32)info.height;
			/*if (_xr) {
				colorFmt = _xr.getXRSwapchainFormat();
				width = _xr.getXRConfig(xr.XRConfigKey.SWAPCHAIN_WIDTH).getInt();
				height = _xr.getXRConfig(xr.XRConfigKey.SWAPCHAIN_HEIGHT).getInt();
			}*/
		_colorTexture = new CCVKTexture();
		_depthStencilTexture = new CCVKTexture();

		SwapchainTextureInfo textureInfo = .();
		textureInfo.swapchain = this;
		textureInfo.format = colorFmt;
		textureInfo.width = width;
		textureInfo.height = height;
		initTexture(textureInfo, ref _colorTexture);

		textureInfo.format = depthStencilFmt;
		initTexture(textureInfo, ref _depthStencilTexture);

//#if CC_PLATFORM == CC_PLATFORM_ANDROID
//				var window = CC_GET_SYSTEM_WINDOW(_windowId);
//				auto viewSize = window.getViewSize();
//				checkSwapchainStatus(viewSize.width, viewSize.height);
//#else
		checkSwapchainStatus();
//#endif
	}

	protected override void doDestroy()
	{
		if (_gpuSwapchain == null) return;

		CCVKDevice.getInstance().waitAllFences();

		_depthStencilTexture = null;
		_colorTexture = null;

		var gpuDevice = CCVKDevice.getInstance().gpuDevice();
		var gpuContext = CCVKDevice.getInstance().gpuContext();

		destroySwapchain(gpuDevice);

		if (_gpuSwapchain.vkSurface != .Null)
		{
			vkDestroySurfaceKHR(gpuContext.vkInstance, _gpuSwapchain.vkSurface, null);
			_gpuSwapchain.vkSurface = .Null;
		}

		gpuDevice.swapchains.Remove(_gpuSwapchain);
		_gpuSwapchain = null;
	}

	protected override void doResize(uint32 width, uint32 height, SurfaceTransform transform)
	{
		checkSwapchainStatus(width, height); // the orientation info from system event is not reliable
	}

	protected override void doDestroySurface()
	{
		if (_gpuSwapchain == null || _gpuSwapchain.vkSurface == .Null) return;
		var gpuDevice = CCVKDevice.getInstance().gpuDevice();
		var gpuContext = CCVKDevice.getInstance().gpuContext();

		CCVKDevice.getInstance().waitAllFences();
		destroySwapchain(gpuDevice);
		_gpuSwapchain.lastPresentResult = .VK_NOT_READY;

		vkDestroySurfaceKHR(gpuContext.vkInstance, _gpuSwapchain.vkSurface, null);
		_gpuSwapchain.vkSurface = .Null;
	}

	protected override void doCreateSurface(void* windowHandle)
	{ // NOLINT
		if (_gpuSwapchain == null || _gpuSwapchain.vkSurface != .Null) return;
		createVkSurface();
//#if CC_PLATFORM == CC_PLATFORM_ANDROID
//				var window = CC_GET_SYSTEM_WINDOW(_windowId);
//				auto viewSize = window.getViewSize();
//				checkSwapchainStatus(viewSize.width, viewSize.height);
//#else
		checkSwapchainStatus();
//#endif
	}

	protected void createVkSurface()
	{
			/*if (_xr) {
				// xr do not need VkSurface
				_gpuSwapchain.vkSurface = .Null;
				return;
			}*/
		var gpuContext = CCVKDevice.getInstance().gpuContext();

/*#if defined(VK_USE_PLATFORM_ANDROID_KHR)
		VkAndroidSurfaceCreateInfoKHR surfaceCreateInfo{ VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR };
			surfaceCreateInfo.window = reinterpret_cast<ANativeWindow*>(_windowHandle);
			VK_CHECK!(vkCreateAndroidSurfaceKHR(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#elif defined(VK_USE_PLATFORM_WIN32_KHR)
			VkWin32SurfaceCreateInfoKHR surfaceCreateInfo{ VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR };
			surfaceCreateInfo.hinstance = (HINSTANCE)GetModuleHandle(null);
			surfaceCreateInfo.hwnd = reinterpret_cast<HWND>(_windowHandle);
			VK_CHECK!(vkCreateWin32SurfaceKHR(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#elif defined(VK_USE_PLATFORM_VI_NN)
			VkViSurfaceCreateInfoNN surfaceCreateInfo{ VK_STRUCTURE_TYPE_VI_SURFACE_CREATE_INFO_NN };
			surfaceCreateInfo.window = _windowHandle;
			VK_CHECK!(vkCreateViSurfaceNN(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#elif defined(VK_USE_PLATFORM_MACOS_MVK)
			VkMacOSSurfaceCreateInfoMVK surfaceCreateInfo{ VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK };
			surfaceCreateInfo.pView = _windowHandle;
			VK_CHECK!(vkCreateMacOSSurfaceMVK(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#elif defined(VK_USE_PLATFORM_WAYLAND_KHR)
			VkWaylandSurfaceCreateInfoKHR surfaceCreateInfo{ VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR };
			surfaceCreateInfo.display = null; // TODO
			surfaceCreateInfo.surface = reinterpret_cast<wl_surface*>(_windowHandle);
			VK_CHECK!(vkCreateWaylandSurfaceKHR(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#elif defined(VK_USE_PLATFORM_XCB_KHR)
			VkXcbSurfaceCreateInfoKHR surfaceCreateInfo{ VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR };
			surfaceCreateInfo.connection = null; // TODO
			surfaceCreateInfo.window = reinterpret_cast<uint64>(_windowHandle);
			VK_CHECK!(vkCreateXcbSurfaceKHR(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
		#else
		#pragma error Platform not supported
		#endif*/
			// assuming windows for now
		VkWin32SurfaceCreateInfoKHR surfaceCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR };
		surfaceCreateInfo.hinstance = (HINSTANCE)GetModuleHandle(null);
		surfaceCreateInfo.hwnd = _windowHandle;
		VK_CHECK!(vkCreateWin32SurfaceKHR(gpuContext.vkInstance, &surfaceCreateInfo, null, &_gpuSwapchain.vkSurface));
	}

	protected void destroySwapchain(CCVKGPUDevice gpuDevice)
	{
		if (_gpuSwapchain.vkSwapchain != .Null)
		{
			_gpuSwapchain.swapchainImages.Clear();

/*#if CC_SWAPPY_ENABLED
	SwappyVk_destroySwapchain(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain);
			#endif*/

			vkDestroySwapchainKHR(gpuDevice.vkDevice, _gpuSwapchain.vkSwapchain, null);
			_gpuSwapchain.vkSwapchain = .Null;
			// reset index only after device not ready
			_gpuSwapchain.curImageIndex = 0;
			gpuDevice.curBackBufferIndex = 0;
		}
	}

	protected CCVKGPUSwapchain _gpuSwapchain;
		//IXRInterface* _xr = null;
}
