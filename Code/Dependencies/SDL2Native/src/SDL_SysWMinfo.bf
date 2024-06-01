using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_SysWMinfo
    {
        public SDL_version version;
        public SDL_SysWM_Type subsystem;
        public SDL_SysWMinfoUnion info;
    }
}
