using System;
using System.Text;

namespace Sedulous.MetalBindings
{
    public struct Selector
    {
        public readonly void* NativePtr;

        public this(void* ptr)
        {
            NativePtr = ptr;
        }

        public this(String name)
        {
            NativePtr = ObjectiveCRuntime.sel_registerName((uint8*)name.Ptr);
        }

        public String Name
        {
            get
            {
                uint8* name = ObjectiveCRuntime.sel_getName(NativePtr);
                return MTLUtil.GetUtf8String(name);
            }
        }

        public static implicit operator Selector(String s) => Selector(s);
    }
}