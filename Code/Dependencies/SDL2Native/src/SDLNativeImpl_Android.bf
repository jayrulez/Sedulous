using System;
using System.Security;

namespace SDL2Native
{
    internal sealed class SDL2NativeImpl_Android : SDL2NativeImpl
    {
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetError")]
        private static extern char8* INTERNAL_SDL_GetError();
        [Inline]
        private char8* SDL_GetError_Raw() => INTERNAL_SDL_GetError();
        [Inline]
        public override char8* SDL_GetError() => SDL_GetError_Raw();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_ClearError")]
        private static extern void INTERNAL_SDL_ClearError();
        [Inline]
        public override void SDL_ClearError() => INTERNAL_SDL_ClearError();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_Init")]
        private static extern int32 INTERNAL_SDL_Init(SDL_Init_Flags flags);
        [Inline]
        public override int32 SDL_Init(SDL_Init_Flags flags) => INTERNAL_SDL_Init(flags);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_Quit")]
        private static extern void INTERNAL_SDL_Quit();
        [Inline]
        public override void SDL_Quit() => INTERNAL_SDL_Quit();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_PumpEvents")]
        private static extern void INTERNAL_SDL_PumpEvents();
        [Inline]
        public override void SDL_PumpEvents() => INTERNAL_SDL_PumpEvents();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_PollEvent")]
        private static extern int32 INTERNAL_SDL_PollEvent(out SDL_Event event);
        [Inline]
        public override int32 SDL_PollEvent(out SDL_Event event) => INTERNAL_SDL_PollEvent(out event);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetEventFilter")]
        private static extern void INTERNAL_SDL_SetEventFilter(SDL_EventFilter filter, void* userdata);
        [Inline]
        public override void SDL_SetEventFilter(SDL_EventFilter filter, void* userdata) => INTERNAL_SDL_SetEventFilter(filter, userdata);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_CreateWindow")]
        private static extern SDL_Window* INTERNAL_SDL_CreateWindow(char8* title, int32 x, int32 y, int32 w, int32 h, SDL_WindowFlags flags);
        [Inline]
        public override SDL_Window* SDL_CreateWindow(char8* title, int32 x, int32 y, int32 w, int32 h, SDL_WindowFlags flags) => INTERNAL_SDL_CreateWindow(title, x, y, w, h, flags);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_CreateWindowFrom")]
        private static extern SDL_Window* INTERNAL_SDL_CreateWindowFrom(void* data);
        [Inline]
        public override SDL_Window* SDL_CreateWindowFrom(void* data) => INTERNAL_SDL_CreateWindowFrom(data);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_DestroyWindow")]
        private static extern void INTERNAL_SDL_DestroyWindow(SDL_Window* window);
        [Inline]
        public override void SDL_DestroyWindow(SDL_Window* window) => INTERNAL_SDL_DestroyWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowID")]
        private static extern uint32 INTERNAL_SDL_GetWindowID(SDL_Window* window);
        [Inline]
        public override uint32 SDL_GetWindowID(SDL_Window* window) => INTERNAL_SDL_GetWindowID(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowTitle")]
        private static extern char8* INTERNAL_SDL_GetWindowTitle(SDL_Window* window);
        [Inline]
        private char8* SDL_GetWindowTitle_Raw(SDL_Window* window) => INTERNAL_SDL_GetWindowTitle(window);
        [Inline]
        public override char8* SDL_GetWindowTitle(SDL_Window* window) => SDL_GetWindowTitle_Raw(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowTitle")]
        private static extern void INTERNAL_SDL_SetWindowTitle(SDL_Window* window, char8* title);
        [Inline]
        public override void SDL_SetWindowTitle(SDL_Window* window, char8* title) => INTERNAL_SDL_SetWindowTitle(window, title);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowIcon")]
        private static extern void INTERNAL_SDL_SetWindowIcon(SDL_Window* window, SDL_Surface* icon);
        [Inline]
        public override void SDL_SetWindowIcon(SDL_Window* window, SDL_Surface* icon) => INTERNAL_SDL_SetWindowIcon(window, icon);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowPosition")]
        private static extern void INTERNAL_SDL_GetWindowPosition(SDL_Window* window, out int32 x, out int32 y);
        [Inline]
        public override void SDL_GetWindowPosition(SDL_Window* window, out int32 x, out int32 y) => INTERNAL_SDL_GetWindowPosition(window, out x, out y);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowPosition")]
        private static extern void INTERNAL_SDL_SetWindowPosition(SDL_Window* window, int32 x, int32 y);
        [Inline]
        public override void SDL_SetWindowPosition(SDL_Window* window, int32 x, int32 y) => INTERNAL_SDL_SetWindowPosition(window, x, y);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowSize")]
        private static extern void INTERNAL_SDL_GetWindowSize(SDL_Window* window, out int32 w, out int32 h);
        [Inline]
        public override void SDL_GetWindowSize(SDL_Window* window, out int32 w, out int32 h) => INTERNAL_SDL_GetWindowSize(window, out w, out h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowSize")]
        private static extern void INTERNAL_SDL_SetWindowSize(SDL_Window* window, int32 w, int32 h);
        [Inline]
        public override void SDL_SetWindowSize(SDL_Window* window, int32 w, int32 h) => INTERNAL_SDL_SetWindowSize(window, w, h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowMinimumSize")]
        private static extern void INTERNAL_SDL_GetWindowMinimumSize(SDL_Window* window, out int32 w, out int32 h);
        [Inline]
        public override void SDL_GetWindowMinimumSize(SDL_Window* window, out int32 w, out int32 h) => INTERNAL_SDL_GetWindowMinimumSize(window, out w, out h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowMinimumSize")]
        private static extern void INTERNAL_SDL_SetWindowMinimumSize(SDL_Window* window, int32 w, int32 h);
        [Inline]
        public override void SDL_SetWindowMinimumSize(SDL_Window* window, int32 w, int32 h) => INTERNAL_SDL_SetWindowMinimumSize(window, w, h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowMaximumSize")]
        private static extern void INTERNAL_SDL_GetWindowMaximumSize(SDL_Window* window, out int32 w, out int32 h);
        [Inline]
        public override void SDL_GetWindowMaximumSize(SDL_Window* window, out int32 w, out int32 h) => INTERNAL_SDL_GetWindowMaximumSize(window, out w, out h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowMaximumSize")]
        private static extern void INTERNAL_SDL_SetWindowMaximumSize(SDL_Window* window, int32 w, int32 h);
        [Inline]
        public override void SDL_SetWindowMaximumSize(SDL_Window* window, int32 w, int32 h) => INTERNAL_SDL_SetWindowMaximumSize(window, w, h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowGrab")]
        private static extern bool INTERNAL_SDL_GetWindowGrab(SDL_Window* window);
        [Inline]
        public override bool SDL_GetWindowGrab(SDL_Window* window) => INTERNAL_SDL_GetWindowGrab(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowGrab")]
        private static extern void INTERNAL_SDL_SetWindowGrab(SDL_Window* window, bool grabbed);
        [Inline]
        public override void SDL_SetWindowGrab(SDL_Window* window, bool grabbed) => INTERNAL_SDL_SetWindowGrab(window, grabbed);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowBordered")]
        private static extern int32 INTERNAL_SDL_SetWindowBordered(SDL_Window* window, bool bordered);
        [Inline]
        public override int32 SDL_SetWindowBordered(SDL_Window* window, bool bordered) => INTERNAL_SDL_SetWindowBordered(window, bordered);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowFullscreen")]
        private static extern int32 INTERNAL_SDL_SetWindowFullscreen(SDL_Window* window, uint32 flags);
        [Inline]
        public override int32 SDL_SetWindowFullscreen(SDL_Window* window, uint32 flags) => INTERNAL_SDL_SetWindowFullscreen(window, flags);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowDisplayMode")]
        private static extern int32 INTERNAL_SDL_SetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode);
        [Inline]
        public override int32 SDL_SetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => INTERNAL_SDL_SetWindowDisplayMode(window, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowDisplayMode")]
        private static extern int32 INTERNAL_SDL_GetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode);
        [Inline]
        public override int32 SDL_GetWindowDisplayMode(SDL_Window* window, SDL_DisplayMode* mode) => INTERNAL_SDL_GetWindowDisplayMode(window, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowDisplayIndex")]
        private static extern int32 INTERNAL_SDL_GetWindowDisplayIndex(SDL_Window* window);
        [Inline]
        public override int32 SDL_GetWindowDisplayIndex(SDL_Window* window) => INTERNAL_SDL_GetWindowDisplayIndex(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowFlags")]
        private static extern SDL_WindowFlags INTERNAL_SDL_GetWindowFlags(SDL_Window* window);
        [Inline]
        public override SDL_WindowFlags SDL_GetWindowFlags(SDL_Window* window) => INTERNAL_SDL_GetWindowFlags(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_ShowWindow")]
        private static extern void INTERNAL_SDL_ShowWindow(SDL_Window* window);
        [Inline]
        public override void SDL_ShowWindow(SDL_Window* window) => INTERNAL_SDL_ShowWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_HideWindow")]
        private static extern void INTERNAL_SDL_HideWindow(SDL_Window* window);
        [Inline]
        public override void SDL_HideWindow(SDL_Window* window) => INTERNAL_SDL_HideWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_MaximizeWindow")]
        private static extern void INTERNAL_SDL_MaximizeWindow(SDL_Window* window);
        [Inline]
        public override void SDL_MaximizeWindow(SDL_Window* window) => INTERNAL_SDL_MaximizeWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_MinimizeWindow")]
        private static extern void INTERNAL_SDL_MinimizeWindow(SDL_Window* window);
        [Inline]
        public override void SDL_MinimizeWindow(SDL_Window* window) => INTERNAL_SDL_MinimizeWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_RestoreWindow")]
        private static extern void INTERNAL_SDL_RestoreWindow(SDL_Window* window);
        [Inline]
        public override void SDL_RestoreWindow(SDL_Window* window) => INTERNAL_SDL_RestoreWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowWMInfo")]
        private static extern bool INTERNAL_SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* info);
        [Inline]
        public override bool SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* info) => INTERNAL_SDL_GetWindowWMInfo(window, info);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_RWFromFile")]
        private static extern SDL_RWops* INTERNAL_SDL_RWFromFile(char8* file, char8* mode);
        [Inline]
        public override SDL_RWops* SDL_RWFromFile(char8* file, char8* mode) => INTERNAL_SDL_RWFromFile(file, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_RWFromMem")]
        private static extern SDL_RWops* INTERNAL_SDL_RWFromMem(void* mem, int32 size);
        [Inline]
        public override SDL_RWops* SDL_RWFromMem(void* mem, int32 size) => INTERNAL_SDL_RWFromMem(mem, size);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_AllocRW")]
        private static extern SDL_RWops* INTERNAL_SDL_AllocRW();
        [Inline]
        public override SDL_RWops* SDL_AllocRW() => INTERNAL_SDL_AllocRW();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_FreeRW")]
        private static extern void INTERNAL_SDL_FreeRW(SDL_RWops* area);
        [Inline]
        public override void SDL_FreeRW(SDL_RWops* area) => INTERNAL_SDL_FreeRW(area);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_LoadBMP_RW")]
        private static extern SDL_Surface* INTERNAL_SDL_LoadBMP_RW(SDL_RWops* src, int32 freesrc);
        [Inline]
        public override SDL_Surface* SDL_LoadBMP_RW(SDL_RWops* src, int32 freesrc) => INTERNAL_SDL_LoadBMP_RW(src, freesrc);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SaveBMP_RW")]
        private static extern int32 INTERNAL_SDL_SaveBMP_RW(SDL_Surface* surface, SDL_RWops* dst, int32 freedst);
        [Inline]
        public override int32 SDL_SaveBMP_RW(SDL_Surface* surface, SDL_RWops* dst, int32 freedst) => INTERNAL_SDL_SaveBMP_RW(surface, dst, freedst);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetMouseState")]
        private static extern uint32 INTERNAL_SDL_GetMouseState(out int32 x, out int32 y);
        [Inline]
        public override uint32 SDL_GetMouseState(out int32 x, out int32 y) => INTERNAL_SDL_GetMouseState(out x, out y);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetKeyboardState")]
        private static extern uint8* INTERNAL_SDL_GetKeyboardState(out int32 numkeys);
        [Inline]
        public override uint8* SDL_GetKeyboardState(out int32 numkeys) => INTERNAL_SDL_GetKeyboardState(out numkeys);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetScancodeFromKey")]
        private static extern SDL_Scancode INTERNAL_SDL_GetScancodeFromKey(SDL_Keycode keycode);
        [Inline]
        public override SDL_Scancode SDL_GetScancodeFromKey(SDL_Keycode keycode) => INTERNAL_SDL_GetScancodeFromKey(keycode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetModState")]
        private static extern SDL_Keymod INTERNAL_SDL_GetModState();
        [Inline]
        public override SDL_Keymod SDL_GetModState() => INTERNAL_SDL_GetModState();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetHint")]
        private static extern bool INTERNAL_SDL_SetHint(char8* name, char8* value);
        [Inline]
        public override bool SDL_SetHint(char8* name, char8* value) => INTERNAL_SDL_SetHint(name, value);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_CreateRGBSurface")]
        private static extern SDL_Surface* INTERNAL_SDL_CreateRGBSurface(uint32 flags, int32 width, int32 height, int32 depth, uint32 Rmask, uint32 Gmask, uint32 Bmask, uint32 AMask);
        [Inline]
        public override SDL_Surface* SDL_CreateRGBSurface(uint32 flags, int32 width, int32 height, int32 depth, uint32 Rmask, uint32 Gmask, uint32 Bmask, uint32 AMask) => INTERNAL_SDL_CreateRGBSurface(flags, width, height, depth, Rmask, Gmask, Bmask, AMask);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_FreeSurface")]
        private static extern void INTERNAL_SDL_FreeSurface(SDL_Surface* surface);
        [Inline]
        public override void SDL_FreeSurface(SDL_Surface* surface) => INTERNAL_SDL_FreeSurface(surface);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_LockSurface")]
        private static extern int32 INTERNAL_SDL_LockSurface(SDL_Surface* surface);
        [Inline]
        public override int32 SDL_LockSurface(SDL_Surface* surface) => INTERNAL_SDL_LockSurface(surface);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_UnlockSurface")]
        private static extern void INTERNAL_SDL_UnlockSurface(SDL_Surface* surface);
        [Inline]
        public override void SDL_UnlockSurface(SDL_Surface* surface) => INTERNAL_SDL_UnlockSurface(surface);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_UpperBlit")]
        private static extern int32 INTERNAL_SDL_BlitSurface(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect);
        [Inline]
        public override int32 SDL_BlitSurface(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => INTERNAL_SDL_BlitSurface(src, srcrect, dst, dstrect);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_UpperBlitScaled")]
        private static extern int32 INTERNAL_SDL_BlitScaled(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect);
        [Inline]
        public override int32 SDL_BlitScaled(SDL_Surface* src, SDL_Rect* srcrect, SDL_Surface* dst, SDL_Rect* dstrect) => INTERNAL_SDL_BlitScaled(src, srcrect, dst, dstrect);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetSurfaceBlendMode")]
        private static extern int32 INTERNAL_SDL_SetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode blendMode);
        [Inline]
        public override int32 SDL_SetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode blendMode) => INTERNAL_SDL_SetSurfaceBlendMode(surface, blendMode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetSurfaceBlendMode")]
        private static extern int32 INTERNAL_SDL_GetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode* blendMode);
        [Inline]
        public override int32 SDL_GetSurfaceBlendMode(SDL_Surface* surface, SDL_BlendMode* blendMode) => INTERNAL_SDL_GetSurfaceBlendMode(surface, blendMode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_FillRect")]
        private static extern int32 INTERNAL_SDL_FillRect(SDL_Surface* surface, SDL_Rect* rect, uint32 color);
        [Inline]
        public override int32 SDL_FillRect(SDL_Surface* surface, SDL_Rect* rect, uint32 color) => INTERNAL_SDL_FillRect(surface, rect, color);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_FillRects")]
        private static extern int32 INTERNAL_SDL_FillRects(SDL_Surface* dst, SDL_Rect* rects, int32 count, uint32 colors);
        [Inline]
        public override int32 SDL_FillRects(SDL_Surface* dst, SDL_Rect* rects, int32 count, uint32 colors) => INTERNAL_SDL_FillRects(dst, rects, count, colors);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_CreateColorCursor")]
        private static extern SDL_Cursor* INTERNAL_SDL_CreateColorCursor(SDL_Surface* surface, int32 hot_x, int32 hot_y);
        [Inline]
        public override SDL_Cursor* SDL_CreateColorCursor(SDL_Surface* surface, int32 hot_x, int32 hot_y) => INTERNAL_SDL_CreateColorCursor(surface, hot_x, hot_y);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_FreeCursor")]
        private static extern void INTERNAL_SDL_FreeCursor(SDL_Cursor* cursor);
        [Inline]
        public override void SDL_FreeCursor(SDL_Cursor* cursor) => INTERNAL_SDL_FreeCursor(cursor);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_ShowCursor")]
        private static extern int32 INTERNAL_SDL_ShowCursor(int32 toggle);
        [Inline]
        public override int32 SDL_ShowCursor(int32 toggle) => INTERNAL_SDL_ShowCursor(toggle);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetCursor")]
        private static extern SDL_Cursor* INTERNAL_SDL_GetCursor();
        [Inline]
        public override SDL_Cursor* SDL_GetCursor() => INTERNAL_SDL_GetCursor();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetCursor")]
        private static extern void INTERNAL_SDL_SetCursor(SDL_Cursor* cursor);
        [Inline]
        public override void SDL_SetCursor(SDL_Cursor* cursor) => INTERNAL_SDL_SetCursor(cursor);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDefaultCursor")]
        private static extern SDL_Cursor* INTERNAL_SDL_GetDefaultCursor();
        [Inline]
        public override SDL_Cursor* SDL_GetDefaultCursor() => INTERNAL_SDL_GetDefaultCursor();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetNumVideoDisplays")]
        private static extern int32 INTERNAL_SDL_GetNumVideoDisplays();
        [Inline]
        public override int32 SDL_GetNumVideoDisplays() => INTERNAL_SDL_GetNumVideoDisplays();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDisplayName")]
        private static extern char8* INTERNAL_SDL_GetDisplayName(int32 displayIndex);
        [Inline]
        private char8* SDL_GetDisplayName_Raw(int32 displayIndex) => INTERNAL_SDL_GetDisplayName(displayIndex);
        [Inline]
        public override char8* SDL_GetDisplayName(int32 displayIndex) => SDL_GetDisplayName_Raw(displayIndex);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDisplayBounds")]
        private static extern int32 INTERNAL_SDL_GetDisplayBounds(int32 displayIndex, SDL_Rect* rect);
        [Inline]
        public override int32 SDL_GetDisplayBounds(int32 displayIndex, SDL_Rect* rect) => INTERNAL_SDL_GetDisplayBounds(displayIndex, rect);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetNumDisplayModes")]
        private static extern int32 INTERNAL_SDL_GetNumDisplayModes(int32 displayIndex);
        [Inline]
        public override int32 SDL_GetNumDisplayModes(int32 displayIndex) => INTERNAL_SDL_GetNumDisplayModes(displayIndex);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDisplayMode")]
        private static extern int32 INTERNAL_SDL_GetDisplayMode(int32 displayIndex, int32 modeIndex, SDL_DisplayMode* mode);
        [Inline]
        public override int32 SDL_GetDisplayMode(int32 displayIndex, int32 modeIndex, SDL_DisplayMode* mode) => INTERNAL_SDL_GetDisplayMode(displayIndex, modeIndex, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetCurrentDisplayMode")]
        private static extern int32 INTERNAL_SDL_GetCurrentDisplayMode(int32 displayIndex, SDL_DisplayMode* mode);
        [Inline]
        public override int32 SDL_GetCurrentDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => INTERNAL_SDL_GetCurrentDisplayMode(displayIndex, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDesktopDisplayMode")]
        private static extern int32 INTERNAL_SDL_GetDesktopDisplayMode(int32 displayIndex, SDL_DisplayMode* mode);
        [Inline]
        public override int32 SDL_GetDesktopDisplayMode(int32 displayIndex, SDL_DisplayMode* mode) => INTERNAL_SDL_GetDesktopDisplayMode(displayIndex, mode);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetClosestDisplayMode")]
        private static extern SDL_DisplayMode* INTERNAL_SDL_GetClosestDisplayMode(int32 displayIndex, SDL_DisplayMode* mode, SDL_DisplayMode* closest);
        [Inline]
        public override SDL_DisplayMode* SDL_GetClosestDisplayMode(int32 displayIndex, SDL_DisplayMode* mode, SDL_DisplayMode* closest) => INTERNAL_SDL_GetClosestDisplayMode(displayIndex, mode, closest);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_PixelFormatEnumToMasks")]
        private static extern bool INTERNAL_SDL_PixelFormatEnumToMasks(uint32 format, int32* bpp, uint32* Rmask, uint32* Gmask, uint32* Bmask, uint32* Amask);
        [Inline]
        public override bool SDL_PixelFormatEnumToMasks(uint32 format, int32* bpp, uint32* Rmask, uint32* Gmask, uint32* Bmask, uint32* Amask) => INTERNAL_SDL_PixelFormatEnumToMasks(format, bpp, Rmask, Gmask, Bmask, Amask);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_GetProcAddress")]
        private static extern void* INTERNAL_SDL_GL_GetProcAddress(char8* proc);
        [Inline]
        public override void* SDL_GL_GetProcAddress(char8* proc) => INTERNAL_SDL_GL_GetProcAddress(proc);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_CreateContext")]
        private static extern SDL_GLContext* INTERNAL_SDL_GL_CreateContext(SDL_Window* window);
        [Inline]
        public override SDL_GLContext* SDL_GL_CreateContext(SDL_Window* window) => INTERNAL_SDL_GL_CreateContext(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_DeleteContext")]
        private static extern void INTERNAL_SDL_GL_DeleteContext(SDL_GLContext* context);
        [Inline]
        public override void SDL_GL_DeleteContext(SDL_GLContext* context) => INTERNAL_SDL_GL_DeleteContext(context);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_GetCurrentContext")]
        private static extern SDL_GLContext* INTERNAL_SDL_GL_GetCurrentContext();
        [Inline]
        public override SDL_GLContext* SDL_GL_GetCurrentContext() => INTERNAL_SDL_GL_GetCurrentContext();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_MakeCurrent")]
        private static extern int32 INTERNAL_SDL_GL_MakeCurrent(SDL_Window* window, SDL_GLContext* context);
        [Inline]
        public override int32 SDL_GL_MakeCurrent(SDL_Window* window, SDL_GLContext* context) => INTERNAL_SDL_GL_MakeCurrent(window, context);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_SetAttribute")]
        private static extern int32 INTERNAL_SDL_GL_SetAttribute(SDL_GLattr attr, int32 value);
        [Inline]
        public override int32 SDL_GL_SetAttribute(SDL_GLattr attr, int32 value) => INTERNAL_SDL_GL_SetAttribute(attr, value);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_GetAttribute")]
        private static extern int32 INTERNAL_SDL_GL_GetAttribute(SDL_GLattr attr, int32* value);
        [Inline]
        public override int32 SDL_GL_GetAttribute(SDL_GLattr attr, int32* value) => INTERNAL_SDL_GL_GetAttribute(attr, value);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_SwapWindow")]
        private static extern void INTERNAL_SDL_GL_SwapWindow(SDL_Window* window);
        [Inline]
        public override void SDL_GL_SwapWindow(SDL_Window* window) => INTERNAL_SDL_GL_SwapWindow(window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_SetSwapInterval")]
        private static extern int32 INTERNAL_SDL_GL_SetSwapInterval(int32 interval);
        [Inline]
        public override int32 SDL_GL_SetSwapInterval(int32 interval) => INTERNAL_SDL_GL_SetSwapInterval(interval);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GL_GetDrawableSize")]
        private static extern void INTERNAL_SDL_GL_GetDrawableSize(SDL_Window* window, out int32 w, out int32 h);
        [Inline]
        public override void SDL_GL_GetDrawableSize(SDL_Window* window, out int32 w, out int32 h) => INTERNAL_SDL_GL_GetDrawableSize(window, out w, out h);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_NumJoysticks")]
        private static extern int32 INTERNAL_SDL_NumJoysticks();
        [Inline]
        public override int32 SDL_NumJoysticks() => INTERNAL_SDL_NumJoysticks();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_IsGameController")]
        private static extern bool INTERNAL_SDL_IsGameController(int32 joystick_index);
        [Inline]
        public override bool SDL_IsGameController(int32 joystick_index) => INTERNAL_SDL_IsGameController(joystick_index);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerOpen")]
        private static extern SDL_GameController* INTERNAL_SDL_GameControllerOpen(int32 index);
        [Inline]
        public override SDL_GameController* SDL_GameControllerOpen(int32 index) => INTERNAL_SDL_GameControllerOpen(index);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerClose")]
        private static extern void INTERNAL_SDL_GameControllerClose(SDL_GameController* gamecontroller);
        [Inline]
        public override void SDL_GameControllerClose(SDL_GameController* gamecontroller) => INTERNAL_SDL_GameControllerClose(gamecontroller);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerNameForIndex")]
        private static extern char8* INTERNAL_SDL_GameControllerNameForIndex(int32 joystick_index);
        [Inline]
        private char8* SDL_GameControllerNameForIndex_Raw(int32 joystick_index) => INTERNAL_SDL_GameControllerNameForIndex(joystick_index);
        [Inline]
        public override char8* SDL_GameControllerNameForIndex(int32 joystick_index) => SDL_GameControllerNameForIndex_Raw(joystick_index);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerGetButton")]
        private static extern bool INTERNAL_SDL_GameControllerGetButton(SDL_GameController* gamecontroller, SDL_GameControllerButton button);
        [Inline]
        public override bool SDL_GameControllerGetButton(SDL_GameController* gamecontroller, SDL_GameControllerButton button) => INTERNAL_SDL_GameControllerGetButton(gamecontroller, button);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerGetJoystick")]
        private static extern SDL_Joystick* INTERNAL_SDL_GameControllerGetJoystick(SDL_GameController* gamecontroller);
        [Inline]
        public override SDL_Joystick* SDL_GameControllerGetJoystick(SDL_GameController* gamecontroller) => INTERNAL_SDL_GameControllerGetJoystick(gamecontroller);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_JoystickInstanceID")]
        private static extern int32 INTERNAL_SDL_JoystickInstanceID(SDL_Joystick* joystick);
        [Inline]
        public override int32 SDL_JoystickInstanceID(SDL_Joystick* joystick) => INTERNAL_SDL_JoystickInstanceID(joystick);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetNumTouchDevices")]
        private static extern int32 INTERNAL_SDL_GetNumTouchDevices();
        [Inline]
        public override int32 SDL_GetNumTouchDevices() => INTERNAL_SDL_GetNumTouchDevices();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetTouchDevice")]
        private static extern int64 INTERNAL_SDL_GetTouchDevice(int32 index);
        [Inline]
        public override int64 SDL_GetTouchDevice(int32 index) => INTERNAL_SDL_GetTouchDevice(index);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetNumTouchFingers")]
        private static extern int32 INTERNAL_SDL_GetNumTouchFingers(int64 touchID);
        [Inline]
        public override int32 SDL_GetNumTouchFingers(int64 touchID) => INTERNAL_SDL_GetNumTouchFingers(touchID);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetTouchFinger")]
        private static extern SDL_Finger* INTERNAL_SDL_GetTouchFinger(int64 touchID, int32 index);
        [Inline]
        public override SDL_Finger* SDL_GetTouchFinger(int64 touchID, int32 index) => INTERNAL_SDL_GetTouchFinger(touchID, index);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_RecordGesture")]
        private static extern int32 INTERNAL_SDL_RecordGesture(int64 touchID);
        [Inline]
        public override int32 SDL_RecordGesture(int64 touchID) => INTERNAL_SDL_RecordGesture(touchID);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SaveAllDollarTemplates")]
        private static extern int32 INTERNAL_SDL_SaveAllDollarTemplates(SDL_RWops* dst);
        [Inline]
        public override int32 SDL_SaveAllDollarTemplates(SDL_RWops* dst) => INTERNAL_SDL_SaveAllDollarTemplates(dst);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SaveDollarTemplate")]
        private static extern int32 INTERNAL_SDL_SaveDollarTemplate(int64 gestureID, SDL_RWops* dst);
        [Inline]
        public override int32 SDL_SaveDollarTemplate(int64 gestureID, SDL_RWops* dst) => INTERNAL_SDL_SaveDollarTemplate(gestureID, dst);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_LoadDollarTemplates")]
        private static extern int32 INTERNAL_SDL_LoadDollarTemplates(int64 touchID, SDL_RWops* src);
        [Inline]
        public override int32 SDL_LoadDollarTemplates(int64 touchID, SDL_RWops* src) => INTERNAL_SDL_LoadDollarTemplates(touchID, src);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_StartTextInput")]
        private static extern void INTERNAL_SDL_StartTextInput();
        [Inline]
        public override void SDL_StartTextInput() => INTERNAL_SDL_StartTextInput();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_StopTextInput")]
        private static extern void INTERNAL_SDL_StopTextInput();
        [Inline]
        public override void SDL_StopTextInput() => INTERNAL_SDL_StopTextInput();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetTextInputRect")]
        private static extern void INTERNAL_SDL_SetTextInputRect(SDL_Rect* rect);
        [Inline]
        public override void SDL_SetTextInputRect(SDL_Rect* rect) => INTERNAL_SDL_SetTextInputRect(rect);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_HasClipboardText")]
        private static extern bool INTERNAL_SDL_HasClipboardText();
        [Inline]
        public override bool SDL_HasClipboardText() => INTERNAL_SDL_HasClipboardText();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetClipboardText")]
        private static extern char8* INTERNAL_SDL_GetClipboardText();
        [Inline]
        public override char8* SDL_GetClipboardText() => INTERNAL_SDL_GetClipboardText();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetClipboardText")]
        private static extern void INTERNAL_SDL_SetClipboardText(char8* text);
        [Inline]
        public override void SDL_SetClipboardText(char8* text) => INTERNAL_SDL_SetClipboardText(text);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetPowerInfo")]
        private static extern SDL_PowerState INTERNAL_SDL_GetPowerInfo(int32* secs, int32* pct);
        [Inline]
        public override SDL_PowerState SDL_GetPowerInfo(int32* secs, int32* pct) => INTERNAL_SDL_GetPowerInfo(secs, pct);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_ShowSimpleMessageBox")]
        private static extern int32 INTERNAL_SDL_ShowSimpleMessageBox(uint32 flags, char8* title, char8* message, SDL_Window* window);
        [Inline]
        public override int32 SDL_ShowSimpleMessageBox(uint32 flags, char8* title, char8* message, SDL_Window* window) => INTERNAL_SDL_ShowSimpleMessageBox(flags, title, message, window);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetWindowOpacity")]
        private static extern int32 INTERNAL_SDL_SetWindowOpacity(SDL_Window* window, float opacity);
        [Inline]
        public override int32 SDL_SetWindowOpacity(SDL_Window* window, float opacity) => INTERNAL_SDL_SetWindowOpacity(window, opacity);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetWindowOpacity")]
        private static extern int32 INTERNAL_SDL_GetWindowOpacity(SDL_Window* window, float* opacity);
        [Inline]
        public override int32 SDL_GetWindowOpacity(SDL_Window* window, float* opacity) => INTERNAL_SDL_GetWindowOpacity(window, opacity);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerAddMapping")]
        private static extern int32 INTERNAL_SDL_GameControllerAddMapping(char8* mappingString);
        [Inline]
        public override int32 SDL_GameControllerAddMapping(char8* mappingString) => INTERNAL_SDL_GameControllerAddMapping(mappingString);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerAddMappingsFromRW")]
        private static extern int32 INTERNAL_SDL_GameControllerAddMappingsFromRW(SDL_RWops* rw, int32 freerw);
        [Inline]
        public override int32 SDL_GameControllerAddMappingsFromRW(SDL_RWops* rw, int32 freerw) => INTERNAL_SDL_GameControllerAddMappingsFromRW(rw, freerw);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerMapping")]
        private static extern char8* INTERNAL_SDL_GameControllerMapping(SDL_GameController* gamecontroller);
        [Inline]
        private char8* SDL_GameControllerMapping_Raw(SDL_GameController* gamecontroller) => INTERNAL_SDL_GameControllerMapping(gamecontroller);
        [Inline]
        public override char8* SDL_GameControllerMapping(SDL_GameController* gamecontroller) => SDL_GameControllerMapping_Raw(gamecontroller);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GameControllerMappingForGUID")]
        private static extern char8* INTERNAL_SDL_GameControllerMappingForGUID(Guid guid);
        [Inline]
        private char8* SDL_GameControllerMappingForGUID_Raw(Guid guid) => INTERNAL_SDL_GameControllerMappingForGUID(guid);
        [Inline]
        public override char8* SDL_GameControllerMappingForGUID(Guid guid) => SDL_GameControllerMappingForGUID_Raw(guid);

        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_JoystickGetGUID")]
        private static extern Guid INTERNAL_SDL_JoystickGetGUID(SDL_Joystick *joystick);
        [Inline]
        public override Guid SDL_JoystickGetGUID(SDL_Joystick *joystick) => INTERNAL_SDL_JoystickGetGUID(joystick);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetDisplayDPI")]
        private static extern int32 INTERNAL_SDL_GetDisplayDPI(int32 displayIndex, float* ddpi, float* hdpi, float* vdpi);
        [Inline]
        public override int32 SDL_GetDisplayDPI(int32 displayIndex, float* ddpi, float* hdpi, float* vdpi) => INTERNAL_SDL_GetDisplayDPI(displayIndex, ddpi, hdpi, vdpi);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_free")]
        private static extern void INTERNAL_SDL_free(void* mem);
        [Inline]
        public override void SDL_free(void* mem) => INTERNAL_SDL_free(mem);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_GetRelativeMouseMode")]
        private static extern bool INTERNAL_SDL_GetRelativeMouseMode();
        [Inline]
        public override bool SDL_GetRelativeMouseMode() => INTERNAL_SDL_GetRelativeMouseMode();
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_SetRelativeMouseMode")]
        private static extern int32 INTERNAL_SDL_SetRelativeMouseMode(bool enabled);
        [Inline]
        public override int32 SDL_SetRelativeMouseMode(bool enabled) => INTERNAL_SDL_SetRelativeMouseMode(enabled);
        
        [/*LibName("SDL2"), */CallingConvention(.Cdecl), LinkName("SDL_WarpMouseInWindow")]
        private static extern void INTERNAL_SDL_WarpMouseInWindow(SDL_Window* window, int32 x, int32 y);
        [Inline]
        public override void SDL_WarpMouseInWindow(SDL_Window* window, int32 x, int32 y) => INTERNAL_SDL_WarpMouseInWindow(window, x, y);
    }

}
