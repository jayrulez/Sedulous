using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    [CRepr]
    public struct MTLRenderPassDescriptor
    {
        private static readonly ObjCClass s_class = ObjCClass(nameof(MTLRenderPassDescriptor));
        public readonly void* NativePtr;
        public static MTLRenderPassDescriptor New() => s_class.AllocInit<MTLRenderPassDescriptor>();

        public MTLRenderPassColorAttachmentDescriptorArray colorAttachments
            => objc_msgSend<MTLRenderPassColorAttachmentDescriptorArray>(NativePtr, sel_colorAttachments);

        public MTLRenderPassDepthAttachmentDescriptor depthAttachment
            => objc_msgSend<MTLRenderPassDepthAttachmentDescriptor>(NativePtr, sel_depthAttachment);

        public MTLRenderPassStencilAttachmentDescriptor stencilAttachment
            => objc_msgSend<MTLRenderPassStencilAttachmentDescriptor>(NativePtr, sel_stencilAttachment);

        private static readonly Selector sel_colorAttachments = "colorAttachments";
        private static readonly Selector sel_depthAttachment = "depthAttachment";
        private static readonly Selector sel_stencilAttachment = "stencilAttachment";
    }
}