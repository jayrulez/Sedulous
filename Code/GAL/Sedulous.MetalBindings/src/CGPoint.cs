using System;
namespace Sedulous.MetalBindings
{
    public struct CGPoint
    {
        public CGFloat x;
        public CGFloat y;

        public this(double x, double y)
        {
            this.x = x;
            this.y = y;
        }

        public override void ToString(String str) => str.AppendF("({0},{1})", x, y);
    }
}