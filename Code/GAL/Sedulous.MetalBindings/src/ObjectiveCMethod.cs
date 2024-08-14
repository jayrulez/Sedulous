using System;

namespace Sedulous.MetalBindings
{
    public struct ObjectiveCMethod
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;
        public static implicit operator void*(ObjectiveCMethod method) => method.NativePtr;
        public static implicit operator ObjectiveCMethod(void* ptr) => new ObjectiveCMethod(ptr);

        public Selector GetSelector() => ObjectiveCRuntime.method_getName(this);
        public String GetName() => GetSelector().Name;
    }
}