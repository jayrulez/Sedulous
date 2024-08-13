using System;
using System.Diagnostics;
using Win32.Graphics.Direct3D11;
using Win32.Graphics.Dxgi.Common;
using Win32.Foundation;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    public class D3D11Texture : Texture
    {
        private readonly ID3D11Device* _device;
        private String _name;

        public override uint32 Width { get; protected set; }
        public override uint32 Height { get; protected set; }
        public override uint32 Depth { get; protected set; }
        public override uint32 MipLevels { get; protected set; }
        public override uint32 ArrayLayers { get; protected set; }
        public override PixelFormat Format { get;  protected set;}
        public override TextureUsage Usage { get; protected set; }
        public override TextureType Type { get; protected set; }
        public override TextureSampleCount SampleCount { get; protected set; }
        public override bool IsDisposed => DeviceTexture == null;

        public ref ID3D11Resource* DeviceTexture { get; }
        public DXGI_FORMAT DxgiFormat { get; }
        public DXGI_FORMAT TypelessDxgiFormat { get; }

        public this(ID3D11Device* device, in TextureDescription description)
        {
            _device = device;
            Width = description.Width;
            Height = description.Height;
            Depth = description.Depth;
            MipLevels = description.MipLevels;
            ArrayLayers = description.ArrayLayers;
            Format = description.Format;
            Usage = description.Usage;
            Type = description.Type;
            SampleCount = description.SampleCount;

            DxgiFormat = D3D11Formats.ToDxgiFormat(
                description.Format,
                (description.Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil);
            TypelessDxgiFormat = D3D11Formats.GetTypelessFormat(DxgiFormat);

            D3D11_CPU_ACCESS_FLAG cpuFlags = 0;
			D3D11_USAGE resourceUsage = .D3D11_USAGE_DEFAULT;
			D3D11_BIND_FLAG bindFlags = 0;
			D3D11_RESOURCE_MISC_FLAG optionFlags = 0;

            if ((description.Usage & TextureUsage.RenderTarget) == TextureUsage.RenderTarget)
			{
			    bindFlags |= .D3D11_BIND_RENDER_TARGET;
			}
			if ((description.Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil)
			{
			    bindFlags |= .D3D11_BIND_DEPTH_STENCIL;
			}
			if ((description.Usage & TextureUsage.Sampled) == TextureUsage.Sampled)
			{
			    bindFlags |= .D3D11_BIND_SHADER_RESOURCE;
			}
			if ((description.Usage & TextureUsage.Storage) == TextureUsage.Storage)
			{
			    bindFlags |= .D3D11_BIND_UNORDERED_ACCESS;
			}
			if ((description.Usage & TextureUsage.Staging) == TextureUsage.Staging)
			{
			    cpuFlags = .D3D11_CPU_ACCESS_READ | .D3D11_CPU_ACCESS_WRITE;
			    resourceUsage = .D3D11_USAGE_STAGING;
			}

			if ((description.Usage & TextureUsage.GenerateMipmaps) != 0)
			{
			    bindFlags |= .D3D11_BIND_RENDER_TARGET | .D3D11_BIND_SHADER_RESOURCE;
			    optionFlags |= .D3D11_RESOURCE_MISC_GENERATE_MIPS;
			}

            uint32 arraySize = description.ArrayLayers;
            if ((description.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
            {
                optionFlags |= .D3D11_RESOURCE_MISC_TEXTURECUBE;
                arraySize *= 6;
            }

            uint32 roundedWidth = description.Width;
            uint32 roundedHeight = description.Height;
            if (FormatHelpers.IsCompressedFormat(description.Format))
            {
                roundedWidth = ((roundedWidth + 3) / 4) * 4;
                roundedHeight = ((roundedHeight + 3) / 4) * 4;
            }

            if (Type == TextureType.Texture1D)
            {
                D3D11_TEXTURE1D_DESC desc1D = D3D11_TEXTURE1D_DESC()
                {
                    Width = roundedWidth,
                    MipLevels = description.MipLevels,
                    ArraySize = arraySize,
                    Format = TypelessDxgiFormat,
                    BindFlags = bindFlags,
                    CPUAccessFlags = cpuFlags,
                    Usage = resourceUsage,
                    MiscFlags= optionFlags,
                };

                HRESULT hr = device.CreateTexture1D(&desc1D, null, (ID3D11Texture1D**)&DeviceTexture);
            }
            else if (Type == TextureType.Texture2D)
            {
                D3D11_TEXTURE2D_DESC deviceDescription = D3D11_TEXTURE2D_DESC()
                {
                    Width = roundedWidth,
                    Height = roundedHeight,
                    MipLevels = description.MipLevels,
                    ArraySize = arraySize,
                    Format = TypelessDxgiFormat,
                    BindFlags = bindFlags,
                    CPUAccessFlags = cpuFlags,
                    Usage = resourceUsage,
                    SampleDesc = .(FormatHelpers.GetSampleCountUInt32(SampleCount), 0),
                    MiscFlags = optionFlags,
                };

                HRESULT hr = device.CreateTexture2D(&deviceDescription, null, (ID3D11Texture2D**)&DeviceTexture);
            }
            else
            {
                Debug.Assert(Type == TextureType.Texture3D);
                D3D11_TEXTURE3D_DESC desc3D = D3D11_TEXTURE3D_DESC()
                {
                    Width = roundedWidth,
                    Height = roundedHeight,
                    Depth = description.Depth,
                    MipLevels = description.MipLevels,
                    Format = TypelessDxgiFormat,
                    BindFlags = bindFlags,
                    CPUAccessFlags = cpuFlags,
                    Usage = resourceUsage,
                    MiscFlags = optionFlags,
                };

                HRESULT hr = device.CreateTexture3D(&desc3D, null, (ID3D11Texture3D**)&DeviceTexture);
            }
        }

        public this(ID3D11Texture2D* existingTexture, TextureType type, PixelFormat format)
        {
			ID3D11Device* pDevice = null;
			existingTexture.GetDevice(&pDevice);

            _device = pDevice;
            DeviceTexture = existingTexture;
			D3D11_TEXTURE2D_DESC* existingTextureDesc = existingTexture.GetDesc(.. scope .());
            Width = (uint32)existingTextureDesc.Width;
            Height = (uint32)existingTextureDesc.Height;
            Depth = 1;
            MipLevels = (uint32)existingTextureDesc.MipLevels;
            ArrayLayers = (uint32)existingTextureDesc.ArraySize;
            Format = format;
            SampleCount = FormatHelpers.GetSampleCount((uint32)existingTextureDesc.SampleDesc.Count);
            Type = type;
            Usage = D3D11Formats.GetVdUsage(
                existingTextureDesc.BindFlags,
                existingTextureDesc.CPUAccessFlags,
                existingTextureDesc.MiscFlags);

            DxgiFormat = D3D11Formats.ToDxgiFormat(
                format,
                (Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil);
            TypelessDxgiFormat = D3D11Formats.GetTypelessFormat(DxgiFormat);
        }

        protected override TextureView CreateFullTextureView(GraphicsDevice gd)
        {
            TextureViewDescription desc = TextureViewDescription(this);
            D3D11GraphicsDevice d3d11GD = Util.AssertSubtype<GraphicsDevice, D3D11GraphicsDevice>(gd);
            return new D3D11TextureView(d3d11GD, desc);
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                D3D11Util.SetDebugName(DeviceTexture, value);
            }
        }

        protected override void DisposeCore()
        {
            DeviceTexture.Release();
        }

		public uint32 CalculateSubresourceIndex(uint32 mipSlice, uint32 arraySlice)
		{
			uint32 mipSize = 0;
			switch(Type)
			{
			case .Texture1D:
				return ((ID3D11Texture1D*)DeviceTexture).CalculateSubResourceIndex(mipSlice, arraySlice, &mipSize);
			case .Texture2D:
				return ((ID3D11Texture2D*)DeviceTexture).CalculateSubResourceIndex(mipSlice, arraySlice, &mipSize);
			case .Texture3D:
				return ((ID3D11Texture2D*)DeviceTexture).CalculateSubResourceIndex(mipSlice, arraySlice, &mipSize);
			}
		}
    }
}
