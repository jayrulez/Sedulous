using SDL2;
using System;
namespace NRI.Framework.SDL;

class SDLWindow : Window
{
	private SDL.Window* SDLNativeWindow;
	private String mTitle = new String() ~ delete _;

	public void* NativeWindow { get; private set; }

	public override String Title
	{
		get
		{
			mTitle.Clear();
			mTitle.Append(SDL.GetWindowTitle(SDLNativeWindow));
			return mTitle;
		}

		set
		{
			SDL.SetWindowTitle(SDLNativeWindow, value);
			mTitle.Set(value);
		}
	}

	public override bool Visible
	{
		get
		{
			return (SDL.GetWindowFlags(SDLNativeWindow) | (uint32)SDL.WindowFlags.Shown) > 0;
		}

		set
		{
			SDL.HideWindow(SDLNativeWindow);
		}
	}

	public this(StringView title, uint32 width, uint32 height, bool isVisible = true, GraphicsAPI graphicsAPI = .MAX_NUM)
		: base(title, width, height)
	{
		SDL.WindowFlags flags = SDL.WindowFlags.Resizable;
		if(isVisible)
			flags |=  .Shown;

		if(graphicsAPI == .VULKAN)
			flags |= SDL.WindowFlags.Vulkan;

		SDLNativeWindow = SDL.CreateWindow(title.ToScopeCStr!(), .Undefined, .Undefined, (int32)width, (int32)height, flags);

		if (SDLNativeWindow == null)
		{
			Runtime.FatalError("Failed to create SDL window.");
		}

		SDL.SDL_SysWMinfo info = .();
		SDL.GetVersion(out info.version);
		SDL.GetWindowWMInfo(SDLNativeWindow, ref info);
		SDL.SDL_SYSWM_TYPE subsystem = info.subsystem;
		switch (subsystem) {
		case SDL.SDL_SYSWM_TYPE.SDL_SYSWM_WINDOWS:
			NativeWindow = (void*)(int)info.info.win.window;
			SurfaceInfo = .()
				{
					Type = .WINDOWS,
					windows = .()
						{
							hwnd = NativeWindow
						}
				};
			break;

		case SDL.SDL_SYSWM_TYPE.SDL_SYSWM_UNKNOWN: fallthrough;
		default:
			Runtime.FatalError("Subsystem not currently supported.");
		}
	}

	public ~this()
	{
		if (SDLNativeWindow != null)
		{
			SDL.DestroyWindow(SDLNativeWindow);
			SDLNativeWindow = null;
		}
	}

	private void OnEvent(SDL.Event ev)
	{
		if (ev.type == SDL.EventType.WindowEvent)
		{
			var windowEvent = ev.window;
			if (windowEvent.windowEvent != .SizeChanged)
			{
				switch (windowEvent.windowEvent) {
				case .FocusGained:
					OnFocusGained();
					break;

				case .Focus_lost:
					OnFocusLost();
					break;

				case .Close:
					OnClosing();
					break;

				default:
					break;
				}
			} else
			{
				SDL.GetWindowSize(SDLNativeWindow, var width, var height);

				Width = (uint32)width;
				Height = (uint32)height;

				OnResized();
			}
		}
	}
}