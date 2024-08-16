using Bulkan;
using System.Collections;
namespace Sedulous.RAL.VK;

class VKGPUDescriptorPool
{
	private VKDevice m_device;


	public this(VKDevice device)
	{
		m_device = device;
	}

	public DescriptorSetPool AllocateDescriptorSet(VkDescriptorSetLayout set_layout,
		Dictionary<VkDescriptorType, uint> count)
	{
		var set_layout;

		DescriptorSetPool res = .();
		res.pool = CreateDescriptorPool(count);

		VkDescriptorSetAllocateInfo alloc_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
		alloc_info.descriptorPool = res.pool;
		alloc_info.descriptorSetCount = 1;
		alloc_info.pSetLayouts = &set_layout;
		VkDescriptorSet descriptorSet = .Null;
		VulkanNative.vkAllocateDescriptorSets(m_device.GetDevice(), &alloc_info, &descriptorSet);
		res.set = descriptorSet;

		return res;
	}


	private VkDescriptorPool CreateDescriptorPool(Dictionary<VkDescriptorType, uint> count)
	{
		List<VkDescriptorPoolSize> pool_sizes = scope .();
		for (var x in count)
		{
			VkDescriptorPoolSize pool_size = .();
			pool_size.type = x.key;
			pool_size.descriptorCount = (uint32)x.value;
			pool_sizes.Add(pool_size);
		}

		// TODO: fix me
		if (count.IsEmpty)
		{
			VkDescriptorPoolSize pool_size = .();
			pool_size.type = VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER;
			pool_size.descriptorCount = 1;
			pool_sizes.Add(pool_size);
		}

		VkDescriptorPoolCreateInfo pool_info = .();
		pool_info.poolSizeCount = (uint32)pool_sizes.Count;
		pool_info.pPoolSizes = pool_sizes.Ptr;
		pool_info.maxSets = 1;
		pool_info.flags = VkDescriptorPoolCreateFlags.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;

		VkDescriptorPool pool = .Null;
		VulkanNative.vkCreateDescriptorPool(m_device.GetDevice(), &pool_info, null, &pool);
		return pool;
	}
}