using System;
using Vulkan;
using Vulkan.Xlib;
using static Sedulous.GAL.VK.VulkanUtil;
using static Vulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
    /// <summary>
    /// An object which can be used to create a VkSurfaceKHR.
    /// </summary>
    public abstract class VKSurfaceSource
    {
        internal VKSurfaceSource() { }

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
        public static VKSurfaceSource CreateWin32(IntPtr hinstance, IntPtr hwnd) => new Win32VkSurfaceInfo(hinstance, hwnd);
        /// <summary>
        /// Creates a new VkSurfaceSource from the given Xlib information.
        /// </summary>
        /// <param name="display">A pointer to the Xlib Display.</param>
        /// <param name="window">An Xlib window.</param>
        /// <returns>A new VkSurfaceSource.</returns>
        public static VKSurfaceSource CreateXlib(Display* display, Window window) => new XlibVkSurfaceInfo(display, window);

        internal abstract SwapchainSource GetSurfaceSource();
    }

    internal class Win32VkSurfaceInfo : VKSurfaceSource
    {
        private readonly IntPtr _hinstance;
        private readonly IntPtr _hwnd;

        public Win32VkSurfaceInfo(IntPtr hinstance, IntPtr hwnd)
        {
            _hinstance = hinstance;
            _hwnd = hwnd;
        }

        public override VkSurfaceKHR CreateSurface(VkInstance instance)
        {
            return VKSurfaceUtil.CreateSurface(null, instance, GetSurfaceSource());
        }

        internal override SwapchainSource GetSurfaceSource()
        {
            return new Win32SwapchainSource(_hwnd, _hinstance);
        }
    }

    internal class XlibVkSurfaceInfo : VKSurfaceSource
    {
        private readonly Display* _display;
        private readonly Window _window;

        public XlibVkSurfaceInfo(Display* display, Window window)
        {
            _display = display;
            _window = window;
        }

        public override VkSurfaceKHR CreateSurface(VkInstance instance)
        {
            return VKSurfaceUtil.CreateSurface(null, instance, GetSurfaceSource());
        }

        internal override SwapchainSource GetSurfaceSource()
        {
            return new XlibSwapchainSource((IntPtr)_display, _window.Value);
        }
    }
}
