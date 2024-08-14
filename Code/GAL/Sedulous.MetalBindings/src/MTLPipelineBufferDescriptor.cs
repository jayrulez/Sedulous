using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct MTLPipelineBufferDescriptor
    {
        public readonly void* NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public MTLMutability mutability
        {
            get => (MTLMutability)uint_objc_msgSend(NativePtr, sel_mutability);
            set => objc_msgSend(NativePtr, sel_setMutability, (uint32)value);
        }

        private static readonly Selector sel_mutability = "mutability";
        private static readonly Selector sel_setMutability = "setMutability:";
    }
}