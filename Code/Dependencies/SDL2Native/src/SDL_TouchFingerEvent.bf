using System;

namespace SDL2Native
{
	typealias SDL_FingerID = int64;
	typealias SDL_TouchID = int64;

	[CRepr]
	struct SDL_TouchFingerEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public SDL_TouchID touchId;
        public SDL_FingerID fingerId;
        public float x;
        public float y;
        public float dx;
        public float dy;
        public float pressure;
    }
}