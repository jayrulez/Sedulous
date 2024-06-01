using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_KeyboardEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public uint8 state;
        public uint8 @repeat;
        public uint8 padding2;
        public uint8 padding3;
        public SDL_Keysym keysym;
    }

}