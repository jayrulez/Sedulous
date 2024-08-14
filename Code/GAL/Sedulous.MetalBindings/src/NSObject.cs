using static Sedulous.MetalBindings.ObjectiveCRuntime;
using System;

namespace Sedulous.MetalBindings
{
    public struct NSObject
    {
        public readonly void* NativePtr;

        public this(void* ptr) => NativePtr = ptr;

        public Bool8 IsKindOfClass(void* @class) => bool8_objc_msgSend(NativePtr, sel_isKindOfClass, @class);

        private static readonly Selector sel_isKindOfClass = "isKindOfClass:";
    }
}
