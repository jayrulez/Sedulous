using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_ControllerDeviceEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_JoystickID which;
    }

}
