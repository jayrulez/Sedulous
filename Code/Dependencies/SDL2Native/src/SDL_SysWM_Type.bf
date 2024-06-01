using System;
namespace SDL2Native
{
	[CRepr]
	enum SDL_SysWM_Type
    {
        SDL_SYSWM_UNKNOWN,
        SDL_SYSWM_WINDOWS,
        SDL_SYSWM_X11,
        SDL_SYSWM_DIRECTFB,
        SDL_SYSWM_COCOA,
        SDL_SYSWM_UIKIT,
        SDL_SYSWM_WAYLAND,
        SDL_SYSWM_MIR,
        SDL_SYSWM_WINRT,
        SDL_SYSWM_ANDROID,
        SDL_SYSWM_VIVANTE,
        SDL_SYSWM_OS2
    }
}