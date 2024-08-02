using System;
using Bulkan;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Raytracing helpers.
/// </summary>
public static class VKRaytracingHelpers
{
	/// <summary>
	/// Buffer data.
	/// </summary>
	public struct BufferData
	{
		/// <summary>
		/// Buffer vulkan resource.
		/// </summary>
		public VkBuffer Buffer;

		/// <summary>
		/// Device memory resource.
		/// </summary>
		public VkDeviceMemory Memory;
	}

	/// <summary>
	/// Create Acceleration Structure buffer.
	/// </summary>
	/// <param name="context">The vulkan context.</param>
	/// <param name="bufferSize">The buffer size.</param>
	/// <param name="usage">The buffer usage.</param>
	/// <returns>The buffer memory address.</returns>
	public static BufferData CreateBuffer(VKGraphicsContext context, uint64 bufferSize, VkBufferUsageFlags usage)
	{
		VkBufferCreateInfo vkBufferCreateInfo = default(VkBufferCreateInfo);
		vkBufferCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
		vkBufferCreateInfo.size = bufferSize;
		vkBufferCreateInfo.usage = usage;
		vkBufferCreateInfo.flags = VkBufferCreateFlags.None;
		vkBufferCreateInfo.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
		VkBufferCreateInfo bufferInfo = vkBufferCreateInfo;
		VkBuffer newBuffer = default(VkBuffer);
		VulkanNative.vkCreateBuffer(context.VkDevice, &bufferInfo, null, &newBuffer);
		VkMemoryRequirements memoryRequirements = default(VkMemoryRequirements);
		VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, newBuffer, &memoryRequirements);
		VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo = default(VkMemoryAllocateFlagsInfo);
		vkMemoryAllocateFlagsInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO;
		vkMemoryAllocateFlagsInfo.flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT;
		VkMemoryAllocateFlagsInfo memoryAllocateFlagsInfo = vkMemoryAllocateFlagsInfo;
		VkMemoryAllocateInfo vkMemoryAllocateInfo = default(VkMemoryAllocateInfo);
		vkMemoryAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
		vkMemoryAllocateInfo.pNext = &memoryAllocateFlagsInfo;
		vkMemoryAllocateInfo.allocationSize = memoryRequirements.size;
		vkMemoryAllocateInfo.memoryTypeIndex = (uint32)VKHelpers.FindMemoryType(context, memoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
		VkMemoryAllocateInfo memoryAllocateInfo = vkMemoryAllocateInfo;
		VkDeviceMemory deviceMemory = default(VkDeviceMemory);
		VulkanNative.vkAllocateMemory(context.VkDevice, &memoryAllocateInfo, null, &deviceMemory);
		VulkanNative.vkBindBufferMemory(context.VkDevice, newBuffer, deviceMemory, 0uL);
		BufferData result = default(BufferData);
		result.Buffer = newBuffer;
		result.Memory = deviceMemory;
		return result;
	}

	/// <summary>
	/// Create a stagging buffer from data.
	/// </summary>
	/// <param name="context">The vulkan context.</param>
	/// <param name="data">The source data pointer.</param>
	/// <param name="bufferSize">The buffer size.</param>
	/// <param name="usage">The buffer usage.</param>
	/// <returns>The buffer memory address.</returns>
	public static BufferData CreateMappedBuffer(VKGraphicsContext context, void* data, uint64 bufferSize, VkBufferUsageFlags usage)
	{
		VkBufferCreateInfo vkBufferCreateInfo = default(VkBufferCreateInfo);
		vkBufferCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
		vkBufferCreateInfo.size = bufferSize;
		vkBufferCreateInfo.usage = usage;
		vkBufferCreateInfo.flags = VkBufferCreateFlags.None;
		vkBufferCreateInfo.sharingMode = VkSharingMode.VK_SHARING_MODE_EXCLUSIVE;
		VkBufferCreateInfo bufferInfo = vkBufferCreateInfo;
		VkBuffer newBuffer = default(VkBuffer);
		VulkanNative.vkCreateBuffer(context.VkDevice, &bufferInfo, null, &newBuffer);
		VkMemoryRequirements memoryRequirements = default(VkMemoryRequirements);
		VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, newBuffer, &memoryRequirements);
		VkMemoryAllocateFlagsInfo vkMemoryAllocateFlagsInfo = default(VkMemoryAllocateFlagsInfo);
		vkMemoryAllocateFlagsInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO;
		vkMemoryAllocateFlagsInfo.flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT;
		VkMemoryAllocateFlagsInfo memoryAllocateFlagsInfo = vkMemoryAllocateFlagsInfo;
		VkMemoryAllocateInfo vkMemoryAllocateInfo = default(VkMemoryAllocateInfo);
		vkMemoryAllocateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
		vkMemoryAllocateInfo.pNext = &memoryAllocateFlagsInfo;
		vkMemoryAllocateInfo.allocationSize = memoryRequirements.size;
		vkMemoryAllocateInfo.memoryTypeIndex = (uint32)VKHelpers.FindMemoryType(context, memoryRequirements.memoryTypeBits, VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
		VkMemoryAllocateInfo memoryAllocateInfo = vkMemoryAllocateInfo;
		VkDeviceMemory deviceMemory = default(VkDeviceMemory);
		VulkanNative.vkAllocateMemory(context.VkDevice, &memoryAllocateInfo, null, &deviceMemory);
		VulkanNative.vkBindBufferMemory(context.VkDevice, newBuffer, deviceMemory, 0uL);
		if (data != null)
		{
			void* dataPointer = default(void*);
			VulkanNative.vkMapMemory(context.VkDevice, deviceMemory, 0uL, bufferSize, VkMemoryMapFlags.None, &dataPointer);
			Internal.MemCpy(dataPointer, (void*)data, (uint32)bufferSize);
			VulkanNative.vkUnmapMemory(context.VkDevice, deviceMemory);
		}
		BufferData result = default(BufferData);
		result.Buffer = newBuffer;
		result.Memory = deviceMemory;
		return result;
	}
}
