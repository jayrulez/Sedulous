using System;
using static SDL2Native.SDL_PixelFormatEnum;

namespace SDL2Native
{

    /// <summary>
    /// Contains SDL2 preprocessor macros.
    /// </summary>
    extension SDL2Native
    {
        public static void SDL_VERSION(SDL_version* version)
        {
            version.major = 2;
            version.minor = 0;
            version.patch = 7;
        }

        public const uint32 SDL_SWSURFACE = 0;
        public const uint32 SDL_PREALLOC = 0x00000001;
        public const uint32 SDL_RLEACCEL = 0x00000002;
        public const uint32 SDL_DONTFREE = 0x00000004;

        public static bool SDL_MUSTLOCK(SDL_Surface* surface) => (surface.flags & SDL_RLEACCEL) != 0;

        public static uint32 SDL_PIXELFLAG(SDL_PixelFormatEnum format) => ((((uint32)format) >> 28) & 0x0F);
        public static uint32 SDL_PIXELTYPE(SDL_PixelFormatEnum format) => ((((uint32)format) >> 24) & 0x0F);
        public static uint32 SDL_PIXELORDER(SDL_PixelFormatEnum format) => ((((uint32)format) >> 20) & 0x0F);
        public static uint32 SDL_PIXELLAYOUT(SDL_PixelFormatEnum format) => ((((uint32)format) >> 16) & 0x0F);
        public static uint32 SDL_BITSPERPIXEL(SDL_PixelFormatEnum format) => ((((uint32)format) >> 8) & 0xFF);
        public static uint32 SDL_BYTESPERPIXEL(SDL_PixelFormatEnum format) =>
           (SDL_ISPIXELFORMAT_FOURCC(format) ?
                ((((format) == SDL_PIXELFORMAT_YUY2) ||
                  ((format) == SDL_PIXELFORMAT_UYVY) ||
                  ((format) == SDL_PIXELFORMAT_YVYU)) ? 2u : 1u) : ((((uint32)format) >> 0) & 0xFF));

        public static uint32 SDL_FOURCC(uint8 A, uint8 B, uint8 C, uint8 D) =>
            ((uint32)A << 0) | ((uint32)B << 8) | ((uint32)C << 16) | ((uint32)D << 24);

        public static uint32 SDL_DEFINE_PIXELFOURCC(char8 A, char8 B, char8 C, char8 D) => 
            SDL_FOURCC((uint8)A, (uint8)B, (uint8)C, (uint8)D);

        public static uint32 SDL_DEFINE_PIXELFORMAT(uint32 type, uint32 order, uint32 layout, uint32 bits, uint32 bytes) =>
            ((1 << 28) | ((type) << 24) | ((order) << 20) | ((layout) << 16) | ((bits) << 8) | ((bytes) << 0));

        public static bool SDL_ISPIXELFORMAT_FOURCC(SDL_PixelFormatEnum format) =>
            ((format != 0) && (SDL_PIXELFLAG(format) != 1));

        public static readonly uint32 SDL_WINDOWPOS_UNDEFINED_MASK = 0x1FFF0000;
        public static uint32 SDL_WINDOWPOS_UNDEFINED() => SDL_WINDOWPOS_UNDEFINED_DISPLAY(0);
        public static uint32 SDL_WINDOWPOS_UNDEFINED_DISPLAY(uint32 displayIndex) => SDL_WINDOWPOS_UNDEFINED_MASK | displayIndex;

        public static readonly uint32 SDL_WINDOWPOS_CENTERED_MASK = 0x2FFF0000;
        public static uint32 SDL_WINDOWPOS_CENTERED() => SDL_WINDOWPOS_CENTERED_DISPLAY(0);
        public static uint32 SDL_WINDOWPOS_CENTERED_DISPLAY(uint32 displayIndex) => SDL_WINDOWPOS_CENTERED_MASK | displayIndex;
    }
}