using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    internal class MTLResourceFactory : ResourceFactory
    {
        private readonly MTLGraphicsDevice _gd;

        public this(MTLGraphicsDevice gd)
            : base(gd.Features)
        {
            _gd = gd;
        }

        public override GraphicsBackend BackendType => GraphicsBackend.Metal;

        public override CommandList CreateCommandList(in CommandListDescription description)
        {
            return new MTLCommandList(description, _gd);
        }

        public override Pipeline CreateComputePipeline(in ComputePipelineDescription description)
        {
            return new MTLPipeline(description, _gd);
        }

        public override Framebuffer CreateFramebuffer(in FramebufferDescription description)
        {
            return new MTLFramebuffer(_gd, description);
        }

        protected override Pipeline CreateGraphicsPipelineCore(in GraphicsPipelineDescription description)
        {
            return new MTLPipeline(description, _gd);
        }

        public override ResourceLayout CreateResourceLayout(in ResourceLayoutDescription description)
        {
            return new MTLResourceLayout(description, _gd);
        }

        public override ResourceSet CreateResourceSet(in ResourceSetDescription description)
        {
            ValidationHelpers.ValidateResourceSet(_gd, description);
            return new MTLResourceSet(description, _gd);
        }

        protected override Sampler CreateSamplerCore(in SamplerDescription description)
        {
            return new MTLSampler(description, _gd);
        }

        protected override Shader CreateShaderCore(in ShaderDescription description)
        {
            return new MTLShader(description, _gd);
        }

        protected override DeviceBuffer CreateBufferCore(in BufferDescription description)
        {
            return new Sedulous.GAL.MTL.MTLBuffer(description, _gd);
        }

        protected override Texture CreateTextureCore(in TextureDescription description)
        {
            return new Sedulous.GAL.MTL.MTLTexture(description, _gd);
        }

        protected override Texture CreateTextureCore(uint64 nativeTexture, in TextureDescription description)
        {
            return new Sedulous.GAL.MTL.MTLTexture(nativeTexture, description);
        }

        protected override TextureView CreateTextureViewCore(in TextureViewDescription description)
        {
            return new MTLTextureView(description, _gd);
        }

        public override Fence CreateFence(bool signaled)
        {
            return new MTLFence(signaled);
        }

        public override Swapchain CreateSwapchain(in SwapchainDescription description)
        {
            return new MTLSwapchain(_gd, description);
        }
    }
}
