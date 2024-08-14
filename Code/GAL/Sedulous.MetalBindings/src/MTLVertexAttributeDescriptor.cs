using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct MTLVertexAttributeDescriptor
    {
        public readonly void* NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public MTLVertexFormat format
        {
            get => (MTLVertexFormat)uint_objc_msgSend(NativePtr, sel_format);
            set => objc_msgSend(NativePtr, sel_setFormat, (uint32)value);
        }

        public uint offset
        {
            get => UIntPtr_objc_msgSend(NativePtr, sel_offset);
            set => objc_msgSend(NativePtr, sel_setOffset, value);
        }

        public uint bufferIndex
        {
            get => UIntPtr_objc_msgSend(NativePtr, sel_bufferIndex);
            set => objc_msgSend(NativePtr, sel_setBufferIndex, value);
        }

        private static readonly Selector sel_format = "format";
        private static readonly Selector sel_setFormat = "setFormat:";
        private static readonly Selector sel_offset = "offset";
        private static readonly Selector sel_setOffset = "setOffset:";
        private static readonly Selector sel_bufferIndex = "bufferIndex";
        private static readonly Selector sel_setBufferIndex = "setBufferIndex:";
    }
}