using Vulkan;

namespace Sedulous.GAL.VK
{
    internal class VKResourceFactory : ResourceFactory
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkDevice _device;

        public VKResourceFactory(VKGraphicsDevice vkGraphicsDevice)
            : base (vkGraphicsDevice.Features)
        {
            _gd = vkGraphicsDevice;
            _device = vkGraphicsDevice.Device;
        }

        public override GraphicsBackend BackendType => GraphicsBackend.Vulkan;

        public override CommandList CreateCommandList(ref CommandListDescription description)
        {
            return new VKCommandList(_gd, ref description);
        }

        public override Framebuffer CreateFramebuffer(ref FramebufferDescription description)
        {
            return new VKFramebuffer(_gd, ref description, false);
        }

        protected override Pipeline CreateGraphicsPipelineCore(ref GraphicsPipelineDescription description)
        {
            return new VKPipeline(_gd, ref description);
        }

        public override Pipeline CreateComputePipeline(ref ComputePipelineDescription description)
        {
            return new VKPipeline(_gd, ref description);
        }

        public override ResourceLayout CreateResourceLayout(ref ResourceLayoutDescription description)
        {
            return new VKResourceLayout(_gd, ref description);
        }

        public override ResourceSet CreateResourceSet(ref ResourceSetDescription description)
        {
            ValidationHelpers.ValidateResourceSet(_gd, ref description);
            return new VKResourceSet(_gd, ref description);
        }

        protected override Sampler CreateSamplerCore(ref SamplerDescription description)
        {
            return new VKSampler(_gd, ref description);
        }

        protected override Shader CreateShaderCore(ref ShaderDescription description)
        {
            return new VKShader(_gd, ref description);
        }

        protected override Texture CreateTextureCore(ref TextureDescription description)
        {
            return new VKTexture(_gd, ref description);
        }

        protected override Texture CreateTextureCore(ulong nativeTexture, ref TextureDescription description)
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

        protected override TextureView CreateTextureViewCore(ref TextureViewDescription description)
        {
            return new VKTextureView(_gd, ref description);
        }

        protected override DeviceBuffer CreateBufferCore(ref BufferDescription description)
        {
            return new VKBuffer(_gd, description.SizeInBytes, description.Usage);
        }

        public override Fence CreateFence(bool signaled)
        {
            return new VKFence(_gd, signaled);
        }

        public override Swapchain CreateSwapchain(ref SwapchainDescription description)
        {
            return new VKSwapchain(_gd, ref description);
        }
    }
}
