using Bulkan;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    internal class VKResourceFactory : ResourceFactory
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkDevice _device;

        public this(VKGraphicsDevice vkGraphicsDevice)
            : base (vkGraphicsDevice.Features)
        {
            _gd = vkGraphicsDevice;
            _device = vkGraphicsDevice.Device;
        }

        public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

        public override CommandList CreateCommandList(in CommandListDescription description)
        {
            return new VKCommandList(_gd, description);
        }

        public override Framebuffer CreateFramebuffer(in FramebufferDescription description)
        {
            return new VKFramebuffer(_gd, description, false);
        }

        protected override Pipeline CreateGraphicsPipelineCore(in GraphicsPipelineDescription description)
        {
            return new VKPipeline(_gd, description);
        }

        public override Pipeline CreateComputePipeline(in ComputePipelineDescription description)
        {
            return new VKPipeline(_gd, description);
        }

        public override ResourceLayout CreateResourceLayout(in ResourceLayoutDescription description)
        {
            return new VKResourceLayout(_gd, description);
        }

        public override ResourceSet CreateResourceSet(in ResourceSetDescription description)
        {
            ValidationHelpers.ValidateResourceSet(_gd, description);
            return new VKResourceSet(_gd, description);
        }

        protected override Sampler CreateSamplerCore(in SamplerDescription description)
        {
            return new VKSampler(_gd, description);
        }

        protected override Shader CreateShaderCore(in ShaderDescription description)
        {
            return new VKShader(_gd, description);
        }

        protected override Texture CreateTextureCore(in TextureDescription description)
        {
            return new VKTexture(_gd, description);
        }

        protected override Texture CreateTextureCore(uint64 nativeTexture, in TextureDescription description)
        {
            return new VKTexture(
                _gd,
                description.Width, description.Height,
                description.MipLevels, description.ArrayLayers,
                VKFormats.VdToVkPixelFormat(description.Format, (description.Usage & TextureUsage.DepthStencil) != 0),
                description.Usage,
                description.SampleCount,
                nativeTexture);
        }

        protected override TextureView CreateTextureViewCore(in TextureViewDescription description)
        {
            return new VKTextureView(_gd, description);
        }

        protected override DeviceBuffer CreateBufferCore(in BufferDescription description)
        {
            return new VKBuffer(_gd, description.SizeInBytes, description.Usage);
        }

        public override Fence CreateFence(bool signaled)
        {
            return new VKFence(_gd, signaled);
        }

        public override Swapchain CreateSwapchain(in SwapchainDescription description)
        {
            return new VKSwapchain(_gd, description);
        }
    }
}
