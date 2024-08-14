using System;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    internal class MTLTexture : Texture
    {
        private bool _disposed;

        /// <summary>
        /// The native MTLTexture object. This property is only valid for non-staging Textures.
        /// </summary>
        public Sedulous.MetalBindings.MTLTexture DeviceTexture { get; }
        /// <summary>
        /// The staging MTLBuffer object. This property is only valid for staging Textures.
        /// </summary>
        public Sedulous.MetalBindings.MTLBuffer StagingBuffer { get; }

        public override PixelFormat Format { get; protected set; }

        public override uint32 Width { get; protected set; }

        public override uint32 Height { get; protected set; }

        public override uint32 Depth { get; protected set; }

        public override uint32 MipLevels { get; protected set; }

        public override uint32 ArrayLayers { get; protected set; }

        public override TextureUsage Usage { get; protected set; }

        public override TextureType Type { get; protected set; }

        public override TextureSampleCount SampleCount { get; protected set; }
        public override String Name { get; set; }
        public override bool IsDisposed => _disposed;
        public MTLPixelFormat MTLPixelFormat { get; }
        public MTLTextureType MTLTextureType { get; }

        public this(in TextureDescription description, MTLGraphicsDevice _gd)
        {
            Width = description.Width;
            Height = description.Height;
            Depth = description.Depth;
            ArrayLayers = description.ArrayLayers;
            MipLevels = description.MipLevels;
            Format = description.Format;
            Usage = description.Usage;
            Type = description.Type;
            SampleCount = description.SampleCount;
            bool isDepth = (Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil;

            MTLPixelFormat = MTLFormats.VdToMTLPixelFormat(Format, isDepth);
            MTLTextureType = MTLFormats.VdToMTLTextureType(
                    Type,
                    ArrayLayers,
                    SampleCount != TextureSampleCount.Count1,
                    (Usage & TextureUsage.Cubemap) != 0);
            if (Usage != TextureUsage.Staging)
            {
                MTLTextureDescriptor texDescriptor = MTLTextureDescriptor.New();
                texDescriptor.width = (uint)Width;
                texDescriptor.height = (uint)Height;
                texDescriptor.depth = (uint)Depth;
                texDescriptor.mipmapLevelCount = (uint)MipLevels;
                texDescriptor.arrayLength = (uint)ArrayLayers;
                texDescriptor.sampleCount = (uint)FormatHelpers.GetSampleCountUInt32(SampleCount);
                texDescriptor.textureType = MTLTextureType;
                texDescriptor.pixelFormat = MTLPixelFormat;
                texDescriptor.textureUsage = MTLFormats.VdToMTLTextureUsage(Usage);
                texDescriptor.storageMode = MTLStorageMode.Private;

                DeviceTexture = _gd.Device.newTextureWithDescriptor(texDescriptor);
                ObjectiveCRuntime.release(texDescriptor.NativePtr);
            }
            else
            {
                uint32 blockSize = FormatHelpers.IsCompressedFormat(Format) ? 4u : 1u;
                uint32 totalStorageSize = 0;
                for (uint32 level = 0; level < MipLevels; level++)
                {
                    Util.GetMipDimensions(this, level, var levelWidth, var levelHeight, var levelDepth);
                    uint32 storageWidth = Math.Max(levelWidth, blockSize);
                    uint32 storageHeight = Math.Max(levelHeight, blockSize);
                    totalStorageSize += levelDepth * FormatHelpers.GetDepthPitch(
                        FormatHelpers.GetRowPitch(levelWidth, Format),
                        levelHeight,
                        Format);
                }
                totalStorageSize *= ArrayLayers;

                StagingBuffer = _gd.Device.newBufferWithLengthOptions(
                    (uint)totalStorageSize,
                    MTLResourceOptions.StorageModeShared);
            }
        }

        public this(uint64 nativeTexture, in TextureDescription description)
        {
            DeviceTexture = Sedulous.MetalBindings.MTLTexture((void*)(int)nativeTexture);
            Width = description.Width;
            Height = description.Height;
            Depth = description.Depth;
            ArrayLayers = description.ArrayLayers;
            MipLevels = description.MipLevels;
            Format = description.Format;
            Usage = description.Usage;
            Type = description.Type;
            SampleCount = description.SampleCount;
            bool isDepth = (Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil;

            MTLPixelFormat = MTLFormats.VdToMTLPixelFormat(Format, isDepth);
            MTLTextureType = MTLFormats.VdToMTLTextureType(
                    Type,
                    ArrayLayers,
                    SampleCount != TextureSampleCount.Count1,
                    (Usage & TextureUsage.Cubemap) != 0);
        }

        internal uint32 GetSubresourceSize(uint32 mipLevel, uint32 arrayLayer)
        {
            uint32 blockSize = FormatHelpers.IsCompressedFormat(Format) ? 4 : 1;
            Util.GetMipDimensions(this, mipLevel, var width, var height, var depth);
            uint32 storageWidth = Math.Max(blockSize, width);
            uint32 storageHeight = Math.Max(blockSize, height);
            return depth * FormatHelpers.GetDepthPitch(
                FormatHelpers.GetRowPitch(storageWidth, Format),
                storageHeight,
                Format);
        }

        internal void GetSubresourceLayout(uint32 mipLevel, uint32 arrayLayer, out uint32 rowPitch, out uint32 depthPitch)
        {
            uint32 blockSize = FormatHelpers.IsCompressedFormat(Format) ? 4 : 1;
            Util.GetMipDimensions(this, mipLevel, var mipWidth, var mipHeight, var mipDepth);
            uint32 storageWidth = Math.Max(blockSize, mipWidth);
            uint32 storageHeight = Math.Max(blockSize, mipHeight);
            rowPitch = FormatHelpers.GetRowPitch(storageWidth, Format);
            depthPitch = FormatHelpers.GetDepthPitch(rowPitch, storageHeight, Format);
        }

        protected override void DisposeCore()
        {
            if (!_disposed)
            {
                _disposed = true;
                if (!StagingBuffer.IsNull)
                {
                    ObjectiveCRuntime.release(StagingBuffer.NativePtr);
                }
                else
                {
                    ObjectiveCRuntime.release(DeviceTexture.NativePtr);
                }
            }
        }
    }
}
