using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_Cursor
    {
        public SDL_Cursor* next;
        public void* driverdata;
    }

}
