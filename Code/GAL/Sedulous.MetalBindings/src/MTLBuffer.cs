using System;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLBuffer
    {
        public readonly void* NativePtr;
        public this(void* ptr) => NativePtr = ptr;
        public bool IsNull => NativePtr == null;

        public void* contents() => ObjectiveCRuntime.IntPtr_objc_msgSend(NativePtr, sel_contents);

        public uint length => ObjectiveCRuntime.UIntPtr_objc_msgSend(NativePtr, sel_length);

        public void didModifyRange(NSRange range)
            => ObjectiveCRuntime.objc_msgSend(NativePtr, sel_didModifyRange, range);

        public void addDebugMarker(NSString marker, NSRange range)
            => ObjectiveCRuntime.objc_msgSend(NativePtr, sel_addDebugMarker, marker.NativePtr, range);

        public void removeAllDebugMarkers()
            => ObjectiveCRuntime.objc_msgSend(NativePtr, sel_removeAllDebugMarkers);

        private static readonly Selector sel_contents = "contents";
        private static readonly Selector sel_length = "length";
        private static readonly Selector sel_didModifyRange = "didModifyRange:";
        private static readonly Selector sel_addDebugMarker = "addDebugMarker:range:";
        private static readonly Selector sel_removeAllDebugMarkers = "removeAllDebugMarkers";
    }
}