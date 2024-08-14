using static Sedulous.MetalBindings.ObjectiveCRuntime;
using System;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLCommandBuffer
    {
        public readonly void* NativePtr;

        public MTLRenderCommandEncoder renderCommandEncoderWithDescriptor(MTLRenderPassDescriptor desc)
        {
            return MTLRenderCommandEncoder(
                IntPtr_objc_msgSend(NativePtr, sel_renderCommandEncoderWithDescriptor, desc.NativePtr));
        }

        public void presentDrawable(void* drawable) => objc_msgSend(NativePtr, sel_presentDrawable, drawable);

        public void commit() => objc_msgSend(NativePtr, sel_commit);

        public MTLBlitCommandEncoder blitCommandEncoder()
            => objc_msgSend<MTLBlitCommandEncoder>(NativePtr, sel_blitCommandEncoder);

        public MTLComputeCommandEncoder computeCommandEncoder()
            => objc_msgSend<MTLComputeCommandEncoder>(NativePtr, sel_computeCommandEncoder);

        public void waitUntilCompleted() => objc_msgSend(NativePtr, sel_waitUntilCompleted);

        public void addCompletedHandler(MTLCommandBufferHandler block)
            => objc_msgSend(NativePtr, sel_addCompletedHandler, block);
        public void addCompletedHandler(void* block)
            => objc_msgSend(NativePtr, sel_addCompletedHandler, block);

        public MTLCommandBufferStatus status => (MTLCommandBufferStatus)uint_objc_msgSend(NativePtr, sel_status);

        private static readonly Selector sel_renderCommandEncoderWithDescriptor = "renderCommandEncoderWithDescriptor:";
        private static readonly Selector sel_presentDrawable = "presentDrawable:";
        private static readonly Selector sel_commit = "commit";
        private static readonly Selector sel_blitCommandEncoder = "blitCommandEncoder";
        private static readonly Selector sel_computeCommandEncoder = "computeCommandEncoder";
        private static readonly Selector sel_waitUntilCompleted = "waitUntilCompleted";
        private static readonly Selector sel_addCompletedHandler = "addCompletedHandler:";
        private static readonly Selector sel_status = "status";
    }
}