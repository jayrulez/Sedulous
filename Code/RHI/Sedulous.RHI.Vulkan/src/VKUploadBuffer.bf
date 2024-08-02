using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

internal class VKUploadBuffer : UploadBuffer
{
	/// <summary>
	/// The Vulkan texture instance.
	/// </summary>
	public VkBuffer NativeBuffer;

	public VkDeviceMemory BufferMemory;

	public this(VKGraphicsContext context, uint64 size, uint32 align = 512)
		: base(context, size, align)
	{
	}

	protected override void RefreshBuffer(uint64 size)
	{
		VKGraphicsContext nativeContext = (VKGraphicsContext)context;
		VkBufferCreateInfo bufferInfo = default(VkBufferCreateInfo);
		bufferInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
		bufferInfo.size = size;
		bufferInfo.usage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
		bufferInfo.sharingMode = (nativeContext.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE);
		int32 queueFamilies = ((!nativeContext.CopyQueueSupported) ? 1 : 2);
		uint32* queueFamilyIndices = scope uint32[queueFamilies]*;
		*queueFamilyIndices = (uint32)nativeContext.QueueIndices.GraphicsFamily;
		if (nativeContext.CopyQueueSupported)
		{
			queueFamilyIndices[1] = (uint32)nativeContext.QueueIndices.CopyFamily;
		}
		bufferInfo.pQueueFamilyIndices = queueFamilyIndices;
		bufferInfo.queueFamilyIndexCount = (uint32)queueFamilies;
		VkBuffer newBuffer = default(VkBuffer);
		VulkanNative.vkCreateBuffer(nativeContext.VkDevice, &bufferInfo, null, &newBuffer);
		NativeBuffer = newBuffer;
		VkMemoryRequirements buffermemoryRequirements = default(VkMemoryRequirements);
		VulkanNative.vkGetBufferMemoryRequirements(nativeContext.VkDevice, NativeBuffer, &buffermemoryRequirements);
		VkMemoryPropertyFlags memoryPropertyFlags = VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
		VkMemoryAllocateInfo allocInfo = default(VkMemoryAllocateInfo);
		allocInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
		allocInfo.allocationSize = buffermemoryRequirements.size;
		int32 memoryType = VKHelpers.FindMemoryType(nativeContext, buffermemoryRequirements.memoryTypeBits, memoryPropertyFlags);
		if (memoryType == -1)
		{
			nativeContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
		}
		allocInfo.memoryTypeIndex = (uint32)memoryType;
		VkDeviceMemory newDeviceMemory = default(VkDeviceMemory);
		VulkanNative.vkAllocateMemory(nativeContext.VkDevice, &allocInfo, null, &newDeviceMemory);
		BufferMemory = newDeviceMemory;
		VulkanNative.vkBindBufferMemory(nativeContext.VkDevice, NativeBuffer, BufferMemory, 0uL);
		void* data = null;
		VulkanNative.vkMapMemory(nativeContext.VkDevice, BufferMemory, 0uL, (uint32)size, VkMemoryMapFlags.None, &data);
		DataCurrent = (DataBegin = (uint64)(int)data);
		TotalSize = size;
		DataEnd = DataBegin + size;
	}

	public override void Dispose()
	{
		VKGraphicsContext obj = (VKGraphicsContext)context;
		VulkanNative.vkUnmapMemory(obj.VkDevice, BufferMemory);
		VulkanNative.vkDestroyBuffer(obj.VkDevice, NativeBuffer, null);
		VulkanNative.vkFreeMemory(obj.VkDevice, BufferMemory, null);
	}
}
