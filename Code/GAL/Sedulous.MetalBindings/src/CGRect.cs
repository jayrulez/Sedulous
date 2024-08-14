using System;
namespace Sedulous.MetalBindings
{
    public struct CGRect
    {
        public CGPoint origin;
        public CGSize size;

        public this(CGPoint origin, CGSize size)
        {
            this.origin = origin;
            this.size = size;
        }

        public override void ToString(String str) => str.AppendF("{0}, {1}", origin, size);
    }
}