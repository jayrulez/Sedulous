using System;

namespace Sedulous.MetalBindings
{
    public struct BlockLiteral
    {
        public IntPtr isa;
        public int32 flags;
        public int32 reserved;
        public IntPtr invoke;
        public BlockDescriptor* descriptor;
    };

    public struct BlockDescriptor
    {
        public uint64 reserved;
        public uint64 Block_size;
    }
}

