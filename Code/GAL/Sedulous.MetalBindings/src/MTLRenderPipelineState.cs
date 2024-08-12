using System;

namespace Sedulous.MetalBindings
{
    public struct MTLRenderPipelineState
    {
        public readonly IntPtr NativePtr;
        public MTLRenderPipelineState(IntPtr ptr) => NativePtr = ptr;
    }
}