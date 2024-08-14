using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    public struct MTLVertexBufferLayoutDescriptorArray
    {
        public readonly void* NativePtr;

        public MTLVertexBufferLayoutDescriptor this[uint32 index]
        {
            get
            {
                void* value = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, index);
                return MTLVertexBufferLayoutDescriptor(value);
            }
            set => objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, index);
        }
    }
}