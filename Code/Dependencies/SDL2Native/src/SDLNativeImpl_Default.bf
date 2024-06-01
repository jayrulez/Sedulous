using System;
using System.Security;

namespace SDL2Native
{
	using internal SDL2Native;

	[StaticInitPriority(99)]
	internal sealed class SDL2NativeImpl_Default : SDL2NativeImpl
	{
		private static bool sInvokeErrorCallback = true;

		private static readonly NativeLibrary lib;

		/*public static void Init()
		{
		}*/

		static this()
		{
			switch (Environment.OSVersion.Platform)
			{
			case .Unix:
				NativeLibrary.Load("libSDL2", out lib);
				break;
			case .MacOSX:
				NativeLibrary.Load("libSDL2", out lib);
				break;
			default:
				NativeLibrary.Load("SDL2", out lib);
				break;
			}
		}

		static ~this()
		{
			if (lib != null)
				delete lib;
		}

		public this()
		{
		}


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GetError_RawDelegate();
		private readonly SDL_GetError_RawDelegate pSDL_GetError_Raw = lib.LoadFunction<SDL_GetError_RawDelegate>("SDL_GetError", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GetError() => pSDL_GetError_Raw();


		[CallingConvention(.Cdecl)]
		private function void SDL_ClearErrorDelegate();
		private readonly SDL_ClearErrorDelegate pSDL_ClearError = lib.LoadFunction<SDL_ClearErrorDelegate>("SDL_ClearError", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_ClearError() => pSDL_ClearError();


		[CallingConvention(.Cdecl)]
		private function int32 SDL_InitDelegate(SDL_Init_Flags flags);
		private readonly SDL_InitDelegate pSDL_Init = lib.LoadFunction<SDL_InitDelegate>("SDL_Init", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_Init(SDL_Init_Flags flags) => pSDL_Init(flags);


		[CallingConvention(.Cdecl)]
		private function void SDL_QuitDelegate();
		private readonly SDL_QuitDelegate pSDL_Quit = lib.LoadFunction<SDL_QuitDelegate>("SDL_Quit", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_Quit() => pSDL_Quit();


		[CallingConvention(.Cdecl)]
		private function void SDL_PumpEventsDelegate();
		private readonly SDL_PumpEventsDelegate pSDL_PumpEvents = lib.LoadFunction<SDL_PumpEventsDelegate>("SDL_PumpEvents", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_PumpEvents() => pSDL_PumpEvents();


		[CallingConvention(.Cdecl)]
		private function int32 SDL_PollEventDelegate(out SDL_Event event);
		private readonly SDL_PollEventDelegate pSDL_PollEvent = lib.LoadFunction<SDL_PollEventDelegate>("SDL_PollEvent", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_PollEvent(out SDL_Event event) => pSDL_PollEvent(out event);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetEventFilterDelegate(SDL_EventFilter filter, void* userdata);
		private readonly SDL_SetEventFilterDelegate pSDL_SetEventFilter = lib.LoadFunction<SDL_SetEventFilterDelegate>("SDL_SetEventFilter", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetEventFilter(SDL_EventFilter filter, void* userdata) => pSDL_SetEventFilter(filter, userdata);


		[CallingConvention(.Cdecl)]
		private function SDL_Window* SDL_CreateWindowDelegate(char8* title, int32 x, int32 y, int32 w, int32 h, SDL_WindowFlags flags);
		private readonly SDL_CreateWindowDelegate pSDL_CreateWindow = lib.LoadFunction<SDL_CreateWindowDelegate>("SDL_CreateWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Window* SDL_CreateWindow(char8* title, int32 x, int32 y, int32 w, int32 h, SDL_WindowFlags flags) => pSDL_CreateWindow(title, x, y, w, h, flags);


		[CallingConvention(.Cdecl)]
		private function SDL_Window* SDL_CreateWindowFromDelegate(void* data);
		private readonly SDL_CreateWindowFromDelegate pSDL_CreateWindowFrom = lib.LoadFunction<SDL_CreateWindowFromDelegate>("SDL_CreateWindowFrom", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Window* SDL_CreateWindowFrom(void* data) => pSDL_CreateWindowFrom(data);


		[CallingConvention(.Cdecl)]
		private function void SDL_DestroyWindowDelegate(SDL_Window* window);
		private readonly SDL_DestroyWindowDelegate pSDL_DestroyWindow = lib.LoadFunction<SDL_DestroyWindowDelegate>("SDL_DestroyWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_DestroyWindow(SDL_Window* window) => pSDL_DestroyWindow(window);


		[CallingConvention(.Cdecl)]
		private function uint32 SDL_GetWindowIDDelegate(SDL_Window* window);
		private readonly SDL_GetWindowIDDelegate pSDL_GetWindowID = lib.LoadFunction<SDL_GetWindowIDDelegate>("SDL_GetWindowID", .. ?, sInvokeErrorCallback);
		[Inline]
		public override uint32 SDL_GetWindowID(SDL_Window* window) => pSDL_GetWindowID(window);


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GetWindowTitle_RawDelegate(SDL_Window* window);
		private readonly SDL_GetWindowTitle_RawDelegate pSDL_GetWindowTitle_Raw = lib.LoadFunction<SDL_GetWindowTitle_RawDelegate>("SDL_GetWindowTitle", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GetWindowTitle(SDL_Window* window) => pSDL_GetWindowTitle_Raw(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowTitleDelegate(SDL_Window* window, char8* title);
		private readonly SDL_SetWindowTitleDelegate pSDL_SetWindowTitle = lib.LoadFunction<SDL_SetWindowTitleDelegate>("SDL_SetWindowTitle", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowTitle(SDL_Window* window, char8* title) => pSDL_SetWindowTitle(window, title);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowIconDelegate(SDL_Window* window, SDL_Surface* icon);
		private readonly SDL_SetWindowIconDelegate pSDL_SetWindowIcon = lib.LoadFunction<SDL_SetWindowIconDelegate>("SDL_SetWindowIcon", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowIcon(SDL_Window* window, SDL_Surface* icon) => pSDL_SetWindowIcon(window, icon);


		[CallingConvention(.Cdecl)]
		private function void SDL_GetWindowPositionDelegate(SDL_Window* window, out int32 x, out int32 y);
		private readonly SDL_GetWindowPositionDelegate pSDL_GetWindowPosition = lib.LoadFunction<SDL_GetWindowPositionDelegate>("SDL_GetWindowPosition", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GetWindowPosition(SDL_Window* window, out int32 x, out int32 y) => pSDL_GetWindowPosition(window, out x, out y);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowPositionDelegate(SDL_Window* window, int32 x, int32 y);
		private readonly SDL_SetWindowPositionDelegate pSDL_SetWindowPosition = lib.LoadFunction<SDL_SetWindowPositionDelegate>("SDL_SetWindowPosition", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowPosition(SDL_Window* window, int32 x, int32 y) => pSDL_SetWindowPosition(window, x, y);


		[CallingConvention(.Cdecl)]
		private function void SDL_GetWindowSizeDelegate(SDL_Window* window, out int32 w, out int32 h);
		private readonly SDL_GetWindowSizeDelegate pSDL_GetWindowSize = lib.LoadFunction<SDL_GetWindowSizeDelegate>("SDL_GetWindowSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GetWindowSize(SDL_Window* window, out int32 w, out int32 h) => pSDL_GetWindowSize(window, out w, out h);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowSizeDelegate(SDL_Window* window, int32 w, int32 h);
		private readonly SDL_SetWindowSizeDelegate pSDL_SetWindowSize = lib.LoadFunction<SDL_SetWindowSizeDelegate>("SDL_SetWindowSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowSize(SDL_Window* window, int32 w, int32 h) => pSDL_SetWindowSize(window, w, h);


		[CallingConvention(.Cdecl)]
		private function void SDL_GetWindowMinimumSizeDelegate(SDL_Window* window, out int32 w, out int32 h);
		private readonly SDL_GetWindowMinimumSizeDelegate pSDL_GetWindowMinimumSize = lib.LoadFunction<SDL_GetWindowMinimumSizeDelegate>("SDL_GetWindowMinimumSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GetWindowMinimumSize(SDL_Window* window, out int32 w, out int32 h) => pSDL_GetWindowMinimumSize(window, out w, out h);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowMinimumSizeDelegate(SDL_Window* window, int32 w, int32 h);
		private readonly SDL_SetWindowMinimumSizeDelegate pSDL_SetWindowMinimumSize = lib.LoadFunction<SDL_SetWindowMinimumSizeDelegate>("SDL_SetWindowMinimumSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowMinimumSize(SDL_Window* window, int32 w, int32 h) => pSDL_SetWindowMinimumSize(window, w, h);


		[CallingConvention(.Cdecl)]
		private function void SDL_GetWindowMaximumSizeDelegate(SDL_Window* window, out int32 w, out int32 h);
		private readonly SDL_GetWindowMaximumSizeDelegate pSDL_GetWindowMaximumSize = lib.LoadFunction<SDL_GetWindowMaximumSizeDelegate>("SDL_GetWindowMaximumSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GetWindowMaximumSize(SDL_Window* window, out int32 w, out int32 h) => pSDL_GetWindowMaximumSize(window, out w, out h);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowMaximumSizeDelegate(SDL_Window* window, int32 w, int32 h);
		private readonly SDL_SetWindowMaximumSizeDelegate pSDL_SetWindowMaximumSize = lib.LoadFunction<SDL_SetWindowMaximumSizeDelegate>("SDL_SetWindowMaximumSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowMaximumSize(SDL_Window* window, int32 w, int32 h) => pSDL_SetWindowMaximumSize(window, w, h);


		[CallingConvention(.Cdecl)]
		private function bool SDL_GetWindowGrabDelegate(SDL_Window* window);
		private readonly SDL_GetWindowGrabDelegate pSDL_GetWindowGrab = lib.LoadFunction<SDL_GetWindowGrabDelegate>("SDL_GetWindowGrab", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_GetWindowGrab(SDL_Window* window) => pSDL_GetWindowGrab(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_SetWindowGrabDelegate(SDL_Window* window, bool grabbed);
		private readonly SDL_SetWindowGrabDelegate pSDL_SetWindowGrab = lib.LoadFunction<SDL_SetWindowGrabDelegate>("SDL_SetWindowGrab", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetWindowGrab(SDL_Window* window, bool grabbed) => pSDL_SetWindowGrab(window, grabbed);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetWindowBorderedDelegate(SDL_Window* window, bool bordered);
		private readonly SDL_SetWindowBorderedDelegate pSDL_SetWindowBordered = lib.LoadFunction<SDL_SetWindowBorderedDelegate>("SDL_SetWindowBordered", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetWindowBordered(SDL_Window* window, bool bordered) => pSDL_SetWindowBordered(window, bordered);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetWindowFullscreenDelegate(SDL_Window* window, uint32 flags);
		private readonly SDL_SetWindowFullscreenDelegate pSDL_SetWindowFullscreen = lib.LoadFunction<SDL_SetWindowFullscreenDelegate>("SDL_SetWindowFullscreen", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetWindowFullscreen(SDL_Window* window, uint32 flags) => pSDL_SetWindowFullscreen(window, flags);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetWindowDisplayModeDelegate(SDL_Window* window, SDL_DisplayMode* mode);
		private readonly SDL_SetWindowDisplayModeDelegate pSDL_SetWindowDisplayMode = lib.LoadFunction<SDL_SetWindowDisplayModeDelegate>("SDL_SetWindowDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => pSDL_SetWindowDisplayMode(window, mode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetWindowDisplayModeDelegate(SDL_Window* window, SDL_DisplayMode* mode);
		private readonly SDL_GetWindowDisplayModeDelegate pSDL_GetWindowDisplayMode = lib.LoadFunction<SDL_GetWindowDisplayModeDelegate>("SDL_GetWindowDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => pSDL_GetWindowDisplayMode(window, mode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetWindowDisplayIndexDelegate(SDL_Window* window);
		private readonly SDL_GetWindowDisplayIndexDelegate pSDL_GetWindowDisplayIndex = lib.LoadFunction<SDL_GetWindowDisplayIndexDelegate>("SDL_GetWindowDisplayIndex", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetWindowDisplayIndex(SDL_Window* window) => pSDL_GetWindowDisplayIndex(window);


		[CallingConvention(.Cdecl)]
		private function SDL_WindowFlags SDL_GetWindowFlagsDelegate(SDL_Window* window);
		private readonly SDL_GetWindowFlagsDelegate pSDL_GetWindowFlags = lib.LoadFunction<SDL_GetWindowFlagsDelegate>("SDL_GetWindowFlags", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_WindowFlags SDL_GetWindowFlags(SDL_Window* window) => pSDL_GetWindowFlags(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_ShowWindowDelegate(SDL_Window* window);
		private readonly SDL_ShowWindowDelegate pSDL_ShowWindow = lib.LoadFunction<SDL_ShowWindowDelegate>("SDL_ShowWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_ShowWindow(SDL_Window* window) => pSDL_ShowWindow(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_HideWindowDelegate(SDL_Window* window);
		private readonly SDL_HideWindowDelegate pSDL_HideWindow = lib.LoadFunction<SDL_HideWindowDelegate>("SDL_HideWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_HideWindow(SDL_Window* window) => pSDL_HideWindow(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_MaximizeWindowDelegate(SDL_Window* window);
		private readonly SDL_MaximizeWindowDelegate pSDL_MaximizeWindow = lib.LoadFunction<SDL_MaximizeWindowDelegate>("SDL_MaximizeWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_MaximizeWindow(SDL_Window* window) => pSDL_MaximizeWindow(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_MinimizeWindowDelegate(SDL_Window* window);
		private readonly SDL_MinimizeWindowDelegate pSDL_MinimizeWindow = lib.LoadFunction<SDL_MinimizeWindowDelegate>("SDL_MinimizeWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_MinimizeWindow(SDL_Window* window) => pSDL_MinimizeWindow(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_RestoreWindowDelegate(SDL_Window* window);
		private readonly SDL_RestoreWindowDelegate pSDL_RestoreWindow = lib.LoadFunction<SDL_RestoreWindowDelegate>("SDL_RestoreWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_RestoreWindow(SDL_Window* window) => pSDL_RestoreWindow(window);


		[CallingConvention(.Cdecl)]
		private function bool SDL_GetWindowWMInfoDelegate(SDL_Window* window, SDL_SysWMinfo* info);
		private readonly SDL_GetWindowWMInfoDelegate pSDL_GetWindowWMInfo = lib.LoadFunction<SDL_GetWindowWMInfoDelegate>("SDL_GetWindowWMInfo", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* info) => pSDL_GetWindowWMInfo(window, info);


		[CallingConvention(.Cdecl)]
		private function SDL_RWops* SDL_RWFromFileDelegate(char8* file, char8* mode);
		private readonly SDL_RWFromFileDelegate pSDL_RWFromFile = lib.LoadFunction<SDL_RWFromFileDelegate>("SDL_RWFromFile", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_RWops* SDL_RWFromFile(char8* file, char8* mode) => pSDL_RWFromFile(file, mode);


		[CallingConvention(.Cdecl)]
		private function SDL_RWops* SDL_RWFromMemDelegate(void* mem, int32 size);
		private readonly SDL_RWFromMemDelegate pSDL_RWFromMem = lib.LoadFunction<SDL_RWFromMemDelegate>("SDL_RWFromMem", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_RWops* SDL_RWFromMem(void* mem, int32 size) => pSDL_RWFromMem(mem, size);


		[CallingConvention(.Cdecl)]
		private function SDL_RWops* SDL_AllocRWDelegate();
		private readonly SDL_AllocRWDelegate pSDL_AllocRW = lib.LoadFunction<SDL_AllocRWDelegate>("SDL_AllocRW", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_RWops* SDL_AllocRW() => pSDL_AllocRW();


		[CallingConvention(.Cdecl)]
		private function void SDL_FreeRWDelegate(SDL_RWops* area);
		private readonly SDL_FreeRWDelegate pSDL_FreeRW = lib.LoadFunction<SDL_FreeRWDelegate>("SDL_FreeRW", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_FreeRW(SDL_RWops* area) => pSDL_FreeRW(area);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Surface* SDL_LoadBMP_RWDelegate(SDL_RWops* src, int32 freesrc);
		private readonly SDL_LoadBMP_RWDelegate pSDL_LoadBMP_RW = lib.LoadFunction<SDL_LoadBMP_RWDelegate>("SDL_LoadBMP_RW", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Surface* SDL_LoadBMP_RW(SDL_RWops* src, int32 freesrc) => pSDL_LoadBMP_RW(src, freesrc);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SaveBMP_RWDelegate(SDL_Surface* surface, SDL_RWops* dst, int32 freedst);
		private readonly SDL_SaveBMP_RWDelegate pSDL_SaveBMP_RW = lib.LoadFunction<SDL_SaveBMP_RWDelegate>("SDL_SaveBMP_RW", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SaveBMP_RW(SDL_Surface* surface, SDL_RWops* dst, int32 freedst) => pSDL_SaveBMP_RW(surface, dst, freedst);


		[CallingConvention(.Cdecl)]
		private function uint32 SDL_GetMouseStateDelegate(out int32 x, out int32 y);
		private readonly SDL_GetMouseStateDelegate pSDL_GetMouseState = lib.LoadFunction<SDL_GetMouseStateDelegate>("SDL_GetMouseState", .. ?, sInvokeErrorCallback);
		[Inline]
		public override uint32 SDL_GetMouseState(out int32 x, out int32 y) => pSDL_GetMouseState(out x, out y);


		[CallingConvention(.Cdecl)]
		private function uint8* SDL_GetKeyboardStateDelegate(out int32 numkeys);
		private readonly SDL_GetKeyboardStateDelegate pSDL_GetKeyboardState = lib.LoadFunction<SDL_GetKeyboardStateDelegate>("SDL_GetKeyboardState", .. ?, sInvokeErrorCallback);
		[Inline]
		public override uint8* SDL_GetKeyboardState(out int32 numkeys) => pSDL_GetKeyboardState(out numkeys);


		[CallingConvention(.Cdecl)]
		private function SDL_Scancode SDL_GetScancodeFromKeyDelegate(SDL_Keycode keycode);
		private readonly SDL_GetScancodeFromKeyDelegate pSDL_GetScancodeFromKey = lib.LoadFunction<SDL_GetScancodeFromKeyDelegate>("SDL_GetScancodeFromKey", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Scancode SDL_GetScancodeFromKey(SDL_Keycode keycode) => pSDL_GetScancodeFromKey(keycode);


		[CallingConvention(.Cdecl)]
		private function SDL_Keymod SDL_GetModStateDelegate();
		private readonly SDL_GetModStateDelegate pSDL_GetModState = lib.LoadFunction<SDL_GetModStateDelegate>("SDL_GetModState", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Keymod SDL_GetModState() => pSDL_GetModState();


		[CallingConvention(.Cdecl)]
		private function bool SDL_SetHintDelegate(char8* name, char8* value);
		private readonly SDL_SetHintDelegate pSDL_SetHint = lib.LoadFunction<SDL_SetHintDelegate>("SDL_SetHint", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_SetHint(char8* name, char8* value) => pSDL_SetHint(name, value);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Surface* SDL_CreateRGBSurfaceDelegate(uint32 flags, int32 width, int32 height, int32 depth, uint32 Rmask, uint32 Gmask, uint32 Bmask, uint32 AMask);
		private readonly SDL_CreateRGBSurfaceDelegate pSDL_CreateRGBSurface = lib.LoadFunction<SDL_CreateRGBSurfaceDelegate>("SDL_CreateRGBSurface", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Surface* SDL_CreateRGBSurface(uint32 flags, int32 width, int32 height, int32 depth, uint32 Rmask, uint32 Gmask, uint32 Bmask, uint32 AMask) => pSDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, AMask);


		[CallingConvention(.Cdecl)]
		private function void SDL_FreeSurfaceDelegate(SDL_Surface* surface);
		private readonly SDL_FreeSurfaceDelegate pSDL_FreeSurface = lib.LoadFunction<SDL_FreeSurfaceDelegate>("SDL_FreeSurface", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_FreeSurface(SDL_Surface* surface) => pSDL_FreeSurface(surface);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_LockSurfaceDelegate(SDL_Surface* surface);
		private readonly SDL_LockSurfaceDelegate pSDL_LockSurface = lib.LoadFunction<SDL_LockSurfaceDelegate>("SDL_LockSurface", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_LockSurface(SDL_Surface* surface) => pSDL_LockSurface(surface);


		[CallingConvention(.Cdecl)]
		private function void SDL_UnlockSurfaceDelegate(SDL_Surface* surface);
		private readonly SDL_UnlockSurfaceDelegate pSDL_UnlockSurface = lib.LoadFunction<SDL_UnlockSurfaceDelegate>("SDL_UnlockSurface", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_UnlockSurface(SDL_Surface* surface) => pSDL_UnlockSurface(surface);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_BlitSurfaceDelegate(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect);
		private readonly SDL_BlitSurfaceDelegate pSDL_BlitSurface = lib.LoadFunction<SDL_BlitSurfaceDelegate>("SDL_UpperBlit", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_BlitSurface(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => pSDL_BlitSurface(src, srcrect, dst, dstrect);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_BlitScaledDelegate(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect);
		private readonly SDL_BlitScaledDelegate pSDL_BlitScaled = lib.LoadFunction<SDL_BlitScaledDelegate>("SDL_UpperBlitScaled", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_BlitScaled(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => pSDL_BlitScaled(src, srcrect, dst, dstrect);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetSurfaceBlendModeDelegate(SDL_Surface* surface, SDL_BlendMode blendMode);
		private readonly SDL_SetSurfaceBlendModeDelegate pSDL_SetSurfaceBlendMode = lib.LoadFunction<SDL_SetSurfaceBlendModeDelegate>("SDL_SetSurfaceBlendMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode blendMode) => pSDL_SetSurfaceBlendMode(surface, blendMode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetSurfaceBlendModeDelegate(SDL_Surface* surface, SDL_BlendMode* blendMode);
		private readonly SDL_GetSurfaceBlendModeDelegate pSDL_GetSurfaceBlendMode = lib.LoadFunction<SDL_GetSurfaceBlendModeDelegate>("SDL_GetSurfaceBlendMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode* blendMode) => pSDL_GetSurfaceBlendMode(surface, blendMode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_FillRectDelegate(SDL_Surface* surface, SDL_Rect* rect, uint32 color);
		private readonly SDL_FillRectDelegate pSDL_FillRect = lib.LoadFunction<SDL_FillRectDelegate>("SDL_FillRect", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_FillRect(SDL_Surface* surface, SDL_Rect* rect, uint32 color) => pSDL_FillRect(surface, rect, color);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_FillRectsDelegate(SDL_Surface* dst, SDL_Rect* rects, int32 count, uint32 colors);
		private readonly SDL_FillRectsDelegate pSDL_FillRects = lib.LoadFunction<SDL_FillRectsDelegate>("SDL_FillRects", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_FillRects(SDL_Surface* dst, SDL_Rect* rects, int32 count, uint32 colors) => pSDL_FillRects(dst, rects, count, colors);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Cursor* SDL_CreateColorCursorDelegate(SDL_Surface* surface, int32 hot_x, int32 hot_y);
		private readonly SDL_CreateColorCursorDelegate pSDL_CreateColorCursor = lib.LoadFunction<SDL_CreateColorCursorDelegate>("SDL_CreateColorCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Cursor* SDL_CreateColorCursor(SDL_Surface* surface, int32 hot_x, int32 hot_y) => pSDL_CreateColorCursor(surface, hot_x, hot_y);


		[CallingConvention(.Cdecl)]
		private function void SDL_FreeCursorDelegate(SDL_Cursor* cursor);
		private readonly SDL_FreeCursorDelegate pSDL_FreeCursor = lib.LoadFunction<SDL_FreeCursorDelegate>("SDL_FreeCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_FreeCursor(SDL_Cursor* cursor) => pSDL_FreeCursor(cursor);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_ShowCursorDelegate(int32 toggle);
		private readonly SDL_ShowCursorDelegate pSDL_ShowCursor = lib.LoadFunction<SDL_ShowCursorDelegate>("SDL_ShowCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_ShowCursor(int32 toggle) => pSDL_ShowCursor(toggle);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Cursor* SDL_GetCursorDelegate();
		private readonly SDL_GetCursorDelegate pSDL_GetCursor = lib.LoadFunction<SDL_GetCursorDelegate>("SDL_GetCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Cursor* SDL_GetCursor() => pSDL_GetCursor();


		[CallingConvention(.Cdecl)]
		private function void SDL_SetCursorDelegate(SDL_Cursor* cursor);
		private readonly SDL_SetCursorDelegate pSDL_SetCursor = lib.LoadFunction<SDL_SetCursorDelegate>("SDL_SetCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetCursor(SDL_Cursor* cursor) => pSDL_SetCursor(cursor);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Cursor* SDL_GetDefaultCursorDelegate();
		private readonly SDL_GetDefaultCursorDelegate pSDL_GetDefaultCursor = lib.LoadFunction<SDL_GetDefaultCursorDelegate>("SDL_GetDefaultCursor", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Cursor* SDL_GetDefaultCursor() => pSDL_GetDefaultCursor();


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetNumVideoDisplaysDelegate();
		private readonly SDL_GetNumVideoDisplaysDelegate pSDL_GetNumVideoDisplays = lib.LoadFunction<SDL_GetNumVideoDisplaysDelegate>("SDL_GetNumVideoDisplays", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetNumVideoDisplays() => pSDL_GetNumVideoDisplays();


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GetDisplayName_RawDelegate(int32 displayIndex);
		private readonly SDL_GetDisplayName_RawDelegate pSDL_GetDisplayName_Raw = lib.LoadFunction<SDL_GetDisplayName_RawDelegate>("SDL_GetDisplayName", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GetDisplayName(int32 displayIndex) => pSDL_GetDisplayName_Raw(displayIndex);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetDisplayBoundsDelegate(int32 displayIndex, SDL_Rect* rect);
		private readonly SDL_GetDisplayBoundsDelegate pSDL_GetDisplayBounds = lib.LoadFunction<SDL_GetDisplayBoundsDelegate>("SDL_GetDisplayBounds", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetDisplayBounds(int32 displayIndex, SDL_Rect* rect) => pSDL_GetDisplayBounds(displayIndex, rect);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetNumDisplayModesDelegate(int32 displayIndex);
		private readonly SDL_GetNumDisplayModesDelegate pSDL_GetNumDisplayModes = lib.LoadFunction<SDL_GetNumDisplayModesDelegate>("SDL_GetNumDisplayModes", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetNumDisplayModes(int32 displayIndex) => pSDL_GetNumDisplayModes(displayIndex);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetDisplayModeDelegate(int32 displayIndex, int32 modeIndex, SDL_DisplayMode* mode);
		private readonly SDL_GetDisplayModeDelegate pSDL_GetDisplayMode = lib.LoadFunction<SDL_GetDisplayModeDelegate>("SDL_GetDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetDisplayMode(int32 displayIndex, int32 modeIndex, SDL_DisplayMode* mode) => pSDL_GetDisplayMode(displayIndex, modeIndex, mode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetCurrentDisplayModeDelegate(int32 displayIndex, SDL_DisplayMode* mode);
		private readonly SDL_GetCurrentDisplayModeDelegate pSDL_GetCurrentDisplayMode = lib.LoadFunction<SDL_GetCurrentDisplayModeDelegate>("SDL_GetCurrentDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetCurrentDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => pSDL_GetCurrentDisplayMode(displayIndex, mode);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetDesktopDisplayModeDelegate(int32 displayIndex, SDL_DisplayMode* mode);
		private readonly SDL_GetDesktopDisplayModeDelegate pSDL_GetDesktopDisplayMode = lib.LoadFunction<SDL_GetDesktopDisplayModeDelegate>("SDL_GetDesktopDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetDesktopDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => pSDL_GetDesktopDisplayMode(displayIndex, mode);


		[CallingConvention(.Cdecl)]
		private delegate SDL_DisplayMode* SDL_GetClosestDisplayModeDelegate(int32 displayIndex, SDL_DisplayMode* mode, SDL_DisplayMode* closest);
		private readonly SDL_GetClosestDisplayModeDelegate pSDL_GetClosestDisplayMode = lib.LoadFunction<SDL_GetClosestDisplayModeDelegate>("SDL_GetClosestDisplayMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_DisplayMode* SDL_GetClosestDisplayMode(int32 displayIndex, SDL_DisplayMode* mode, SDL_DisplayMode* closest) => pSDL_GetClosestDisplayMode(displayIndex, mode, closest);


		[CallingConvention(.Cdecl)]
		private function bool SDL_PixelFormatEnumToMasksDelegate(uint32 format, int32* bpp, uint32* Rmask, uint32* Gmask, uint32* Bmask, uint32* Amask);
		private readonly SDL_PixelFormatEnumToMasksDelegate pSDL_PixelFormatEnumToMasks = lib.LoadFunction<SDL_PixelFormatEnumToMasksDelegate>("SDL_PixelFormatEnumToMasks", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_PixelFormatEnumToMasks(uint32 format, int32* bpp, uint32* Rmask, uint32* Gmask, uint32* Bmask, uint32* Amask) => pSDL_PixelFormatEnumToMasks(format, bpp, Rmask, Gmask, Bmask, Amask);


		[CallingConvention(.Cdecl)]
		private function void* SDL_GL_GetProcAddressDelegate(char8* proc);
		private readonly SDL_GL_GetProcAddressDelegate pSDL_GL_GetProcAddress = lib.LoadFunction<SDL_GL_GetProcAddressDelegate>("SDL_GL_GetProcAddress", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void* SDL_GL_GetProcAddress(char8* proc) => pSDL_GL_GetProcAddress(proc);


		[CallingConvention(.Cdecl)]
		private function SDL_GLContext* SDL_GL_CreateContextDelegate(SDL_Window* window);
		private readonly SDL_GL_CreateContextDelegate pSDL_GL_CreateContext = lib.LoadFunction<SDL_GL_CreateContextDelegate>("SDL_GL_CreateContext", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_GLContext* SDL_GL_CreateContext(SDL_Window* window) => pSDL_GL_CreateContext(window);


		[CallingConvention(.Cdecl)]
		private function void SDL_GL_DeleteContextDelegate(SDL_GLContext* context);
		private readonly SDL_GL_DeleteContextDelegate pSDL_GL_DeleteContext = lib.LoadFunction<SDL_GL_DeleteContextDelegate>("SDL_GL_DeleteContext", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GL_DeleteContext(SDL_GLContext* context) => pSDL_GL_DeleteContext(context);


		[CallingConvention(.Cdecl)]
		private function SDL_GLContext* SDL_GL_GetCurrentContextDelegate();
		private readonly SDL_GL_GetCurrentContextDelegate pSDL_GL_GetCurrentContext = lib.LoadFunction<SDL_GL_GetCurrentContextDelegate>("SDL_GL_GetCurrentContext", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_GLContext* SDL_GL_GetCurrentContext() => pSDL_GL_GetCurrentContext();


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GL_MakeCurrentDelegate(SDL_Window* window, SDL_GLContext* context);
		private readonly SDL_GL_MakeCurrentDelegate pSDL_GL_MakeCurrent = lib.LoadFunction<SDL_GL_MakeCurrentDelegate>("SDL_GL_MakeCurrent", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GL_MakeCurrent(SDL_Window* window, SDL_GLContext* context) => pSDL_GL_MakeCurrent(window, context);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GL_SetAttributeDelegate(SDL_GLattr attr, int32 value);
		private readonly SDL_GL_SetAttributeDelegate pSDL_GL_SetAttribute = lib.LoadFunction<SDL_GL_SetAttributeDelegate>("SDL_GL_SetAttribute", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GL_SetAttribute(SDL_GLattr attr, int32 value) => pSDL_GL_SetAttribute(attr, value);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GL_GetAttributeDelegate(SDL_GLattr attr, int32* value);
		private readonly SDL_GL_GetAttributeDelegate pSDL_GL_GetAttribute = lib.LoadFunction<SDL_GL_GetAttributeDelegate>("SDL_GL_GetAttribute", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GL_GetAttribute(SDL_GLattr attr, int32* value) => pSDL_GL_GetAttribute(attr, value);


		[CallingConvention(.Cdecl)]
		private function void SDL_GL_SwapWindowDelegate(SDL_Window* window);
		private readonly SDL_GL_SwapWindowDelegate pSDL_GL_SwapWindow = lib.LoadFunction<SDL_GL_SwapWindowDelegate>("SDL_GL_SwapWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GL_SwapWindow(SDL_Window* window) => pSDL_GL_SwapWindow(window);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GL_SetSwapIntervalDelegate(int32 interval);
		private readonly SDL_GL_SetSwapIntervalDelegate pSDL_GL_SetSwapInterval = lib.LoadFunction<SDL_GL_SetSwapIntervalDelegate>("SDL_GL_SetSwapInterval", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GL_SetSwapInterval(int32 interval) => pSDL_GL_SetSwapInterval(interval);


		[CallingConvention(.Cdecl)]
		private function void SDL_GL_GetDrawableSizeDelegate(SDL_Window* window, out int32 w, out int32 h);
		private readonly SDL_GL_GetDrawableSizeDelegate pSDL_GL_GetDrawableSize = lib.LoadFunction<SDL_GL_GetDrawableSizeDelegate>("SDL_GL_GetDrawableSize", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GL_GetDrawableSize(SDL_Window* window, out int32 w, out int32 h) => pSDL_GL_GetDrawableSize(window, out w, out h);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_NumJoysticksDelegate();
		private readonly SDL_NumJoysticksDelegate pSDL_NumJoysticks = lib.LoadFunction<SDL_NumJoysticksDelegate>("SDL_NumJoysticks", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_NumJoysticks() => pSDL_NumJoysticks();


		[CallingConvention(.Cdecl)]
		private function bool SDL_IsGameControllerDelegate(int32 joystick_index);
		private readonly SDL_IsGameControllerDelegate pSDL_IsGameController = lib.LoadFunction<SDL_IsGameControllerDelegate>("SDL_IsGameController", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_IsGameController(int32 joystick_index) => pSDL_IsGameController(joystick_index);


		[CallingConvention(.Cdecl)]
		private function SDL_GameController* SDL_GameControllerOpenDelegate(int32 index);
		private readonly SDL_GameControllerOpenDelegate pSDL_GameControllerOpen = lib.LoadFunction<SDL_GameControllerOpenDelegate>("SDL_GameControllerOpen", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_GameController* SDL_GameControllerOpen(int32 index) => pSDL_GameControllerOpen(index);


		[CallingConvention(.Cdecl)]
		private function void SDL_GameControllerCloseDelegate(SDL_GameController* gamecontroller);
		private readonly SDL_GameControllerCloseDelegate pSDL_GameControllerClose = lib.LoadFunction<SDL_GameControllerCloseDelegate>("SDL_GameControllerClose", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_GameControllerClose(SDL_GameController* gamecontroller) => pSDL_GameControllerClose(gamecontroller);


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GameControllerNameForIndex_RawDelegate(int32 joystick_index);
		private readonly SDL_GameControllerNameForIndex_RawDelegate pSDL_GameControllerNameForIndex_Raw = lib.LoadFunction<SDL_GameControllerNameForIndex_RawDelegate>("SDL_GameControllerNameForIndex", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GameControllerNameForIndex(int32 joystick_index) => pSDL_GameControllerNameForIndex_Raw(joystick_index);


		[CallingConvention(.Cdecl)]
		private function bool SDL_GameControllerGetButtonDelegate(SDL_GameController* gamecontroller, SDL_GameControllerButton button);
		private readonly SDL_GameControllerGetButtonDelegate pSDL_GameControllerGetButton = lib.LoadFunction<SDL_GameControllerGetButtonDelegate>("SDL_GameControllerGetButton", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_GameControllerGetButton(SDL_GameController* gamecontroller, SDL_GameControllerButton button) => pSDL_GameControllerGetButton(gamecontroller, button);


		[CallingConvention(.Cdecl)]
		private function SDL_Joystick* SDL_GameControllerGetJoystickDelegate(SDL_GameController* gamecontroller);
		private readonly SDL_GameControllerGetJoystickDelegate pSDL_GameControllerGetJoystick = lib.LoadFunction<SDL_GameControllerGetJoystickDelegate>("SDL_GameControllerGetJoystick", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Joystick* SDL_GameControllerGetJoystick(SDL_GameController* gamecontroller) => pSDL_GameControllerGetJoystick(gamecontroller);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_JoystickInstanceIDDelegate(SDL_Joystick* joystick);
		private readonly SDL_JoystickInstanceIDDelegate pSDL_JoystickInstanceID = lib.LoadFunction<SDL_JoystickInstanceIDDelegate>("SDL_JoystickInstanceID", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_JoystickInstanceID(SDL_Joystick* joystick) => pSDL_JoystickInstanceID(joystick);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetNumTouchDevicesDelegate();
		private readonly SDL_GetNumTouchDevicesDelegate pSDL_GetNumTouchDevices = lib.LoadFunction<SDL_GetNumTouchDevicesDelegate>("SDL_GetNumTouchDevices", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetNumTouchDevices() => pSDL_GetNumTouchDevices();


		[CallingConvention(.Cdecl)]
		private function int64 SDL_GetTouchDeviceDelegate(int32 index);
		private readonly SDL_GetTouchDeviceDelegate pSDL_GetTouchDevice = lib.LoadFunction<SDL_GetTouchDeviceDelegate>("SDL_GetTouchDevice", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int64 SDL_GetTouchDevice(int32 index) => pSDL_GetTouchDevice(index);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetNumTouchFingersDelegate(int64 touchID);
		private readonly SDL_GetNumTouchFingersDelegate pSDL_GetNumTouchFingers = lib.LoadFunction<SDL_GetNumTouchFingersDelegate>("SDL_GetNumTouchFingers", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetNumTouchFingers(int64 touchID) => pSDL_GetNumTouchFingers(touchID);


		[CallingConvention(.Cdecl)]
		private delegate SDL_Finger* SDL_GetTouchFingerDelegate(int64 touchID, int32 index);
		private readonly SDL_GetTouchFingerDelegate pSDL_GetTouchFinger = lib.LoadFunction<SDL_GetTouchFingerDelegate>("SDL_GetTouchFinger", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_Finger* SDL_GetTouchFinger(int64 touchID, int32 index) => pSDL_GetTouchFinger(touchID, index);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_RecordGestureDelegate(int64 touchID);
		private readonly SDL_RecordGestureDelegate pSDL_RecordGesture = lib.LoadFunction<SDL_RecordGestureDelegate>("SDL_RecordGesture", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_RecordGesture(int64 touchID) => pSDL_RecordGesture(touchID);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SaveAllDollarTemplatesDelegate(SDL_RWops* dst);
		private readonly SDL_SaveAllDollarTemplatesDelegate pSDL_SaveAllDollarTemplates = lib.LoadFunction<SDL_SaveAllDollarTemplatesDelegate>("SDL_SaveAllDollarTemplates", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SaveAllDollarTemplates(SDL_RWops* dst) => pSDL_SaveAllDollarTemplates(dst);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SaveDollarTemplateDelegate(int64 gestureID, SDL_RWops* dst);
		private readonly SDL_SaveDollarTemplateDelegate pSDL_SaveDollarTemplate = lib.LoadFunction<SDL_SaveDollarTemplateDelegate>("SDL_SaveDollarTemplate", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SaveDollarTemplate(int64 gestureID, SDL_RWops* dst) => pSDL_SaveDollarTemplate(gestureID, dst);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_LoadDollarTemplatesDelegate(int64 touchID, SDL_RWops* src);
		private readonly SDL_LoadDollarTemplatesDelegate pSDL_LoadDollarTemplates = lib.LoadFunction<SDL_LoadDollarTemplatesDelegate>("SDL_LoadDollarTemplates", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_LoadDollarTemplates(int64 touchID, SDL_RWops* src) => pSDL_LoadDollarTemplates(touchID, src);


		[CallingConvention(.Cdecl)]
		private function void SDL_StartTextInputDelegate();
		private readonly SDL_StartTextInputDelegate pSDL_StartTextInput = lib.LoadFunction<SDL_StartTextInputDelegate>("SDL_StartTextInput", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_StartTextInput() => pSDL_StartTextInput();


		[CallingConvention(.Cdecl)]
		private function void SDL_StopTextInputDelegate();
		private readonly SDL_StopTextInputDelegate pSDL_StopTextInput = lib.LoadFunction<SDL_StopTextInputDelegate>("SDL_StopTextInput", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_StopTextInput() => pSDL_StopTextInput();


		[CallingConvention(.Cdecl)]
		private function void SDL_SetTextInputRectDelegate(SDL_Rect* rect);
		private readonly SDL_SetTextInputRectDelegate pSDL_SetTextInputRect = lib.LoadFunction<SDL_SetTextInputRectDelegate>("SDL_SetTextInputRect", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetTextInputRect(SDL_Rect* rect) => pSDL_SetTextInputRect(rect);


		[CallingConvention(.Cdecl)]
		private function bool SDL_HasClipboardTextDelegate();
		private readonly SDL_HasClipboardTextDelegate pSDL_HasClipboardText = lib.LoadFunction<SDL_HasClipboardTextDelegate>("SDL_HasClipboardText", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_HasClipboardText() => pSDL_HasClipboardText();


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GetClipboardTextDelegate();
		private readonly SDL_GetClipboardTextDelegate pSDL_GetClipboardText = lib.LoadFunction<SDL_GetClipboardTextDelegate>("SDL_GetClipboardText", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GetClipboardText() => pSDL_GetClipboardText();


		[CallingConvention(.Cdecl)]
		private function void SDL_SetClipboardTextDelegate(char8* text);
		private readonly SDL_SetClipboardTextDelegate pSDL_SetClipboardText = lib.LoadFunction<SDL_SetClipboardTextDelegate>("SDL_SetClipboardText", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_SetClipboardText(char8* text) => pSDL_SetClipboardText(text);


		[CallingConvention(.Cdecl)]
		private function SDL_PowerState SDL_GetPowerInfoDelegate(int32* secs, int32* pct);
		private readonly SDL_GetPowerInfoDelegate pSDL_GetPowerInfo = lib.LoadFunction<SDL_GetPowerInfoDelegate>("SDL_GetPowerInfo", .. ?, sInvokeErrorCallback);
		[Inline]
		public override SDL_PowerState SDL_GetPowerInfo(int32* secs, int32* pct) => pSDL_GetPowerInfo(secs, pct);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_ShowSimpleMessageBoxDelegate(uint32 flags, char8* title, char8* message, SDL_Window* window);
		private readonly SDL_ShowSimpleMessageBoxDelegate pSDL_ShowSimpleMessageBox = lib.LoadFunction<SDL_ShowSimpleMessageBoxDelegate>("SDL_ShowSimpleMessageBox", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_ShowSimpleMessageBox(uint32 flags, char8* title, char8* message, SDL_Window* window) => pSDL_ShowSimpleMessageBox(flags, title, message, window);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetWindowOpacityDelegate(SDL_Window* window, float opacity);
		private readonly SDL_SetWindowOpacityDelegate pSDL_SetWindowOpacity = lib.LoadFunction<SDL_SetWindowOpacityDelegate>("SDL_SetWindowOpacity", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetWindowOpacity(SDL_Window* window, float opacity) => pSDL_SetWindowOpacity(window, opacity);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetWindowOpacityDelegate(SDL_Window* window, float* opacity);
		private readonly SDL_GetWindowOpacityDelegate pSDL_GetWindowOpacity = lib.LoadFunction<SDL_GetWindowOpacityDelegate>("SDL_GetWindowOpacity", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetWindowOpacity(SDL_Window* window, float* opacity) => pSDL_GetWindowOpacity(window, opacity);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GameControllerAddMappingDelegate(char8* mappingString);
		private readonly SDL_GameControllerAddMappingDelegate pSDL_GameControllerAddMapping = lib.LoadFunction<SDL_GameControllerAddMappingDelegate>("SDL_GameControllerAddMapping", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GameControllerAddMapping(char8* mappingString) => pSDL_GameControllerAddMapping(mappingString);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GameControllerAddMappingsFromRWDelegate(SDL_RWops* rw, int32 freerw);
		private readonly SDL_GameControllerAddMappingsFromRWDelegate pSDL_GameControllerAddMappingsFromRW = lib.LoadFunction<SDL_GameControllerAddMappingsFromRWDelegate>("SDL_GameControllerAddMappingsFromRW", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GameControllerAddMappingsFromRW(SDL_RWops* rw, int32 freerw) => pSDL_GameControllerAddMappingsFromRW(rw, freerw);


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GameControllerMapping_RawDelegate(SDL_GameController* gamecontroller);
		private readonly SDL_GameControllerMapping_RawDelegate pSDL_GameControllerMapping_Raw = lib.LoadFunction<SDL_GameControllerMapping_RawDelegate>("SDL_GameControllerMapping", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GameControllerMapping(SDL_GameController* gamecontroller) => pSDL_GameControllerMapping_Raw(gamecontroller);


		[CallingConvention(.Cdecl)]
		private function char8* SDL_GameControllerMappingForGUID_RawDelegate(Guid guid);
		private readonly SDL_GameControllerMappingForGUID_RawDelegate pSDL_GameControllerMappingForGUID_Raw = lib.LoadFunction<SDL_GameControllerMappingForGUID_RawDelegate>("SDL_GameControllerMappingForGUID", .. ?, sInvokeErrorCallback);
		[Inline]
		public override char8* SDL_GameControllerMappingForGUID(Guid guid) => pSDL_GameControllerMappingForGUID_Raw(guid);

		// todo: verify
		[CallingConvention(.Cdecl)]
		private function Guid SDL_JoystickGetGUIDDelegate(SDL_Joystick* joystick);
		private readonly SDL_JoystickGetGUIDDelegate pSDL_JoystickGetGUID = lib.LoadFunction<SDL_JoystickGetGUIDDelegate>("SDL_JoystickGetGUID", .. ?, sInvokeErrorCallback);
		[Inline]
		public override Guid SDL_JoystickGetGUID(SDL_Joystick* joystick) => pSDL_JoystickGetGUID(joystick);


		[CallingConvention(.Cdecl)]
		private function int32 SDL_GetDisplayDPIDelegate(int32 displayIndex, float* ddpi, float* hdpi, float* vdpi);
		private readonly SDL_GetDisplayDPIDelegate pSDL_GetDisplayDPI = lib.LoadFunction<SDL_GetDisplayDPIDelegate>("SDL_GetDisplayDPI", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_GetDisplayDPI(int32 displayIndex, float* ddpi, float* hdpi, float* vdpi) => pSDL_GetDisplayDPI(displayIndex, ddpi, hdpi, vdpi);


		[CallingConvention(.Cdecl)]
		private function void SDL_freeDelegate(void* mem);
		private readonly SDL_freeDelegate pSDL_free = lib.LoadFunction<SDL_freeDelegate>("SDL_free", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_free(void* mem) => pSDL_free(mem);


		[CallingConvention(.Cdecl)]
		private function bool SDL_GetRelativeMouseModeDelegate();
		private readonly SDL_GetRelativeMouseModeDelegate pSDL_GetRelativeMouseMode = lib.LoadFunction<SDL_GetRelativeMouseModeDelegate>("SDL_GetRelativeMouseMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override bool SDL_GetRelativeMouseMode() => pSDL_GetRelativeMouseMode();


		[CallingConvention(.Cdecl)]
		private function int32 SDL_SetRelativeMouseModeDelegate(bool enabled);
		private readonly SDL_SetRelativeMouseModeDelegate pSDL_SetRelativeMouseMode = lib.LoadFunction<SDL_SetRelativeMouseModeDelegate>("SDL_SetRelativeMouseMode", .. ?, sInvokeErrorCallback);
		[Inline]
		public override int32 SDL_SetRelativeMouseMode(bool enabled) => pSDL_SetRelativeMouseMode(enabled);


		[CallingConvention(.Cdecl)]
		private function void SDL_WarpMouseInWindowDelegate(SDL_Window* window, int32 x, int32 y);
		private readonly SDL_WarpMouseInWindowDelegate pSDL_WarpMouseInWindow = lib.LoadFunction<SDL_WarpMouseInWindowDelegate>("SDL_WarpMouseInWindow", .. ?, sInvokeErrorCallback);
		[Inline]
		public override void SDL_WarpMouseInWindow(SDL_Window* window, int32 x, int32 y) => pSDL_WarpMouseInWindow(window, x, y);
	}
}
