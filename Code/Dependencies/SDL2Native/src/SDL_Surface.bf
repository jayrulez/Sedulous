using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_Surface
    {
        public uint32 flags;
        public SDL_PixelFormat* format;
        public int32 w, h;
        public int32 pitch;
        public void* pixels;
        public void* userdata;
        public int32 locked;
        public void* lock_data;
        public SDL_Rect clip_rect;
        public void* map;
        public int32 refcount;
    }
}
