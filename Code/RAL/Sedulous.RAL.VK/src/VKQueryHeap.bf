using Bulkan;
using System;
namespace Sedulous.RAL.VK;

class VKQueryHeap : QueryHeap
{
	private VKDevice m_device;
	private VkQueryPool m_query_pool;
	private VkQueryType m_query_type;

	public this(VKDevice device, QueryHeapType type, uint32 count)
	{
		m_device = device;
		Runtime.Assert(type == QueryHeapType.kAccelerationStructureCompactedSize);
		m_query_type = VkQueryType.VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR;
		VkQueryPoolCreateInfo desc = .() { sType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO };
		desc.queryCount = count;
		desc.queryType = m_query_type;
		VulkanNative.vkCreateQueryPool(m_device.GetDevice(), &desc, null, &m_query_pool);
	}

	public override QueryHeapType GetQueryHeapType()
	{
		return QueryHeapType.kAccelerationStructureCompactedSize;
	}

	public VkQueryType GetQueryType()
	{
		return m_query_type;
	}

	public VkQueryPool GetQueryPool()
	{
		return m_query_pool;
	}
}