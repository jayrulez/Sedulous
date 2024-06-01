using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_JoyBallEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_JoystickID which;
        public uint8 ball;
        public uint8 padding1;
        public uint8 padding2;
        public uint8 padding3;
        public int16 xrel;
        public int16 yrel;
    }

}
