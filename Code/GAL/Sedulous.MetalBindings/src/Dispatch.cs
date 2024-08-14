using System;

namespace Sedulous.MetalBindings
{
    public static class Dispatch
    {
        private const String LibdispatchLocation = @"/usr/lib/system/libdispatch.dylib";

        [Import(LibdispatchLocation)]
        public static extern DispatchQueue dispatch_get_global_queue(QualityOfServiceLevel identifier, uint64 flags);

        [Import(LibdispatchLocation)]
        public static extern DispatchData dispatch_data_create(
            void* buffer,
            uint size,
            DispatchQueue queue,
            void* destructorBlock);

        [Import(LibdispatchLocation)]
        public static extern void dispatch_release(void* nativePtr);
    }

    public enum QualityOfServiceLevel : int64
    {
        QOS_CLASS_USER_INTERACTIVE = 0x21,
        QOS_CLASS_USER_INITIATED = 0x19,
        QOS_CLASS_DEFAULT = 0x15,
        QOS_CLASS_UTILITY = 0x11,
        QOS_CLASS_BACKGROUND = 0x9,
        QOS_CLASS_UNSPECIFIED = 0,
    }

    public struct DispatchQueue
    {
        public readonly void* NativePtr;
    }

    public struct DispatchData
    {
        public readonly void* NativePtr;
    }
}