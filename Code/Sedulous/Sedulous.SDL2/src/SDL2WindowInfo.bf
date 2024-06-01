using System;
using System.Collections;
using Sedulous.Platform;
using Sedulous.Foundation;
using Sedulous.Foundation.Utilities;
using SDL2Native;
using static SDL2Native.SDL2Native;
using internal Sedulous.Foundation;
using internal Sedulous.SDL2;

namespace Sedulous.SDL2
{
    /// <summary>
    /// Represents the SDL2 implementation of the <see cref="IWindowInfo"/> interface.
    /// </summary>
    public class SDL2WindowInfo : IWindowInfo
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SDL2WindowInfo"/> class.
        /// </summary>
        /// <param name="backend">The backend.</param>
        internal this(SDL2PlatformBackend backend)
        {
            Contract.Require(backend, nameof(backend));

            mBackend = backend;
        }
        
        /// <summary>
        /// Updates the state of the application's displays.
        /// </summary>
        /// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
        public void Update(Time time)
        {
            for (var window in windows)
                ((SDL2Window)window).Update(time);
        }
        
        /// <summary>
        /// Gets the window with the specified identifier.
        /// </summary>
        /// <returns>The window with the specified identifier, or null if no such window exists.</returns>
        public IWindow GetByID(int32 id)
        {
            var match = default(SDL2Window);
            for (SDL2Window window in windows)
            {
                if (SDL_GetWindowID((SDL_Window*)window) == (uint32)id)
                {
                    match = window;
                    break;
                }
            }
            return match;
        }

        /// <summary>
        /// Gets a pointer to the SDL2 window object encapsulated by the window with the specified identifier.
        /// </summary>
        /// <returns>A pointer to the SDL2 window object encapsulated by the window with the specified identifier.</returns>
        public SDL_Window* GetPtrByID(int32 id)
        {
            var window = GetByID(id);
            if (window != null)
            {
                return (SDL_Window*)(SDL2Window)window;
            }
            return null;
        }

        /// <summary>
        /// Gets the context's primary window.
        /// </summary>
        /// <returns>The context's primary window, or null if the context is headless.</returns>
        public IWindow GetPrimary()
        {
            return Primary;
        }

        /// <summary>
        /// Gets a pointer to the SDL2 window object encapsulated by the primary window.
        /// </summary>
        /// <returns>A pointer to the SDL2 window object encapsulated by the primary window.</returns>
        public SDL_Window* GetPrimaryPointer()
        {
            return (SDL_Window*)(SDL2Window)Primary;
        }

        /// <summary>
        /// Gets the context's current window.
        /// </summary>
        /// <returns>The context's current window.</returns>
        public IWindow GetCurrent()
        {
            return Current;
        }

        /// <summary>
        /// Gets a pointer to the SDL2 window object encapsulated by the current window.
        /// </summary>
        /// <returns>A pointer to the SDL2 window object encapsulated by the current window.</returns>
        public SDL_Window* GetCurrentPointer()
        {
            return (SDL_Window*)(SDL2Window)Current;
        }

        /// <summary>
        /// Creates a new window and attaches it to the current context.
        /// </summary>
        /// <param name="caption">The window's caption text.</param>
        /// <param name="x">The x-coordinate at which to position the window's top-left corner.</param>
        /// <param name="y">The y-coordinate at which to position the window's top-left corner.</param>
        /// <param name="width">The width of the window's client area in pixels.</param>
        /// <param name="height">The height of the window's client area in pixels.</param>
        /// <param name="flags">A set of WindowFlags values indicating how to create the window.</param>
        /// <returns>The window that was created.</returns>
        public IWindow Create(StringView caption, int32 x, int32 y, int32 width, int32 height, WindowFlags flags = WindowFlags.None)
        {
            SDL_WindowFlags sdlflags = 0;

            if (mBackend.SupportsHighDensityDisplayModes)
                sdlflags |= .SDL_WINDOW_ALLOW_HIGHDPI;

            if ((flags & WindowFlags.Hidden) == WindowFlags.Hidden || (flags & WindowFlags.ShownImmediately) != WindowFlags.ShownImmediately)
                sdlflags |= .SDL_WINDOW_HIDDEN;

            if ((flags & WindowFlags.Resizable) == WindowFlags.Resizable)
                sdlflags |= .SDL_WINDOW_RESIZABLE;

            if ((flags & WindowFlags.Borderless) == WindowFlags.Borderless)
                sdlflags |= .SDL_WINDOW_BORDERLESS;

            var sdlptr = SDL_CreateWindow(caption.IsEmpty ? String.Empty : caption.Ptr,
                x < 0 ? (int32)SDL_WINDOWPOS_CENTERED_MASK : x,
                y < 0 ? (int32)SDL_WINDOWPOS_CENTERED_MASK : y,
                width, height, sdlflags);
            
            if (sdlptr == null)
                Runtime.SDL2Error();

            var visible = (flags & WindowFlags.Hidden) != WindowFlags.Hidden;
            var win = new SDL2Window(mBackend, sdlptr, visible);
            windows.Add(win);

			if(Primary == null)
			{
				Primary = win;
			}

            OnWindowCreated(win);

            return win;
        }

        /// <summary>
        /// Creates a new window from the specified native window and attaches it to the current context.
        /// </summary>
        /// <param name="ptr">A pointer that represents the native window to attach to the context.</param>
        /// <returns>The window that was created.</returns>
        public IWindow CreateFromNativePointer(SDL_Window* ptr)
        {
            var sdlptr = SDL_CreateWindowFrom(ptr);
            if (sdlptr == null)
                Runtime.SDL2Error();

            var win = new SDL2Window(mBackend, sdlptr, true);
            windows.Add(win);

            OnWindowCreated(win);

            return win;
        }

        /// <summary>
        /// Destroys the specified window.
        /// </summary>
        /// <remarks>Windows which were created from native pointers are disassociated from the current context,
        /// but are not actually destroyed.  To destroy such windows, use the native framework which created them.</remarks>
        /// <param name="window">The window to destroy.</param>
        /// <returns>true if the window was destroyed; false if the window was closed.</returns>
        public bool Destroy(IWindow window)
        {
            Contract.Require(window, nameof(window));

            if (!windows.Remove(window))
            	Runtime.InvalidOperationError("InvalidResource");

            if (window == Current)
                Runtime.InvalidOperationError();

            OnWindowDestroyed(window);

            var sdlwin = (SDL2Window)window;

            var native = sdlwin.Native;
            delete sdlwin;

            return !native;
        }

        /// <summary>
        /// Destroys the window with the specified identifier.
        /// </summary>
        /// <param name="windowID">The identifier of the window to destroy.</param>
        /// <returns>true if the window was destroyed; false if the window was closed.</returns>
        public bool DestroyByID(int32 windowID)
        {
            var window = GetByID(windowID);
            if (window != null)
            {
                Destroy(window);
            }
            return windows.Count == 0;
        }

        /// <summary>
        /// Gets the collection's enumerator.
        /// </summary>
        /// <returns>The collection's enumerator.</returns>
        public List<IWindow>.Enumerator GetEnumerator()
        {
            return windows.GetEnumerator();
        }


        /// <summary>
        /// Occurs after a window has been created.
        /// </summary>
        public readonly EventAccessor<WindowInfoEventHandler> WindowCreated {get;} = new .() ~ delete _;

        /// <summary>
        /// Occurs when a window is about to be destroyed.
        /// </summary>
        public readonly EventAccessor<WindowInfoEventHandler> WindowDestroyed{get;} = new .() ~ delete _;

        /// <summary>
        /// Raises the WindowCreated event.
        /// </summary>
        /// <param name="window">The window that was created.</param>
        protected virtual void OnWindowCreated(IWindow window) =>
            WindowCreated?.Invoke(window);

        /// <summary>
        /// Raises the WindowDestroyed event.
        /// </summary>
        /// <param name="window">The window that is being destroyed.</param>
        protected virtual void OnWindowDestroyed(IWindow window) =>
            WindowDestroyed?.Invoke(window);

        /// <summary>
        /// Gets the window manager's list of windows.
        /// </summary>
        protected List<IWindow> Windows { get { return windows; } }

        /// <summary>
        /// Gets or sets the primary window.
        /// </summary>
        protected IWindow Primary { get; set; }

        /// <summary>
        /// Gets or sets the current window.
        /// </summary>
        protected IWindow Current { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether vertical sync is enabled.
        /// </summary>
        protected bool VSync { get; set; }

        // The context's attached windows.
        private readonly List<IWindow> windows = new List<IWindow>() ~ delete _;

		private readonly SDL2PlatformBackend mBackend;
    }
}
