using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct UIView
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;

        public CALayer layer => objc_msgSend<CALayer>(NativePtr, "layer");

        public CGRect frame => CGRect_objc_msgSend(NativePtr, "frame");
    }
}