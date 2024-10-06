using System;
using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// Represents a Vulkan query heap object.
/// </summary>
public class VKQueryHeap : QueryHeap
{
	/// <summary>
	/// The Vulkan native object.
	/// </summary>
	public VkQueryPool nativeQueryHeap;

	private VKGraphicsContext vkContext;

	/// <inheritdoc />
	public override void* NativePointer => (void*)(int)nativeQueryHeap.Handle;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKQueryHeap" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The query heap description.</param>
	public this(VKGraphicsContext context, in QueryHeapDescription description)
		: base(context, description)
	{
		vkContext = context;
		VkQueryPoolCreateInfo poolInfo = VkQueryPoolCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO,
			queryCount = description.QueryCount
		};
		switch (description.Type)
		{
		case QueryType.Timestamp:
			poolInfo.queryType = VkQueryType.VK_QUERY_TYPE_TIMESTAMP;
			break;
		case QueryType.Occlusion,
			 QueryType.BinaryOcclusion:
			poolInfo.queryType = VkQueryType.VK_QUERY_TYPE_OCCLUSION;
			break;
		}
		VkQueryPool newPool = default(VkQueryPool);
		VulkanNative.vkCreateQueryPool(vkContext.VkDevice, &poolInfo, null, &newPool);
		nativeQueryHeap = newPool;
		VulkanNative.vkResetQueryPool(vkContext.VkDevice, nativeQueryHeap, 0, poolInfo.queryCount);
	}

	/// <inheritdoc />
	public override bool ReadData(uint32 startIndex, uint32 count, uint64[] results)
	{
		uint64 stride = 8uL;
		uint32 size = 8 * count;
		VkResult num = VulkanNative.vkGetQueryPoolResults(vkContext.VkDevice, nativeQueryHeap, startIndex, count, uint(size), (void*)results.Ptr, stride, VkQueryResultFlags.VK_QUERY_RESULT_64_BIT);
		VulkanNative.vkResetQueryPool(vkContext.VkDevice, nativeQueryHeap, startIndex, count);
		return num == VkResult.VK_SUCCESS;
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
				VulkanNative.vkDestroyQueryPool((Context as VKGraphicsContext).VkDevice, nativeQueryHeap, null);
			}
			disposed = true;
		}
	}
}
