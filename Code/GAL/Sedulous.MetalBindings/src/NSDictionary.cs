using System;

namespace Sedulous.MetalBindings
{
    public struct NSDictionary
    {
        public readonly void* NativePtr;

        public uint count => ObjectiveCRuntime.UIntPtr_objc_msgSend(NativePtr, "count");
    }
}