using static Sedulous.MetalBindings.ObjectiveCRuntime;
using System;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLTexture
    {
        public readonly void* NativePtr;

        public this(void* ptr) => NativePtr = ptr;
        public bool IsNull => NativePtr == null;

        public void replaceRegion(
            MTLRegion region,
            uint mipmapLevel,
            uint slice,
            void* pixelBytes,
            uint bytesPerRow,
            uint bytesPerImage)
        {
            objc_msgSend(NativePtr, sel_replaceRegion,
                region,
                mipmapLevel,
                slice,
                (void*)pixelBytes,
                bytesPerRow,
                bytesPerImage);
        }

        public MTLTexture newTextureView(
            MTLPixelFormat pixelFormat,
            MTLTextureType textureType,
            NSRange levelRange,
            NSRange sliceRange)
        {
            void* ret = IntPtr_objc_msgSend(NativePtr, sel_newTextureView,
                (uint32)pixelFormat, (uint32)textureType, levelRange, sliceRange);
            return MTLTexture(ret);
        }

        private static readonly Selector sel_replaceRegion = "replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:";
        private static readonly Selector sel_newTextureView = "newTextureViewWithPixelFormat:textureType:levels:slices:";
    }
}