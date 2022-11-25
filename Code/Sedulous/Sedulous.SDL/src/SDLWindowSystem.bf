using Sedulous.Platform;
using SDL2;
using System;
using Sedulous.NRI;
using System.Collections;
namespace Sedulous.SDL;

class SDLWindowSystem : WindowSystem
{
	private bool mSDLInitialized = false;

	public override bool IsRunning { get; protected set; }

	private Window mPrimaryWindow;

	public override Window PrimaryWindow => mPrimaryWindow;

	private Dictionary<uint32, SDLWindow> mWindows = new .() ~ delete _;

	public this()
	{
		if (SDL.Init(.Everything) < 0)
		{
			Runtime.FatalError(scope $"SDL initialization failed: {SDL.GetError()}");
		}
		mSDLInitialized = true;
	}

	public ~this()
	{
		if (mSDLInitialized)
		{
			SDL.Quit();
		}
	}

	public override Result<void> CreateWindow(StringView title, uint32 width, uint32 height, bool isVisible, GraphicsAPI graphicsAPI, out Window window)
	{
		SDLWindow sdlWindow = new SDLWindow(title, width, height, isVisible, graphicsAPI);

		window = sdlWindow;

		mWindows.Add(window.Id, sdlWindow);

		if (mPrimaryWindow == null)
			mPrimaryWindow = window;

		return .Ok;
	}

	public override void DestroyWindow(Window window)
	{
		if (mWindows.ContainsKey(window.Id))
			mWindows.Remove(window.Id);

		delete window;
	}

	public override void RunMainLoop(delegate void() updateCallback)
	{
		SDL.PumpEvents();

		IsRunning = true;

		while (IsRunning)
		{
			while (SDL.PollEvent(let ev) != 0)
			{
				var sdlWindow = (SDLWindow)GetWindowByID(ev.window.windowID);
				sdlWindow?.[Friend]OnEvent(ev);

				if (ev.type == .Quit)
				{
						// If this is the primary window then stop running
					IsRunning = false;
				}
			}

			updateCallback();
		}
	}

	public override void StopMainLoop()
	{
		IsRunning = false;
	}

	public override Window GetWindowByID(uint32 windowId)
	{
		if (mWindows.ContainsKey(windowId))
			return mWindows[windowId];

		return null;
	}
}