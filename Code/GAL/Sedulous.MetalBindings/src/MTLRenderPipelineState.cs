using System;

namespace Sedulous.MetalBindings
{
    public struct MTLRenderPipelineState
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;
    }
}