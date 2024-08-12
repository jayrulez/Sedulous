using System;
using System.Runtime.InteropServices;
using Sedulous.MetalBindings;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.GAL.OpenGL.EAGL
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct CAEAGLLayer
    {
        public readonly IntPtr NativePtr;

        public static CAEAGLLayer New()
        {
            return MTLUtil.AllocInit<CAEAGLLayer>("CAEAGLLayer");
        }

        public CGRect frame
        {
            get => CGRect_objc_msgSend(NativePtr, "frame");
            set => objc_msgSend(NativePtr, "setFrame:", value);
        }

        public Bool8 opaque
        {
            get => bool8_objc_msgSend(NativePtr, "isOpaque");
            set => objc_msgSend(NativePtr, "setOpaque:", value);
        }

        public void removeFromSuperlayer() => objc_msgSend(NativePtr, "removeFromSuperlayer");

        public void Release() => release(NativePtr);
    }
}