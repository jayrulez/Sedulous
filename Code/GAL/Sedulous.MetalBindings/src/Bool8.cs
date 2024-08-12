namespace Sedulous.MetalBindings
{
    public struct Bool8
    {
        public readonly uint8 Value;

        public Bool8(uint8 value)
        {
            Value = value;
        }

        public Bool8(bool value)
        {
            Value = value ? (uint8)1 : (uint8)0;
        }

        public static implicit operator bool(Bool8 b) => b.Value != 0;
        public static implicit operator uint8(Bool8 b) => b.Value;
        public static implicit operator Bool8(bool b) => new Bool8(b);
    }
}