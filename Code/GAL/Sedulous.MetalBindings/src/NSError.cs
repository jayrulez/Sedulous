using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct NSError
    {
        public readonly void* NativePtr;
        public String domain => string_objc_msgSend(NativePtr, "domain");
        public String localizedDescription => string_objc_msgSend(NativePtr, "localizedDescription");
    }
}