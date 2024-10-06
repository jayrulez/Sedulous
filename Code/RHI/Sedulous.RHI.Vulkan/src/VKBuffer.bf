using System;
using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// Represents a Vulkan buffer object.
/// </summary>
public class VKBuffer : Sedulous.RHI.Buffer
{
	/// <summary>
	/// The Vulkan buffer object.
	/// </summary>
	public VkBuffer NativeBuffer;

	/// <summary>
	/// The Vulkan buffer's memory.
	/// </summary>
	public VkDeviceMemory BufferMemory;

	internal VkDeviceOrHostAddressConstKHR BufferAddress;

	private VKGraphicsContext vkContext;

	private VkBufferUsageFlags vkUsage;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override void* NativePointer => (void*)(int)NativeBuffer.Handle;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			if (!String.IsNullOrEmpty(value))
			{
				name.Set(value);
				vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_BUFFER, NativeBuffer.Handle, name);
			}
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="data">The data pointer.</param>
	/// <param name="description">The buffer description.</param>
	public this(VKGraphicsContext context, void* data, in BufferDescription description)
		: base(context, description)
	{
		vkContext = context;
		vkUsage = VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_SRC_BIT | VkBufferUsageFlags.VK_BUFFER_USAGE_TRANSFER_DST_BIT;
		if ((description.Flags & BufferFlags.VertexBuffer) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT;
		}
		if ((description.Flags & BufferFlags.IndexBuffer) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
		}
		if ((description.Flags & BufferFlags.ConstantBuffer) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
		}
		if ((description.Flags & BufferFlags.ShaderResource) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
		}
		if ((description.Flags & BufferFlags.UnorderedAccess) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_STORAGE_BUFFER_BIT;
		}
		if ((description.Flags & BufferFlags.IndirectBuffer) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT;
		}
		if ((bool)vkContext.VkPhysicalDeviceInfo.Features_1_2.bufferDeviceAddress)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT;
		}
		if ((description.Flags & BufferFlags.AccelerationStructure) != 0)
		{
			vkUsage |= VkBufferUsageFlags.VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR;
		}
		VkBufferCreateInfo bufferInfo = VkBufferCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
			size = description.SizeInBytes,
			usage = vkUsage,
			sharingMode = (context.CopyQueueSupported ? VkSharingMode.VK_SHARING_MODE_CONCURRENT : VkSharingMode.VK_SHARING_MODE_EXCLUSIVE)
		};
		int32 queueFamilies = ((!context.CopyQueueSupported) ? 1 : 2);
		uint32* queueFamilyIndices = scope uint32[queueFamilies]*;
		*queueFamilyIndices = (uint32)context.QueueIndices.GraphicsFamily;
		if (context.CopyQueueSupported)
		{
			queueFamilyIndices[1] = (uint32)context.QueueIndices.CopyFamily;
		}
		bufferInfo.pQueueFamilyIndices = queueFamilyIndices;
		bufferInfo.queueFamilyIndexCount = (uint32)queueFamilies;
		VkBuffer newBuffer = default(VkBuffer);
		VulkanNative.vkCreateBuffer(context.VkDevice, &bufferInfo, null, &newBuffer);
		NativeBuffer = newBuffer;
		VkMemoryRequirements bufferMemoryRequirements = default(VkMemoryRequirements);
		VulkanNative.vkGetBufferMemoryRequirements(context.VkDevice, NativeBuffer, &bufferMemoryRequirements);
		VkMemoryPropertyFlags memoryPropertyFlags = (((description.Usage & ResourceUsage.Dynamic) != ResourceUsage.Dynamic && (description.Usage & ResourceUsage.Staging) != ResourceUsage.Staging) ? VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT : (VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VkMemoryPropertyFlags.VK_MEMORY_PROPERTY_HOST_COHERENT_BIT));
		VkMemoryAllocateInfo allocInfo = VkMemoryAllocateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
			allocationSize = bufferMemoryRequirements.size
		};
		if ((bool)vkContext.VkPhysicalDeviceInfo.Features_1_2.bufferDeviceAddress)
		{
			VkMemoryAllocateFlagsInfo memoryAllocateFlagsInfo = VkMemoryAllocateFlagsInfo()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO,
				flags = VkMemoryAllocateFlags.VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT
			};
			allocInfo.pNext = &memoryAllocateFlagsInfo;
		}
		int32 memoryType = VKHelpers.FindMemoryType(context, bufferMemoryRequirements.memoryTypeBits, memoryPropertyFlags);
		if (memoryType == -1)
		{
			vkContext.ValidationLayer?.Notify("Vulkan", "No suitable memory type.");
		}
		allocInfo.memoryTypeIndex = (uint32)memoryType;
		VkDeviceMemory newDeviceMemory = default(VkDeviceMemory);
		VulkanNative.vkAllocateMemory(context.VkDevice, &allocInfo, null, &newDeviceMemory);
		BufferMemory = newDeviceMemory;
		VulkanNative.vkBindBufferMemory(context.VkDevice, NativeBuffer, BufferMemory, 0uL);
		if (bufferInfo.usage.HasFlag(VkBufferUsageFlags.VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT))
		{
			VkBufferDeviceAddressInfo addressInfo = VkBufferDeviceAddressInfo()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO,
				buffer = newBuffer
			};
			uint64 address = VulkanNative.vkGetBufferDeviceAddress(context.VkDevice, &addressInfo);
			BufferAddress = VkDeviceOrHostAddressConstKHR()
			{
				deviceAddress = address
			};
		}
		if (data != null)
		{
			SetData(context.CopyCommandBuffer, data, description.SizeInBytes);
		}
	}

	/// <summary>
	/// Fills the buffer from a pointer.
	/// </summary>
	/// <param name="commandBuffer">The command buffer.</param>
	/// <param name="source">The data pointer.</param>
	/// <param name="sourceSizeInBytes">The size in bytes.</param>
	/// <param name="destinationOffsetInBytes">The offset in bytes.</param>
	public void SetData(VkCommandBuffer commandBuffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		if (sourceSizeInBytes == 0 || Description.SizeInBytes < sourceSizeInBytes)
		{
			Context.ValidationLayer?.Notify("Vulkan", "invalid source size in bytes.");
		}
		if ((Description.Usage & ResourceUsage.Dynamic) == ResourceUsage.Dynamic || (Description.Usage & ResourceUsage.Staging) == ResourceUsage.Staging)
		{
			void* dataPointer = null;
			VulkanNative.vkMapMemory(vkContext.VkDevice, BufferMemory, destinationOffsetInBytes, sourceSizeInBytes, VkMemoryMapFlags.None, &dataPointer);
			Internal.MemCpy(dataPointer, (void*)source, sourceSizeInBytes);
			VulkanNative.vkUnmapMemory(vkContext.VkDevice, BufferMemory);
			return;
		}
		uint64 bufferPointer = vkContext.BufferUploader.Allocate(sourceSizeInBytes);
		Internal.MemCpy((void*)(int)bufferPointer, (void*)source, sourceSizeInBytes);
		VkBufferCopy copyRegion = default(VkBufferCopy);
		copyRegion.size = sourceSizeInBytes;
		copyRegion.srcOffset = vkContext.BufferUploader.CalculateOffset(bufferPointer);
		copyRegion.dstOffset = destinationOffsetInBytes;
		VkBufferMemoryBarrier barrier = default(VkBufferMemoryBarrier);
		barrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
		barrier.buffer = NativeBuffer;
		barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
		barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
		barrier.srcQueueFamilyIndex = uint32.MaxValue;
		barrier.dstQueueFamilyIndex = uint32.MaxValue;
		barrier.size = uint64.MaxValue;
		VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.None, 0, null, 1, &barrier, 0, null);
		VulkanNative.vkCmdCopyBuffer(commandBuffer, vkContext.BufferUploader.NativeBuffer, NativeBuffer, 1, &copyRegion);
		barrier.srcAccessMask = barrier.dstAccessMask;
		if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_UNIFORM_READ_BIT;
		}
		else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
		}
		else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
		}
		else
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
		}
		VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 1, &barrier, 0, null);
	}

	/// <summary>
	/// Copies this buffer to the destination buffer.
	/// </summary>
	/// <param name="commandBuffer">The command buffer.</param>
	/// <param name="queueType">The command queue type of the command buffer.</param>
	/// <param name="destination">The destination buffer.</param>
	/// <param name="sizeInBytes">The size of data in bytes to copy.</param>
	/// <param name="sourceOffset">The source buffer offset in bytes.</param>
	/// <param name="destinationOffset">The destination buffer offset in bytes.</param>
	public void CopyTo(VkCommandBuffer commandBuffer, CommandQueueType queueType, Sedulous.RHI.Buffer destination, uint32 sizeInBytes, uint32 sourceOffset, uint32 destinationOffset)
	{
		VKBuffer dstBuffer = destination as VKBuffer;
		VkBufferCopy vkBufferCopy = default(VkBufferCopy);
		vkBufferCopy.srcOffset = sourceOffset;
		vkBufferCopy.dstOffset = destinationOffset;
		vkBufferCopy.size = sizeInBytes;
		VkBufferCopy region = vkBufferCopy;
		VkPipelineStageFlags stages = VkPipelineStageFlags.VK_PIPELINE_STAGE_NONE;
		VkBufferMemoryBarrier barrier = default(VkBufferMemoryBarrier);
		barrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
		barrier.buffer = NativeBuffer;
		barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
		if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_UNIFORM_READ_BIT;
			if ((queueType & CommandQueueType.Graphics) != 0)
			{
				stages = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT;
			}
			stages |= VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
		}
		else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_VERTEX_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
			stages = VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT;
		}
		else if ((vkUsage & VkBufferUsageFlags.VK_BUFFER_USAGE_INDEX_BUFFER_BIT) != 0)
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_INDEX_READ_BIT;
			stages = VkPipelineStageFlags.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT;
		}
		else
		{
			barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT;
			if ((queueType & CommandQueueType.Graphics) != 0)
			{
				stages = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT;
			}
			stages |= VkPipelineStageFlags.VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT;
		}
		barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_TRANSFER_WRITE_BIT;
		barrier.srcQueueFamilyIndex = uint32.MaxValue;
		barrier.dstQueueFamilyIndex = uint32.MaxValue;
		barrier.size = uint64.MaxValue;
		VulkanNative.vkCmdPipelineBarrier(commandBuffer, stages, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 0, null, 1, &barrier, 0, null);
		VulkanNative.vkCmdCopyBuffer(commandBuffer, NativeBuffer, dstBuffer.NativeBuffer, 1, &region);
		VkAccessFlags tmp = barrier.srcAccessMask;
		barrier.srcAccessMask = barrier.dstAccessMask;
		barrier.dstAccessMask = tmp;
		VulkanNative.vkCmdPipelineBarrier(commandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_TRANSFER_BIT, stages, VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT, 0, null, 1, &barrier, 0, null);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and optionally managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				VKGraphicsContext obj = Context as VKGraphicsContext;
				VulkanNative.vkDestroyBuffer(obj.VkDevice, NativeBuffer, null);
				VulkanNative.vkFreeMemory(obj.VkDevice, BufferMemory, null);
			}
			disposed = true;
		}
	}
}
