using System;
using System.Runtime.InteropServices;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    [StructLayout(LayoutKind.Sequential)]
    public struct MTLRenderPassColorAttachmentDescriptorArray
    {
        public readonly IntPtr NativePtr;

        public MTLRenderPassColorAttachmentDescriptor this[uint32 index]
        {
            get
            {
                IntPtr value = IntPtr_objc_msgSend(NativePtr, Selectors.objectAtIndexedSubscript, (UIntPtr)index);
                return new MTLRenderPassColorAttachmentDescriptor(value);
            }
            set
            {
                objc_msgSend(NativePtr, Selectors.setObjectAtIndexedSubscript, value.NativePtr, (UIntPtr)index);
            }
        }
    }
}