using System;

namespace SDL2Native
{
    [CRepr]
    struct SDL_WindowEvent
    {
        public uint32 type;
        public uint32 timestamp;
        public uint32 windowID;
        public SDL_WindowEventID event;
        public uint8 padding1;
        public uint8 padding2;
        public uint8 padding3;
        public int32 data1;
        public int32 data2;
    }
}