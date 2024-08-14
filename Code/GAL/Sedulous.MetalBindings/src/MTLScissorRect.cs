using System;

namespace Sedulous.MetalBindings
{
    public struct MTLScissorRect
    {
        public uint x;
        public uint y;
        public uint width;
        public uint height;

        public this(uint32 x, uint32 y, uint32 width, uint32 height)
        {
            this.x = (uint)x;
            this.y = (uint)y;
            this.width = (uint)width;
            this.height = (uint)height;
        }
    }
}