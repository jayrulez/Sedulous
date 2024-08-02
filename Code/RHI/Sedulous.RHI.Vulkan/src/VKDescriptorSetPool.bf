using Bulkan;
using System.Threading;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represent a pool of descriptor sets.
/// </summary>
internal class VKDescriptorSetPool
{
	public class PoolInfo
	{
		public readonly VkDescriptorPool DescriptorPool;

		public uint32 RemainingSets;

		public uint32 ConstantBufferCount;

		public uint32 TextureCount;

		public uint32 SamplerCount;

		public uint32 StorageBufferCount;

		public uint32 StorageImageCount;

		public uint32 AccelerationStructureCount;

		public this(VkDescriptorPool pool, uint32 totalSets, uint32 descriptorCount)
		{
			DescriptorPool = pool;
			RemainingSets = totalSets;
			ConstantBufferCount = descriptorCount;
			TextureCount = descriptorCount;
			SamplerCount = descriptorCount;
			StorageBufferCount = descriptorCount;
			StorageImageCount = descriptorCount;
			AccelerationStructureCount = descriptorCount;
		}

		public bool Allocate(VKResourceCounts resourceCounts)
		{
			if (RemainingSets != 0 && ConstantBufferCount >= resourceCounts.ConstantBufferCount && TextureCount >= resourceCounts.TextureCount && SamplerCount >= resourceCounts.SamplerCount && StorageBufferCount >= resourceCounts.StorageBufferCount && StorageImageCount >= resourceCounts.StorageImageCount && AccelerationStructureCount >= resourceCounts.AccelerationStructureCount)
			{
				RemainingSets--;
				ConstantBufferCount -= resourceCounts.ConstantBufferCount;
				TextureCount -= resourceCounts.TextureCount;
				SamplerCount -= resourceCounts.SamplerCount;
				StorageBufferCount -= resourceCounts.StorageBufferCount;
				StorageImageCount -= resourceCounts.StorageImageCount;
				AccelerationStructureCount -= resourceCounts.AccelerationStructureCount;
				return true;
			}
			return false;
		}

		public void Free(VKGraphicsContext context, VKDescriptorAllocationToken token, VKResourceCounts resourceCounts)
		{
			VkDescriptorSet descriptorSet = token.DescriptorSet;
			VulkanNative.vkFreeDescriptorSets(context.VkDevice, DescriptorPool, 1, &descriptorSet);
			RemainingSets++;
			ConstantBufferCount += resourceCounts.ConstantBufferCount;
			TextureCount += resourceCounts.TextureCount;
			SamplerCount += resourceCounts.SamplerCount;
			StorageBufferCount += resourceCounts.StorageBufferCount;
			StorageImageCount += resourceCounts.StorageImageCount;
			AccelerationStructureCount += resourceCounts.AccelerationStructureCount;
		}
	}

	private VKGraphicsContext context;

	private readonly Monitor lockObject = new .() ~ delete _;

	private readonly List<PoolInfo> pools;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKDescriptorSetPool" /> class.
	/// </summary>
	/// <param name="context">The Vulkan graphics context.</param>
	public this(VKGraphicsContext context)
	{
		this.context = context;
		pools = new List<PoolInfo>();
		pools.Add(CreateNewPool());
	}

	public PoolInfo CreateNewPool()
	{
		uint32 totalSets = 1000;
		uint32 descriptorCount = 100;
		uint32 poolSizeCount = (context.raytracingSupported ? 8 : 7);
		VkDescriptorPoolSize* sizes = scope VkDescriptorPoolSize[(int32)poolSizeCount]*;
		sizes[0].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
		sizes[0].descriptorCount = descriptorCount;
		sizes[1].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
		sizes[1].descriptorCount = descriptorCount;
		sizes[2].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
		sizes[2].descriptorCount = descriptorCount;
		sizes[3].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
		sizes[3].descriptorCount = descriptorCount;
		sizes[4].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
		sizes[4].descriptorCount = descriptorCount;
		sizes[5].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
		sizes[5].descriptorCount = descriptorCount;
		sizes[6].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC;
		sizes[6].descriptorCount = descriptorCount;
		if (context.raytracingSupported)
		{
			sizes[7].type = VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR;
			sizes[7].descriptorCount = descriptorCount;
		}
		VkDescriptorPoolCreateInfo poolInfo = default(VkDescriptorPoolCreateInfo);
		poolInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
		poolInfo.flags = VkDescriptorPoolCreateFlags.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;
		poolInfo.maxSets = totalSets;
		poolInfo.pPoolSizes = sizes;
		poolInfo.poolSizeCount = poolSizeCount;
		VkDescriptorPool descriptorPool = default(VkDescriptorPool);
		VulkanNative.vkCreateDescriptorPool(context.VkDevice, &poolInfo, null, &descriptorPool);
		return new PoolInfo(descriptorPool, totalSets, descriptorCount);
	}

	public VkDescriptorPool GetPool(VKResourceCounts resourceCounts)
	{
		using (lockObject.Enter())
		{
			for (PoolInfo pool in pools)
			{
				if (pool.Allocate(resourceCounts))
				{
					return pool.DescriptorPool;
				}
			}
			PoolInfo newPool = CreateNewPool();
			pools.Add(newPool);
			newPool.Allocate(resourceCounts);
			return newPool.DescriptorPool;
		}
	}

	public VKDescriptorAllocationToken Allocate(VkDescriptorSetLayout layout, VKResourceCounts resourceCounts)
	{
		var layout;

		VkDescriptorPool pool = GetPool(resourceCounts);
		VkDescriptorSetAllocateInfo allocInfo = default(VkDescriptorSetAllocateInfo);
		allocInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
		allocInfo.descriptorSetCount = 1;
		allocInfo.pSetLayouts = &layout;
		allocInfo.descriptorPool = pool;
		VkDescriptorSet descriptorSet = default(VkDescriptorSet);
		VulkanNative.vkAllocateDescriptorSets(context.VkDevice, &allocInfo, &descriptorSet);
		return VKDescriptorAllocationToken(pool, descriptorSet);
	}

	public void Free(VKDescriptorAllocationToken token, VKResourceCounts resourceCounts)
	{
		using (lockObject.Enter())
		{
			for (PoolInfo pool in pools)
			{
				if (pool.DescriptorPool == token.DescriptorPool)
				{
					pool.Free(context, token, resourceCounts);
				}
			}
		}
	}

	public void DestroyAll()
	{
		for (PoolInfo poolInfo in pools)
		{
			VulkanNative.vkDestroyDescriptorPool(context.VkDevice, poolInfo.DescriptorPool, null);
			delete poolInfo;
		}
		delete pools;
	}
}
