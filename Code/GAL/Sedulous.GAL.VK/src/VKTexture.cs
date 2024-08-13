using Bulkan;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using static Sedulous.GAL.VK.VKFormats;
using System.Diagnostics;
using System;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    public class VKTexture : Texture
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkImage _optimalImage;
        private readonly VkMemoryBlock _memoryBlock;
        private readonly VkBuffer _stagingBuffer;
        private PixelFormat _format; // Static for regular images -- may change for shared staging images
        private readonly uint32 _actualImageArrayLayers;
        private bool _destroyed;

        // Immutable except for shared staging Textures.
        private uint32 _width;
        private uint32 _height;
        private uint32 _depth;

        public override uint32 Width { get => _width; protected set {} }

        public override uint32 Height { get => _height; protected set {} }

        public override uint32 Depth  { get => _depth; protected set {} }

        public override PixelFormat Format { get => _format; protected set {} }

        public override uint32 MipLevels { get; protected set; }

        public override uint32 ArrayLayers { get; protected set; }
        public uint32 ActualArrayLayers => _actualImageArrayLayers;

        public override TextureUsage Usage { get; protected set; }

        public override TextureType Type { get; protected set; }

        public override TextureSampleCount SampleCount { get; protected set; }

        public override bool IsDisposed => _destroyed;

        public VkImage OptimalDeviceImage => _optimalImage;
        public VkBuffer StagingBuffer => _stagingBuffer;
        internal VkMemoryBlock Memory => _memoryBlock;

        public VkFormat VkFormat { get; }
        public VkSampleCountFlags VkSampleCount { get; }

        private VkImageLayout[] _imageLayouts;
        private bool _isSwapchainTexture;
        private String _name;

        internal ResourceRefCount RefCount { get; }
        public bool IsSwapchainTexture => _isSwapchainTexture;

        internal this(VKGraphicsDevice gd, in TextureDescription description)
        {
            _gd = gd;
            _width = description.Width;
            _height = description.Height;
            _depth = description.Depth;
            MipLevels = description.MipLevels;
            ArrayLayers = description.ArrayLayers;
            bool isCubemap = ((description.Usage) & TextureUsage.Cubemap) == TextureUsage.Cubemap;
            _actualImageArrayLayers = isCubemap
                ? 6 * ArrayLayers
                : ArrayLayers;
            _format = description.Format;
            Usage = description.Usage;
            Type = description.Type;
            SampleCount = description.SampleCount;
            VkSampleCount = VKFormats.VdToVkSampleCount(SampleCount);
            VkFormat = VKFormats.VdToVkPixelFormat(Format, (description.Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil);

            bool isStaging = (Usage & TextureUsage.Staging) == TextureUsage.Staging;

            if (!isStaging)
            {
                VkImageCreateInfo imageCI = VkImageCreateInfo() {sType = .VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO};
                imageCI.mipLevels = MipLevels;
                imageCI.arrayLayers = _actualImageArrayLayers;
                imageCI.imageType = VKFormats.VdToVkTextureType(Type);
                imageCI.extent.width = Width;
                imageCI.extent.height = Height;
                imageCI.extent.depth = Depth;
                imageCI.initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED;
                imageCI.usage = VKFormats.VdToVkTextureUsage(Usage);
                imageCI.tiling = isStaging ? VkImageTiling.VK_IMAGE_TILING_LINEAR : VkImageTiling.VK_IMAGE_TILING_OPTIMAL;
                imageCI.format = VkFormat;
                imageCI.flags = VkImageCreateFlags.VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT;

                imageCI.samples = VkSampleCount;
                if (isCubemap)
                {
                    imageCI.flags |= VkImageCreateFlags.VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT;
                }

                uint32 subresourceCount = MipLevels * _actualImageArrayLayers * Depth;
                VkResult result = vkCreateImage(gd.Device, &imageCI, null, &_optimalImage);
                CheckResult(result);

                VkMemoryRequirements memoryRequirements = .();
                bool prefersDedicatedAllocation;
                if (_gd.GetImageMemoryRequirements2 != null)
                {
                    VkImageMemoryRequirementsInfo2 memReqsInfo2 = VkImageMemoryRequirementsInfo2() {sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2};
                    memReqsInfo2.image = _optimalImage;
                    VkMemoryRequirements2 memReqs2 = VkMemoryRequirements2() {sType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2};
                    VkMemoryDedicatedRequirements dedicatedReqs = VkMemoryDedicatedRequirements() {sType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS};
                    memReqs2.pNext = &dedicatedReqs;
                    _gd.GetImageMemoryRequirements2(_gd.Device, &memReqsInfo2, &memReqs2);
                    memoryRequirements = memReqs2.memoryRequirements;
                    prefersDedicatedAllocation = dedicatedReqs.prefersDedicatedAllocation || dedicatedReqs.requiresDedicatedAllocation;
                }
                else
                {
                    vkGetImageMemoryRequirements(gd.Device, _optimalImage, &memoryRequirements);
                    prefersDedicatedAllocation = false;
                }

                VkMemoryBlock memoryToken = gd.MemoryManager.Allocate(
                    gd.PhysicalDeviceMemProperties,
                    memoryRequirements.memoryTypeBits,
                    VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
                    false,
                    memoryRequirements.size,
                    memoryRequirements.alignment,
                    prefersDedicatedAllocation,
                    _optimalImage,
                    .Null);
                _memoryBlock = memoryToken;
                result = vkBindImageMemory(gd.Device, _optimalImage, _memoryBlock.DeviceMemory, _memoryBlock.Offset);
                CheckResult(result);

                _imageLayouts = new VkImageLayout[subresourceCount];
                for (int i = 0; i < _imageLayouts.Count; i++)
                {
                    _imageLayouts[i] = VkImageLayout.VK_IMAGE_LAYOUT_PREINITIALIZED;
                }
            }
            else // isStaging
            {
                uint32 depthPitch = FormatHelpers.GetDepthPitch(
                    FormatHelpers.GetRowPitch(Width, Format),
                    Height,
                    Format);
                uint32 stagingSize = depthPitch * Depth;
                for (uint32 level = 1; level < MipLevels; level++)
                {
                    Util.GetMipDimensions(this, level, var mipWidth, var mipHeight, var mipDepth);

                    depthPitch = FormatHelpers.GetDepthPitch(
                        FormatHelpers.GetRowPitch(mipWidth, Format),
                        mipHeight,
                        Format);

                    stagingSize += depthPitch * mipDepth;
                }
                stagingSize *= ArrayLayers;

                VkBufferCreateInfo bufferCI = VkBufferCreateInfo() {sType = .VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO};
                bufferCI.usage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
                bufferCI.size = stagingSize;
                VkResult result = vkCreateBuffer(_gd.Device, &bufferCI, null, &_stagingBuffer);
                CheckResult(result);

                VkMemoryRequirements bufferMemReqs = .();
                bool prefersDedicatedAllocation;
                if (_gd.GetBufferMemoryRequirements2 != null)
                {
                    VkBufferMemoryRequirementsInfo2 memReqInfo2 = VkBufferMemoryRequirementsInfo2() {sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2};
                    memReqInfo2.buffer = _stagingBuffer;
                    VkMemoryRequirements2 memReqs2 = VkMemoryRequirements2() {sType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2};
                    VkMemoryDedicatedRequirements dedicatedReqs = VkMemoryDedicatedRequirements() {sType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS};
                    memReqs2.pNext = &dedicatedReqs;
                    _gd.GetBufferMemoryRequirements2(_gd.Device, &memReqInfo2, &memReqs2);
                    bufferMemReqs = memReqs2.memoryRequirements;
                    prefersDedicatedAllocation = dedicatedReqs.prefersDedicatedAllocation || dedicatedReqs.requiresDedicatedAllocation;
                }
                else
                {
                    vkGetBufferMemoryRequirements(gd.Device, _stagingBuffer, &bufferMemReqs);
                    prefersDedicatedAllocation = false;
                }

                // Use "host cached" memory when available, for better performance of GPU -> CPU transfers
                var propertyFlags = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_CACHED_BIT;
                if (!TryFindMemoryType(_gd.PhysicalDeviceMemProperties, bufferMemReqs.memoryTypeBits, propertyFlags, ?))
                {
                    propertyFlags ^= VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_CACHED_BIT;
                }
                _memoryBlock = _gd.MemoryManager.Allocate(
                    _gd.PhysicalDeviceMemProperties,
                    bufferMemReqs.memoryTypeBits,
                    propertyFlags,
                    true,
                    bufferMemReqs.size,
                    bufferMemReqs.alignment,
                    prefersDedicatedAllocation,
                    VkImage.Null,
                    _stagingBuffer);

                result = vkBindBufferMemory(_gd.Device, _stagingBuffer, _memoryBlock.DeviceMemory, _memoryBlock.Offset);
                CheckResult(result);
            }

            ClearIfRenderTarget();
            TransitionIfSampled();
            RefCount = new ResourceRefCount(new => RefCountedDispose);
        }

        // Used to construct Swapchain textures.
        internal this(
            VKGraphicsDevice gd,
            uint32 width,
            uint32 height,
            uint32 mipLevels,
            uint32 arrayLayers,
            VkFormat vkFormat,
            TextureUsage usage,
            TextureSampleCount sampleCount,
            VkImage existingImage)
        {
            Debug.Assert(width > 0 && height > 0);
            _gd = gd;
            MipLevels = mipLevels;
            _width = width;
            _height = height;
            _depth = 1;
            VkFormat = vkFormat;
            _format = VKFormats.VkToVdPixelFormat(VkFormat);
            ArrayLayers = arrayLayers;
            Usage = usage;
            Type = TextureType.Texture2D;
            SampleCount = sampleCount;
            VkSampleCount = VKFormats.VdToVkSampleCount(sampleCount);
            _optimalImage = existingImage;
            _imageLayouts = new .[](VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED);
            _isSwapchainTexture = true;

            ClearIfRenderTarget();
            RefCount = new ResourceRefCount(new => DisposeCore);
        }

        private void ClearIfRenderTarget()
        {
            // If the image is going to be used as a render target, we need to clear the data before its first use.
            if ((Usage & TextureUsage.RenderTarget) != 0)
            {
                _gd.ClearColorTexture(this, VkClearColorValue(0, 0, 0, 0));
            }
            else if ((Usage & TextureUsage.DepthStencil) != 0)
            {
                _gd.ClearDepthTexture(this, VkClearDepthStencilValue(0, 0));
            }
        }

        private void TransitionIfSampled()
        {
            if ((Usage & TextureUsage.Sampled) != 0)
            {
                _gd.TransitionImageLayout(this, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
            }
        }

        internal VkSubresourceLayout GetSubresourceLayout(uint32 subresource)
        {
            bool staging = _stagingBuffer.Handle != 0;
            Util.GetMipLevelAndArrayLayer(this, subresource, var mipLevel, var arrayLayer);
            if (!staging)
            {
                VkImageAspectFlags aspect = (Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil
                  ? (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT)
                  : VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
                VkImageSubresource imageSubresource = VkImageSubresource()
                {
                    arrayLayer = arrayLayer,
                    mipLevel = mipLevel,
                    aspectMask = aspect,
                };

				VkSubresourceLayout layout = .();
                vkGetImageSubresourceLayout(_gd.Device, _optimalImage, &imageSubresource, &layout);
                return layout;
            }
            else
            {
                uint32 blockSize = FormatHelpers.IsCompressedFormat(Format) ? 4 : 1;
                Util.GetMipDimensions(this, mipLevel, var mipWidth, var mipHeight, var mipDepth);
                uint32 rowPitch = FormatHelpers.GetRowPitch(mipWidth, Format);
                uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, mipHeight, Format);

                VkSubresourceLayout layout = VkSubresourceLayout()
                {
                    rowPitch = rowPitch,
                    depthPitch = depthPitch,
                    arrayPitch = depthPitch,
                    size = depthPitch,
                };
                layout.offset = Util.ComputeSubresourceOffset(this, mipLevel, arrayLayer);

                return layout;
            }
        }

        internal void TransitionImageLayout(
            VkCommandBuffer cb,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            VkImageLayout newLayout)
        {
            if (_stagingBuffer != .Null)
            {
                return;
            }

            VkImageLayout oldLayout = _imageLayouts[CalculateSubresource(baseMipLevel, baseArrayLayer)];
#if DEBUG
            for (uint32 level = 0; level < levelCount; level++)
            {
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    if (_imageLayouts[CalculateSubresource(baseMipLevel + level, baseArrayLayer + layer)] != oldLayout)
                    {
                        Runtime.GALError("Unexpected image layout.");
                    }
                }
            }
#endif
            if (oldLayout != newLayout)
            {
                VkImageAspectFlags aspectMask;
                if ((Usage & TextureUsage.DepthStencil) != 0)
                {
                    aspectMask = FormatHelpers.IsStencilFormat(Format)
                        ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
                        : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
                }
                else
                {
                    aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
                }
                VulkanUtil.TransitionImageLayout(
                    cb,
                    OptimalDeviceImage,
                    baseMipLevel,
                    levelCount,
                    baseArrayLayer,
                    layerCount,
                    aspectMask,
                    _imageLayouts[CalculateSubresource(baseMipLevel, baseArrayLayer)],
                    newLayout);

                for (uint32 level = 0; level < levelCount; level++)
                {
                    for (uint32 layer = 0; layer < layerCount; layer++)
                    {
                        _imageLayouts[CalculateSubresource(baseMipLevel + level, baseArrayLayer + layer)] = newLayout;
                    }
                }
            }
        }

        internal void TransitionImageLayoutNonmatching(
            VkCommandBuffer cb,
            uint32 baseMipLevel,
            uint32 levelCount,
            uint32 baseArrayLayer,
            uint32 layerCount,
            VkImageLayout newLayout)
        {
            if (_stagingBuffer != .Null)
            {
                return;
            }

            for (uint32 level = baseMipLevel; level < baseMipLevel + levelCount; level++)
            {
                for (uint32 layer = baseArrayLayer; layer < baseArrayLayer + layerCount; layer++)
                {
                    uint32 subresource = CalculateSubresource(level, layer);
                    VkImageLayout oldLayout = _imageLayouts[subresource];

                    if (oldLayout != newLayout)
                    {
                        VkImageAspectFlags aspectMask;
                        if ((Usage & TextureUsage.DepthStencil) != 0)
                        {
                            aspectMask = FormatHelpers.IsStencilFormat(Format)
                                ? VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT
                                : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
                        }
                        else
                        {
                            aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
                        }
                        VulkanUtil.TransitionImageLayout(
                            cb,
                            OptimalDeviceImage,
                            level,
                            1,
                            layer,
                            1,
                            aspectMask,
                            oldLayout,
                            newLayout);

                        _imageLayouts[subresource] = newLayout;
                    }
                }
            }
        }

        internal VkImageLayout GetImageLayout(uint32 mipLevel, uint32 arrayLayer)
        {
            return _imageLayouts[CalculateSubresource(mipLevel, arrayLayer)];
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                _gd.SetResourceName(this, value);
            }
        }

        internal void SetStagingDimensions(uint32 width, uint32 height, uint32 depth, PixelFormat format)
        {
            Debug.Assert(_stagingBuffer != .Null);
            Debug.Assert(Usage == TextureUsage.Staging);
            _width = width;
            _height = height;
            _depth = depth;
            _format = format;
        }

        protected override void DisposeCore()
        {
            RefCount.Decrement();
        }

        private void RefCountedDispose()
        {
            if (!_destroyed)
            {
                base.Dispose();

                _destroyed = true;

                bool isStaging = (Usage & TextureUsage.Staging) == TextureUsage.Staging;
                if (isStaging)
                {
                    vkDestroyBuffer(_gd.Device, _stagingBuffer, null);
                }
                else
                {
                    vkDestroyImage(_gd.Device, _optimalImage, null);
                }

                if (_memoryBlock.DeviceMemory.Handle != 0)
                {
                    _gd.MemoryManager.Free(_memoryBlock);
                }
            }
        }

        internal void SetImageLayout(uint32 mipLevel, uint32 arrayLayer, VkImageLayout layout)
        {
            _imageLayouts[CalculateSubresource(mipLevel, arrayLayer)] = layout;
        }
    }
}
