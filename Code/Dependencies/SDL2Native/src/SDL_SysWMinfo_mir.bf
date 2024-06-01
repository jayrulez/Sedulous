using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_mir
    {
        public void* connection;
        public void* surface;
    }
}
