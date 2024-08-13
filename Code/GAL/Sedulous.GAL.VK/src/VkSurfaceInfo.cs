using System;
using Bulkan;
using static Sedulous.GAL.VK.VulkanUtil;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    /// <summary>
    /// An object which can be used to create a VkSurfaceKHR.
    /// </summary>
    public abstract class VKSurfaceSource
    {
        internal this() { }

        /// <summary>
        /// Creates a new VkSurfaceKHR attached to this source.
        /// </summary>
        /// <param name="instance">The VkInstance to use.</param>
        /// <returns>A new VkSurfaceKHR.</returns>
        public abstract VkSurfaceKHR CreateSurface(VkInstance instance);

        /// <summary>
        /// Creates a new <see cref="VKSurfaceSource"/> from the given Win32 instance and window handle.
        /// </summary>
        /// <param name="hinstance">The Win32 instance handle.</param>
        /// <param name="hwnd">The Win32 window handle.</param>
        /// <returns>A new VkSurfaceSource.</returns>
        public static VKSurfaceSource CreateWin32(void* hinstance, void* hwnd) => new Win32VkSurfaceInfo(hinstance, hwnd);
        /// <summary>
        /// Creates a new VkSurfaceSource from the given Xlib information.
        /// </summary>
        /// <param name="display">A pointer to the Xlib Display.</param>
        /// <param name="window">An Xlib window.</param>
        /// <returns>A new VkSurfaceSource.</returns>
        public static VKSurfaceSource CreateXlib(void* display, void* window) => new XlibVkSurfaceInfo(display, window);

        protected abstract SwapchainSource GetSurfaceSource();
    }

    internal class Win32VkSurfaceInfo : VKSurfaceSource
    {
        private readonly void* _hinstance;
        private readonly void* _hwnd;

        public this(void* hinstance, void* hwnd)
        {
            _hinstance = hinstance;
            _hwnd = hwnd;
        }

        public override VkSurfaceKHR CreateSurface(VkInstance instance)
        {
            return VKSurfaceUtil.CreateSurface(null, instance, GetSurfaceSource());
        }

        protected override SwapchainSource GetSurfaceSource()
        {
            return new Win32SwapchainSource(_hwnd, _hinstance);
        }
    }

    internal class XlibVkSurfaceInfo : VKSurfaceSource
    {
        private readonly void* _display;
        private readonly void* _window;

        public this(void* display, void* window)
        {
            _display = display;
            _window = window;
        }

        public override VkSurfaceKHR CreateSurface(VkInstance instance)
        {
            return VKSurfaceUtil.CreateSurface(null, instance, GetSurfaceSource());
        }

        protected override SwapchainSource GetSurfaceSource()
        {
            return new XlibSwapchainSource(_display, _window);
        }
    }
}
