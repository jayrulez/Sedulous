using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_ControllerAxisEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_JoystickID which;
        public uint8 axis;
        public uint8 padding1;
        public uint8 padding2;
        public uint8 padding3;
        public int16 value;
        public uint16 padding4;
    }

}
