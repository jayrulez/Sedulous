using System.Collections;
using Bulkan;
namespace NRI.Vulkan;

public static
{
	public static void AddDescriptorPoolSize(VkDescriptorPoolSize* poolSizeArray, ref uint32 poolSizeArraySize, VkDescriptorType type, uint32 descriptorCount)
	{
		if (descriptorCount == 0)
			return;

		ref VkDescriptorPoolSize poolSize = ref poolSizeArray[poolSizeArraySize++];
		poolSize.type = type;
		poolSize.descriptorCount = descriptorCount;
	}
}

class DescriptorPoolVK : DescriptorPool
{
	private VkDescriptorPool m_Handle = .Null;
	private List<DescriptorSetVK> m_AllocatedSets;
	private uint32 m_UsedSets = 0;
	private DeviceVK m_Device;
	private bool m_OwnsNativeObjects = false;

	public this(DeviceVK device)
	{
		m_Device = device;
		m_AllocatedSets = Allocate!<List<DescriptorSetVK>>(m_Device.GetAllocator());

		const uint initialCapacity = 64;
		m_AllocatedSets.Reserve(initialCapacity);
	}

	public ~this()
	{
		for (int i = 0; i < m_AllocatedSets.Count; i++)
		{
			Deallocate!(m_Device.GetAllocator(), m_AllocatedSets[i]);
		}

		if (m_Handle != .Null && m_OwnsNativeObjects)
			VulkanNative.vkDestroyDescriptorPool(m_Device, m_Handle, m_Device.GetAllocationCallbacks());

		Deallocate!(m_Device.GetAllocator(), m_AllocatedSets);
	}

	public static implicit operator VkDescriptorPool(Self self) => self.m_Handle;
	public DeviceVK GetDevice() => m_Device;

	public Result Create(DescriptorPoolDesc descriptorPoolDesc)
	{
		m_OwnsNativeObjects = true;

		VkDescriptorPoolSize[16] descriptorPoolSizeArray = .();
		for (uint32 i = 0; i < descriptorPoolSizeArray.Count; i++)
			descriptorPoolSizeArray[i].type = (VkDescriptorType)i;

		readonly uint32 physicalDeviceMask = GetPhysicalDeviceGroupMask(descriptorPoolDesc.physicalDeviceMask);

		uint32 phyiscalDeviceNum = 0;
		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
			phyiscalDeviceNum += ((1 << i) & physicalDeviceMask) != 0 ? 1 : 0;

		uint32 poolSizeCount = 0;

		readonly uint32 samplerMaxNum = descriptorPoolDesc.staticSamplerMaxNum + descriptorPoolDesc.samplerMaxNum;
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_SAMPLER, samplerMaxNum);

		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, descriptorPoolDesc.constantBufferMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC, descriptorPoolDesc.dynamicConstantBufferMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE, descriptorPoolDesc.textureMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_STORAGE_IMAGE, descriptorPoolDesc.storageTextureMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER, descriptorPoolDesc.bufferMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER, descriptorPoolDesc.storageBufferMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_STORAGE_BUFFER, descriptorPoolDesc.structuredBufferMaxNum + descriptorPoolDesc.storageStructuredBufferMaxNum);
		AddDescriptorPoolSize(&descriptorPoolSizeArray, ref poolSizeCount, .VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV, descriptorPoolDesc.accelerationStructureMaxNum);

		for (uint32 i = 0; i < poolSizeCount; i++)
			descriptorPoolSizeArray[i].descriptorCount *= phyiscalDeviceNum;

		/*readonly*/ VkDescriptorPoolCreateInfo info = .()
			{
				sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
				pNext = null,
				flags = .VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT,
				maxSets = descriptorPoolDesc.descriptorSetMaxNum * phyiscalDeviceNum,
				poolSizeCount = poolSizeCount,
				pPoolSizes = &descriptorPoolSizeArray
			};

		readonly VkResult result = VulkanNative.vkCreateDescriptorPool(m_Device, &info, m_Device.GetAllocationCallbacks(), &m_Handle);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a descriptor pool: vkCreateDescriptorPool returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public Result Create(NRIVkDescriptorPool vkDescriptorPool)
	{
		m_OwnsNativeObjects = false;
		m_Handle = (VkDescriptorPool)vkDescriptorPool;

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_DESCRIPTOR_POOL, (uint64)m_Handle, name);
	}

	public Result AllocateDescriptorSets(PipelineLayout pipelineLayout, uint32 setIndex, DescriptorSet* descriptorSets, uint32 numberOfCopies, uint32 physicalDeviceMask, uint32 variableDescriptorNum)
	{
		var physicalDeviceMask;
		var variableDescriptorNum;
		readonly PipelineLayoutVK pipelineLayoutVK = (PipelineLayoutVK)pipelineLayout;

		readonly uint32 freeSetNum = (uint32)m_AllocatedSets.Count - m_UsedSets;

		if (freeSetNum < numberOfCopies)
		{
			readonly uint32 newSetNum = numberOfCopies - freeSetNum;
			readonly uint32 prevSetNum = (uint32)m_AllocatedSets.Count;
			m_AllocatedSets.Resize(prevSetNum + newSetNum);

			/*readonly ref MemoryAllocatorInterface lowLevelAllocator = ref m_Device.GetAllocator().GetInterface();

			for (int i = 0; i < newSetNum; i++)
			{
				m_AllocatedSets[prevSetNum + i] = (DescriptorSetVK)lowLevelAllocator.Allocate(lowLevelAllocator.userArg,
					sizeof(DescriptorSetVK), alignof(DescriptorSetVK));

				Construct(m_AllocatedSets[prevSetNum + i], 1, m_Device);
			}*/

			for (int i = 0; i < newSetNum; i++)
			{
				m_AllocatedSets[prevSetNum + i] = Allocate!<DescriptorSetVK>(m_Device.GetAllocator(), m_Device);
			}
		}

		for (int i = 0; i < numberOfCopies; i++)
			descriptorSets[i] = (DescriptorSet)m_AllocatedSets[m_UsedSets + i];
		m_UsedSets += numberOfCopies;

		readonly VkDescriptorSetLayout setLayout = pipelineLayoutVK.GetDescriptorSetLayout(setIndex);
		/*readonly*/ ref DescriptorSetDesc setDesc = ref pipelineLayoutVK.GetRuntimeBindingInfo().descriptorSetDescs[setIndex];
		readonly bool hasVariableDescriptorNum = pipelineLayoutVK.GetRuntimeBindingInfo().hasVariableDescriptorNum[setIndex];

		VkDescriptorSetVariableDescriptorCountAllocateInfo variableDescriptorCountInfo;
		variableDescriptorCountInfo.sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO;
		variableDescriptorCountInfo.pNext = null;
		variableDescriptorCountInfo.descriptorSetCount = 1;
		variableDescriptorCountInfo.pDescriptorCounts = &variableDescriptorNum;

		physicalDeviceMask = GetPhysicalDeviceGroupMask(physicalDeviceMask);

		VkDescriptorSetLayout[PHYSICAL_DEVICE_GROUP_MAX_SIZE] setLayoutArray = .();
		uint32 phyicalDeviceNum = 0;
		for (uint32 i = 0; i < m_Device.GetPhyiscalDeviceGroupSize(); i++)
		{
			if ((1 << i) & physicalDeviceMask != 0)
				setLayoutArray[phyicalDeviceNum++] = setLayout;
		}

		/*readonly*/ VkDescriptorSetAllocateInfo info = .()
			{
				sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
				pNext = hasVariableDescriptorNum ? &variableDescriptorCountInfo : null,
				descriptorPool = m_Handle,
				descriptorSetCount = phyicalDeviceNum,
				pSetLayouts = &setLayoutArray
			};

		VkDescriptorSet[PHYSICAL_DEVICE_GROUP_MAX_SIZE] handles = .();

		VkResult result = .VK_SUCCESS;
		for (uint32 i = 0; i < numberOfCopies && result == .VK_SUCCESS; i++)
		{
			result = VulkanNative.vkAllocateDescriptorSets(m_Device, &info, &handles);
			((DescriptorSetVK)descriptorSets[i]).Create(&handles, physicalDeviceMask, ref setDesc);
		}

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't allocate descriptor sets: vkAllocateDescriptorSets returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public void Reset()
	{
		m_UsedSets = 0;

		readonly VkResult result = VulkanNative.vkResetDescriptorPool(m_Device, m_Handle, /*(VkDescriptorPoolResetFlags)*/ 0);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, void(),
			"Can't reset a descriptor pool: vkResetDescriptorPool returned {0}.", (int32)result);
	}
}