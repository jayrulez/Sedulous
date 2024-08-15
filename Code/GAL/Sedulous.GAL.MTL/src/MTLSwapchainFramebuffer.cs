using System;
using System.Diagnostics;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    internal class MTLSwapchainFramebuffer : MTLFramebufferBase
    {
        private readonly MTLGraphicsDevice _gd;
        private /*readonly*/ MTLPlaceholderTexture _placeholderTexture;
        private Sedulous.GAL.MTL.MTLTexture _depthTexture;
        private readonly MTLSwapchain _parentSwapchain;
        private bool _disposed;

        public override uint32 Width { get => _placeholderTexture.Width; };
        public override uint32 Height { get => _placeholderTexture.Height; };

        public new override ref OutputDescription OutputDescription { get; }

        private /*readonly*/ FramebufferAttachmentList _colorTargets;
        private /*readonly*/ FramebufferAttachmentDescription? _depthTarget;
        private readonly PixelFormat? _depthFormat;

        public override ref FramebufferAttachmentList ColorTargets => ref _colorTargets;
        public override ref FramebufferAttachmentDescription? DepthTarget => ref _depthTarget;

        public override bool IsDisposed => _disposed;

        public this(
            MTLGraphicsDevice gd,
            MTLSwapchain parent,
            uint32 width,
            uint32 height,
            PixelFormat? depthFormat,
            PixelFormat colorFormat)
            : base()
        {
            _gd = gd;
            _parentSwapchain = parent;

            OutputAttachmentDescription? depthAttachment = null;
            if (depthFormat != null)
            {
                _depthFormat = depthFormat;
                depthAttachment = OutputAttachmentDescription(depthFormat.Value);
                RecreateDepthTexture(width, height);
                _depthTarget = FramebufferAttachmentDescription(_depthTexture, 0);
            }
            OutputAttachmentDescription colorAttachment = OutputAttachmentDescription(colorFormat);

            OutputDescription = OutputDescription(depthAttachment, colorAttachment);
            _placeholderTexture = new MTLPlaceholderTexture(colorFormat);
            _placeholderTexture.Resize(width, height);
            _colorTargets = .(FramebufferAttachmentDescription(_placeholderTexture, 0));
        }

        private void RecreateDepthTexture(uint32 width, uint32 height)
        {
            Debug.Assert(_depthFormat.HasValue);
            if (_depthTexture != null)
            {
                _depthTexture.Dispose();
            }

            _depthTexture = Util.AssertSubtype<Texture, Sedulous.GAL.MTL.MTLTexture>(
                _gd.ResourceFactory.CreateTexture(TextureDescription.Texture2D(
                    width, height, 1, 1, _depthFormat.Value, TextureUsage.DepthStencil)));
        }

        public void Resize(uint32 width, uint32 height)
        {
            _placeholderTexture.Resize(width, height);

            if (_depthFormat.HasValue)
            {
                RecreateDepthTexture(width, height);
            }
        }

        public override bool IsRenderable => !_parentSwapchain.CurrentDrawable.IsNull;

        public override MTLRenderPassDescriptor CreateRenderPassDescriptor()
        {
            MTLRenderPassDescriptor ret = MTLRenderPassDescriptor.New();
            var color0 = ret.colorAttachments[0];
            color0.texture = _parentSwapchain.CurrentDrawable.texture;
            color0.loadAction = MTLLoadAction.Load;

            if (_depthTarget != null)
            {
                var depthAttachment = ret.depthAttachment;
                depthAttachment.texture = _depthTexture.DeviceTexture;
                depthAttachment.loadAction = MTLLoadAction.Load;
            }

            return ret;
        }

        public override void Dispose()
        {
            _depthTexture?.Dispose();
            _disposed = true;
        }
    }
}
