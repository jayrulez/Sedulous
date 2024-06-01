using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_wl
    {
        public void* display;
        public void* surface;
        public void* shell_surface;
    }
}
