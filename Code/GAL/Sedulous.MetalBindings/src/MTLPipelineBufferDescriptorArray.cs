using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    public struct MTLPipelineBufferDescriptorArray
    {
        public readonly void* NativePtr;

        public MTLPipelineBufferDescriptor this[uint32 index]
        {
            get
            {
                void* value = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, (uint)index);
                return MTLPipelineBufferDescriptor(value);
            }
            set
            {
                objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, (uint)index);
            }
        }
    }
}