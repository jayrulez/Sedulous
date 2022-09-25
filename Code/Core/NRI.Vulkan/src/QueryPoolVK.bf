using Bulkan;
namespace NRI.Vulkan;

class QueryPoolVK : QueryPool
{
	private VkQueryPool[PHYSICAL_DEVICE_GROUP_MAX_SIZE] m_Handles = .();
	private uint32 m_Stride = 0;
	private VkQueryType m_Type = (VkQueryType)0;
	private DeviceVK m_Device;
	private bool m_OwnsNativeObjects = false;

	public this(DeviceVK device)
	{
		m_Device = device;
	}

	public ~this()
	{
		if (!m_OwnsNativeObjects)
			return;

		for (uint32 i = 0; i < m_Handles.Count; i++)
		{
			if (m_Handles[i] != .Null)
				VulkanNative.vkDestroyQueryPool(m_Device, m_Handles[i], m_Device.GetAllocationCallbacks());
		}
	}

	public VkQueryPool GetHandle(uint32 physicalDeviceIndex) => m_Handles[physicalDeviceIndex];
	public DeviceVK GetDevice() => m_Device;
	public uint32 GetStride() => m_Stride;
	public VkQueryType GetQueryType() => m_Type;

	public Result Create(QueryPoolDesc queryPoolDesc)
	{
		m_OwnsNativeObjects = true;
		m_Type = NRI.Vulkan.GetQueryType(queryPoolDesc.queryType);

		/*readonly*/ VkQueryPoolCreateInfo poolInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO,
				pNext = null,
				flags = /*(VkQueryPoolCreateFlags)*/ 0,
				queryType = m_Type,
				queryCount = queryPoolDesc.capacity,
				pipelineStatistics = GetQueryPipelineStatisticsFlags(queryPoolDesc.pipelineStatsMask)
			};

		readonly uint32 physicalDeviceMask = (queryPoolDesc.physicalDeviceMask == WHOLE_DEVICE_GROUP) ? 0xff : queryPoolDesc.physicalDeviceMask;

		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
		{
			if ((1 << i) & physicalDeviceMask != 0)
			{
				readonly VkResult result = VulkanNative.vkCreateQueryPool(m_Device, &poolInfo, m_Device.GetAllocationCallbacks(), &m_Handles[i]);

				RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
					"Can't create a query pool: vkCreateQueryPool returned {0}.", (int32)result);
			}
		}

		m_Stride = GetQuerySize();

		return Result.SUCCESS;
	}

	public Result Create(QueryPoolVulkanDesc queryPoolDesc)
	{
		m_OwnsNativeObjects = false;
		m_Type = (VkQueryType)queryPoolDesc.vkQueryType;

		readonly VkQueryPool handle = (VkQueryPool)queryPoolDesc.vkQueryPool;
		readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(queryPoolDesc.physicalDeviceMask);

		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
		{
			if ((1 << i) & physicalDeviceMask != 0)
				m_Handles[i] = handle;
		}

		m_Stride = GetQuerySize();

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		uint64[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();
		for (uint i = 0; i < handles.Count; i++)
			handles[i] = (uint64)m_Handles[i];

		m_Device.SetDebugNameToDeviceGroupObject(.VK_OBJECT_TYPE_QUERY_POOL, &handles, name);
	}

	public uint32 GetQuerySize()
	{
		const uint32 highestBitInPipelineStatsBits = 11;

		switch (m_Type)
		{
		case .VK_QUERY_TYPE_TIMESTAMP:
			return sizeof(uint64);
		case .VK_QUERY_TYPE_OCCLUSION:
			return sizeof(uint64);
		case .VK_QUERY_TYPE_PIPELINE_STATISTICS:
			return highestBitInPipelineStatsBits * sizeof(uint64);
		default:
			CHECK(m_Device.GetLogger(), false, "unexpected query type in GetQuerySize: {0}", (uint32)m_Type);
			return 0;
		}
	}
}