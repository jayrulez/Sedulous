using System;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLSize
    {
        public uint Width;
        public uint Height;
        public uint Depth;

        public this(uint32 width, uint32 height, uint32 depth)
        {
            Width = (uint)width;
            Height = (uint)height;
            Depth = (uint)depth;
        }
    }
}