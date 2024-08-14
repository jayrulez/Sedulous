using System;

namespace Sedulous.MetalBindings
{
    public struct MTLOrigin
    {
        public uint x;
        public uint y;
        public uint z;

        public this(uint32 x, uint32 y, uint32 z)
        {
            this.x = (uint)x;
            this.y = (uint)y;
            this.z = (uint)z;
        }
    }
}