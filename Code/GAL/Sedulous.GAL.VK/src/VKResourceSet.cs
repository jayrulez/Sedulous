﻿using System.Collections.Generic;
using Vulkan;
using static Vulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;

namespace Sedulous.GAL.VK
{
    internal class VKResourceSet : ResourceSet
    {
        private readonly VKGraphicsDevice _gd;
        private readonly DescriptorResourceCounts _descriptorCounts;
        private readonly DescriptorAllocationToken _descriptorAllocationToken;
        private readonly List<ResourceRefCount> _refCounts = new List<ResourceRefCount>();
        private bool _destroyed;
        private string _name;

        public VkDescriptorSet DescriptorSet => _descriptorAllocationToken.Set;

        private readonly List<VKTexture> _sampledTextures = new List<VKTexture>();
        public List<VKTexture> SampledTextures => _sampledTextures;
        private readonly List<VKTexture> _storageImages = new List<VKTexture>();
        public List<VKTexture> StorageTextures => _storageImages;

        public ResourceRefCount RefCount { get; }
        public List<ResourceRefCount> RefCounts => _refCounts;

        public override bool IsDisposed => _destroyed;

        public VKResourceSet(VKGraphicsDevice gd, ref ResourceSetDescription description)
            : base(ref description)
        {
            _gd = gd;
            RefCount = new ResourceRefCount(DisposeCore);
            VKResourceLayout vkLayout = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(description.Layout);

            VkDescriptorSetLayout dsl = vkLayout.DescriptorSetLayout;
            _descriptorCounts = vkLayout.DescriptorResourceCounts;
            _descriptorAllocationToken = _gd.DescriptorPoolManager.Allocate(_descriptorCounts, dsl);

            BindableResource[] boundResources = description.BoundResources;
            uint32 descriptorWriteCount = (uint32)boundResources.Length;
            VkWriteDescriptorSet* descriptorWrites = stackalloc VkWriteDescriptorSet[(int32)descriptorWriteCount];
            VkDescriptorBufferInfo* bufferInfos = stackalloc VkDescriptorBufferInfo[(int32)descriptorWriteCount];
            VkDescriptorImageInfo* imageInfos = stackalloc VkDescriptorImageInfo[(int32)descriptorWriteCount];

            for (int32 i = 0; i < descriptorWriteCount; i++)
            {
                VkDescriptorType type = vkLayout.DescriptorTypes[i];

                descriptorWrites[i].sType = VkStructureType.WriteDescriptorSet;
                descriptorWrites[i].descriptorCount = 1;
                descriptorWrites[i].descriptorType = type;
                descriptorWrites[i].dstBinding = (uint32)i;
                descriptorWrites[i].dstSet = _descriptorAllocationToken.Set;

                if (type == VkDescriptorType.UniformBuffer || type == VkDescriptorType.UniformBufferDynamic
                    || type == VkDescriptorType.StorageBuffer || type == VkDescriptorType.StorageBufferDynamic)
                {
                    DeviceBufferRange range = Util.GetBufferRange(boundResources[i], 0);
                    VKBuffer rangedVkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(range.Buffer);
                    bufferInfos[i].buffer = rangedVkBuffer.DeviceBuffer;
                    bufferInfos[i].offset = range.Offset;
                    bufferInfos[i].range = range.SizeInBytes;
                    descriptorWrites[i].pBufferInfo = &bufferInfos[i];
                    _refCounts.Add(rangedVkBuffer.RefCount);
                }
                else if (type == VkDescriptorType.SampledImage)
                {
                    TextureView texView = Util.GetTextureView(_gd, boundResources[i]);
                    VKTextureView vkTexView = Util.AssertSubtype<TextureView, VKTextureView>(texView);
                    imageInfos[i].imageView = vkTexView.ImageView;
                    imageInfos[i].imageLayout = VkImageLayout.ShaderReadOnlyOptimal;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _sampledTextures.Add(Util.AssertSubtype<Texture, VKTexture>(texView.Target));
                    _refCounts.Add(vkTexView.RefCount);
                }
                else if (type == VkDescriptorType.StorageImage)
                {
                    TextureView texView = Util.GetTextureView(_gd, boundResources[i]);
                    VKTextureView vkTexView = Util.AssertSubtype<TextureView, VKTextureView>(texView);
                    imageInfos[i].imageView = vkTexView.ImageView;
                    imageInfos[i].imageLayout = VkImageLayout.General;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _storageImages.Add(Util.AssertSubtype<Texture, VKTexture>(texView.Target));
                    _refCounts.Add(vkTexView.RefCount);
                }
                else if (type == VkDescriptorType.Sampler)
                {
                    VKSampler sampler = Util.AssertSubtype<BindableResource, VKSampler>(boundResources[i]);
                    imageInfos[i].sampler = sampler.DeviceSampler;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _refCounts.Add(sampler.RefCount);
                }
            }

            vkUpdateDescriptorSets(_gd.Device, descriptorWriteCount, descriptorWrites, 0, null);
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

        public override void Dispose()
        {
            RefCount.Decrement();
        }

        private void DisposeCore()
        {
            if (!_destroyed)
            {
                _destroyed = true;
                _gd.DescriptorPoolManager.Free(_descriptorAllocationToken, _descriptorCounts);
            }
        }
    }
}
