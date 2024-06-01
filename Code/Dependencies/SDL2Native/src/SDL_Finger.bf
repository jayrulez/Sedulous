using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_Finger
    {
        public int64 id;
        public float x;
        public float y;
        public float pressure;
    }

}