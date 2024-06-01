using System;
namespace SDL2Native
{
    /// <summary>
    /// Contains SDL2 helper methods.
    /// </summary>
    extension SDL2Native
    {
        [Inline]
        public static SDL_Surface* SDL_LoadBMP(char8* file) => SDL_LoadBMP_RW(SDL_RWFromFile(file, "r"), 1);
        [Inline]
        public static int32 SDL_SaveBMP(SDL_Surface* surface, char8* file) => SDL_SaveBMP_RW(surface, SDL_RWFromFile(file, "wb"), 1);
        [Inline]
        public static int32 SDL_GameControllerAddMappingsFromFile(char8* file) => SDL_GameControllerAddMappingsFromRW(SDL_RWFromFile(file, "rb"), 1);
    }
}
