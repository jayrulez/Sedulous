using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System;
using System.Threading;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    public class VKSwapchain : Swapchain
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkSurfaceKHR _surface;
        private VkSwapchainKHR _deviceSwapchain;
        private readonly VKSwapchainFramebuffer _framebuffer;
        private VkFence _imageAvailableFence;
        private readonly uint32 _presentQueueIndex;
        private readonly VkQueue _presentQueue;
        private bool _syncToVBlank;
        private readonly SwapchainSource _swapchainSource;
        private readonly bool _colorSrgb;
        private bool? _newSyncToVBlank;
        private uint32 _currentImageIndex;
        private String _name;
        private bool _disposed;

		public Monitor PresentLock = new .() ~ delete _;

        public override String Name { get => _name; set { _name = value; _gd.SetResourceName(this, value); } }
        public override Framebuffer Framebuffer => _framebuffer;
        public override bool SyncToVerticalBlank
        {
            get => _newSyncToVBlank ?? _syncToVBlank;
            set
            {
                if (_syncToVBlank != value)
                {
                    _newSyncToVBlank = value;
                }
            }
        }

        public override bool IsDisposed => _disposed;

        public VkSwapchainKHR DeviceSwapchain => _deviceSwapchain;
        public uint32 ImageIndex => _currentImageIndex;
        public VkFence ImageAvailableFence => _imageAvailableFence;
        public VkSurfaceKHR Surface => _surface;
        public VkQueue PresentQueue => _presentQueue;
        public uint32 PresentQueueIndex => _presentQueueIndex;
        internal ResourceRefCount RefCount { get; }

        public this(VKGraphicsDevice gd, in SwapchainDescription description) : this(gd, description, .Null) { }

        public this(VKGraphicsDevice gd, in SwapchainDescription description, VkSurfaceKHR existingSurface)
        {
            _gd = gd;
            _syncToVBlank = description.SyncToVerticalBlank;
            _swapchainSource = description.Source;
            _colorSrgb = description.ColorSrgb;

            if (existingSurface == VkSurfaceKHR.Null)
            {
                _surface = VKSurfaceUtil.CreateSurface(gd, gd.Instance, _swapchainSource);
            }
            else
            {
                _surface = existingSurface;
            }

            if (!GetPresentQueueIndex(out _presentQueueIndex))
            {
                Runtime.GALError($"The system does not support presenting the given Vulkan surface.");
            }
            vkGetDeviceQueue(_gd.Device, _presentQueueIndex, 0, &_presentQueue);

            _framebuffer = new VKSwapchainFramebuffer(gd, this, _surface, description.Width, description.Height, description.DepthFormat);

            CreateSwapchain(description.Width, description.Height);

            VkFenceCreateInfo fenceCI = VkFenceCreateInfo(){sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
            fenceCI.flags = VkFenceCreateFlags.None;
            vkCreateFence(_gd.Device, &fenceCI, null, &_imageAvailableFence);

            AcquireNextImage(_gd.Device, VkSemaphore.Null, _imageAvailableFence);
            vkWaitForFences(_gd.Device, 1, &_imageAvailableFence, true, uint64.MaxValue);
            vkResetFences(_gd.Device, 1, &_imageAvailableFence);

            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        public override void Resize(uint32 width, uint32 height)
        {
            RecreateAndReacquire(width, height);
        }

        public bool AcquireNextImage(VkDevice device, VkSemaphore semaphore, VkFence fence)
        {
            if (_newSyncToVBlank != null)
            {
                _syncToVBlank = _newSyncToVBlank.Value;
                _newSyncToVBlank = null;
                RecreateAndReacquire(_framebuffer.Width, _framebuffer.Height);
                return false;
            }

            VkResult result = vkAcquireNextImageKHR(
                device,
                _deviceSwapchain,
                uint64.MaxValue,
                semaphore,
                fence,
                &_currentImageIndex);
            _framebuffer.SetImageIndex(_currentImageIndex);
            if (result == VkResult.VK_ERROR_OUT_OF_DATE_KHR || result == VkResult.VK_SUBOPTIMAL_KHR)
            {
                CreateSwapchain(_framebuffer.Width, _framebuffer.Height);
                return false;
            }
            else if (result != VkResult.VK_SUCCESS)
            {
                Runtime.GALError("Could not acquire next image from the Vulkan swapchain.");
            }

            return true;
        }

        private void RecreateAndReacquire(uint32 width, uint32 height)
        {
            if (CreateSwapchain(width, height))
            {
                if (AcquireNextImage(_gd.Device, VkSemaphore.Null, _imageAvailableFence))
                {
                    vkWaitForFences(_gd.Device, 1, &_imageAvailableFence, true, uint64.MaxValue);
                    vkResetFences(_gd.Device, 1, &_imageAvailableFence);
                }
            }
        }

        private bool CreateSwapchain(uint32 width, uint32 height)
        {
            // Obtain the surface capabilities first -- this will indicate whether the surface has been lost.
			VkSurfaceCapabilitiesKHR surfaceCapabilities = .();
            VkResult result = vkGetPhysicalDeviceSurfaceCapabilitiesKHR(_gd.PhysicalDevice, _surface, &surfaceCapabilities);
            if (result == VkResult.VK_ERROR_SURFACE_LOST_KHR)
            {
                Runtime.GALError($"The Swapchain's underlying surface has been lost.");
            }

            if (surfaceCapabilities.minImageExtent.width == 0 && surfaceCapabilities.minImageExtent.height == 0
                && surfaceCapabilities.maxImageExtent.width == 0 && surfaceCapabilities.maxImageExtent.height == 0)
            {
                return false;
            }

            if (_deviceSwapchain != VkSwapchainKHR.Null)
            {
                _gd.WaitForIdle();
            }

            _currentImageIndex = 0;
            uint32 surfaceFormatCount = 0;
            result = vkGetPhysicalDeviceSurfaceFormatsKHR(_gd.PhysicalDevice, _surface, &surfaceFormatCount, null);
            CheckResult(result);
            VkSurfaceFormatKHR[] formats = scope VkSurfaceFormatKHR[surfaceFormatCount];
            result = vkGetPhysicalDeviceSurfaceFormatsKHR(_gd.PhysicalDevice, _surface, &surfaceFormatCount, formats.Ptr);
            CheckResult(result);

            VkFormat desiredFormat = _colorSrgb
                ? VkFormat.VK_FORMAT_B8G8R8A8_SRGB
                : VkFormat.VK_FORMAT_B8G8R8A8_UNORM;

            VkSurfaceFormatKHR surfaceFormat = VkSurfaceFormatKHR();
            if (formats.Count == 1 && formats[0].format == VkFormat.VK_FORMAT_UNDEFINED)
            {
                surfaceFormat = VkSurfaceFormatKHR() { colorSpace = VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR, format = desiredFormat };
            }
            else
            {
                for (VkSurfaceFormatKHR format in formats)
                {
                    if (format.colorSpace == VkColorSpaceKHR.VK_COLOR_SPACE_SRGB_NONLINEAR_KHR && format.format == desiredFormat)
                    {
                        surfaceFormat = format;
                        break;
                    }
                }
                if (surfaceFormat.format == VkFormat.VK_FORMAT_UNDEFINED)
                {
                    if (_colorSrgb && surfaceFormat.format != VkFormat.VK_FORMAT_R8G8B8A8_SRGB)
                    {
                        Runtime.GALError($"Unable to create an sRGB Swapchain for this surface.");
                    }

                    surfaceFormat = formats[0];
                }
            }

            uint32 presentModeCount = 0;
            result = vkGetPhysicalDeviceSurfacePresentModesKHR(_gd.PhysicalDevice, _surface, &presentModeCount, null);
            CheckResult(result);
            VkPresentModeKHR[] presentModes = scope VkPresentModeKHR[presentModeCount];
            result = vkGetPhysicalDeviceSurfacePresentModesKHR(_gd.PhysicalDevice, _surface, &presentModeCount, presentModes.Ptr);
            CheckResult(result);

            VkPresentModeKHR presentMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_KHR;

            if (_syncToVBlank)
            {
                if (presentModes.Contains(VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR))
                {
                    presentMode = VkPresentModeKHR.VK_PRESENT_MODE_FIFO_RELAXED_KHR;
                }
            }
            else
            {
                if (presentModes.Contains(VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR))
                {
                    presentMode = VkPresentModeKHR.VK_PRESENT_MODE_MAILBOX_KHR;
                }
                else if (presentModes.Contains(VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR))
                {
                    presentMode = VkPresentModeKHR.VK_PRESENT_MODE_IMMEDIATE_KHR;
                }
            }

            uint32 maxImageCount = surfaceCapabilities.maxImageCount == 0 ? uint32.MaxValue : surfaceCapabilities.maxImageCount;
            uint32 imageCount = Math.Min(maxImageCount, surfaceCapabilities.minImageCount + 1);

            VkSwapchainCreateInfoKHR swapchainCI = VkSwapchainCreateInfoKHR(){sType = .VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR};
            swapchainCI.surface = _surface;
            swapchainCI.presentMode = presentMode;
            swapchainCI.imageFormat = surfaceFormat.format;
            swapchainCI.imageColorSpace = surfaceFormat.colorSpace;
            uint32 clampedWidth = Util.Clamp(width, surfaceCapabilities.minImageExtent.width, surfaceCapabilities.maxImageExtent.width);
            uint32 clampedHeight = Util.Clamp(height, surfaceCapabilities.minImageExtent.height, surfaceCapabilities.maxImageExtent.height);
            swapchainCI.imageExtent = VkExtent2D() { width = clampedWidth, height = clampedHeight };
            swapchainCI.minImageCount = imageCount;
            swapchainCI.imageArrayLayers = 1;
            swapchainCI.imageUsage = VkImageUsageFlags.VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VkImageUsageFlags.VK_IMAGE_USAGE_TRANSFER_DST_BIT;

            uint32[2] queueFamilyIndices = .(_gd.GraphicsQueueIndex, _gd.PresentQueueIndex);

            if (_gd.GraphicsQueueIndex != _gd.PresentQueueIndex)
            {
                swapchainCI.imageSharingMode = VkSharingMode.VK_SHARING_MODE_CONCURRENT;
                swapchainCI.queueFamilyIndexCount = 2;
                swapchainCI.pQueueFamilyIndices = &queueFamilyIndices;
            }
            else
            {
                swapchainCI.imageSharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
                swapchainCI.queueFamilyIndexCount = 0;
            }

            swapchainCI.preTransform = VkSurfaceTransformFlagsKHR.VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
            swapchainCI.compositeAlpha = VkCompositeAlphaFlagsKHR.VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
            swapchainCI.clipped = true;

            VkSwapchainKHR oldSwapchain = _deviceSwapchain;
            swapchainCI.oldSwapchain = oldSwapchain;

            result = vkCreateSwapchainKHR(_gd.Device, &swapchainCI, null, &_deviceSwapchain);
            CheckResult(result);
            if (oldSwapchain != VkSwapchainKHR.Null)
            {
                vkDestroySwapchainKHR(_gd.Device, oldSwapchain, null);
            }

            _framebuffer.SetNewSwapchain(_deviceSwapchain, width, height, surfaceFormat, swapchainCI.imageExtent);
            return true;
        }

        private bool GetPresentQueueIndex(out uint32 queueFamilyIndex)
        {
            uint32 graphicsQueueIndex = _gd.GraphicsQueueIndex;
            uint32 presentQueueIndex = _gd.PresentQueueIndex;

            if (QueueSupportsPresent(graphicsQueueIndex, _surface))
            {
                queueFamilyIndex = graphicsQueueIndex;
                return true;
            }
            else if (graphicsQueueIndex != presentQueueIndex && QueueSupportsPresent(presentQueueIndex, _surface))
            {
                queueFamilyIndex = presentQueueIndex;
                return true;
            }

            queueFamilyIndex = 0;
            return false;
        }

        private bool QueueSupportsPresent(uint32 queueFamilyIndex, VkSurfaceKHR surface)
        {
			VkBool32 supported = false;
            VkResult result = vkGetPhysicalDeviceSurfaceSupportKHR(
                _gd.PhysicalDevice,
                queueFamilyIndex,
                surface,
                &supported);
            CheckResult(result);
            return supported;
        }

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            vkDestroyFence(_gd.Device, _imageAvailableFence, null);
            _framebuffer.Dispose();
            vkDestroySwapchainKHR(_gd.Device, _deviceSwapchain, null);
            vkDestroySurfaceKHR(_gd.Instance, _surface, null);

            _disposed = true;
        }
    }
}
