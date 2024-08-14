using System;

namespace Sedulous.MetalBindings
{
    public struct NSRange
    {
        public uint location;
        public uint length;

        public this(uint location, uint length)
        {
            this.location = location;
            this.length = length;
        }

        public this(uint32 location, uint32 length)
        {
            this.location = (uint)location;
            this.length = (uint)length;
        }
    }
}