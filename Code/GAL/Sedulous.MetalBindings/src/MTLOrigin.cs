using System;

namespace Sedulous.MetalBindings
{
    public struct MTLOrigin
    {
        public UIntPtr x;
        public UIntPtr y;
        public UIntPtr z;

        public MTLOrigin(uint32 x, uint32 y, uint32 z)
        {
            this.x = (UIntPtr)x;
            this.y = (UIntPtr)y;
            this.z = (UIntPtr)z;
        }
    }
}