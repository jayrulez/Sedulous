using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct UIView
    {
        public readonly IntPtr NativePtr;
        public UIView(IntPtr ptr) => NativePtr = ptr;

        public CALayer layer => objc_msgSend<CALayer>(NativePtr, "layer");

        public CGRect frame => CGRect_objc_msgSend(NativePtr, "frame");
    }
}