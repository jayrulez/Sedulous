using Bulkan;
using System;
namespace Sedulous.RAL.VK;

class VKResource : ResourceBase
{
	private VKDevice m_device;
	private VkDeviceMemory m_vk_memory;

	public struct Image
	{
		public VkImage res;
		public VkImage res_owner;
		public VkFormat format = VkFormat.eUndefined;
		public VkExtent2D size = .();
		public uint32 level_count = 1;
		public uint32 sample_count = 1;
		public uint32 array_layers = 1;
	} public Image image;

	public struct Buffer
	{
		public VkBuffer res;
		public uint32 size = 0;
	} public Buffer buffer;

	public struct Sampler
	{
		public VkSampler res;
	} public Sampler sampler;

	public VkAccelerationStructureKHR acceleration_structure_handle = .Null;

	public this(VKDevice device)
	{
		m_device = device;
	}

	public override void CommitMemory(MemoryType memory_type)
	{
		MemoryRequirements mem_requirements = GetMemoryRequirements();
		VkMemoryDedicatedAllocateInfo dedicated_allocate_info = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO };
		VkMemoryDedicatedAllocateInfo* p_dedicated_allocate_info = null;
		if (resource_type == ResourceType.kBuffer)
		{
			dedicated_allocate_info.buffer = buffer.res;
			p_dedicated_allocate_info = &dedicated_allocate_info;
		} else if (resource_type == ResourceType.kTexture)
		{
			dedicated_allocate_info.image = image.res;
			p_dedicated_allocate_info = &dedicated_allocate_info;
		}
		var memory = new VKMemory(m_device, mem_requirements.size, memory_type,
			mem_requirements.memory_type_bits, p_dedicated_allocate_info);
		BindMemory(memory, 0);
	}

	public override void BindMemory(in Memory memory, uint64 offset)
	{
		m_memory = memory;
		m_memory_type = m_memory.GetMemoryType();
		m_vk_memory = m_memory.As<VKMemory>().GetMemory();

		if (resource_type == ResourceType.kBuffer)
		{
			VulkanNative.vkBindBufferMemory(m_device.GetDevice(), buffer.res, m_vk_memory, offset);
		} else if (resource_type == ResourceType.kTexture)
		{
			VulkanNative.vkBindImageMemory(m_device.GetDevice(), image.res, m_vk_memory, offset);
		}
	}

	public override uint64 GetWidth()
	{
		if (resource_type == ResourceType.kTexture)
		{
			return image.size.width;
		}
		return buffer.size;
	}

	public override uint32 GetHeight()
	{
		return image.size.height;
	}

	public override uint16 GetLayerCount()
	{
		return (uint16)image.array_layers;
	}

	public override uint16 GetLevelCount()
	{
		return (uint16)image.level_count;
	}

	public override uint32 GetSampleCount()
	{
		return image.sample_count;
	}

	public override uint64 GetAccelerationStructureHandle()
	{
		VkAccelerationStructureDeviceAddressInfoKHR addressInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR,
				accelerationStructure = acceleration_structure_handle
			};
		return VulkanNative.vkGetAccelerationStructureDeviceAddressKHR(m_device.GetDevice(), &addressInfo);
	}

	public override void SetName(in String name)
	{
		VkDebugUtilsObjectNameInfoEXT info = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT };
		info.pObjectName = name;
		if (resource_type == ResourceType.kBuffer)
		{
			info.objectType = .VK_OBJECT_TYPE_BUFFER;
			info.objectHandle = buffer.res;
		} else if (resource_type == ResourceType.kTexture)
		{
			info.objectType = .VK_OBJECT_TYPE_IMAGE;
			info.objectHandle = image.res;
		}
		VulkanNative.vkSetDebugUtilsObjectNameEXT(m_device.GetDevice(), &info);
	}

	public override uint8* Map()
	{
		uint8* dst_data = null;
		VulkanNative.vkMapMemory(m_device.GetDevice(), m_vk_memory, 0, VulkanNative.VK_WHOLE_SIZE, 0, (.)&dst_data);
		return dst_data;
	}

	public override void Unmap()
	{
		VulkanNative.vkUnmapMemory(m_device.GetDevice(), m_vk_memory);
	}

	public override bool AllowCommonStatePromotion(ResourceState state_after)
	{
		return false;
	}

	public override MemoryRequirements GetMemoryRequirements()
	{
		VkMemoryRequirements2 mem_requirements = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2 };
		if (resource_type == ResourceType.kBuffer)
		{
			VkBufferMemoryRequirementsInfo2 buffer_mem_req = .() { sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2 };
			buffer_mem_req.buffer = buffer.res;
			VulkanNative.vkGetBufferMemoryRequirements2(m_device.GetDevice(), &buffer_mem_req, &mem_requirements);
		} else if (resource_type == ResourceType.kTexture)
		{
			VkImageMemoryRequirementsInfo2 image_mem_req = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2 };
			image_mem_req.image = image.res;
			VulkanNative.vkGetImageMemoryRequirements2(m_device.GetDevice(), &image_mem_req, &mem_requirements);
		}
		return .()
			{
				size = mem_requirements.memoryRequirements.size,
				alignment = mem_requirements.memoryRequirements.alignment,
				memory_type_bits = mem_requirements.memoryRequirements.memoryTypeBits
			};
	}
}