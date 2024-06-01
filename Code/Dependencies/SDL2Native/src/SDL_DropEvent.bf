using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_DropEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public char8* file;
    }

}
