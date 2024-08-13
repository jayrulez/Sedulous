using System;
using System.Diagnostics;
using Bulkan;
using System.Collections;
using System.Threading;
using static Bulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
	using internal Sedulous.GAL.VK;

    internal class VKDescriptorPoolManager
    {
        private readonly VKGraphicsDevice _gd;
        private readonly List<PoolInfo> _pools = new .();
        private readonly Monitor _lock = new .() ~ delete _;

        public this(VKGraphicsDevice gd)
        {
            _gd = gd;
            _pools.Add(CreateNewPool());
        }

        public DescriptorAllocationToken Allocate(DescriptorResourceCounts counts, VkDescriptorSetLayout setLayout)
        {
            using (_lock.Enter())
            {
                VkDescriptorPool pool = GetPool(counts);
                VkDescriptorSetAllocateInfo dsAI = VkDescriptorSetAllocateInfo() {sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO};
                dsAI.descriptorSetCount = 1;
                dsAI.pSetLayouts = &setLayout;
                dsAI.descriptorPool = pool;
				VkDescriptorSet set = .Null;
                VkResult result = vkAllocateDescriptorSets(_gd.Device, &dsAI, &set);
                VulkanUtil.CheckResult(result);

                return DescriptorAllocationToken(set, pool);
            }
        }

        public void Free(DescriptorAllocationToken token, DescriptorResourceCounts counts)
        {
            using (_lock.Enter())
            {
                for (PoolInfo poolInfo in _pools)
                {
                    if (poolInfo.Pool == token.Pool)
                    {
                        poolInfo.Free(_gd.Device, token, counts);
                    }
                }
            }
        }

        private VkDescriptorPool GetPool(DescriptorResourceCounts counts)
        {
            using (_lock.Enter())
            {
                for (PoolInfo poolInfo in _pools)
                {
                    if (poolInfo.Allocate(counts))
                    {
                        return poolInfo.Pool;
                    }
                }

                PoolInfo newPool = CreateNewPool();
                _pools.Add(newPool);
                bool result = newPool.Allocate(counts);
                Debug.Assert(result);
                return newPool.Pool;
            }
        }

        private PoolInfo CreateNewPool()
        {
            uint32 totalSets = 1000;
            uint32 descriptorCount = 100;
            uint32 poolSizeCount = 7;
            VkDescriptorPoolSize* sizes = scope VkDescriptorPoolSize[(int32)poolSizeCount]*;
            sizes[0].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
            sizes[0].descriptorCount = descriptorCount;
            sizes[1].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
            sizes[1].descriptorCount = descriptorCount;
            sizes[2].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
            sizes[2].descriptorCount = descriptorCount;
            sizes[3].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            sizes[3].descriptorCount = descriptorCount;
            sizes[4].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
            sizes[4].descriptorCount = descriptorCount;
            sizes[5].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
            sizes[5].descriptorCount = descriptorCount;
            sizes[6].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC;
            sizes[6].descriptorCount = descriptorCount;

            VkDescriptorPoolCreateInfo poolCI = VkDescriptorPoolCreateInfo(){sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO};
            poolCI.flags = VkDescriptorPoolCreateFlags.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;
            poolCI.maxSets = totalSets;
            poolCI.pPoolSizes = sizes;
            poolCI.poolSizeCount = poolSizeCount;

			VkDescriptorPool descriptorPool = .Null;
            VkResult result = vkCreateDescriptorPool(_gd.Device, &poolCI, null, &descriptorPool);
            VulkanUtil.CheckResult(result);

            return new PoolInfo(descriptorPool, totalSets, descriptorCount);
        }

        internal void DestroyAll()
        {
            for (PoolInfo poolInfo in _pools)
            {
                vkDestroyDescriptorPool(_gd.Device, poolInfo.Pool, null);
            }
        }

        private class PoolInfo
        {
            public readonly VkDescriptorPool Pool;

            public uint32 RemainingSets;

            public uint32 UniformBufferCount;
            public uint32 UniformBufferDynamicCount;
            public uint32 SampledImageCount;
            public uint32 SamplerCount;
            public uint32 StorageBufferCount;
            public uint32 StorageBufferDynamicCount;
            public uint32 StorageImageCount;

            public this(VkDescriptorPool pool, uint32 totalSets, uint32 descriptorCount)
            {
                Pool = pool;
                RemainingSets = totalSets;
                UniformBufferCount = descriptorCount;
                UniformBufferDynamicCount = descriptorCount;
                SampledImageCount = descriptorCount;
                SamplerCount = descriptorCount;
                StorageBufferCount = descriptorCount;
                StorageBufferDynamicCount = descriptorCount;
                StorageImageCount = descriptorCount;
            }

            internal bool Allocate(DescriptorResourceCounts counts)
            {
                if (RemainingSets > 0
                    && UniformBufferCount >= counts.UniformBufferCount
                    && UniformBufferDynamicCount >= counts.UniformBufferDynamicCount
                    && SampledImageCount >= counts.SampledImageCount
                    && SamplerCount >= counts.SamplerCount
                    && StorageBufferCount >= counts.StorageBufferCount
                    && StorageBufferDynamicCount >= counts.StorageBufferDynamicCount
                    && StorageImageCount >= counts.StorageImageCount)
                {
                    RemainingSets -= 1;
                    UniformBufferCount -= counts.UniformBufferCount;
                    UniformBufferDynamicCount -= counts.UniformBufferDynamicCount;
                    SampledImageCount -= counts.SampledImageCount;
                    SamplerCount -= counts.SamplerCount;
                    StorageBufferCount -= counts.StorageBufferCount;
                    StorageBufferDynamicCount -= counts.StorageBufferDynamicCount;
                    StorageImageCount -= counts.StorageImageCount;
                    return true;
                }
                else
                {
                    return false;
                }
            }

            internal void Free(VkDevice device, DescriptorAllocationToken token, DescriptorResourceCounts counts)
            {
                VkDescriptorSet set = token.Set;
                vkFreeDescriptorSets(device, Pool, 1, &set);

                RemainingSets += 1;

                UniformBufferCount += counts.UniformBufferCount;
                SampledImageCount += counts.SampledImageCount;
                SamplerCount += counts.SamplerCount;
                StorageBufferCount += counts.StorageBufferCount;
                StorageImageCount += counts.StorageImageCount;
            }
        }
    }

    internal struct DescriptorAllocationToken
    {
        public readonly VkDescriptorSet Set;
        public readonly VkDescriptorPool Pool;

        public this(VkDescriptorSet set, VkDescriptorPool pool)
        {
            Set = set;
            Pool = pool;
        }
    }
}
