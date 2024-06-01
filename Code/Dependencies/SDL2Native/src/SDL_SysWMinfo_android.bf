using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_android
    {
        public void* window;
        public void* surface;
    }
}
