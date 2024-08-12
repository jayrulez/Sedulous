using Vortice.Direct3D11;

namespace Sedulous.GAL.D3D11
{
    internal static class D3D11Util
    {
        public static int32 ComputeSubresource(uint32 mipLevel, uint32 mipLevelCount, uint32 arrayLayer)
        {
            return (int32)((arrayLayer * mipLevelCount) + mipLevel);
        }

        internal static ShaderResourceViewDescription GetSrvDesc(
            D3D11Texture tex,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            PixelFormat format)
        {
            ShaderResourceViewDescription srvDesc = new ShaderResourceViewDescription();
            srvDesc.Format = D3D11Formats.GetViewFormat(
                D3D11Formats.ToDxgiFormat(format, (tex.Usage & TextureUsage.DepthStencil) != 0));

            if ((tex.Usage & TextureUsage.Cubemap) == TextureUsage.Cubemap)
            {
                if (tex.ArrayLayers == 1)
                {
                    srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.TextureCube;
                    srvDesc.TextureCube.MostDetailedMip = (int32)baseMipLevel;
                    srvDesc.TextureCube.MipLevels = (int32)levelCount;
                }
                else
                {
                    srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.TextureCubeArray;
                    srvDesc.TextureCubeArray.MostDetailedMip = (int32)baseMipLevel;
                    srvDesc.TextureCubeArray.MipLevels = (int32)levelCount;
                    srvDesc.TextureCubeArray.First2DArrayFace = (int32)baseArrayLayer;
                    srvDesc.TextureCubeArray.NumCubes = (int32)tex.ArrayLayers;
                }
            }
            else if (tex.Depth == 1)
            {
                if (tex.ArrayLayers == 1)
                {
                    if (tex.Type == TextureType.Texture1D)
                    {
                        srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture1D;
                        srvDesc.Texture1D.MostDetailedMip = (int32)baseMipLevel;
                        srvDesc.Texture1D.MipLevels = (int32)levelCount;
                    }
                    else
                    {
                        if (tex.SampleCount == TextureSampleCount.Count1)
                            srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture2D;
                        else
                            srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture2DMultisampled;
                        srvDesc.Texture2D.MostDetailedMip = (int32)baseMipLevel;
                        srvDesc.Texture2D.MipLevels = (int32)levelCount;
                    }
                }
                else
                {
                    if (tex.Type == TextureType.Texture1D)
                    {
                        srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture1DArray;
                        srvDesc.Texture1DArray.MostDetailedMip = (int32)baseMipLevel;
                        srvDesc.Texture1DArray.MipLevels = (int32)levelCount;
                        srvDesc.Texture1DArray.FirstArraySlice = (int32)baseArrayLayer;
                        srvDesc.Texture1DArray.ArraySize = (int32)layerCount;
                    }
                    else
                    {
                        srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture2DArray;
                        srvDesc.Texture2DArray.MostDetailedMip = (int32)baseMipLevel;
                        srvDesc.Texture2DArray.MipLevels = (int32)levelCount;
                        srvDesc.Texture2DArray.FirstArraySlice = (int32)baseArrayLayer;
                        srvDesc.Texture2DArray.ArraySize = (int32)layerCount;
                    }
                }
            }
            else
            {
                srvDesc.ViewDimension = Vortice.Direct3D.ShaderResourceViewDimension.Texture3D;
                srvDesc.Texture3D.MostDetailedMip = (int32)baseMipLevel;
                srvDesc.Texture3D.MipLevels = (int32)levelCount;
            }

            return srvDesc;
        }

        internal static int32 GetSyncInterval(bool syncToVBlank)
        {
            return syncToVBlank ? 1 : 0;
        }
    }
}
