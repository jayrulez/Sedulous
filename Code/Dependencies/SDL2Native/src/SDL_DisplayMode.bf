using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_DisplayMode
    {
        public SDL_PixelFormatEnum format;
        public int32 w;
        public int32 h;
        public int32 refresh_rate;
        public void* driver_data;
    }

}
