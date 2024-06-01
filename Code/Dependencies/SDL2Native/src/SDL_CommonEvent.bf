using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_CommonEvent
	{
		public uint32 type;
		public uint32 timestamp;
	}
}
