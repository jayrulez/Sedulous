using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo_uikit
    {
        public void* window;
        public uint32 framebuffer;
        public uint32 colorbuffer;
        public uint32 resolveFramebuffer;
    }
}