using System;
namespace SDL2Native
{
	[CRepr]
	enum SDL_PowerState
    {
        SDL_POWERSTATE_UNKNOWN,
        SDL_POWERSTATE_ON_BATTERY,
        SDL_POWERSTATE_NO_BATTERY,
        SDL_POWERSTATE_CHARGING,
        SDL_POWERSTATE_CHARGED,
    }
}
