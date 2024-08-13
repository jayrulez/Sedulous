using Bulkan;
using System.Collections;
using System;
using static Bulkan.VulkanNative;
using static Sedulous.GAL.VK.VulkanUtil;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.VK;

    internal class VKResourceSet : ResourceSet
    {
        private readonly VKGraphicsDevice _gd;
        private readonly DescriptorResourceCounts _descriptorCounts;
        private readonly DescriptorAllocationToken _descriptorAllocationToken;
        private readonly List<ResourceRefCount> _refCounts = new List<ResourceRefCount>();
        private bool _destroyed;
        private String _name;

        public VkDescriptorSet DescriptorSet => _descriptorAllocationToken.Set;

        private readonly List<VKTexture> _sampledTextures = new List<VKTexture>();
        public List<VKTexture> SampledTextures => _sampledTextures;
        private readonly List<VKTexture> _storageImages = new List<VKTexture>();
        public List<VKTexture> StorageTextures => _storageImages;

        public ResourceRefCount RefCount { get; }
        public List<ResourceRefCount> RefCounts => _refCounts;

        public override bool IsDisposed => _destroyed;

        public this(VKGraphicsDevice gd, in ResourceSetDescription description)
            : base(description)
        {
            _gd = gd;
            RefCount = new ResourceRefCount(new => DisposeCore);
            VKResourceLayout vkLayout = Util.AssertSubtype<ResourceLayout, VKResourceLayout>(description.Layout);

            VkDescriptorSetLayout dsl = vkLayout.DescriptorSetLayout;
            _descriptorCounts = vkLayout.DescriptorResourceCounts;
            _descriptorAllocationToken = _gd.DescriptorPoolManager.Allocate(_descriptorCounts, dsl);

            BindableResource[] boundResources = description.BoundResources;
            uint32 descriptorWriteCount = (uint32)boundResources.Count;
            VkWriteDescriptorSet* descriptorWrites = scope VkWriteDescriptorSet[(int32)descriptorWriteCount]*;
            VkDescriptorBufferInfo* bufferInfos = scope VkDescriptorBufferInfo[(int32)descriptorWriteCount]*;
            VkDescriptorImageInfo* imageInfos = scope VkDescriptorImageInfo[(int32)descriptorWriteCount]*;

            for (int i = 0; i < descriptorWriteCount; i++)
            {
                VkDescriptorType type = vkLayout.DescriptorTypes[i];

                descriptorWrites[i].sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
                descriptorWrites[i].descriptorCount = 1;
                descriptorWrites[i].descriptorType = type;
                descriptorWrites[i].dstBinding = (uint32)i;
                descriptorWrites[i].dstSet = _descriptorAllocationToken.Set;

                if (type == VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER || type == VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC
                    || type == VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER || type == VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC)
                {
                    DeviceBufferRange range = Util.GetBufferRange(boundResources[i], 0);
                    VKBuffer rangedVkBuffer = Util.AssertSubtype<DeviceBuffer, VKBuffer>(range.Buffer);
                    bufferInfos[i].buffer = rangedVkBuffer.DeviceBuffer;
                    bufferInfos[i].offset = range.Offset;
                    bufferInfos[i].range = range.SizeInBytes;
                    descriptorWrites[i].pBufferInfo = &bufferInfos[i];
                    _refCounts.Add(rangedVkBuffer.RefCount);
                }
                else if (type == VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE)
                {
                    TextureView texView = Util.GetTextureView(_gd, boundResources[i]);
                    VKTextureView vkTexView = Util.AssertSubtype<TextureView, VKTextureView>(texView);
                    imageInfos[i].imageView = vkTexView.ImageView;
                    imageInfos[i].imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _sampledTextures.Add(Util.AssertSubtype<Texture, VKTexture>(texView.Target));
                    _refCounts.Add(vkTexView.RefCount);
                }
                else if (type == VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE)
                {
                    TextureView texView = Util.GetTextureView(_gd, boundResources[i]);
                    VKTextureView vkTexView = Util.AssertSubtype<TextureView, VKTextureView>(texView);
                    imageInfos[i].imageView = vkTexView.ImageView;
                    imageInfos[i].imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_GENERAL;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _storageImages.Add(Util.AssertSubtype<Texture, VKTexture>(texView.Target));
                    _refCounts.Add(vkTexView.RefCount);
                }
                else if (type == VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER)
                {
                    VKSampler sampler = Util.AssertSubtype<BindableResource, VKSampler>(boundResources[i]);
                    imageInfos[i].sampler = sampler.DeviceSampler;
                    descriptorWrites[i].pImageInfo = &imageInfos[i];
                    _refCounts.Add(sampler.RefCount);
                }
            }

            vkUpdateDescriptorSets(_gd.Device, descriptorWriteCount, descriptorWrites, 0, null);
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
