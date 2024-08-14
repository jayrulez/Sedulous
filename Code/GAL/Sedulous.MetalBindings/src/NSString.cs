using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct NSString
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;
        public static implicit operator void*(NSString nss) => nss.NativePtr;

        public static NSString New(String s)
        {
            var nss = s_class.Alloc<NSString>();

            uint length = (uint)s.Length;
            void* newString = IntPtr_objc_msgSend(nss, sel_initWithCharacters, (void*)s.Ptr, length);
            return NSString(newString);
        }

        public String GetValue()
        {
            uint8* utf8Ptr = bytePtr_objc_msgSend(NativePtr, sel_utf8String);
            return MTLUtil.GetUtf8String(utf8Ptr);
        }

        private static readonly ObjCClass s_class = ObjCClass(nameof(NSString));
        private static readonly Selector sel_initWithCharacters = "initWithCharacters:length:";
        private static readonly Selector sel_utf8String = "UTF8String";
    }
}