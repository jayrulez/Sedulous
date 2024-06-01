using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_ControllerButtonEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_JoystickID which;
        public uint8 button;
        public uint8 state;
        public uint8 padding1;
        public uint8 epadding2;
    }

}
