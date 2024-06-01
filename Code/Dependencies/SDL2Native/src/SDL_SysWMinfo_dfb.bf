using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_dfb
    {
        public void* dfb;
        public void* window;
        public void* surface;
    }
}
