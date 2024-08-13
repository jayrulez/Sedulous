using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using Sedulous.GAL.Android;
using System;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;

    internal static class VKSurfaceUtil
    {
        internal static VkSurfaceKHR CreateSurface(VKGraphicsDevice gd, VkInstance instance, SwapchainSource swapchainSource)
        {
            // TODO a null GD is passed from VkSurfaceSource.CreateSurface for compatibility
            //      when VkSurfaceInfo is removed we do not have to handle gd == null anymore
            var doCheck = gd != null;

            if (doCheck && !gd.HasSurfaceExtension(CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME))
                Runtime.GALError(scope $"The required instance extension was not available: {CommonStrings.VK_KHR_SURFACE_EXTENSION_NAME}");

            switch (swapchainSource)
            {
                case _ as XlibSwapchainSource://case XlibSwapchainSource xlibSource:
				var xlibSource = (XlibSwapchainSource)_;
                    if (doCheck && !gd.HasSurfaceExtension(CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME))
                    {
                        Runtime.GALError(scope $"The required instance extension was not available: {CommonStrings.VK_KHR_XLIB_SURFACE_EXTENSION_NAME}");
                    }
                    return CreateXlib(instance, xlibSource);
                case _ as WaylandSwapchainSource://case WaylandSwapchainSource waylandSource:
				var waylandSource = (WaylandSwapchainSource)_;
                    if (doCheck && !gd.HasSurfaceExtension(CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME))
                    {
                        Runtime.GALError(scope $"The required instance extension was not available: {CommonStrings.VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME}");
                    }
                    return CreateWayland(instance, waylandSource);
                case _ as Win32SwapchainSource://case Win32SwapchainSource win32Source:
				var win32Source = (Win32SwapchainSource)_;
                    if (doCheck && !gd.HasSurfaceExtension(CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME))
                    {
                        Runtime.GALError(scope $"The required instance extension was not available: {CommonStrings.VK_KHR_WIN32_SURFACE_EXTENSION_NAME}");
                    }
                    return CreateWin32(instance, win32Source);
                case _ as AndroidSurfaceSwapchainSource:
				var androidSource = (AndroidSurfaceSwapchainSource)_;
                    if (doCheck && !gd.HasSurfaceExtension(CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME))
                    {
                        Runtime.GALError(scope $"The required instance extension was not available: {CommonStrings.VK_KHR_ANDROID_SURFACE_EXTENSION_NAME}");
                    }
                    return CreateAndroidSurface(instance, androidSource);
                case _ as NSWindowSwapchainSource://case NSWindowSwapchainSource nsWindowSource:
				var nsWindowSource = (NSWindowSwapchainSource)_;
                    if (doCheck)
                    {
                        bool hasMetalExtension = gd.HasSurfaceExtension(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME);
                        if (hasMetalExtension || gd.HasSurfaceExtension(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME))
                        {
                            return CreateNSWindowSurface(gd, instance, nsWindowSource, hasMetalExtension);
                        }
                        else
                        {
                            Runtime.GALError(scope $"Neither macOS surface extension was available: {CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME}, {CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME}");
                        }
                    }

                    return CreateNSWindowSurface(gd, instance, nsWindowSource, false);
                case _ as NSViewSwapchainSource://case NSViewSwapchainSource nsViewSource:
				var nsViewSource = (NSViewSwapchainSource)_;
                    if (doCheck)
                    {
                        bool hasMetalExtension = gd.HasSurfaceExtension(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME);
                        if (hasMetalExtension || gd.HasSurfaceExtension(CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME))
                        {
                            return CreateNSViewSurface(gd, instance, nsViewSource, hasMetalExtension);
                        }
                        else
                        {
                            Runtime.GALError(scope $"Neither macOS surface extension was available: {CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME}, {CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME}");
                        }
                    }

                    return CreateNSViewSurface(gd, instance, nsViewSource, false);
                case _ as UIViewSwapchainSource://case UIViewSwapchainSource uiViewSource:
				var uiViewSource = (UIViewSwapchainSource)_;
                    if (doCheck)
                    {
                        bool hasMetalExtension = gd.HasSurfaceExtension(CommonStrings.VK_EXT_METAL_SURFACE_EXTENSION_NAME);
                        if (hasMetalExtension || gd.HasSurfaceExtension(CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME))
                        {
                            return CreateUIViewSurface(gd, instance, uiViewSource, hasMetalExtension);
                        }
                        else
                        {
                            Runtime.GALError(scope $"Neither macOS surface extension was available: {CommonStrings.VK_MVK_MACOS_SURFACE_EXTENSION_NAME}, {CommonStrings.VK_MVK_IOS_SURFACE_EXTENSION_NAME}");
                        }
                    }

                    return CreateUIViewSurface(gd, instance, uiViewSource, false);
                default:
                    Runtime.GALError($"The provided SwapchainSource cannot be used to create a Vulkan surface.");
            }
        }

        private static VkSurfaceKHR CreateWin32(VkInstance instance, Win32SwapchainSource win32Source)
        {
            VkWin32SurfaceCreateInfoKHR surfaceCI = VkWin32SurfaceCreateInfoKHR() {sType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR};
            surfaceCI.hwnd = win32Source.Hwnd;
            surfaceCI.hinstance = win32Source.Hinstance;
			VkSurfaceKHR surface = .Null;
            VkResult result = vkCreateWin32SurfaceKHR(instance, &surfaceCI, null, &surface);
            CheckResult(result);
            return surface;
        }

        private static VkSurfaceKHR CreateXlib(VkInstance instance, XlibSwapchainSource xlibSource)
        {
            VkXlibSurfaceCreateInfoKHR xsci = VkXlibSurfaceCreateInfoKHR(){sType = .VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR};
            xsci.dpy = xlibSource.Display;
            xsci.window = xlibSource.Window;
			VkSurfaceKHR surface = .Null;
            VkResult result = vkCreateXlibSurfaceKHR(instance, &xsci, null, &surface);
            CheckResult(result);
            return surface;
        }

        private static VkSurfaceKHR CreateWayland(VkInstance instance, WaylandSwapchainSource waylandSource)
        {
            VkWaylandSurfaceCreateInfoKHR wsci = VkWaylandSurfaceCreateInfoKHR() {sType = .VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR};
            wsci.display = waylandSource.Display;
            wsci.surface = waylandSource.Surface;
			VkSurfaceKHR surface = .Null;
            VkResult result = vkCreateWaylandSurfaceKHR(instance, &wsci, null, &surface);
            CheckResult(result);
            return surface;
        }

        private static VkSurfaceKHR CreateAndroidSurface(VkInstance instance, AndroidSurfaceSwapchainSource androidSource)
        {
            void* aNativeWindow = AndroidRuntime.ANativeWindow_fromSurface(androidSource.JniEnv, androidSource.Surface);

            VkAndroidSurfaceCreateInfoKHR androidSurfaceCI = VkAndroidSurfaceCreateInfoKHR(){sType = .VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR};
            androidSurfaceCI.window = aNativeWindow;
			VkSurfaceKHR surface = .Null;
            VkResult result = vkCreateAndroidSurfaceKHR(instance, &androidSurfaceCI, null, &surface);
            CheckResult(result);
            return surface;
        }

        private static VkSurfaceKHR CreateNSWindowSurface(VKGraphicsDevice gd, VkInstance instance, NSWindowSwapchainSource nsWindowSource, bool hasExtMetalSurface)
        {
			return .Null;
            /*NSWindow nswindow = new NSWindow(nsWindowSource.NSWindow);
            return CreateNSViewSurface(gd, instance, new NSViewSwapchainSource(nswindow.contentView), hasExtMetalSurface);*/
        }

        private static VkSurfaceKHR CreateNSViewSurface(VKGraphicsDevice gd, VkInstance instance, NSViewSwapchainSource nsViewSource, bool hasExtMetalSurface)
        {
			return .Null;
            /*NSView contentView = new NSView(nsViewSource.NSView);

            if (!CAMetalLayer.TryCast(contentView.layer, var metalLayer))
            {
                metalLayer = CAMetalLayer.New();
                contentView.wantsLayer = true;
                contentView.layer = metalLayer.NativePtr;
            }

            if (hasExtMetalSurface)
            {
                VkMetalSurfaceCreateInfoEXT surfaceCI = VkMetalSurfaceCreateInfoEXT() {sType = .VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT};
                surfaceCI.pLayer = metalLayer.NativePtr.ToPointer();
                VkSurfaceKHR surface = .Null;
                VkResult result = gd.CreateMetalSurfaceEXT(instance, &surfaceCI, null, &surface);
                CheckResult(result);
                return surface;
            }
            else
            {
                VkMacOSSurfaceCreateInfoMVK surfaceCI = VkMacOSSurfaceCreateInfoMVK() {sType = .VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK};
                surfaceCI.pView = contentView.NativePtr.ToPointer();
				VkSurfaceKHR surface = .Null;
                VkResult result = vkCreateMacOSSurfaceMVK(instance, &surfaceCI, null, &surface);
                CheckResult(result);
                return surface;
            }*/
        }

        private static VkSurfaceKHR CreateUIViewSurface(VKGraphicsDevice gd, VkInstance instance, UIViewSwapchainSource uiViewSource, bool hasExtMetalSurface)
        {
			return .Null;
            /*UIView uiView = new UIView(uiViewSource.UIView);

            if (!CAMetalLayer.TryCast(uiView.layer, var metalLayer))
            {
                metalLayer = CAMetalLayer.New();
                metalLayer.frame = uiView.frame;
                metalLayer.opaque = true;
                uiView.layer.addSublayer(metalLayer.NativePtr);
            }

            if (hasExtMetalSurface)
            {
                VkMetalSurfaceCreateInfoEXT surfaceCI = VkMetalSurfaceCreateInfoEXT() {sType = .VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT};
                surfaceCI.pLayer = metalLayer.NativePtr.ToPointer();
                VkSurfaceKHR surface = .Null;
                VkResult result = gd.CreateMetalSurfaceEXT(instance, &surfaceCI, null, &surface);
                CheckResult(result);
                return surface;
            }
            else
            {
                VkIOSSurfaceCreateInfoMVK surfaceCI = VkIOSSurfaceCreateInfoMVK(){sType = .VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK};
                surfaceCI.pView = uiView.NativePtr.ToPointer();
				VkSurfaceKHR surface = .Null;
                VkResult result = vkCreateIOSSurfaceMVK(instance, &surfaceCI, null, &surface);
				CheckResult(result);
                return surface;
            }*/
        }
    }
}
