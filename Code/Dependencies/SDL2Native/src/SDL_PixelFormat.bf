using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_PixelFormat
    {
        public uint32 format;
        public SDL_Palette* palette;
        public uint8 BitsPerPixel;
        public uint8 BytesPerPixel;
        public uint8 padding0;
        public uint8 padding1;
        public uint32 Rmask;
        public uint32 Gmask;
        public uint32 Bmask;
        public uint32 Amask;
        public uint8 Rloss;
        public uint8 Gloss;
        public uint8 Bloss;
        public uint8 Aloss;
        public uint8 Rshift;
        public uint8 Gshift;
        public uint8 Bshift;
        public uint8 Ashift;
        public int32 refcount;
        public SDL_PixelFormat* next;
    }

}