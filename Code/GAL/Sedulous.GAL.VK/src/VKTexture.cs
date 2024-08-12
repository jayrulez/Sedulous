﻿using Vulkan;
using static Vulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;
using System.Diagnostics;
using System;

namespace Sedulous.GAL.VK
{
    internal class VKTexture : Texture
    {
        private readonly VKGraphicsDevice _gd;
        private readonly VkImage _optimalImage;
        private readonly VkMemoryBlock _memoryBlock;
        private readonly Vulkan.VkBuffer _stagingBuffer;
        private PixelFormat _format; // Static for regular images -- may change for shared staging images
        private readonly uint32 _actualImageArrayLayers;
        private bool _destroyed;

        // Immutable except for shared staging Textures.
        private uint32 _width;
        private uint32 _height;
        private uint32 _depth;

        public override uint32 Width => _width;

        public override uint32 Height => _height;

        public override uint32 Depth => _depth;

        public override PixelFormat Format => _format;

        public override uint32 MipLevels { get; }

        public override uint32 ArrayLayers { get; }
        public uint32 ActualArrayLayers => _actualImageArrayLayers;

        public override TextureUsage Usage { get; }

        public override TextureType Type { get; }

        public override TextureSampleCount SampleCount { get; }

        public override bool IsDisposed => _destroyed;

        public VkImage OptimalDeviceImage => _optimalImage;
        public Vulkan.VkBuffer StagingBuffer => _stagingBuffer;
        public VkMemoryBlock Memory => _memoryBlock;

        public VkFormat VkFormat { get; }
        public VkSampleCountFlags VkSampleCount { get; }

        private VkImageLayout[] _imageLayouts;
        private bool _isSwapchainTexture;
        private string _name;

        public ResourceRefCount RefCount { get; }
        public bool IsSwapchainTexture => _isSwapchainTexture;

        internal VKTexture(VKGraphicsDevice gd, ref TextureDescription description)
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
                VkImageCreateInfo imageCI = VkImageCreateInfo.New();
                imageCI.mipLevels = MipLevels;
                imageCI.arrayLayers = _actualImageArrayLayers;
                imageCI.imageType = VKFormats.VdToVkTextureType(Type);
                imageCI.extent.width = Width;
                imageCI.extent.height = Height;
                imageCI.extent.depth = Depth;
                imageCI.initialLayout = VkImageLayout.Preinitialized;
                imageCI.usage = VKFormats.VdToVkTextureUsage(Usage);
                imageCI.tiling = isStaging ? VkImageTiling.Linear : VkImageTiling.Optimal;
                imageCI.format = VkFormat;
                imageCI.flags = VkImageCreateFlags.MutableFormat;

                imageCI.samples = VkSampleCount;
                if (isCubemap)
                {
                    imageCI.flags |= VkImageCreateFlags.CubeCompatible;
                }

                uint32 subresourceCount = MipLevels * _actualImageArrayLayers * Depth;
                VkResult result = vkCreateImage(gd.Device, ref imageCI, null, out _optimalImage);
                CheckResult(result);

                VkMemoryRequirements memoryRequirements;
                bool prefersDedicatedAllocation;
                if (_gd.GetImageMemoryRequirements2 != null)
                {
                    VkImageMemoryRequirementsInfo2KHR memReqsInfo2 = VkImageMemoryRequirementsInfo2KHR.New();
                    memReqsInfo2.image = _optimalImage;
                    VkMemoryRequirements2KHR memReqs2 = VkMemoryRequirements2KHR.New();
                    VkMemoryDedicatedRequirementsKHR dedicatedReqs = VkMemoryDedicatedRequirementsKHR.New();
                    memReqs2.pNext = &dedicatedReqs;
                    _gd.GetImageMemoryRequirements2(_gd.Device, &memReqsInfo2, &memReqs2);
                    memoryRequirements = memReqs2.memoryRequirements;
                    prefersDedicatedAllocation = dedicatedReqs.prefersDedicatedAllocation || dedicatedReqs.requiresDedicatedAllocation;
                }
                else
                {
                    vkGetImageMemoryRequirements(gd.Device, _optimalImage, out memoryRequirements);
                    prefersDedicatedAllocation = false;
                }

                VkMemoryBlock memoryToken = gd.MemoryManager.Allocate(
                    gd.PhysicalDeviceMemProperties,
                    memoryRequirements.memoryTypeBits,
                    VkMemoryPropertyFlags.DeviceLocal,
                    false,
                    memoryRequirements.size,
                    memoryRequirements.alignment,
                    prefersDedicatedAllocation,
                    _optimalImage,
                    Vulkan.VkBuffer.Null);
                _memoryBlock = memoryToken;
                result = vkBindImageMemory(gd.Device, _optimalImage, _memoryBlock.DeviceMemory, _memoryBlock.Offset);
                CheckResult(result);

                _imageLayouts = new VkImageLayout[subresourceCount];
                for (int32 i = 0; i < _imageLayouts.Length; i++)
                {
                    _imageLayouts[i] = VkImageLayout.Preinitialized;
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
                    Util.GetMipDimensions(this, level, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);

                    depthPitch = FormatHelpers.GetDepthPitch(
                        FormatHelpers.GetRowPitch(mipWidth, Format),
                        mipHeight,
                        Format);

                    stagingSize += depthPitch * mipDepth;
                }
                stagingSize *= ArrayLayers;

                VkBufferCreateInfo bufferCI = VkBufferCreateInfo.New();
                bufferCI.usage = VkBufferUsageFlags.TransferSrc | VkBufferUsageFlags.TransferDst;
                bufferCI.size = stagingSize;
                VkResult result = vkCreateBuffer(_gd.Device, ref bufferCI, null, out _stagingBuffer);
                CheckResult(result);

                VkMemoryRequirements bufferMemReqs;
                bool prefersDedicatedAllocation;
                if (_gd.GetBufferMemoryRequirements2 != null)
                {
                    VkBufferMemoryRequirementsInfo2KHR memReqInfo2 = VkBufferMemoryRequirementsInfo2KHR.New();
                    memReqInfo2.buffer = _stagingBuffer;
                    VkMemoryRequirements2KHR memReqs2 = VkMemoryRequirements2KHR.New();
                    VkMemoryDedicatedRequirementsKHR dedicatedReqs = VkMemoryDedicatedRequirementsKHR.New();
                    memReqs2.pNext = &dedicatedReqs;
                    _gd.GetBufferMemoryRequirements2(_gd.Device, &memReqInfo2, &memReqs2);
                    bufferMemReqs = memReqs2.memoryRequirements;
                    prefersDedicatedAllocation = dedicatedReqs.prefersDedicatedAllocation || dedicatedReqs.requiresDedicatedAllocation;
                }
                else
                {
                    vkGetBufferMemoryRequirements(gd.Device, _stagingBuffer, out bufferMemReqs);
                    prefersDedicatedAllocation = false;
                }

                // Use "host cached" memory when available, for better performance of GPU -> CPU transfers
                var propertyFlags = VkMemoryPropertyFlags.HostVisible | VkMemoryPropertyFlags.HostCoherent | VkMemoryPropertyFlags.HostCached;
                if (!TryFindMemoryType(_gd.PhysicalDeviceMemProperties, bufferMemReqs.memoryTypeBits, propertyFlags, out _))
                {
                    propertyFlags ^= VkMemoryPropertyFlags.HostCached;
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
            RefCount = new ResourceRefCount(RefCountedDispose);
        }

        // Used to construct Swapchain textures.
        internal VKTexture(
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
            _imageLayouts = new[] { VkImageLayout.Undefined };
            _isSwapchainTexture = true;

            ClearIfRenderTarget();
            RefCount = new ResourceRefCount(DisposeCore);
        }

        private void ClearIfRenderTarget()
        {
            // If the image is going to be used as a render target, we need to clear the data before its first use.
            if ((Usage & TextureUsage.RenderTarget) != 0)
            {
                _gd.ClearColorTexture(this, new VkClearColorValue(0, 0, 0, 0));
            }
            else if ((Usage & TextureUsage.DepthStencil) != 0)
            {
                _gd.ClearDepthTexture(this, new VkClearDepthStencilValue(0, 0));
            }
        }

        private void TransitionIfSampled()
        {
            if ((Usage & TextureUsage.Sampled) != 0)
            {
                _gd.TransitionImageLayout(this, VkImageLayout.ShaderReadOnlyOptimal);
            }
        }

        internal VkSubresourceLayout GetSubresourceLayout(uint32 subresource)
        {
            bool staging = _stagingBuffer.Handle != 0;
            Util.GetMipLevelAndArrayLayer(this, subresource, out uint32 mipLevel, out uint32 arrayLayer);
            if (!staging)
            {
                VkImageAspectFlags aspect = (Usage & TextureUsage.DepthStencil) == TextureUsage.DepthStencil
                  ? (VkImageAspectFlags.Depth | VkImageAspectFlags.Stencil)
                  : VkImageAspectFlags.Color;
                VkImageSubresource imageSubresource = new VkImageSubresource
                {
                    arrayLayer = arrayLayer,
                    mipLevel = mipLevel,
                    aspectMask = aspect,
                };

                vkGetImageSubresourceLayout(_gd.Device, _optimalImage, ref imageSubresource, out VkSubresourceLayout layout);
                return layout;
            }
            else
            {
                uint32 blockSize = FormatHelpers.IsCompressedFormat(Format) ? 4u : 1u;
                Util.GetMipDimensions(this, mipLevel, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);
                uint32 rowPitch = FormatHelpers.GetRowPitch(mipWidth, Format);
                uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, mipHeight, Format);

                VkSubresourceLayout layout = new VkSubresourceLayout()
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
            if (_stagingBuffer != Vulkan.VkBuffer.Null)
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
                        ? VkImageAspectFlags.Depth | VkImageAspectFlags.Stencil
                        : VkImageAspectFlags.Depth;
                }
                else
                {
                    aspectMask = VkImageAspectFlags.Color;
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
            if (_stagingBuffer != Vulkan.VkBuffer.Null)
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
                                ? VkImageAspectFlags.Depth | VkImageAspectFlags.Stencil
                                : VkImageAspectFlags.Depth;
                        }
                        else
                        {
                            aspectMask = VkImageAspectFlags.Color;
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

        public override string Name
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
            Debug.Assert(_stagingBuffer != Vulkan.VkBuffer.Null);
            Debug.Assert(Usage == TextureUsage.Staging);
            _width = width;
            _height = height;
            _depth = depth;
            _format = format;
        }

        private protected override void DisposeCore()
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
