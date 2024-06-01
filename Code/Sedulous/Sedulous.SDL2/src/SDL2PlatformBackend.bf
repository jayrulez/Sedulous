using System;
using Sedulous.SDL2;
using Sedulous.Platform;
using Sedulous.Foundation.Utilities;
using SDL2Native;
using Sedulous.Platform.Input;
using Sedulous.SDL2.Input;
using Sedulous.Core;
using System.Diagnostics;
using static Sedulous.Platform.IPlatformBackend;
using static SDL2Native.SDL2Native;
using internal Sedulous.Core;
using internal Sedulous.SDL2;

enum ContextHostState
{
	None = 0,
	Running,
	Suspended
}

namespace Sedulous.SDL2
{
	/// <summary>
	/// Represents the SDL2 implementation of the <see cref="IPlatform"/> interface.
	/// </summary>
	public abstract class SDL2PlatformBackend : IPlatformBackend
	{
		public typealias FrameCallback = delegate void(Time elapsedTicks);

		private static bool sSDLInitialized = false;

		public static bool SDLInitialized => sSDLInitialized;

		static this()
		{
			if (SDL_Init(.SDL_INIT_EVERYTHING) < 0)
			{
				Runtime.FatalError(scope $"SDL initialization failed: {SDL_GetError()}");
			}
			sSDLInitialized = true;
		}

		static ~this()
		{
			if (sSDLInitialized)
			{
				SDL_Quit();
			}
		}

		// Property values.
		private bool isCursorVisible = true;
		//private Cursor cursor;
		private readonly ClipboardService mClipboard;
		private readonly MessageBoxService mMessageBoxService;
		private readonly SDL2WindowInfo mWindows;
		private readonly SDL2DisplayInfo mDisplays;
		private readonly SDL2InputSystem mInputSystem;
		private readonly Context mContext;

		private readonly Stopwatch mTimer = new .() ~ delete _;
		internal readonly TimeTracker HostUpdateTimeTracker = new .() ~ delete _;

		private ContextHostState mState = .None;

		/// <inheritdoc/>
		public bool IsPrimaryWindowInitialized
		{
			get;
			private set;
		}

		/// <inheritdoc/>
		public bool IsCursorVisible
		{
			get { return isCursorVisible; }
			set
			{
				if (value != isCursorVisible)
				{
					var result = SDL_ShowCursor(value ? SDL_ENABLE : SDL_DISABLE);
					if (result < 0)
						Runtime.SDL2Error();

					isCursorVisible = SDL_ShowCursor(SDL_QUERY) != 0;
				}
			}
		}

		public ClipboardService Clipboard => mClipboard;

		public IWindowInfo Windows => mWindows;

		public IDisplayInfo Displays => mDisplays;

		public InputSystem Input => mInputSystem;

		public IContext Context => mContext;

		public ContextInitializingCallback OnContextInitializing { get; private set; }

		public ContextInitializedCallback OnContextInitialized { get; private set; }

		public ContextShuttingDownCallback OnContextShuttingDown { get; private set; }

		public bool IsRunning { get; private set; }

		public bool IsSuspended => mState.HasFlag(.Suspended);

		public abstract bool SupportsMultipleThreads { get; }

		public abstract bool SupportsHighDensityDisplayModes { get; }

		/// <summary>
		/// Initializes a new instance of the <see cref="SDL2Platform"/> class.
		/// </summary>
		/// <param name="configuration">The platform configuration.</param>
		public this(SDL2PlatformConfiguration configuration)
		{
			mContext = new .(this);
			mClipboard = new SDL2ClipboardService();
			mMessageBoxService = new SDL2MessageBoxService();
			mWindows = new SDL2WindowInfo(this);
			mDisplays = new SDL2DisplayInfo(this);
			isCursorVisible = SDL_ShowCursor(SDL_QUERY) != 0;
			mInputSystem = new .(this);
		}

		public ~this()
		{
			delete mInputSystem;
			for (SDL2Window window in mWindows)
			{
				mWindows.Destroy(window);
			}
			delete mWindows;
			delete mDisplays;
			delete mMessageBoxService;
			delete mClipboard;
			delete mContext;
		}

		/// <inheritdoc/>
		private void Update(Time time)
		{
			this.mDisplays.Update(time);
			this.mWindows.Update(time);
			this.mInputSystem.Update(time);
		}

		/// <inheritdoc/>
		public void ShowMessageBox(MessageBoxType type, String title, String message, IWindow parent = null)
		{
			var parent;
			if (parent == null)
				parent = Windows.GetPrimary();

			var window = (parent == null) ? null : (SDL_Window*)((SDL2Window)parent);
			mMessageBoxService.ShowMessageBox(type, title, message, window);
		}


		public void Exit()
		{
			IsRunning = false;
		}

		protected void StartMainLoop(
			ContextInitializingCallback initializingCallback = null,
			ContextInitializedCallback initializedCallback = null)
		{
			var initializer = scope ContextInitializer();
			// host initialization
			if (this.OnContextInitializing != null)
			{
				if (this.OnContextInitializing.Invoke(initializer) case .Err)
				{
					Debug.WriteLine("Host initialization failed.");
					return;
				}
			}

			if (initializingCallback != null)
			{
				if (initializingCallback(initializer) case .Err)
				{
					Debug.WriteLine("Initialization callback failed.");
					return;
				}
			}

			if (mContext.Initialize(initializer) case .Err)
			{
				Debug.WriteLine("Context initialization failed.");
				return;
			}

			this.OnContextInitialized?.Invoke(mContext);

			initializedCallback?.Invoke(mContext);

			mState = .Running;

			mTimer.Start();
			SDL_SetEventFilter( => SDLEventFilter, Internal.UnsafeCastToPtr(this));

			SDL_PumpEvents();

			IsRunning = true;
		}

		protected void RunOneFrame()
		{
			mInputSystem.ResetDeviceStates();

			while (SDL_PollEvent(let ev) != 0)
			{
				switch (ev.type) {
				case .SDL_QUIT:
					IsRunning = false;
					break;

				case .SDL_WINDOWEVENT:
					var sdlWindow = (SDL2Window)mWindows.GetByID((.)ev.window.windowID);
					sdlWindow?.[Friend]HandleEvent(ev);
					if (ev.window.event == .SDL_WINDOWEVENT_CLOSE)
					{
						// If this is the primary window then stop running
						if (sdlWindow == (SDL2Window)mWindows.GetPrimary())
						{
							IsRunning = false;
						}
					}
					break;

				default:
					if (mInputSystem.HandleEvent(ev))
					{
					}
					break;
				}
			}

			var elapsedTicks = mTimer.Elapsed.Ticks;
			mTimer.Restart();

			Time updateTime = HostUpdateTimeTracker.Increment(TimeSpan(elapsedTicks));

			Update(updateTime);
			mContext.Update(updateTime);
		}

		protected void StopMainLoop(ContextShuttingDownCallback shuttingDownCallback)
		{
			mTimer.Stop();

			SDL_SetEventFilter(null, null);

			mState = .None;
			
			shuttingDownCallback?.Invoke(mContext);

			// host Context shutdown
			this.OnContextShuttingDown?.Invoke(mContext);

			mContext.Shutdown();
		}

		private void Suspend()
		{
			mState |= .Suspended;
		}

		private void Resume()
		{
			mState &= ~.Suspended;
		}

		private static int32 SDLEventFilter(void* userData, SDL_Event* event)
		{
			if (userData == null || event == null)
			{
				return 1;
			}

			SDL2PlatformBackend backend = (SDL2PlatformBackend)Internal.UnsafeCastToObject(userData);
			if (backend == null)
			{
				return 1;
			}

			switch (event.type)
			{
			case .SDL_APP_TERMINATING:
				return 0;

			case .SDL_APP_WILLENTERBACKGROUND:
				return 0;

			case .SDL_APP_DIDENTERBACKGROUND:
				backend.Suspend();
				return 0;

			case .SDL_APP_WILLENTERFOREGROUND:
				return 0;

			case .SDL_APP_DIDENTERFOREGROUND:
				backend.Resume();
				return 0;

			case .SDL_APP_LOWMEMORY:
				return 0;

			default: return 1;
			}
		}
	}
}
