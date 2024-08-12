using System;
using System.Runtime.InteropServices;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    [StructLayout(LayoutKind.Sequential)]
    public struct MTLCompileOptions
    {
        public readonly IntPtr NativePtr;

        public static implicit operator IntPtr(MTLCompileOptions mco) => mco.NativePtr;

        public static MTLCompileOptions New()
        {
            return s_class.AllocInit<MTLCompileOptions>();
        }

        public Bool8 fastMathEnabled
        {
            get => bool8_objc_msgSend(NativePtr, sel_fastMathEnabled);
            set => objc_msgSend(NativePtr, sel_setFastMathEnabled, value);
        }

        public MTLLanguageVersion languageVersion
        {
            get => (MTLLanguageVersion)uint_objc_msgSend(NativePtr, sel_languageVersion);
            set => objc_msgSend(NativePtr, sel_setLanguageVersion, (uint32)value);
        }

        private static readonly ObjCClass s_class = new ObjCClass(nameof(MTLCompileOptions));
        private static readonly Selector sel_fastMathEnabled = "fastMathEnabled";
        private static readonly Selector sel_setFastMathEnabled = "setFastMathEnabled:";
        private static readonly Selector sel_languageVersion = "languageVersion";
        private static readonly Selector sel_setLanguageVersion = "setLanguageVersion:";
    }
}