using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct MTLVertexBufferLayoutDescriptor
    {
        public readonly void* NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public MTLVertexStepFunction stepFunction
        {
            get => (MTLVertexStepFunction)uint_objc_msgSend(NativePtr, sel_stepFunction);
            set => objc_msgSend(NativePtr, sel_setStepFunction, (uint32)value);
        }

        public uint stride
        {
            get => UIntPtr_objc_msgSend(NativePtr, sel_stride);
            set => objc_msgSend(NativePtr, sel_setStride, value);
        }

        public uint stepRate
        {
            get => UIntPtr_objc_msgSend(NativePtr, sel_stepRate);
            set => objc_msgSend(NativePtr, sel_setStepRate, value);
        }

        private static readonly Selector sel_stepFunction = "stepFunction";
        private static readonly Selector sel_setStepFunction = "setStepFunction:";
        private static readonly Selector sel_stride = "stride";
        private static readonly Selector sel_setStride = "setStride:";
        private static readonly Selector sel_stepRate = "stepRate";
        private static readonly Selector sel_setStepRate = "setStepRate:";
    }
}