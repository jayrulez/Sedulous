using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    public struct MTLBlitCommandEncoder
    {
        public readonly void* NativePtr;
        public bool IsNull => NativePtr == null;

        public void copy(
            MTLBuffer sourceBuffer,
            uint sourceOffset,
            MTLBuffer destinationBuffer,
            uint destinationOffset,
            uint size)
            => objc_msgSend(
                NativePtr,
                sel_copyFromBuffer0,
                sourceBuffer, sourceOffset, destinationBuffer, destinationOffset, size);

        public void copyFromBuffer(
            MTLBuffer sourceBuffer,
            uint sourceOffset,
            uint sourceBytesPerRow,
            uint sourceBytesPerImage,
            MTLSize sourceSize,
            MTLTexture destinationTexture,
            uint destinationSlice,
            uint destinationLevel,
            MTLOrigin destinationOrigin)
            => objc_msgSend(
                NativePtr,
                sel_copyFromBuffer1,
                sourceBuffer.NativePtr,
                sourceOffset,
                sourceBytesPerRow,
                sourceBytesPerImage,
                sourceSize,
                destinationTexture.NativePtr,
                destinationSlice,
                destinationLevel,
                destinationOrigin);

        public void copyTextureToBuffer(
            MTLTexture sourceTexture,
            uint sourceSlice,
            uint sourceLevel,
            MTLOrigin sourceOrigin,
            MTLSize sourceSize,
            MTLBuffer destinationBuffer,
            uint destinationOffset,
            uint destinationBytesPerRow,
            uint destinationBytesPerImage)
            => objc_msgSend(NativePtr, sel_copyFromTexture0,
                sourceTexture,
                sourceSlice,
                sourceLevel,
                sourceOrigin,
                sourceSize,
                destinationBuffer,
                destinationOffset,
                destinationBytesPerRow,
                destinationBytesPerImage);

        public void generateMipmapsForTexture(MTLTexture texture)
            => objc_msgSend(NativePtr, sel_generateMipmapsForTexture, texture.NativePtr);

        public void synchronizeResource(void* resource) => objc_msgSend(NativePtr, sel_synchronizeResource, resource);

        public void endEncoding() => objc_msgSend(NativePtr, sel_endEncoding);

        public void pushDebugGroup(NSString @string) => objc_msgSend(NativePtr, Selectors.pushDebugGroup, @string.NativePtr);

        public void popDebugGroup() => objc_msgSend(NativePtr, Selectors.popDebugGroup);

        public void insertDebugSignpost(NSString @string)
            => objc_msgSend(NativePtr, Selectors.insertDebugSignpost, @string.NativePtr);

        public void copyFromTexture(
            MTLTexture sourceTexture,
            uint sourceSlice,
            uint sourceLevel,
            MTLOrigin sourceOrigin,
            MTLSize sourceSize,
            MTLTexture destinationTexture,
            uint destinationSlice,
            uint destinationLevel,
            MTLOrigin destinationOrigin)
            => objc_msgSend(NativePtr, sel_copyFromTexture1,
                sourceTexture,
                sourceSlice,
                sourceLevel,
                sourceOrigin,
                sourceSize,
                destinationTexture,
                destinationSlice,
                destinationLevel,
                destinationOrigin);

        private static readonly Selector sel_copyFromBuffer0 = "copyFromBuffer:sourceOffset:toBuffer:destinationOffset:size:";
        private static readonly Selector sel_copyFromBuffer1 = "copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:";
        private static readonly Selector sel_copyFromTexture0 = "copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:";
        private static readonly Selector sel_copyFromTexture1 = "copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:";
        private static readonly Selector sel_generateMipmapsForTexture = "generateMipmapsForTexture:";
        private static readonly Selector sel_synchronizeResource = "synchronizeResource:";
        private static readonly Selector sel_endEncoding = "endEncoding";
    }
}