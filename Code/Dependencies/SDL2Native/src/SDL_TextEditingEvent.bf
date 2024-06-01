using System;

namespace SDL2Native
{
	[CRepr]
	struct SDL_TextEditingEvent
    {
        public const int32 TEXT_SIZE = 32;

        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public char8[TEXT_SIZE] text;
        public int32 start;
        public int32 length;
    }
}