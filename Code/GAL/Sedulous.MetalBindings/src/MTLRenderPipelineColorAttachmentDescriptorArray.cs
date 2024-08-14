using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    [CRepr]
    public struct MTLRenderPipelineColorAttachmentDescriptorArray
    {
        public readonly void* NativePtr;

        public MTLRenderPipelineColorAttachmentDescriptor this[uint32 index]
        {
            get
            {
                void* ptr = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, index);
                return MTLRenderPipelineColorAttachmentDescriptor(ptr);
            }
            set
            {
                objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, index);
            }
        }
    }
}