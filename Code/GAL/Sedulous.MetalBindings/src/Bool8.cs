namespace Sedulous.MetalBindings
{
    public struct Bool8
    {
        public readonly uint8 Value;

        public this(uint8 value)
        {
            Value = value;
        }

        public this(bool value)
        {
            Value = value ? (uint8)1 : (uint8)0;
        }

        public static implicit operator bool(Bool8 b) => b.Value != 0;
        public static implicit operator uint8(Bool8 b) => b.Value;
        public static implicit operator Bool8(bool b) => Bool8(b);
    }
}