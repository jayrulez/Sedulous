using Win32.Graphics.Direct3D11;
using System;
using Win32.Foundation;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;

    public class D3D11TextureView : TextureView
    {
        private String _name;
        private bool _disposed;

        public ref ID3D11ShaderResourceView* ShaderResourceView { get; }
        public ref ID3D11UnorderedAccessView* UnorderedAccessView { get; }

        public this(D3D11GraphicsDevice gd, in TextureViewDescription description)
            : base(description)
        {
            ID3D11Device* device = gd.Device;
            D3D11Texture d3dTex = Util.AssertSubtype<Texture, D3D11Texture>(description.Target);
            D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = D3D11Util.GetSrvDesc(
                d3dTex,
                description.BaseMipLevel,
                description.MipLevels,
                description.BaseArrayLayer,
                description.ArrayLayers,
                Format);
            HRESULT hr = device.CreateShaderResourceView(d3dTex.DeviceTexture, &srvDesc, &ShaderResourceView);

            if ((d3dTex.Usage & TextureUsage.Storage) == TextureUsage.Storage)
            {
                D3D11_UNORDERED_ACCESS_VIEW_DESC uavDesc = D3D11_UNORDERED_ACCESS_VIEW_DESC();
                uavDesc.Format = D3D11Formats.GetViewFormat(d3dTex.DxgiFormat);

                if ((d3dTex.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
                {
                    Runtime.NotSupported();
                }
                else if (d3dTex.Depth == 1)
                {
                    if (d3dTex.ArrayLayers == 1)
                    {
                        if (d3dTex.Type == TextureType.Texture1D)
                        {
                            uavDesc.ViewDimension = .D3D11_UAV_DIMENSION_TEXTURE1D;
                            uavDesc.Texture1D.MipSlice = description.BaseMipLevel;
                        }
                        else
                        {
                            uavDesc.ViewDimension = .D3D11_UAV_DIMENSION_TEXTURE2D;
                            uavDesc.Texture2D.MipSlice = description.BaseMipLevel;
                        }
                    }
                    else
                    {
                        if (d3dTex.Type == TextureType.Texture1D)
                        {
                            uavDesc.ViewDimension = .D3D11_UAV_DIMENSION_TEXTURE1DARRAY;
                            uavDesc.Texture1DArray.MipSlice = description.BaseMipLevel;
                            uavDesc.Texture1DArray.FirstArraySlice = description.BaseArrayLayer;
                            uavDesc.Texture1DArray.ArraySize = description.ArrayLayers;
                        }
                        else
                        {
                            uavDesc.ViewDimension = .D3D11_UAV_DIMENSION_TEXTURE2DARRAY;
                            uavDesc.Texture2DArray.MipSlice = description.BaseMipLevel;
                            uavDesc.Texture2DArray.FirstArraySlice = description.BaseArrayLayer;
                            uavDesc.Texture2DArray.ArraySize = description.ArrayLayers;
                        }
                    }
                }
                else
                {
                    uavDesc.ViewDimension = .D3D11_UAV_DIMENSION_TEXTURE3D;
                    uavDesc.Texture3D.MipSlice = description.BaseMipLevel;

                    // Map the entire range of the 3D texture.
                    uavDesc.Texture3D.FirstWSlice = 0;
                    uavDesc.Texture3D.WSize = d3dTex.Depth;
                }

                hr = device.CreateUnorderedAccessView(d3dTex.DeviceTexture, &uavDesc, &UnorderedAccessView);
            }
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                if (ShaderResourceView != null)
				{
				    D3D11Util.SetDebugName(ShaderResourceView, scope $"{value}_SRV");
				}
				if (UnorderedAccessView != null)
				{
				    D3D11Util.SetDebugName(UnorderedAccessView, scope $"{value}_UAV");
				}
            }
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            if (!_disposed)
            {
                ShaderResourceView?.Release();
                UnorderedAccessView?.Release();
                _disposed = true;
            }
        }
    }
}
