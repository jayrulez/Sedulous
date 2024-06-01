using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_Keysym
    {
        public SDL_Scancode scancode;
        public SDL_Keycode keycode;
        public SDL_Keymod mod;
        public uint32 unused;
    }

}