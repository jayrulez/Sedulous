using Bulkan;
using System;
namespace Sedulous.RAL.VK;

class VKGPUBindlessDescriptorPoolTyped
{
	private VKDevice m_device;
	private VkDescriptorType m_type;
	private uint32 m_size = 0;
	private uint32 m_offset = 0;
	private struct Descriptor
	{
		public VkDescriptorPool pool;
		public VkDescriptorSetLayout set_layout;
		public VkDescriptorSet set;
	}
	private Descriptor m_descriptor;
	private MultiMap<uint32, uint32> m_empty_ranges;

	public this(VKDevice device, VkDescriptorType type)
	{
		m_device = device;
		m_type = type;
	}

	public VKGPUDescriptorPoolRange Allocate(uint32 count)
	{
		var entry = m_empty_ranges.LowerBound(count);
		if (entry != null)
		{
			uint offset = entry.Value.value;
			uint size = entry.Value.key;
			m_empty_ranges.Remove(entry.Value);
			return new VKGPUDescriptorPoolRange(this, (uint32)offset, (uint32)size);
		}
		if (m_offset + count > m_size)
		{
			ResizeHeap(Math.Max(m_offset + count, 2 * (m_size + 1)));
			if (m_offset + count > m_size)
			{
				Runtime.FatalError(scope $"Failed to resize {nameof(VKGPUBindlessDescriptorPoolTyped)}");
			}
		}
		m_offset += count;
		return new VKGPUDescriptorPoolRange(this, uint32(m_offset - count), count);
	}

	public void OnRangeDestroy(uint32 offset, uint32 size)
	{
		m_empty_ranges.Add(size, offset);
	}

	public VkDescriptorSet GetDescriptorSet()
	{
		return m_descriptor.set;
	}


	private void ResizeHeap(uint32 req_size)
	{
		var req_size;
		req_size = Math.Min(req_size, m_device.GetMaxDescriptorSetBindings(m_type));

		if (m_size >= req_size)
		{
			return;
		}

		Descriptor descriptor = .();

		VkDescriptorPoolSize pool_size = .();
		pool_size.type = m_type;
		pool_size.descriptorCount = req_size;

		VkDescriptorPoolCreateInfo pool_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
		pool_info.poolSizeCount = 1;
		pool_info.pPoolSizes = &pool_size;
		pool_info.maxSets = 1;
		pool_info.flags = VkDescriptorPoolCreateFlags.VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT;

		VulkanNative.vkCreateDescriptorPool(m_device.GetDevice(), &pool_info, null, &descriptor.pool);

		VkDescriptorSetLayoutBinding binding = .();
		binding.binding = 0;
		binding.descriptorType = m_type;
		binding.descriptorCount = m_device.GetMaxDescriptorSetBindings(binding.descriptorType);
		binding.stageFlags = VkShaderStageFlags.VK_SHADER_STAGE_ALL;

		VkDescriptorBindingFlags binding_flag = VkDescriptorBindingFlags.VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT;

		VkDescriptorSetLayoutBindingFlagsCreateInfo layout_flags_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO };
		layout_flags_info.bindingCount = 1;
		layout_flags_info.pBindingFlags = &binding_flag;

		VkDescriptorSetLayoutCreateInfo layout_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
		layout_info.bindingCount = 1;
		layout_info.pBindings = &binding;
		layout_info.pNext = &layout_flags_info;

		VulkanNative.vkCreateDescriptorSetLayout(m_device.GetDevice(), &layout_info, null, &descriptor.set_layout);

		VkDescriptorSetVariableDescriptorCountAllocateInfo variable_descriptor_count_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO };
		variable_descriptor_count_info.descriptorSetCount = 1;
		variable_descriptor_count_info.pDescriptorCounts = &req_size;

		VkDescriptorSetAllocateInfo alloc_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
		alloc_info.descriptorPool = descriptor.pool;
		alloc_info.descriptorSetCount = 1;
		alloc_info.pSetLayouts = &descriptor.set_layout;
		alloc_info.pNext = &variable_descriptor_count_info;

		VulkanNative.vkAllocateDescriptorSets(m_device.GetDevice(), &alloc_info, &descriptor.set);

		if (m_size > 0)
		{
			VkCopyDescriptorSet copy_descriptors = .() { sType = .VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET };
			copy_descriptors.srcSet = m_descriptor.set;
			copy_descriptors.dstSet = descriptor.set;
			copy_descriptors.descriptorCount = m_size;
			VulkanNative.vkUpdateDescriptorSets(m_device.GetDevice(), 0, null, 1, &copy_descriptors);
		}

		m_size = req_size;

		VulkanNative.vkFreeDescriptorSets(m_device.GetDevice(), m_descriptor.pool, 1, &m_descriptor.set);
		m_descriptor = descriptor;
	}
}