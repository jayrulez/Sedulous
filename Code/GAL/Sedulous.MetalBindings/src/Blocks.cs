using System;

namespace Sedulous.MetalBindings
{
    public struct BlockLiteral
    {
        public IntPtr isa;
        public int flags;
        public int reserved;
        public IntPtr invoke;
        public BlockDescriptor* descriptor;
    };

    public struct BlockDescriptor
    {
        public ulong reserved;
        public ulong Block_size;
    }
}

