using System;

namespace Sedulous.MetalBindings
{
    public struct NSRange
    {
        public UIntPtr location;
        public UIntPtr length;

        public NSRange(UIntPtr location, UIntPtr length)
        {
            this.location = location;
            this.length = length;
        }

        public NSRange(uint32 location, uint32 length)
        {
            this.location = (UIntPtr)location;
            this.length = (UIntPtr)length;
        }
    }
}