using Win32.Graphics.Direct3D11;
using System;
using Win32.Graphics.Direct3D;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL.D3D11;

    internal static class D3D11Util
    {
        public static int32 ComputeSubresource(uint32 mipLevel, uint32 mipLevelCount, uint32 arrayLayer)
        {
            return (int32)((arrayLayer * mipLevelCount) + mipLevel);
        }

        internal static D3D11_SHADER_RESOURCE_VIEW_DESC GetSrvDesc(
            D3D11Texture tex,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            PixelFormat format)
        {
            D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc = D3D11_SHADER_RESOURCE_VIEW_DESC();
            srvDesc.Format = D3D11Formats.GetViewFormat(
                D3D11Formats.ToDxgiFormat(format, (tex.Usage & TextureUsage.DepthStencil) != 0));

            if ((tex.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
            {
                if (tex.ArrayLayers == 1)
                {
                    srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURECUBE;
                    srvDesc.TextureCube.MostDetailedMip = baseMipLevel;
                    srvDesc.TextureCube.MipLevels = levelCount;
                }
                else
                {
                    srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURECUBEARRAY;
                    srvDesc.TextureCubeArray.MostDetailedMip = baseMipLevel;
                    srvDesc.TextureCubeArray.MipLevels = levelCount;
                    srvDesc.TextureCubeArray.First2DArrayFace = baseArrayLayer;
                    srvDesc.TextureCubeArray.NumCubes = tex.ArrayLayers;
                }
            }
            else if (tex.Depth == 1)
            {
                if (tex.ArrayLayers == 1)
                {
                    if (tex.Type == TextureType.Texture1D)
                    {
                        srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE1D;
                        srvDesc.Texture1D.MostDetailedMip = baseMipLevel;
                        srvDesc.Texture1D.MipLevels = levelCount;
                    }
                    else
                    {
                        if (tex.SampleCount == TextureSampleCount.Count1)
                            srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE2D;
                        else
                            srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE2DMS;
                        srvDesc.Texture2D.MostDetailedMip = baseMipLevel;
                        srvDesc.Texture2D.MipLevels = levelCount;
                    }
                }
                else
                {
                    if (tex.Type == TextureType.Texture1D)
                    {
                        srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE1DARRAY;
                        srvDesc.Texture1DArray.MostDetailedMip = baseMipLevel;
                        srvDesc.Texture1DArray.MipLevels = levelCount;
                        srvDesc.Texture1DArray.FirstArraySlice = baseArrayLayer;
                        srvDesc.Texture1DArray.ArraySize = layerCount;
                    }
                    else
                    {
                        srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE2DARRAY;
                        srvDesc.Texture2DArray.MostDetailedMip = baseMipLevel;
                        srvDesc.Texture2DArray.MipLevels = levelCount;
                        srvDesc.Texture2DArray.FirstArraySlice = baseArrayLayer;
                        srvDesc.Texture2DArray.ArraySize = layerCount;
                    }
                }
            }
            else
            {
                srvDesc.ViewDimension = .D3D_SRV_DIMENSION_TEXTURE3D;
                srvDesc.Texture3D.MostDetailedMip = baseMipLevel;
                srvDesc.Texture3D.MipLevels = levelCount;
            }

            return srvDesc;
        }

        internal static int32 GetSyncInterval(bool syncToVBlank)
        {
            return syncToVBlank ? 1 : 0;
        }

		internal static void SetDebugName(ID3D11DeviceChild* deviceObject, StringView name)
		{
			deviceObject.SetPrivateData(WKPDID_D3DDebugObjectName, (.)name.Length, name.Ptr);
		}
    }
}
