using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_x11
    {
        public void* display;
        public void* window;
    }
}
