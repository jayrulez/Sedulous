using System;
typealias SDL_GestureID = int64;

namespace SDL2Native
{
	[CRepr]
	struct SDL_DollarGestureEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_TouchID touchId;
        public SDL_GestureID gestureId;
        public uint32 numFingers;
        public float error;
        public float x;
        public float y;
    }

}
