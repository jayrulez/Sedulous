using System;

namespace Sedulous.MetalBindings
{
    public struct MTLComputePipelineState
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;
        public bool IsNull => NativePtr == null;
    }
}