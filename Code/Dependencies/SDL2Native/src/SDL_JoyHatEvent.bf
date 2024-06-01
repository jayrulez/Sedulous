using System;
namespace SDL2Native
{
	typealias SDL_JoystickID = int32;

	[CRepr]
	struct SDL_JoyHatEvent
	{
		public uint32 type;
		public uint32 timestamp;
		public SDL_JoystickID which;
		public uint8 hat;
		public uint8 value;
		public uint8 padding1;
		public uint8 padding2;
	}
}
