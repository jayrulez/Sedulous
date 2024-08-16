using Bulkan;
namespace Sedulous.RAL.VK;

class VKMemory : Memory
{
	private MemoryType m_memory_type;
	private VkDeviceMemory m_memory;

	public this(VKDevice device,
		uint64 size,
		MemoryType memory_type,
		uint32 memory_type_bits,
		VkMemoryDedicatedAllocateInfo* dedicated_allocate_info)
	{
		m_memory_type = memory_type;

		VkMemoryAllocateFlagsInfo alloc_flag_info = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO };
		alloc_flag_info.pNext = dedicated_allocate_info;
		alloc_flag_info.flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT;

		VkMemoryPropertyFlags properties = .();
		if (memory_type == MemoryType.kDefault)
		{
			properties = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
		} else if (memory_type == MemoryType.kUpload)
		{
			properties = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT;
		} else if (memory_type == MemoryType.kReadback)
		{
			properties = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT;
		}

		VkMemoryAllocateInfo alloc_info = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO };
		alloc_info.pNext = &alloc_flag_info;
		alloc_info.allocationSize = size;
		alloc_info.memoryTypeIndex = device.FindMemoryType(memory_type_bits, properties);
		VulkanNative.vkAllocateMemory(device.GetDevice(), &alloc_info, null, &m_memory);
	}

	public override MemoryType GetMemoryType()
	{
		return m_memory_type;
	}

	public VkDeviceMemory GetMemory()
	{
		return m_memory;
	}
}