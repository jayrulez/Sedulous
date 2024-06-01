using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_MouseWheelEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public uint32 which;
        public int32 x;
        public int32 y;
    }

}