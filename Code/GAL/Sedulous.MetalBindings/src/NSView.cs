using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct NSView
    {
        public readonly void* NativePtr;
        public static implicit operator void*(NSView nsView) => nsView.NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public Bool8 wantsLayer
        {
            get => bool8_objc_msgSend(NativePtr, "wantsLayer");
            set => objc_msgSend(NativePtr, "setWantsLayer:", value);
        }

        public void* layer
        {
            get => IntPtr_objc_msgSend(NativePtr, "layer");
            set => objc_msgSend(NativePtr, "setLayer:", value);
        }

        public CGRect frame
        {
            get
            {
                /*return RuntimeInformation.ProcessArchitecture == Architecture.Arm64
                    ? CGRect_objc_msgSend(NativePtr, "frame")
                    : objc_msgSend_stret<CGRect>(NativePtr, "frame");*/
				// todo: Fix check above
				return CGRect_objc_msgSend(NativePtr, "frame");
            }
        }
    }
}