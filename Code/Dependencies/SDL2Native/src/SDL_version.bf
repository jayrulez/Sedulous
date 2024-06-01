using System;

namespace SDL2Native
{
	[CRepr]
    struct SDL_version
    {
        public uint8 major;
        public uint8 minor;
        public uint8 patch;
    }
}
