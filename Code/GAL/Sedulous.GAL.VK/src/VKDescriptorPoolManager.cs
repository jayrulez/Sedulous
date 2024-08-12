﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using Vulkan;
using static Vulkan.VulkanNative;

namespace Sedulous.GAL.VK
{
    internal class VKDescriptorPoolManager
    {
        private readonly VKGraphicsDevice _gd;
        private readonly List<PoolInfo> _pools = new List<PoolInfo>();
        private readonly object _lock = new object();

        public VKDescriptorPoolManager(VKGraphicsDevice gd)
        {
            _gd = gd;
            _pools.Add(CreateNewPool());
        }

        public DescriptorAllocationToken Allocate(DescriptorResourceCounts counts, VkDescriptorSetLayout setLayout)
        {
            lock (_lock)
            {
                VkDescriptorPool pool = GetPool(counts);
                VkDescriptorSetAllocateInfo dsAI = VkDescriptorSetAllocateInfo.New();
                dsAI.descriptorSetCount = 1;
                dsAI.pSetLayouts = &setLayout;
                dsAI.descriptorPool = pool;
                VkResult result = vkAllocateDescriptorSets(_gd.Device, ref dsAI, out VkDescriptorSet set);
                VulkanUtil.CheckResult(result);

                return new DescriptorAllocationToken(set, pool);
            }
        }

        public void Free(DescriptorAllocationToken token, DescriptorResourceCounts counts)
        {
            lock (_lock)
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
            lock (_lock)
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
            VkDescriptorPoolSize* sizes = stackalloc VkDescriptorPoolSize[(int32)poolSizeCount];
            sizes[0].type = VkDescriptorType.UniformBuffer;
            sizes[0].descriptorCount = descriptorCount;
            sizes[1].type = VkDescriptorType.SampledImage;
            sizes[1].descriptorCount = descriptorCount;
            sizes[2].type = VkDescriptorType.Sampler;
            sizes[2].descriptorCount = descriptorCount;
            sizes[3].type = VkDescriptorType.StorageBuffer;
            sizes[3].descriptorCount = descriptorCount;
            sizes[4].type = VkDescriptorType.StorageImage;
            sizes[4].descriptorCount = descriptorCount;
            sizes[5].type = VkDescriptorType.UniformBufferDynamic;
            sizes[5].descriptorCount = descriptorCount;
            sizes[6].type = VkDescriptorType.StorageBufferDynamic;
            sizes[6].descriptorCount = descriptorCount;

            VkDescriptorPoolCreateInfo poolCI = VkDescriptorPoolCreateInfo.New();
            poolCI.flags = VkDescriptorPoolCreateFlags.FreeDescriptorSet;
            poolCI.maxSets = totalSets;
            poolCI.pPoolSizes = sizes;
            poolCI.poolSizeCount = poolSizeCount;

            VkResult result = vkCreateDescriptorPool(_gd.Device, ref poolCI, null, out VkDescriptorPool descriptorPool);
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

            public PoolInfo(VkDescriptorPool pool, uint32 totalSets, uint32 descriptorCount)
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
                vkFreeDescriptorSets(device, Pool, 1, ref set);

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

        public DescriptorAllocationToken(VkDescriptorSet set, VkDescriptorPool pool)
        {
            Set = set;
            Pool = pool;
        }
    }
}
