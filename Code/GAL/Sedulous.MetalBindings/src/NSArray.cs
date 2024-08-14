using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct NSArray
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;

        public uint count => UIntPtr_objc_msgSend(NativePtr, sel_count);
        private static readonly Selector sel_count = "count";
    }
}