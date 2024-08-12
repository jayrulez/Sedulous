using static Sedulous.MetalBindings.ObjectiveCRuntime;
using System;

namespace Sedulous.MetalBindings
{
    public struct NSObject
    {
        public readonly IntPtr NativePtr;

        public NSObject(IntPtr ptr) => NativePtr = ptr;

        public Bool8 IsKindOfClass(IntPtr @class) => bool8_objc_msgSend(NativePtr, sel_isKindOfClass, @class);

        private static readonly Selector sel_isKindOfClass = "isKindOfClass:";
    }
}
