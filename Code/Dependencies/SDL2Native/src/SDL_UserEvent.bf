using System;

namespace SDL2Native
{

	[CRepr]
	struct SDL_UserEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public int32 code;
        public void* data1;
        public void* data2;
    }
}