using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_MultiGestureEvent
	{
		public uint32 type;
		public uint32 timestamp;
		public SDL_TouchID touchId;
		public float dTheta;
		public float dDist;
		public float x;
		public float y;
		public uint16 numFingers;
		public uint16 padding;
	}
}