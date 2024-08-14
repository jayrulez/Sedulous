using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct CALayer
    {
        public readonly void* NativePtr;
        public static implicit operator void*(CALayer c) => c.NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public void addSublayer(void* layer)
        {
            objc_msgSend(NativePtr, "addSublayer:", layer);
        }
    }
}