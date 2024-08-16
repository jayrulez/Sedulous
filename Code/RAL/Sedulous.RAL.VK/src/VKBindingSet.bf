using System.Collections;
using Bulkan;
namespace Sedulous.RAL.VK;

class VKBindingSet : BindingSet
{
	private VKDevice m_device;
	private List<DescriptorSetPool> m_descriptors;
	private List<VkDescriptorSet> m_descriptor_sets;
	private VKBindingSetLayout m_layout;

	public this(VKDevice device, VKBindingSetLayout layout)
	{
		m_device = device;
		m_layout = layout;

		var bindless_type = m_layout.GetBindlessType();
		var descriptor_set_layouts = m_layout.GetDescriptorSetLayouts();
		var descriptor_count_by_set = m_layout.GetDescriptorCountBySet();
		for (uint i = 0; i < (uint)descriptor_set_layouts.Count; ++i)
		{
			if (bindless_type.ContainsKey((uint32)i))
			{
				m_descriptor_sets.Add(m_device.GetGPUBindlessDescriptorPool(bindless_type[(uint32)i]).GetDescriptorSet());
			} else
			{
				var pool = m_device.GetGPUDescriptorPool().AllocateDescriptorSet(descriptor_set_layouts[(uint32)i], descriptor_count_by_set[(uint32)i]);
				m_descriptors.Add(pool);
				m_descriptor_sets.Add(pool.set);
			}
		}
	}

	public override void WriteBindings(in List<BindingDesc> bindings)
	{
		List<VkWriteDescriptorSet> descriptors = scope .();
		for (BindingDesc binding in bindings)
		{
			VKView vk_view = binding.view.As<VKView>();
			VkWriteDescriptorSet descriptor = vk_view.GetDescriptor();
			descriptor.descriptorType = GetDescriptorType(binding.bind_key.view_type);
			descriptor.dstSet = m_descriptor_sets[binding.bind_key.space];
			descriptor.dstBinding = binding.bind_key.slot;
			descriptor.dstArrayElement = 0;
			descriptor.descriptorCount = 1;
			if (descriptor.pImageInfo != null || descriptor.pBufferInfo != null || descriptor.pTexelBufferView != null || descriptor.pNext != null)
			{
				descriptors.Add(descriptor);
			}
		}

		if (!descriptors.IsEmpty)
		{
			VulkanNative.vkUpdateDescriptorSets(m_device.GetDevice(), (uint32)descriptors.Count, descriptors.Ptr, 0, null);
		}
	}

	public readonly ref List<VkDescriptorSet> GetDescriptorSets()
	{
		return ref m_descriptor_sets;
	}
}