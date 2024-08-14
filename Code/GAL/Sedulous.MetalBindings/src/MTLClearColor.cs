using System;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLClearColor
    {
        public double red;
        public double green;
        public double blue;
        public double alpha;

        public this(double r, double g, double b, double a)
        {
            red = r;
            green = g;
            blue = b;
            alpha = a;
        }
    }
}