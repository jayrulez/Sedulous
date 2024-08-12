using System;
using System.Runtime.InteropServices;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    [StructLayout(LayoutKind.Sequential)]
    public struct MTLRenderPipelineColorAttachmentDescriptorArray
    {
        public readonly IntPtr NativePtr;

        public MTLRenderPipelineColorAttachmentDescriptor this[uint32 index]
        {
            get
            {
                IntPtr ptr = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, index);
                return new MTLRenderPipelineColorAttachmentDescriptor(ptr);
            }
            set
            {
                objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, index);
            }
        }
    }
}