using System;

namespace Sedulous.GAL
{
	using internal Sedulous.GAL;

    /// <summary>
    /// A platform-specific object representing a renderable surface.
    /// A SwapchainSource can be created with one of several static factory methods.
    /// A SwapchainSource is used to describe a Swapchain (see <see cref="SwapchainDescription"/>).
    /// </summary>
    public abstract class SwapchainSource
    {
        internal this() { }

        /// <summary>
        /// Creates a new SwapchainSource for a Win32 window.
        /// </summary>
        /// <param name="hwnd">The Win32 window handle.</param>
        /// <param name="hinstance">The Win32 instance handle.</param>
        /// <returns>A new SwapchainSource which can be used to create a <see cref="Swapchain"/> for the given Win32 window.
        /// </returns>
        public static SwapchainSource CreateWin32(void* hwnd, void* hinstance) => new Win32SwapchainSource(hwnd, hinstance);

        /// <summary>
        /// Creates a new SwapchainSource for a UWP SwapChain panel.
        /// </summary>
        /// <param name="swapChainPanel">A COM object which must implement the <see cref="Vortice.DXGI.ISwapChainPanelNative"/>
        /// or <see cref="Vortice.DXGI.ISwapChainBackgroundPanelNative"/> interface. Generally, this should be a SwapChainPanel
        /// or SwapChainBackgroundPanel contained in your application window.</param>
        /// <param name="logicalDpi">The logical DPI of the swapchain panel.</param>
        /// <returns>A new SwapchainSource which can be used to create a <see cref="Swapchain"/> for the given UWP panel.
        /// </returns>
        public static SwapchainSource CreateUwp(Object swapChainPanel, float logicalDpi)
            => new UwpSwapchainSource(swapChainPanel, logicalDpi);

        /// <summary>
        /// Creates a new SwapchainSource from the given Xlib information.
        /// </summary>
        /// <param name="display">An Xlib Display.</param>
        /// <param name="window">An Xlib Window.</param>
        /// <returns>A new SwapchainSource which can be used to create a <see cref="Swapchain"/> for the given Xlib window.
        /// </returns>
        public static SwapchainSource CreateXlib(void* display, void* window) => new XlibSwapchainSource(display, window);

        /// <summary>
        /// Creates a new SwapchainSource from the given Wayland information.
        /// </summary>
        /// <param name="display">The Wayland display proxy.</param>
        /// <param name="surface">The Wayland surface proxy to map.</param>
        /// <returns>A new SwapchainSource which can be used to create a <see cref="Swapchain"/> for the given Wayland surface.
        /// </returns>
        public static SwapchainSource CreateWayland(void* display, void* surface) => new WaylandSwapchainSource(display, surface);


        /// <summary>
        /// Creates a new SwapchainSource for the given NSWindow.
        /// </summary>
        /// <param name="nsWindow">A pointer to an NSWindow.</param>
        /// <returns>A new SwapchainSource which can be used to create a Metal <see cref="Swapchain"/> for the given NSWindow.
        /// </returns>
        public static SwapchainSource CreateNSWindow(void* nsWindow) => new NSWindowSwapchainSource(nsWindow);

        /// <summary>
        /// Creates a new SwapchainSource for the given UIView.
        /// </summary>
        /// <param name="uiView">The UIView's native handle.</param>
        /// <returns>A new SwapchainSource which can be used to create a Metal <see cref="Swapchain"/> or an OpenGLES
        /// <see cref="GraphicsDevice"/> for the given UIView.
        /// </returns>
        public static SwapchainSource CreateUIView(void* uiView) => new UIViewSwapchainSource(uiView);

        /// <summary>
        /// Creates a new SwapchainSource for the given Android Surface.
        /// </summary>
        /// <param name="surfaceHandle">The handle of the Android Surface.</param>
        /// <param name="jniEnv">The Java Native Interface Environment handle.</param>
        /// <returns>A new SwapchainSource which can be used to create a Vulkan <see cref="Swapchain"/> or an OpenGLES
        /// <see cref="GraphicsDevice"/> for the given Android Surface.</returns>
        public static SwapchainSource CreateAndroidSurface(void* surfaceHandle, void* jniEnv)
            => new AndroidSurfaceSwapchainSource(surfaceHandle, jniEnv);

        /// <summary>
        /// Creates a new SwapchainSource for the given NSView.
        /// </summary>
        /// <param name="nsView">A pointer to an NSView.</param>
        /// <returns>A new SwapchainSource which can be used to create a Metal <see cref="Swapchain"/> for the given NSView.
        /// </returns>
        public static SwapchainSource CreateNSView(void* nsView)
            => new NSViewSwapchainSource(nsView);
    }

    internal class Win32SwapchainSource : SwapchainSource
    {
        public void* Hwnd { get; }
        public void* Hinstance { get; }

        public this(void* hwnd, void* hinstance)
        {
            Hwnd = hwnd;
            Hinstance = hinstance;
        }
    }

    internal class UwpSwapchainSource : SwapchainSource
    {
        public Object SwapChainPanelNative { get; }
        public float LogicalDpi { get; }

        public this(Object swapChainPanelNative, float logicalDpi)
        {
            SwapChainPanelNative = swapChainPanelNative;
            LogicalDpi = logicalDpi;
        }
    }

    internal class XlibSwapchainSource : SwapchainSource
    {
        public void* Display { get; }
        public void* Window { get; }

        public this(void* display, void* window)
        {
            Display = display;
            Window = window;
        }
    }

    internal class WaylandSwapchainSource : SwapchainSource
    {
        public void* Display { get; }
        public void* Surface { get; }

        public this(void* display, void* surface)
        {
            Display = display;
            Surface = surface;
        }
    }

    internal class NSWindowSwapchainSource : SwapchainSource
    {
        public void* NSWindow { get; }

        public this(void* nsWindow)
        {
            NSWindow = nsWindow;
        }
    }

    internal class UIViewSwapchainSource : SwapchainSource
    {
        public void* UIView { get; }

        public this(void* uiView)
        {
            UIView = uiView;
        }
    }

    internal class AndroidSurfaceSwapchainSource : SwapchainSource
    {
        public void* Surface { get; }
        public void* JniEnv { get; }

        public this(void* surfaceHandle, void* jniEnv)
        {
            Surface = surfaceHandle;
            JniEnv = jniEnv;
        }
    }

    internal class NSViewSwapchainSource : SwapchainSource
    {
        public void* NSView { get; }

        public this(void* nsView)
        {
            NSView = nsView;
        }
    }
}
