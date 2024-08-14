using System;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    internal class MTLFramebuffer : MTLFramebufferBase
    {
        public override bool IsRenderable => true;
        private bool _disposed;

        public this(MTLGraphicsDevice gd, in FramebufferDescription description)
            : base(gd, description)
        {
        }

        public override MTLRenderPassDescriptor CreateRenderPassDescriptor()
        {
            MTLRenderPassDescriptor ret = MTLRenderPassDescriptor.New();
            for (int32 i = 0; i < ColorTargets.Count; i++)
            {
                FramebufferAttachmentDescription colorTarget = ColorTargets[i];
                Sedulous.GAL.MTL.MTLTexture mtlTarget = Util.AssertSubtype<Texture, Sedulous.GAL.MTL.MTLTexture>(colorTarget.Target);
                MTLRenderPassColorAttachmentDescriptor colorDescriptor = ret.colorAttachments[(uint32)i];
                colorDescriptor.texture = mtlTarget.DeviceTexture;
                colorDescriptor.loadAction = MTLLoadAction.Load;
                colorDescriptor.slice = (uint)colorTarget.ArrayLayer;
                colorDescriptor.level = (uint)colorTarget.MipLevel;
            }

            if (DepthTarget != null)
            {
                Sedulous.GAL.MTL.MTLTexture mtlDepthTarget = Util.AssertSubtype<Texture, Sedulous.GAL.MTL.MTLTexture>(DepthTarget.Value.Target);
                MTLRenderPassDepthAttachmentDescriptor depthDescriptor = ret.depthAttachment;
                depthDescriptor.loadAction = MTLLoadAction.Load;
                depthDescriptor.storeAction = MTLStoreAction.Store;
                depthDescriptor.texture = mtlDepthTarget.DeviceTexture;
                depthDescriptor.slice = (uint)DepthTarget.Value.ArrayLayer;
                depthDescriptor.level = (uint)DepthTarget.Value.MipLevel;

                if (FormatHelpers.IsStencilFormat(mtlDepthTarget.Format))
                {
                    MTLRenderPassStencilAttachmentDescriptor stencilDescriptor = ret.stencilAttachment;
                    stencilDescriptor.loadAction = MTLLoadAction.Load;
                    stencilDescriptor.storeAction = MTLStoreAction.Store;
                    stencilDescriptor.texture = mtlDepthTarget.DeviceTexture;
                    stencilDescriptor.slice = (uint)DepthTarget.Value.ArrayLayer;
                }
            }

            return ret;
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }
    }
}
