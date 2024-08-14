using System;

namespace Sedulous.MetalBindings
{
    public struct NSAutoreleasePool : IDisposable
    {
        private static readonly ObjCClass s_class = ObjCClass(nameof(NSAutoreleasePool));
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;

        public static NSAutoreleasePool Begin()
        {
            return s_class.AllocInit<NSAutoreleasePool>();
        }

        public void Dispose()
        {
            ObjectiveCRuntime.release(this.NativePtr);
        }
    }
}