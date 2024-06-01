using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_Rect
    {
        public int32 x, y;
        public int32 w, h;
    }
}
