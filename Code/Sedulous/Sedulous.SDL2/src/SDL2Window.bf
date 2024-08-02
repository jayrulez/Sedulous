using System;
using Sedulous.Platform;
using Sedulous.Foundation.Utilities;
using SDL2Native;
using Sedulous.Foundation.Mathematics;
using Sedulous.Foundation;

using internal Sedulous.SDL2;
using internal Sedulous.Foundation;
using static SDL2Native.SDL2Native;

namespace Sedulous.SDL2
{
	/// <summary>
	/// Represents the SDL2 implementation of the <see cref="IWindow"/> interface.
	/// </summary>
	public sealed class SDL2Window : IWindow
	{
		private readonly SDL2PlatformBackend mBackend;

		public ref SurfaceInfo SurfaceInfo { get; private set; }

		/// <summary>
		/// Initializes a new instance of the <see cref="SDL2Window"/> class.
		/// </summary>
		/// <param name="backend">The backend.</param>
		/// <param name="ptr">The SDL2 pointer that represents the window.</param>
		/// <param name="visible">A value indicating whether this window should be visible by default.</param>
		/// <param name="native">A value indicating whether the window was created from a native pointer.</param>
		internal this(SDL2PlatformBackend backend, SDL_Window* ptr, bool visible, bool native = false)
		{
			mBackend = backend;

			this.ptr = ptr;
			this.ID = (int32)SDL_GetWindowID(ptr);
			this.Native = native;

			SDL_SysWMinfo info = .();
			SDL_GetVersion(&info.version);
			SDL_GetWindowWMInfo(ptr, &info);
			SDL_SysWM_Type subsystem = info.subsystem;
			switch (subsystem) {
			case .SDL_SYSWM_WINDOWS:
				SurfaceInfo = .()
					{
						Type = .Win32,
						Win32 = .()
							{
								Hwnd = (void*)(int)info.info.win.window
							}
					};
				break;

			// todo: support these platforms
			case .SDL_SYSWM_X11,
				.SDL_SYSWM_COCOA,
				.SDL_SYSWM_UIKIT,
				.SDL_SYSWM_WAYLAND,
				.SDL_SYSWM_WINRT,
				.SDL_SYSWM_ANDROID,
				.SDL_SYSWM_UNKNOWN: fallthrough;
			default:
				Runtime.FatalError("Subsystem not currently supported.");
			}

			UpdateWindowedPosition(Position);
			UpdateWindowedClientSize(ClientSize);

			var flags = SDL_GetWindowFlags(ptr);

			if ((flags & .SDL_WINDOW_OPENGL) == .SDL_WINDOW_OPENGL)
				this.windowStatus |= WindowStatusFlags.OpenGL;

			if ((flags & .SDL_WINDOW_VULKAN) == .SDL_WINDOW_VULKAN)
				this.windowStatus |= WindowStatusFlags.Vulkan;

			if ((flags & .SDL_WINDOW_INPUT_FOCUS) == .SDL_WINDOW_INPUT_FOCUS)
				this.windowStatus |= WindowStatusFlags.Focused;

			if ((flags & .SDL_WINDOW_MINIMIZED) == .SDL_WINDOW_MINIMIZED)
				this.windowStatus |= WindowStatusFlags.Minimized;

			if ((flags & .SDL_WINDOW_HIDDEN) == .SDL_WINDOW_HIDDEN && visible)
				this.windowStatus |= WindowStatusFlags.Unshown;

			this.WindowScale = Display?.DensityScale ?? 1f;
		}

		public ~this()
		{
			SDL_DestroyWindow(ptr);
		}

		/// <summary>
		/// Explicitly converts a window to its underlying SDL2 pointer.
		/// </summary>
		/// <param name="window">The window to convert.</param>
		/// <returns>The window's underlying SDL2 pointer.</returns>
		public static explicit operator SDL_Window*(SDL2Window window)
		{
			return (window == null) ? null : window.ptr;
		}

		/// <inheritdoc/>
		internal bool HandleEvent(SDL_Event evt)
		{
			if (evt.type != .SDL_WINDOWEVENT || evt.window.windowID != (uint32)ID)
				return false;

			switch (evt.window.event)
			{
			case .SDL_WINDOWEVENT_SHOWN:
				OnShown();
				return true;

			case .SDL_WINDOWEVENT_HIDDEN:
				OnHidden();
				return true;

			case .SDL_WINDOWEVENT_MINIMIZED:
				this.windowStatus |= WindowStatusFlags.Minimized;
				OnMinimized();
				return true;

			case .SDL_WINDOWEVENT_MAXIMIZED:
				this.windowStatus &= ~WindowStatusFlags.Minimized;
				OnMaximized();
				return true;

			case .SDL_WINDOWEVENT_RESTORED:
				this.windowStatus &= ~WindowStatusFlags.Minimized;
				OnRestored();
				return true;

			case .SDL_WINDOWEVENT_MOVED:
				UpdateWindowedPosition(Point2(evt.window.data1, evt.window.data2));
				return true;

			case .SDL_WINDOWEVENT_SIZE_CHANGED:
				UpdateWindowedClientSize(Size2(evt.window.data1, evt.window.data2));
				OnSizeChanged();
				return true;

			case .SDL_WINDOWEVENT_FOCUS_GAINED:
				this.windowStatus |= WindowStatusFlags.Focused;
				return true;

			case .SDL_WINDOWEVENT_FOCUS_LOST:
				this.windowStatus &= ~WindowStatusFlags.Focused;
				return true;

			default: return false;
			}
		}

		/// <inheritdoc/>
		public void WarpMouseWithinWindow(int32 x, int32 y)
		{
			SDL_WarpMouseInWindow(ptr, x, y);
		}

		/// <inheritdoc/>
		public void SetFullscreenDisplayMode(DisplayMode displayMode)
		{
			SetFullscreenDisplayModeInternal(displayMode);
		}

		/// <inheritdoc/>
		public void SetFullscreenDisplayMode(int32 width, int32 height, int32 bpp, int32 refresh, int32? displayIndex = null)
		{
			Contract.EnsureRange(width > 0, nameof(width));
			Contract.EnsureRange(height > 0, nameof(height));
			Contract.EnsureRange(bpp > 0, nameof(bpp));
			Contract.EnsureRange(refresh > 0, nameof(refresh));

			if (displayIndex.HasValue)
			{
				var displayIndexValue = displayIndex.Value;
				if (displayIndexValue < 0 || displayIndexValue >= mBackend.Displays.Count)
					Runtime.ArgumentOutOfRangeError(nameof(displayIndex));
			}

			SetFullscreenDisplayModeInternal(DisplayMode(width, height, bpp, refresh, displayIndex));
		}

		/// <inheritdoc/>
		public DisplayMode? GetFullscreenDisplayMode()
		{
			return displayMode;
		}

		/// <inheritdoc/>
		public void SetWindowBounds(Rectangle bounds, float scale = 1f)
		{
			Contract.EnsureRange(scale >= 1f, nameof(scale));

			this.WindowedPosition = bounds.Location;
			this.WindowedClientSize = bounds.Size;
			this.WindowScale = scale;
		}

		/// <inheritdoc/>
		public void SetWindowedClientSize(Size2 size, float scale = 1f)
		{
			Contract.EnsureRange(scale >= 1f, nameof(scale));

			this.WindowedClientSize = size;
			this.WindowScale = scale;
		}

		/// <inheritdoc/>
		public void SetWindowedClientSizeCentered(Size2 size, float scale = 1f)
		{
			Contract.EnsureRange(scale >= 1f, nameof(scale));

			this.WindowedClientSize = size;
			this.WindowScale = scale;
			this.WindowedPosition = Point2((int32)SDL_WINDOWPOS_CENTERED_MASK, (int32)SDL_WINDOWPOS_CENTERED_MASK);
		}

		/// <inheritdoc/>
		public void SetWindowMode(WindowMode mode)
		{
			if (windowMode == mode)
				return;

			UpdateWindowedPosition(Position);
			UpdateWindowedClientSize(ClientSize);

			switch (mode)
			{
			case WindowMode.Windowed:
				{
					if (SDL_SetWindowFullscreen(ptr, 0) < 0)
						Runtime.SDL2Error();

					var x = windowedPosition?.X ?? IPlatformBackend.WindowConfiguration.DefaultWindowPositionX;
					var y = windowedPosition?.Y ?? IPlatformBackend.WindowConfiguration.DefaultWindowPositionY;
					var w = windowedClientSize?.Width ?? IPlatformBackend.WindowConfiguration.DefaultWindowClientWidth;
					var h = windowedClientSize?.Height ?? IPlatformBackend.WindowConfiguration.DefaultWindowClientHeight;

					SDL_SetWindowSize(ptr, w, h);
					SDL_SetWindowPosition(ptr, x, y);
				}
				break;

			case WindowMode.Fullscreen:
				{
					if (displayMode != null)
					{
						if (displayMode.Value.DisplayIndex.HasValue)
						{
							var display = mBackend.Displays[displayMode.Value.DisplayIndex.Value];
							ChangeDisplay(display);
						}
					}
					else
					{
						SetDesktopDisplayMode();
					}

					if (SDL_SetWindowFullscreen(ptr, (uint32)SDL_WindowFlags.SDL_WINDOW_FULLSCREEN) < 0)
						Runtime.SDL2Error();
				}
				break;

			case WindowMode.FullscreenWindowed:
				{
					if (SDL_SetWindowFullscreen(ptr, 0) < 0)
						Runtime.SDL2Error();

					var displayBounds = Display.Bounds;

					SDL_SetWindowSize(ptr, displayBounds.Width, displayBounds.Height);
					SDL_SetWindowPosition(ptr, displayBounds.X, displayBounds.Y);
				}
				break;

			default:
				Runtime.NotSupportedError(nameof(mode));
			}

			windowMode = mode;
			UpdateMouseGrab();
		}

		/// <inheritdoc/>
		public WindowMode GetWindowMode()
		{
			return windowMode;
		}

		/// <inheritdoc/>
		public void SetWindowState(WindowState state)
		{
			switch (state)
			{
			case WindowState.Normal:
				SDL_RestoreWindow(ptr);
				break;

			case WindowState.Minimized:
				SDL_MinimizeWindow(ptr);
				break;

			case WindowState.Maximized:
				SDL_MaximizeWindow(ptr);
				break;

			default:
				Runtime.NotSupportedError("state");
			}
		}

		/// <inheritdoc/>
		public WindowState GetWindowState()
		{
			var flags = SDL_GetWindowFlags(ptr);

			if ((flags & .SDL_WINDOW_MAXIMIZED) == .SDL_WINDOW_MAXIMIZED)
				return WindowState.Maximized;

			if ((flags & .SDL_WINDOW_MINIMIZED) == .SDL_WINDOW_MINIMIZED)
				return WindowState.Minimized;

			return WindowState.Normal;
		}

		/// <inheritdoc/>
		public void ChangeDisplay(int32 displayIndex)
		{
			var displayIndex;
			if (displayIndex < 0 || displayIndex >= mBackend.Displays.Count)
				displayIndex = 0;

			var display = mBackend.Displays[displayIndex];
			ChangeDisplay(display);
		}

		/// <inheritdoc/>
		public void ChangeDisplay(IDisplay display)
		{
			Contract.Require(display, nameof(display));

			if (Display == display)
				return;

			var x = display.Bounds.Center.X - (ClientSize.Width / 2);
			var y = display.Bounds.Center.Y - (ClientSize.Height / 2);

			Position = Point2(x, y);
		}

		/// <summary>
		/// Updates the window's state.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to <see cref="Context.Update(Time)"/>.</param>
		public void Update(Time time)
		{
			if (Display.DensityScale != WindowScale)
				HandleDpiChanged();
		}

		/// <summary>
		/// Draws the window.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to Draw.</param>
		public void Draw(Time time)
		{
			OnDrawing(time);
			OnDrawingUI(time);
		}

		/// <inheritdoc/>
		public int32 ID { get; }

		private readonly String mCaption = new .() ~ delete _;

		/// <inheritdoc/>
		public String Caption
		{
			get
			{
				mCaption.Set(scope .(SDL_GetWindowTitle(ptr)));
				return mCaption;
			}
			set
			{
				mCaption.Set(value ?? String.Empty);
				SDL_SetWindowTitle(ptr, mCaption);
			}
		}

		/// <inheritdoc/>
		public float WindowScale { get; private set; }

		/// <inheritdoc/>
		public Point2 Position
		{
			get
			{
				SDL_GetWindowPosition(ptr, var x, var y);
				return Point2(x, y);
			}
			set
			{
				if (GetWindowMode() == WindowMode.Windowed && GetWindowState() == WindowState.Normal)
					windowedPosition = value;

				SDL_SetWindowPosition(ptr, value.X, value.Y);
			}
		}

		/// <inheritdoc/>
		public Point2 WindowedPosition
		{
			get => windowedPosition.GetValueOrDefault();
			set
			{
				windowedPosition = value;
				if (GetWindowMode() == WindowMode.Windowed && GetWindowState() == WindowState.Normal)
				{
					SDL_SetWindowPosition(ptr, value.X, value.Y);
				}
			}
		}

		/// <inheritdoc/>
		public Size2 DrawableSize
		{
			get
			{
				int32 w, h;

				var isOpenGLWindow = (this.windowStatus & WindowStatusFlags.OpenGL) == WindowStatusFlags.OpenGL;
				if (isOpenGLWindow)
				{
					SDL_GL_GetDrawableSize(ptr, out w, out h);
				}
				else
				{
					SDL_GetWindowSize(ptr, out w, out h);
				}

				return Size2(w, h);
			}
		}

		/// <inheritdoc/>
		public Size2 ClientSize
		{
			get
			{
				SDL_GetWindowSize(ptr, var w, var h);
				return Size2(w, h);
			}
			set
			{
				if (GetWindowMode() == WindowMode.Windowed && GetWindowState() == WindowState.Normal)
				{
					windowedClientSize = value;
				}

				SDL_SetWindowSize(ptr, value.Width, value.Height);
			}
		}

		/// <inheritdoc/>
		public Size2 WindowedClientSize
		{
			get => windowedClientSize.GetValueOrDefault();
			set
			{
				windowedClientSize = value;
				if (GetWindowMode() == WindowMode.Windowed && GetWindowState() == WindowState.Normal)
				{
					SDL_SetWindowSize(ptr, value.Width, value.Height);
				}
			}
		}

		/// <inheritdoc/>
		public Size2 MinimumClientSize
		{
			get
			{
				SDL_GetWindowMinimumSize(ptr, var w, var h);
				return Size2(w, h);
			}
			set
			{
				SDL_SetWindowMinimumSize(ptr, value.Width, value.Height);
			}
		}

		/// <inheritdoc/>
		public Size2 MaximumClientSize
		{
			get
			{
				SDL_GetWindowMaximumSize(ptr, var w, var h);
				return Size2(w, h);
			}
			set
			{
				SDL_SetWindowMaximumSize(ptr, value.Width, value.Height);
			}
		}

		/// <inheritdoc/>
		public bool SynchronizeWithVerticalRetrace { get; set; } = true;

		/// <inheritdoc/>
		public bool Active =>
			(windowStatus & WindowStatusFlags.Focused) == WindowStatusFlags.Focused &&
			(windowStatus & WindowStatusFlags.Minimized) != WindowStatusFlags.Minimized;

		/// <inheritdoc/>
		public bool Visible
		{
			get
			{
				var flags = SDL_GetWindowFlags(ptr);
				return (flags & .SDL_WINDOW_SHOWN) == .SDL_WINDOW_SHOWN;
			}
			set
			{
				if (value)
				{
					SDL_ShowWindow(ptr);
				}
				else
				{
					SDL_HideWindow(ptr);
				}
			}
		}

		/// <inheritdoc/>
		public bool Resizable
		{
			get
			{
				var flags = SDL_GetWindowFlags(ptr);
				return (flags & .SDL_WINDOW_RESIZABLE) == .SDL_WINDOW_RESIZABLE;
			}
		}

		/// <inheritdoc/>
		public bool Borderless
		{
			get
			{
				var flags = SDL_GetWindowFlags(ptr);
				return (flags & .SDL_WINDOW_BORDERLESS) == .SDL_WINDOW_BORDERLESS;
			}
		}

		/// <inheritdoc/>
		public bool Native { get; }

		/// <inheritdoc/>
		public bool GrabsMouseWhenWindowed
		{
			get => grabsMouseWhenWindowed;
			set
			{
				grabsMouseWhenWindowed = value;
				UpdateMouseGrab();
			}
		}

		/// <inheritdoc/>
		public bool GrabsMouseWhenFullscreenWindowed
		{
			get => grabsMouseWhenFullscreenWindowed;
			set
			{
				grabsMouseWhenFullscreenWindowed = value;
				UpdateMouseGrab();
			}
		}

		/// <inheritdoc/>
		public bool GrabsMouseWhenFullscreen
		{
			get => grabsMouseWhenFullscreen;
			set
			{
				grabsMouseWhenFullscreen = value;
				UpdateMouseGrab();
			}
		}

		/// <inheritdoc/>
		public float Opacity
		{
			get
			{
				float opacity = 0;
				SDL_GetWindowOpacity(ptr, &opacity);
				return opacity;
			}
			set
			{
				var value;
				value = MathUtil.Clamp(value, 0.0f, 1.0f);
				SDL_SetWindowOpacity(ptr, value);
			}
		}

		/// <inheritdoc/>
		/*public Surface2D Icon
		{
			get => icon;
			set
			{
				SetIcon(value ?? DefaultWindowIcon);
				icon = value;
			}
		}*/

		/// <inheritdoc/>
		//public Compositor Compositor { get; private set; }

		/// <inheritdoc/>
		public IDisplay Display
		{
			get
			{
				var index = SDL_GetWindowDisplayIndex(ptr);
				var platform = mBackend;
				if (platform != null)
					return mBackend.Displays[index];

				return null;
			}
		}

		/// <summary>
		/// Occurs when the window is shown.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> Shown { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is hidden.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> Hidden { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is minimized.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> Minimized { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is maximized.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> Maximized { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is restored.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> Restored { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window size is changed.
		/// </summary>
		public readonly EventAccessor<WindowEventHandler> SizeChanged { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is rendered.
		/// </summary>
		public readonly EventAccessor<WindowDrawingEventHandler> Drawing { get; } = new .() ~ delete _;

		/// <summary>
		/// Occurs when the window is drawing its UI layer.
		/// </summary>
		public readonly EventAccessor<WindowDrawingEventHandler> DrawingUI { get; } = new .() ~ delete _;

		/// <summary>
		/// Gets or sets a value indicating whether this is the current window.
		/// </summary>
		internal bool IsCurrentWindow
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a value indicating whether the window is bound for rendering.
		/// </summary>
		internal bool IsBoundForRendering
		{
			get => (windowStatus & WindowStatusFlags.BoundForRendering) == WindowStatusFlags.BoundForRendering;
			set
			{
				if (value)
				{
					windowStatus |= WindowStatusFlags.BoundForRendering;
					if ((windowStatus & WindowStatusFlags.Unshown) == WindowStatusFlags.Unshown)
					{
						windowStatus &= ~WindowStatusFlags.Unshown;
						SDL_ShowWindow(ptr);
					}
				}
				else
				{
					windowStatus &= ~WindowStatusFlags.BoundForRendering;
				}
			}
		}

		/// <summary>
		/// Retrieves the low word of a message parameter.
		/// </summary>
		private static int32 LOWORD(int32 word) => (word & 0xffff);

		/// <summary>
		/// Retrieves the high word of a message parameter.
		/// </summary>
		private static int32 HIWORD(int32 word) => (word >> 16) & 0xffff;

		/// <summary>
		/// Sets the window's fullscreen display mode.
		/// </summary>
		/// <param name="displayMode">The fullscreen display mode to set, or null to use the desktop display mode.</param>
		private void SetFullscreenDisplayModeInternal(DisplayMode? displayMode)
		{
			var displayMode;
			if (displayMode == null)
			{
				SetDesktopDisplayMode();
			}
			else
			{
				SDL_DisplayMode sdlMode = default;
				sdlMode.w = displayMode.Value.Width;
				sdlMode.h = displayMode.Value.Height;
				sdlMode.refresh_rate = displayMode.Value.RefreshRate;
				switch (displayMode.Value.BitsPerPixel)
				{
				case 15:
					sdlMode.format = .SDL_PIXELFORMAT_RGB555;
					break;

				case 16:
					sdlMode.format = .SDL_PIXELFORMAT_RGB565;
					break;

				default:
					sdlMode.format = .SDL_PIXELFORMAT_RGB888;
					break;
				}

				var wasFullscreen = windowMode == WindowMode.Fullscreen;
				if (wasFullscreen)
					SetWindowMode(WindowMode.Windowed);

				if (SDL_SetWindowDisplayMode(ptr, &sdlMode) < 0)
					Runtime.SDL2Error();

				if (wasFullscreen)
				{
					if (displayMode.Value.DisplayIndex.HasValue)
					{
						ChangeDisplay(displayMode.Value.DisplayIndex.Value);
					}
					SetWindowMode(WindowMode.Fullscreen);
				}

				if (SDL_GetWindowDisplayMode(ptr, &sdlMode) < 0)
					Runtime.SDL2Error();

				int32 bpp = 0;
				uint32 Rmask = 0, Gmask = 0, Bmask = 0, Amask = 0;
				SDL_PixelFormatEnumToMasks((uint32)sdlMode.format, &bpp, &Rmask, &Gmask, &Bmask, &Amask);

				var displayIndex = displayMode.Value.DisplayIndex;
				if (displayIndex.HasValue)
				{
					if (displayIndex < 0 || displayIndex >= mBackend.Displays.Count)
						displayIndex = null;
				}

				displayMode = DisplayMode(sdlMode.w, sdlMode.h, bpp, sdlMode.refresh_rate, displayIndex);
			}
			this.displayMode = displayMode;
		}

		/*/// <summary>
		/// Sets the window's icon.
		/// </summary>
		/// <param name="surface">The surface that contains the icon to set.</param>
		private void SetIcon(Surface2D surface)
		{
			var surfptr = (surface == null) ? null : ((SDL2Surface2D)surface).NativePtr;
			SDL_SetWindowIcon(ptr, (IntPtr)surfptr);
		}*/

		/// <summary>
		/// Raises the Drawing event.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to Draw.</param>
		private void OnDrawing(Time time) =>
			Drawing?.Invoke(this, time);

		/// <summary>
		/// Raises the DrawingUI event.
		/// </summary>
		/// <param name="time">Time elapsed since the last call to Draw.</param>
		private void OnDrawingUI(Time time) =>
			DrawingUI?.Invoke(this, time);

		/// <summary>
		/// Raises the Shown event.
		/// </summary>
		private void OnShown() =>
			Shown?.Invoke(this);

		/// <summary>
		/// Raises the Hidden event.
		/// </summary>
		private void OnHidden() =>
			Hidden?.Invoke(this);

		/// <summary>
		/// Raises the Maximized event.
		/// </summary>
		private void OnMaximized() =>
			Maximized?.Invoke(this);

		/// <summary>
		/// Raises the Minimized event.
		/// </summary>
		private void OnMinimized() =>
			Minimized?.Invoke(this);

		/// <summary>
		/// Raises the Restored event.
		/// </summary>
		private void OnRestored() =>
			Restored?.Invoke(this);

		/// <summary>
		/// Raises the SizeChanged event.
		/// </summary>
		private void OnSizeChanged() =>
			SizeChanged?.Invoke(this);

		/// <summary>
		/// Called when the window's DPI changes.
		/// </summary>
		private void HandleDpiChanged(float? reportedScale = null)
		{
			// Inform our display that it needs to re-query DPI information.
			((SDL2Display)Display)?.RefreshDensityInformation();

			// On Windows, resize the window to match the new scale.
			if (mBackend.Context.Platform == .Windows && mBackend.SupportsHighDensityDisplayModes)
			{
				var factor = (reportedScale ?? Display.DensityScale) / WindowScale;

				SDL_GetWindowPosition(ptr, var windowX, var windowY);
				SDL_GetWindowSize(ptr, var windowW, var windowH);

				var size = Size2((int32)(windowW * factor), (int32)(windowH * factor));
				var bounds = Rectangle(windowX, windowY, windowW, windowH);
				Rectangle.Inflate(bounds, (int32)Math.Ceiling((size.Width - windowW) / 2.0), 0, out bounds);

				WindowedPosition = bounds.Location;
				WindowedClientSize = size;
			}
			WindowScale = (reportedScale ?? Display.DensityScale);

			// Inform the rest of the system that this window's DPI has changed.
			// todo: Send a WindowDensityChange event
		}

		/// <summary>
		/// Updates the window's windowed position, if it is currently in the correct mode and state.
		/// </summary>
		/// <param name="position">The new windowed position.</param>
		private void UpdateWindowedPosition(Point2 position)
		{
			if (windowedPosition == null || (GetWindowState() == WindowState.Normal && GetWindowMode() == WindowMode.Windowed))
			{
				windowedPosition = position;
			}
		}

		/// <summary>
		/// Updates the window's windowed client size, if it is currently in the correct mode and state.
		/// </summary>
		/// <param name="size">The new windowed client size.</param>
		private void UpdateWindowedClientSize(Size2 size)
		{
			if (windowedClientSize == null || (GetWindowState() == WindowState.Normal && GetWindowMode() == WindowMode.Windowed))
			{
				windowedClientSize = size;
			}
		}

		/// <summary>
		/// Updates the window's mouse grab state.
		/// </summary>
		private void UpdateMouseGrab()
		{
			switch (windowMode)
			{
			case WindowMode.Windowed:
				SDL_SetWindowGrab(ptr, grabsMouseWhenWindowed);
				break;

			case WindowMode.Fullscreen:
				SDL_SetWindowGrab(ptr, grabsMouseWhenFullscreen);
				break;

			case WindowMode.FullscreenWindowed:
				SDL_SetWindowGrab(ptr, grabsMouseWhenFullscreenWindowed);
				break;
			}
		}

		/// <summary>
		/// Sets the window to use the desktop display mode for its current display.
		/// </summary>
		private void SetDesktopDisplayMode()
		{
			SDL_DisplayMode mode;
			if (SDL_GetDesktopDisplayMode(Display.Index, &mode) < 0)
				Runtime.SDL2Error();

			if (SDL_SetWindowDisplayMode(ptr, &mode) < 0)
				Runtime.SDL2Error();
		}

		// Property values.
		private Point2? windowedPosition;
		private Size2? windowedClientSize;
		private bool grabsMouseWhenWindowed;
		private bool grabsMouseWhenFullscreenWindowed;
		private bool grabsMouseWhenFullscreen;
		//private Surface2D icon;

		// State values.
		private readonly SDL_Window* ptr;
		private WindowMode windowMode = WindowMode.Windowed;
		private WindowStatusFlags windowStatus = WindowStatusFlags.None;
		private DisplayMode? displayMode;
	}
}
