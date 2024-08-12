using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct MTLVertexAttributeDescriptorArray
    {
        public readonly IntPtr NativePtr;

        public MTLVertexAttributeDescriptor this[uint32 index]
        {
            get
            {
                IntPtr value = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, index);
                return new MTLVertexAttributeDescriptor(value);
            }
            set => objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, index);
        }
    }
}