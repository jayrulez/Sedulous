using Win32.Graphics.Direct3D11;
using System;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    internal class D3D11ResourceFactory : ResourceFactory, IDisposable
    {
        private readonly D3D11GraphicsDevice _gd;
        private readonly ID3D11Device* _device;
        private readonly D3D11ResourceCache _cache;

        public override GraphicsBackend BackendType => GraphicsBackend.Direct3D11;

        public this(D3D11GraphicsDevice gd)
            : base(gd.Features)
        {
            _gd = gd;
            _device = gd.Device;
            _cache = new D3D11ResourceCache(_device);
        }

        public override CommandList CreateCommandList(in CommandListDescription description)
        {
            return new D3D11CommandList(_gd, description);
        }

        public override Framebuffer CreateFramebuffer(in FramebufferDescription description)
        {
            return new D3D11Framebuffer(_device, description);
        }

        protected override Pipeline CreateGraphicsPipelineCore(in GraphicsPipelineDescription description)
        {
            return new D3D11Pipeline(_cache, description);
        }

        public override Pipeline CreateComputePipeline(in ComputePipelineDescription description)
        {
            return new D3D11Pipeline(_cache, description);
        }

        public override ResourceLayout CreateResourceLayout(in ResourceLayoutDescription description)
        {
            return new D3D11ResourceLayout(description);
        }

        public override ResourceSet CreateResourceSet(in ResourceSetDescription description)
        {
            ValidationHelpers.ValidateResourceSet(_gd, description);
            return new D3D11ResourceSet(description);
        }

        protected override Sampler CreateSamplerCore(in SamplerDescription description)
        {
            return new D3D11Sampler(_device, description);
        }

        protected override Shader CreateShaderCore(in ShaderDescription description)
        {
            return new D3D11Shader(_device, description);
        }

        protected override Texture CreateTextureCore(in TextureDescription description)
        {
            return new D3D11Texture(_device, description);
        }

        protected override Texture CreateTextureCore(uint64 nativeTexture, in TextureDescription description)
        {
            ID3D11Texture2D* existingTexture = (ID3D11Texture2D*)(void*)(int)nativeTexture;
			return new D3D11Texture(existingTexture, description.Type, description.Format);
        }

        protected override TextureView CreateTextureViewCore(in TextureViewDescription description)
        {
            return new D3D11TextureView(_gd, description);
        }

        protected override DeviceBuffer CreateBufferCore(in BufferDescription description)
        {
            return new D3D11Buffer(
                _device,
                description.SizeInBytes,
                description.Usage,
                description.StructureByteStride,
                description.RawBuffer);
        }

        public override Fence CreateFence(bool signaled)
        {
            return new D3D11Fence(signaled);
        }

        public override Swapchain CreateSwapchain(in SwapchainDescription description)
        {
            return new D3D11Swapchain(_gd, description);
        }

        public void Dispose()
        {
            _cache.Dispose();
        }
    }
}
