using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_MouseMotionEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public uint32 which;
        public uint32 state;
        public int32 x;
        public int32 y;
        public int32 xrel;
        public int32 yrel;
    }

}