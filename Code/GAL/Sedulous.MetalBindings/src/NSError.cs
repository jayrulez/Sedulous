using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct NSError
    {
        public readonly IntPtr NativePtr;
        public string domain => string_objc_msgSend(NativePtr, "domain");
        public string localizedDescription => string_objc_msgSend(NativePtr, "localizedDescription");
    }
}