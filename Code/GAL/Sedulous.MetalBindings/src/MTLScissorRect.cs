using System;

namespace Sedulous.MetalBindings
{
    public struct MTLScissorRect
    {
        public UIntPtr x;
        public UIntPtr y;
        public UIntPtr width;
        public UIntPtr height;

        public MTLScissorRect(uint32 x, uint32 y, uint32 width, uint32 height)
        {
            this.x = (UIntPtr)x;
            this.y = (UIntPtr)y;
            this.width = (UIntPtr)width;
            this.height = (UIntPtr)height;
        }
    }
}