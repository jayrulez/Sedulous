using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_win
    {
        public void* window;
        public void* hdc;
    }
}
