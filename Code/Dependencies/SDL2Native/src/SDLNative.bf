using System;
namespace SDL2Native
{
	using internal SDL2Native;

	static class SDL2Native
	{
		private static readonly SDL2NativeImpl impl;

		static this()
		{
			switch (Environment.OSVersion.Platform)
			{
			/*case .Android:
					impl = new SDL2NativeImpl_Android();
				break;*/
			default:
				impl = new SDL2NativeImpl_Default();
				break;
			}
		}

		static ~this()
		{
			if (impl != null)
				delete impl;
		}

		public const int32 SDL_QUERY = -1;
		public const int32 SDL_DISABLE = 0;
		public const int32 SDL_ENABLE = 1;

		[Inline]
		public static void SDL_GetVersion(SDL_version* version) => impl.SDL_GetVersion(version);

		[Inline]
		public static char8* SDL_GetError() => impl.SDL_GetError();

		[Inline]
		public static void SDL_ClearError() => impl.SDL_ClearError();

		[Inline]
		public static int32 SDL_Init(SDL_Init_Flags flags) => impl.SDL_Init(flags);

		[Inline]
		public static void SDL_Quit() => impl.SDL_Quit();

		[Inline]
		public static void SDL_PumpEvents() => impl.SDL_PumpEvents();

		[Inline]
		public static int32 SDL_PollEvent(out SDL_Event event) => impl.SDL_PollEvent(out event);

		[Inline]
		public static void SDL_SetEventFilter(SDL_EventFilter filter, void* userdata) => impl.SDL_SetEventFilter(filter, userdata);

		[Inline]
		public static SDL_Window* SDL_CreateWindow(char8* title, int32 x, int32 y, int32 w, int32 h, SDL_WindowFlags flags) => impl.SDL_CreateWindow(title, x, y, w, h, flags);

		[Inline]
		public static SDL_Window* SDL_CreateWindowFrom(void* data) => impl.SDL_CreateWindowFrom(data);

		[Inline]
		public static void SDL_DestroyWindow(SDL_Window* window) => impl.SDL_DestroyWindow(window);

		[Inline]
		public static uint32 SDL_GetWindowID(SDL_Window* window) => impl.SDL_GetWindowID(window);

		[Inline]
		public static char8* SDL_GetWindowTitle(SDL_Window* window) => impl.SDL_GetWindowTitle(window);

		[Inline]
		public static void SDL_SetWindowTitle(SDL_Window* window, char8* title) => impl.SDL_SetWindowTitle(window, title);

		[Inline]
		public static void SDL_SetWindowIcon(SDL_Window* window, SDL_Surface* icon) => impl.SDL_SetWindowIcon(window, icon);

		[Inline]
		public static void SDL_GetWindowPosition(SDL_Window* window, out int32 x, out int32 y) => impl.SDL_GetWindowPosition(window, out x, out y);

		[Inline]
		public static void SDL_SetWindowPosition(SDL_Window* window, int32 x, int32 y) => impl.SDL_SetWindowPosition(window, x, y);

		[Inline]
		public static void SDL_GetWindowSize(SDL_Window* window, out int32 w, out int32 h) => impl.SDL_GetWindowSize(window, out w, out h);

		[Inline]
		public static void SDL_SetWindowSize(SDL_Window* window, int32 w, int32 h) => impl.SDL_SetWindowSize(window, w, h);

		[Inline]
		public static void SDL_GetWindowMinimumSize(SDL_Window* window, out int32 w, out int32 h) => impl.SDL_GetWindowMinimumSize(window, out w, out h);

		[Inline]
		public static void SDL_SetWindowMinimumSize(SDL_Window* window, int32 w, int32 h) => impl.SDL_SetWindowMinimumSize(window, w, h);

		[Inline]
		public static void SDL_GetWindowMaximumSize(SDL_Window* window, out int32 w, out int32 h) => impl.SDL_GetWindowMaximumSize(window, out w, out h);

		[Inline]
		public static void SDL_SetWindowMaximumSize(SDL_Window* window, int32 w, int32 h) => impl.SDL_SetWindowMaximumSize(window, w, h);

		[Inline]
		public static bool SDL_GetWindowGrab(SDL_Window* window) => impl.SDL_GetWindowGrab(window);

		[Inline]
		public static void SDL_SetWindowGrab(SDL_Window* window, bool grabbed) => impl.SDL_SetWindowGrab(window, grabbed);

		[Inline]
		public static int32 SDL_SetWindowBordered(SDL_Window* window, bool bordered) => impl.SDL_SetWindowBordered(window, bordered);

		[Inline]
		public static int32 SDL_SetWindowFullscreen(SDL_Window* window, uint32 flags) => impl.SDL_SetWindowFullscreen(window, flags);

		[Inline]
		public static int32 SDL_SetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => impl.SDL_SetWindowDisplayMode(window, mode);

		[Inline]
		public static int32 SDL_GetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => impl.SDL_GetWindowDisplayMode(window, mode);

		[Inline]
		public static int32 SDL_GetWindowDisplayIndex(SDL_Window* window) => impl.SDL_GetWindowDisplayIndex(window);

		[Inline]
		public static SDL_WindowFlags SDL_GetWindowFlags(SDL_Window* window) => impl.SDL_GetWindowFlags(window);

		[Inline]
		public static void SDL_ShowWindow(SDL_Window* window) => impl.SDL_ShowWindow(window);

		[Inline]
		public static void SDL_HideWindow(SDL_Window* window) => impl.SDL_HideWindow(window);

		[Inline]
		public static void SDL_MaximizeWindow(SDL_Window* window) => impl.SDL_MaximizeWindow(window);

		[Inline]
		public static void SDL_MinimizeWindow(SDL_Window* window) => impl.SDL_MinimizeWindow(window);

		[Inline]
		public static void SDL_RestoreWindow(SDL_Window* window) => impl.SDL_RestoreWindow(window);

		[Inline]
		public static bool SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* info) => impl.SDL_GetWindowWMInfo(window, info);

		[Inline]
		public static SDL_RWops* SDL_RWFromFile(char8* file, char8* mode) => impl.SDL_RWFromFile(file, mode);

		[Inline]
		public static SDL_RWops* SDL_RWFromMem(void* mem, int32 size) => impl.SDL_RWFromMem(mem, size);

		[Inline]
		public static SDL_RWops* SDL_AllocRW() => impl.SDL_AllocRW();

		[Inline]
		public static void SDL_FreeRW(SDL_RWops* area) => impl.SDL_FreeRW(area);

		[Inline]
		public static SDL_Surface* SDL_LoadBMP_RW(SDL_RWops* src, int32 freesrc) => impl.SDL_LoadBMP_RW(src, freesrc);

		[Inline]
		public static int32 SDL_SaveBMP_RW(SDL_Surface* surface, SDL_RWops* dst, int32 freedst) => impl.SDL_SaveBMP_RW(surface, dst, freedst);

		[Inline]
		public static uint32 SDL_GetMouseState(out int32 x, out int32 y) => impl.SDL_GetMouseState(out x, out y);

		[Inline]
		public static uint8* SDL_GetKeyboardState(out int32 numkeys) => impl.SDL_GetKeyboardState(out numkeys);

		[Inline]
		public static SDL_Scancode SDL_GetScancodeFromKey(SDL_Keycode keycode) => impl.SDL_GetScancodeFromKey(keycode);

		[Inline]
		public static SDL_Keymod SDL_GetModState() => impl.SDL_GetModState();

		[Inline]
		public static bool SDL_SetHint(char8* name, char8* value) => impl.SDL_SetHint(name, value);

		[Inline]
		public static SDL_Surface* SDL_CreateRGBSurface(uint32 flags, int32 width, int32 height, int32 depth, uint32 Rmask, uint32 Gmask, uint32 Bmask, uint32 AMask) => impl.SDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, AMask);

		[Inline]
		public static void SDL_FreeSurface(SDL_Surface* surface) => impl.SDL_FreeSurface(surface);

		[Inline]
		public static int32 SDL_LockSurface(SDL_Surface* surface) => impl.SDL_LockSurface(surface);

		[Inline]
		public static void SDL_UnlockSurface(SDL_Surface* surface) => impl.SDL_UnlockSurface(surface);

		[Inline]
		public static int32 SDL_BlitSurface(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => impl.SDL_BlitSurface(src, srcrect, dst, dstrect);

		[Inline]
		public static int32 SDL_BlitScaled(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => impl.SDL_BlitScaled(src, srcrect, dst, dstrect);

		[Inline]
		public static int32 SDL_SetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode blendMode) => impl.SDL_SetSurfaceBlendMode(surface, blendMode);

		[Inline]
		public static int32 SDL_GetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode* blendMode) => impl.SDL_GetSurfaceBlendMode(surface, blendMode);

		[Inline]
		public static int32 SDL_FillRect(SDL_Surface* surface, SDL_Rect* rect, uint32 color) => impl.SDL_FillRect(surface, rect, color);

		[Inline]
		public static int32 SDL_FillRects(SDL_Surface* dst, SDL_Rect* rects, int32 count, uint32 colors) => impl.SDL_FillRects(dst, rects, count, colors);

		[Inline]
		public static SDL_Cursor* SDL_CreateColorCursor(SDL_Surface* surface, int32 hot_x, int32 hot_y) => impl.SDL_CreateColorCursor(surface, hot_x, hot_y);

		[Inline]
		public static void SDL_FreeCursor(SDL_Cursor* cursor) => impl.SDL_FreeCursor(cursor);

		[Inline]
		public static int32 SDL_ShowCursor(int32 toggle) => impl.SDL_ShowCursor(toggle);

		[Inline]
		public static SDL_Cursor* SDL_GetCursor() => impl.SDL_GetCursor();

		[Inline]
		public static void SDL_SetCursor(SDL_Cursor* cursor) => impl.SDL_SetCursor(cursor);

		[Inline]
		public static SDL_Cursor* SDL_GetDefaultCursor() => impl.SDL_GetDefaultCursor();

		[Inline]
		public static int32 SDL_GetNumVideoDisplays() => impl.SDL_GetNumVideoDisplays();

		[Inline]
		public static char8* SDL_GetDisplayName(int32 displayIndex) => impl.SDL_GetDisplayName(displayIndex);

		[Inline]
		public static int32 SDL_GetDisplayBounds(int32 displayIndex, SDL_Rect* rect) => impl.SDL_GetDisplayBounds(displayIndex, rect);

		[Inline]
		public static int32 SDL_GetNumDisplayModes(int32 displayIndex) => impl.SDL_GetNumDisplayModes(displayIndex);

		[Inline]
		public static int32 SDL_GetDisplayMode(int32 displayIndex, int32 modeIndex, SDL_DisplayMode* mode) => impl.SDL_GetDisplayMode(displayIndex, modeIndex, mode);

		[Inline]
		public static int32 SDL_GetCurrentDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => impl.SDL_GetCurrentDisplayMode(displayIndex, mode);

		[Inline]
		public static int32 SDL_GetDesktopDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => impl.SDL_GetDesktopDisplayMode(displayIndex, mode);

		[Inline]
		public static SDL_DisplayMode* SDL_GetClosestDisplayMode(int32 displayIndex, SDL_DisplayMode* mode, SDL_DisplayMode* closest) => impl.SDL_GetClosestDisplayMode(displayIndex, mode, closest);

		[Inline]
		public static bool SDL_PixelFormatEnumToMasks(uint32 format, int32* bpp, uint32* Rmask, uint32* Gmask, uint32* Bmask, uint32* Amask) => impl.SDL_PixelFormatEnumToMasks(format, bpp, Rmask, Gmask, Bmask, Amask);

		[Inline]
		public static void* SDL_GL_GetProcAddress(char8* proc) => impl.SDL_GL_GetProcAddress(proc);

		[Inline]
		public static SDL_GLContext* SDL_GL_CreateContext(SDL_Window* window) => impl.SDL_GL_CreateContext(window);

		[Inline]
		public static void SDL_GL_DeleteContext(SDL_GLContext* context) => impl.SDL_GL_DeleteContext(context);

		[Inline]
		public static SDL_GLContext* SDL_GL_GetCurrentContext() => impl.SDL_GL_GetCurrentContext();

		[Inline]
		public static int32 SDL_GL_MakeCurrent(SDL_Window* window, SDL_GLContext* context) => impl.SDL_GL_MakeCurrent(window, context);

		[Inline]
		public static int32 SDL_GL_SetAttribute(SDL_GLattr attr, int32 value) => impl.SDL_GL_SetAttribute(attr, value);

		[Inline]
		public static int32 SDL_GL_GetAttribute(SDL_GLattr attr, int32* value) => impl.SDL_GL_GetAttribute(attr, value);

		[Inline]
		public static void SDL_GL_SwapWindow(SDL_Window* window) => impl.SDL_GL_SwapWindow(window);

		[Inline]
		public static int32 SDL_GL_SetSwapInterval(int32 interval) => impl.SDL_GL_SetSwapInterval(interval);

		[Inline]
		public static void SDL_GL_GetDrawableSize(SDL_Window* window, out int32 w, out int32 h) => impl.SDL_GL_GetDrawableSize(window, out w, out h);

		[Inline]
		public static int32 SDL_NumJoysticks() => impl.SDL_NumJoysticks();

		[Inline]
		public static bool SDL_IsGameController(int32 joystick_index) => impl.SDL_IsGameController(joystick_index);

		[Inline]
		public static SDL_GameController* SDL_GameControllerOpen(int32 index) => impl.SDL_GameControllerOpen(index);

		[Inline]
		public static void SDL_GameControllerClose(SDL_GameController* gamecontroller) => impl.SDL_GameControllerClose(gamecontroller);

		[Inline]
		public static char8* SDL_GameControllerNameForIndex(int32 joystick_index) => impl.SDL_GameControllerNameForIndex(joystick_index);

		[Inline]
		public static bool SDL_GameControllerGetButton(SDL_GameController* gamecontroller, SDL_GameControllerButton button) => impl.SDL_GameControllerGetButton(gamecontroller, button);

		[Inline]
		public static SDL_Joystick* SDL_GameControllerGetJoystick(SDL_GameController* gamecontroller) => impl.SDL_GameControllerGetJoystick(gamecontroller);

		[Inline]
		public static int32 SDL_JoystickInstanceID(SDL_Joystick* joystick) => impl.SDL_JoystickInstanceID(joystick);

		[Inline]
		public static int32 SDL_GetNumTouchDevices() => impl.SDL_GetNumTouchDevices();

		[Inline]
		public static int64 SDL_GetTouchDevice(int32 index) => impl.SDL_GetTouchDevice(index);

		[Inline]
		public static int32 SDL_GetNumTouchFingers(int64 touchID) => impl.SDL_GetNumTouchFingers(touchID);

		[Inline]
		public static SDL_Finger* SDL_GetTouchFinger(int64 touchID, int32 index) => impl.SDL_GetTouchFinger(touchID, index);

		[Inline]
		public static int32 SDL_RecordGesture(int64 touchID) => impl.SDL_RecordGesture(touchID);

		[Inline]
		public static int32 SDL_SaveAllDollarTemplates(SDL_RWops* dst) => impl.SDL_SaveAllDollarTemplates(dst);

		[Inline]
		public static int32 SDL_SaveDollarTemplate(int64 gestureID, SDL_RWops* dst) => impl.SDL_SaveDollarTemplate(gestureID, dst);

		[Inline]
		public static int32 SDL_LoadDollarTemplates(int64 touchID, SDL_RWops* src) => impl.SDL_LoadDollarTemplates(touchID, src);

		[Inline]
		public static void SDL_StartTextInput() => impl.SDL_StartTextInput();

		[Inline]
		public static void SDL_StopTextInput() => impl.SDL_StopTextInput();

		[Inline]
		public static void SDL_SetTextInputRect(SDL_Rect* rect) => impl.SDL_SetTextInputRect(rect);

		[Inline]
		public static bool SDL_HasClipboardText() => impl.SDL_HasClipboardText();

		[Inline]
		public static char8* SDL_GetClipboardText() => impl.SDL_GetClipboardText();

		[Inline]
		public static void SDL_SetClipboardText(char8* text) => impl.SDL_SetClipboardText(text);

		[Inline]
		public static SDL_PowerState SDL_GetPowerInfo(int32* secs, int32* pct) => impl.SDL_GetPowerInfo(secs, pct);

		[Inline]
		public static int32 SDL_ShowSimpleMessageBox(uint32 flags, char8* title, char8* message, SDL_Window* window) => impl.SDL_ShowSimpleMessageBox(flags, title, message, window);

		[Inline]
		public static int32 SDL_SetWindowOpacity(SDL_Window* window, float opacity) => impl.SDL_SetWindowOpacity(window, opacity);

		[Inline]
		public static int32 SDL_GetWindowOpacity(SDL_Window* window, float* opacity) => impl.SDL_GetWindowOpacity(window, opacity);

		[Inline]
		public static int32 SDL_GameControllerAddMapping(char8* mappingString) => impl.SDL_GameControllerAddMapping(mappingString);

		[Inline]
		public static int32 SDL_GameControllerAddMappingsFromRW(SDL_RWops* rw, int32 freerw) => impl.SDL_GameControllerAddMappingsFromRW(rw, freerw);

		[Inline]
		public static char8* SDL_GameControllerMapping(SDL_GameController* gamecontroller) => impl.SDL_GameControllerMapping(gamecontroller);

		[Inline]
		public static char8* SDL_GameControllerMappingForGUID(Guid guid) => impl.SDL_GameControllerMappingForGUID(guid);

		[Inline]
		public static Guid SDL_JoystickGetGUID(SDL_Joystick* joystick) => impl.SDL_JoystickGetGUID(joystick);

		[Inline]
		public static int32 SDL_GetDisplayDPI(int32 displayIndex, float* ddpi, float* hdpi, float* vdpi) => impl.SDL_GetDisplayDPI(displayIndex, ddpi, hdpi, vdpi);

		[Inline]
		public static void SDL_free(void* mem) => impl.SDL_free(mem);

		[Inline]
		public static bool SDL_GetRelativeMouseMode() => impl.SDL_GetRelativeMouseMode();

		[Inline]
		public static int32 SDL_SetRelativeMouseMode(bool enabled) => impl.SDL_SetRelativeMouseMode(enabled);

		[Inline]
		public static void SDL_WarpMouseInWindow(SDL_Window* window, int32 x, int32 y) => impl.SDL_WarpMouseInWindow(window, x, y);
	}
}
