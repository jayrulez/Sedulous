using System;

namespace Sedulous.MetalBindings
{
    // TODO: Technically this should be "pointer-sized",
    // but there are no non-64-bit platforms that anyone cares about.
    public struct CGFloat
    {
        private readonly double _value;

        public this(double value)
        {
            _value = value;
        }

        public double Value
        {
            get => _value;
        }

        public static implicit operator CGFloat(double value) => CGFloat(value);
        public static implicit operator double(CGFloat cgf) => cgf.Value;

        public override void ToString(String str) => _value.ToString(str);
    }
}