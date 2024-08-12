using System;
using System.Text;

namespace Sedulous.MetalBindings
{
    public struct Selector
    {
        public readonly IntPtr NativePtr;

        public Selector(IntPtr ptr)
        {
            NativePtr = ptr;
        }

        public Selector(string name)
        {
            int32 byteCount = Encoding.UTF8.GetMaxByteCount(name.Length);
            uint8* utf8BytesPtr = stackalloc uint8[byteCount];
            fixed (char* namePtr = name)
            {
                Encoding.UTF8.GetBytes(namePtr, name.Length, utf8BytesPtr, byteCount);
            }

            NativePtr = ObjectiveCRuntime.sel_registerName(utf8BytesPtr);
        }

        public string Name
        {
            get
            {
                uint8* name = ObjectiveCRuntime.sel_getName(NativePtr);
                return MTLUtil.GetUtf8String(name);
            }
        }

        public static implicit operator Selector(string s) => new Selector(s);
    }
}