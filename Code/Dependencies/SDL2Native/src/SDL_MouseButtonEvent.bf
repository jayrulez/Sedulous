using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_MouseButtonEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public uint32 which;
        public uint8 button;
        public uint8 state;
        public uint8 clicks;
        public uint8 padding1;
        public int32 x;
        public int32 y;
    }

}