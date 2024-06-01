using System;

namespace SDL2Native
{
	[CRepr, Union]
	struct SDL_SysWMinfoUnion
    {
        public SDL_SysWMinfo_win win;
        public SDL_SysWMinfo_winrt winrt;
        public SDL_SysWMinfo_x11 x11;
        public SDL_SysWMinfo_dfb dfb;
        public SDL_SysWMinfo_cocoa cocoa;
        public SDL_SysWMinfo_uikit uikit;
        public SDL_SysWMinfo_wl wl;
        public SDL_SysWMinfo_mir mir;
        public SDL_SysWMinfo_android android;
        public int32 dummy;
    }
}
