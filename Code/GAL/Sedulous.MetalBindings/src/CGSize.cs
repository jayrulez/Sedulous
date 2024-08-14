using System;

namespace Sedulous.MetalBindings
{
    public struct CGSize
    {
        public double width;
        public double height;

        public this(double width, double height)
        {
            this.width = width;
            this.height = height;
        }

        public override void ToString(String str) => str.AppendF("{0} x {1}", width, height);
    }
}