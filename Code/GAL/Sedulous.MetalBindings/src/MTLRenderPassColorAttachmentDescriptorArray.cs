using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    [CRepr]
    public struct MTLRenderPassColorAttachmentDescriptorArray
    {
        public readonly void* NativePtr;

        public MTLRenderPassColorAttachmentDescriptor this[uint32 index]
        {
            get
            {
                void* value = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, (uint)index);
                return MTLRenderPassColorAttachmentDescriptor(value);
            }
            set
            {
                objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, (uint)index);
            }
        }
    }
}