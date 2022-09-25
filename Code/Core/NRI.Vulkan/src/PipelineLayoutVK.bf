using Bulkan;
using System.Collections;
using System;
namespace NRI.Vulkan;

struct PushConstantRangeBindingDesc
{
	public VkShaderStageFlags flags;
	public uint32 offset;
}

struct RuntimeBindingInfo : IDisposable
{
	private DeviceAllocator<uint8> m_Allocator;

	public this(DeviceAllocator<uint8> allocator)
	{
		m_Allocator = allocator;

		hasVariableDescriptorNum = Allocate!<List<bool>>(m_Allocator);
		descriptorSetRangeDescs = Allocate!<List<DescriptorRangeDesc>>(m_Allocator);
		dynamicConstantBufferDescs = Allocate!<List<DynamicConstantBufferDesc>>(m_Allocator);
		descriptorSetDescs = Allocate!<List<DescriptorSetDesc>>(m_Allocator);
		pushConstantDescs = Allocate!<List<PushConstantDesc>>(m_Allocator);
		pushConstantBindings = Allocate!<List<PushConstantRangeBindingDesc>>(m_Allocator);
	}

	public List<bool> hasVariableDescriptorNum;
	public List<DescriptorRangeDesc> descriptorSetRangeDescs;
	public List<DynamicConstantBufferDesc> dynamicConstantBufferDescs;
	public List<DescriptorSetDesc> descriptorSetDescs;
	public List<PushConstantDesc> pushConstantDescs;
	public List<PushConstantRangeBindingDesc> pushConstantBindings;

	public void Dispose()
	{
		Deallocate!(m_Allocator, pushConstantBindings);
		Deallocate!(m_Allocator, pushConstantDescs);
		Deallocate!(m_Allocator, descriptorSetDescs);
		Deallocate!(m_Allocator, dynamicConstantBufferDescs);
		Deallocate!(m_Allocator, descriptorSetRangeDescs);
		Deallocate!(m_Allocator, hasVariableDescriptorNum);
	}
}

class PipelineLayoutVK : PipelineLayout
{
	private void FillBindingOffsets(bool ignoreGlobalSPIRVOffsets, uint32* bindingOffsets)
	{
		SPIRVBindingOffsets spirvBindingOffsets;

		if (ignoreGlobalSPIRVOffsets)
			spirvBindingOffsets = .();
		else
			spirvBindingOffsets = m_Device.GetSPIRVBindingOffsets();

		bindingOffsets[(uint32)DescriptorType.SAMPLER] = spirvBindingOffsets.samplerOffset;
		bindingOffsets[(uint32)DescriptorType.CONSTANT_BUFFER] = spirvBindingOffsets.constantBufferOffset;
		bindingOffsets[(uint32)DescriptorType.TEXTURE] = spirvBindingOffsets.textureOffset;
		bindingOffsets[(uint32)DescriptorType.STORAGE_TEXTURE] = spirvBindingOffsets.storageTextureAndBufferOffset;
		bindingOffsets[(uint32)DescriptorType.BUFFER] = spirvBindingOffsets.textureOffset;
		bindingOffsets[(uint32)DescriptorType.STORAGE_BUFFER] = spirvBindingOffsets.storageTextureAndBufferOffset;
		bindingOffsets[(uint32)DescriptorType.STRUCTURED_BUFFER] = spirvBindingOffsets.textureOffset;
		bindingOffsets[(uint32)DescriptorType.STORAGE_STRUCTURED_BUFFER] = spirvBindingOffsets.storageTextureAndBufferOffset;
		bindingOffsets[(uint32)DescriptorType.ACCELERATION_STRUCTURE] = spirvBindingOffsets.textureOffset;
	}

	private void ReserveStaticSamplers(PipelineLayoutDesc pipelineLayoutDesc)
	{
		uint32 staticSamplerNum = 0;
		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
			staticSamplerNum += pipelineLayoutDesc.descriptorSets[i].staticSamplerNum;

		m_StaticSamplers.Reserve(staticSamplerNum);
	}

	private void CreateSetLayout(DescriptorSetDesc descriptorSetDesc, uint32* bindingOffsets)
	{
		uint32 bindingMaxNum = descriptorSetDesc.dynamicConstantBufferNum + descriptorSetDesc.staticSamplerNum;

		for (uint32 i = 0; i < descriptorSetDesc.rangeNum; i++)
		{
			readonly ref DescriptorRangeDesc range = ref descriptorSetDesc.ranges[i];
			bindingMaxNum += range.isArray ? 1 : range.descriptorNum;
		}

		VkDescriptorSetLayoutBinding* bindings = ALLOCATE_SCRATCH!<VkDescriptorSetLayoutBinding>(m_Device, bindingMaxNum);
		VkDescriptorBindingFlags* bindingFlags = ALLOCATE_SCRATCH!<VkDescriptorBindingFlags>(m_Device, bindingMaxNum);
		VkDescriptorSetLayoutBinding* bindingsBegin = bindings;
		VkDescriptorBindingFlags* bindingFlagsBegin = bindingFlags;

		FillDescriptorBindings(descriptorSetDesc, bindingOffsets, ref bindings, ref bindingFlags);
		FillDynamicConstantBufferBindings(descriptorSetDesc, bindingOffsets, ref bindings, ref bindingFlags);
		CreateStaticSamplersAndFillSamplerBindings(descriptorSetDesc, bindingOffsets, ref bindings, ref bindingFlags);

		readonly uint32 bindingNum = uint32(bindings - bindingsBegin);

		VkDescriptorSetLayoutBindingFlagsCreateInfo bindingFlagsInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO,
				pNext = null,
				bindingCount = bindingNum,
				pBindingFlags = bindingFlagsBegin
			};

		VkDescriptorSetLayoutCreateInfo info = .()
			{
				sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
				pNext = m_Device.IsDescriptorIndexingExtSupported() ? &bindingFlagsInfo : null,
				flags = (VkDescriptorSetLayoutCreateFlags)0,
				bindingCount = bindingNum,
				pBindings = bindingsBegin
			};

		VkDescriptorSetLayout handle = .Null;

		readonly VkResult result = VulkanNative.vkCreateDescriptorSetLayout(m_Device, &info, m_Device.GetAllocationCallbacks(), &handle);

		m_DescriptorSetLayouts.Add(handle);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, void(),
			"Can't create the descriptor set layout: vkCreateDescriptorSetLayout returned {0}.", (int32)result);

		FREE_SCRATCH!(m_Device, bindingsBegin, bindingMaxNum);
		FREE_SCRATCH!(m_Device, bindingFlagsBegin, bindingMaxNum);
	}

	private void FillDescriptorBindings(DescriptorSetDesc descriptorSetDesc, uint32* bindingOffsets,
		ref VkDescriptorSetLayoutBinding* bindings, ref VkDescriptorBindingFlags* bindingFlags)
	{
		const VkDescriptorBindingFlags variableSizedArrayFlags = .VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT |
			.VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT;

		for (uint32 i = 0; i < descriptorSetDesc.rangeNum; i++)
		{
			readonly ref DescriptorRangeDesc range = ref descriptorSetDesc.ranges[i];

			readonly uint32 baseBindingIndex = range.baseRegisterIndex + bindingOffsets[(uint32)range.descriptorType];

			if (range.isArray)
			{
				*(bindingFlags++) = range.isDescriptorNumVariable ? variableSizedArrayFlags : 0;

				ref VkDescriptorSetLayoutBinding descriptorBinding = ref *(bindings++);
				descriptorBinding = .();
				descriptorBinding.binding = baseBindingIndex;
				descriptorBinding.descriptorType = GetDescriptorType(range.descriptorType);
				descriptorBinding.descriptorCount = range.descriptorNum;
				descriptorBinding.stageFlags = GetShaderStageFlags(range.visibility);
			}
			else
			{
				for (uint32 j = 0; j < range.descriptorNum; j++)
				{
					*(bindingFlags++) = 0;

					ref VkDescriptorSetLayoutBinding descriptorBinding = ref *(bindings++);
					descriptorBinding = .();
					descriptorBinding.binding = baseBindingIndex + j;
					descriptorBinding.descriptorType = GetDescriptorType(range.descriptorType);
					descriptorBinding.descriptorCount = 1;
					descriptorBinding.stageFlags = GetShaderStageFlags(range.visibility);
				}
			}
		}
	}

	private void FillDynamicConstantBufferBindings(DescriptorSetDesc descriptorSetDesc, uint32* bindingOffsets,
		ref VkDescriptorSetLayoutBinding* bindings, ref VkDescriptorBindingFlags* bindingFlags)
	{
		for (uint32 i = 0; i < descriptorSetDesc.dynamicConstantBufferNum; i++)
		{
			readonly ref DynamicConstantBufferDesc buffer = ref descriptorSetDesc.dynamicConstantBuffers[i];

			*(bindingFlags++) = 0;

			ref VkDescriptorSetLayoutBinding descriptorBinding = ref *(bindings++);
			descriptorBinding = .();
			descriptorBinding.binding = buffer.registerIndex + bindingOffsets[(uint32)DescriptorType.CONSTANT_BUFFER];
			descriptorBinding.descriptorType = .VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
			descriptorBinding.descriptorCount = 1;
			descriptorBinding.stageFlags = GetShaderStageFlags(buffer.visibility);
		}
	}

	private void CreateStaticSamplersAndFillSamplerBindings(DescriptorSetDesc descriptorSetDesc, uint32* bindingOffsets,
		ref VkDescriptorSetLayoutBinding* bindings, ref VkDescriptorBindingFlags* bindingFlags)
	{
		for (uint32 i = 0; i < descriptorSetDesc.staticSamplerNum; i++)
		{
			readonly ref StaticSamplerDesc sampler = ref descriptorSetDesc.staticSamplers[i];

			m_StaticSamplers.Add(Allocate!<DescriptorVK>(m_Device.GetAllocator(), m_Device));
			ref DescriptorVK descriptor = ref m_StaticSamplers.Back;

			descriptor.Create(sampler.samplerDesc);

			*(bindingFlags++) = 0;

			ref VkDescriptorSetLayoutBinding descriptorBinding = ref *(bindings++);
			descriptorBinding = .();
			descriptorBinding.binding = sampler.registerIndex + bindingOffsets[(uint32)DescriptorType.SAMPLER];
			descriptorBinding.descriptorType = .VK_DESCRIPTOR_TYPE_SAMPLER;
			descriptorBinding.descriptorCount = 1;
			descriptorBinding.stageFlags = GetShaderStageFlags(sampler.visibility);
			descriptorBinding.pImmutableSamplers = &descriptor.GetSampler();
		}
	}

	private void FillPushConstantRanges(PipelineLayoutDesc pipelineLayoutDesc, VkPushConstantRange* pushConstantRanges)
	{
		uint32 offset = 0;

		for (uint32 i = 0; i < pipelineLayoutDesc.pushConstantNum; i++)
		{
			readonly ref PushConstantDesc pushConstantDesc = ref pipelineLayoutDesc.pushConstants[i];

			ref VkPushConstantRange range = ref pushConstantRanges[i];
			range = .();
			range.stageFlags = GetShaderStageFlags(pushConstantDesc.visibility);
			range.offset = offset;
			range.size = pushConstantDesc.size;

			offset += pushConstantDesc.size;
		}
	}

	private void FillRuntimeBindingInfo(PipelineLayoutDesc pipelineLayoutDesc, uint32* bindingOffsets)
	{
		ref RuntimeBindingInfo destination = ref m_RuntimeBindingInfo;
		readonly ref PipelineLayoutDesc source = ref pipelineLayoutDesc;

		destination.descriptorSetDescs.Insert(0, Span<DescriptorSetDesc>(source.descriptorSets, source.descriptorSetNum));

		destination.pushConstantDescs.Insert(0, Span<PushConstantDesc>(source.pushConstants, source.pushConstantNum));

		destination.pushConstantBindings.Resize(source.pushConstantNum);
		for (uint32 i = 0, offset = 0; i < source.pushConstantNum; i++)
    {
        destination.pushConstantBindings[i] = .(){ flags = GetShaderStageFlags(source.pushConstants[i].visibility), offset = offset };
        offset += source.pushConstants[i].size;
    }

    int rangeNum = 0;
    int dynamicConstantBufferNum = 0;
    for (uint32 i = 0; i < source.descriptorSetNum; i++)
    {
        rangeNum += source.descriptorSets[i].rangeNum;
        dynamicConstantBufferNum += source.descriptorSets[i].dynamicConstantBufferNum;
    }

    destination.hasVariableDescriptorNum.Resize(source.descriptorSetNum);
    destination.descriptorSetRangeDescs.Reserve(rangeNum);
    destination.dynamicConstantBufferDescs.Reserve(dynamicConstantBufferNum);

    for (uint32 i = 0; i < source.descriptorSetNum; i++)
    {
        readonly ref DescriptorSetDesc descriptorSetDesc = ref source.descriptorSets[i];

        destination.hasVariableDescriptorNum[i] = false;

        destination.descriptorSetDescs[i].ranges =
            destination.descriptorSetRangeDescs.Ptr + destination.descriptorSetRangeDescs.Count;

        destination.descriptorSetDescs[i].dynamicConstantBuffers =
            destination.dynamicConstantBufferDescs.Ptr + destination.dynamicConstantBufferDescs.Count;

        // Copy descriptor range descs
        destination.descriptorSetRangeDescs.AddRange(Span<DescriptorRangeDesc>(descriptorSetDesc.ranges, descriptorSetDesc.rangeNum));

        // Fix descriptor range binding offsets and check for variable descriptor num
        DescriptorRangeDesc* ranges = destination.descriptorSetDescs[i].ranges;
        for (uint32 j = 0; j < descriptorSetDesc.rangeNum; j++)
        {
            ranges[j].baseRegisterIndex += bindingOffsets[(uint32)descriptorSetDesc.ranges[j].descriptorType];

            if (m_Device.IsDescriptorIndexingExtSupported() && descriptorSetDesc.ranges[j].isDescriptorNumVariable)
                destination.hasVariableDescriptorNum[i] = true;
        }

        // Copy dynamic constant buffer descs
        destination.dynamicConstantBufferDescs.AddRange(Span<DynamicConstantBufferDesc>(descriptorSetDesc.dynamicConstantBuffers, descriptorSetDesc.dynamicConstantBufferNum));

        // Copy dynamic constant buffer binding offsets
        DynamicConstantBufferDesc* dynamicConstantBuffers = destination.descriptorSetDescs[i].dynamicConstantBuffers;
        for (uint32 j = 0; j < descriptorSetDesc.dynamicConstantBufferNum; j++)
            dynamicConstantBuffers[j].registerIndex += bindingOffsets[(uint32)DescriptorType.CONSTANT_BUFFER];
    }
}

	private VkPipelineLayout m_Handle = .Null;
	private VkPipelineBindPoint m_PipelineBindPoint = 0;//VK_PIPELINE_BIND_POINT_MAX_ENUM;
	private RuntimeBindingInfo m_RuntimeBindingInfo;
	private List<VkDescriptorSetLayout> m_DescriptorSetLayouts;
	private List<DescriptorVK> m_StaticSamplers;
	private DeviceVK m_Device;

	public this(DeviceVK device){
		m_Device = device;

		m_RuntimeBindingInfo = .(m_Device.GetAllocator());
		m_DescriptorSetLayouts = Allocate!<List<VkDescriptorSetLayout>>(m_Device.GetAllocator());
		m_StaticSamplers = Allocate!<List<DescriptorVK>>(m_Device.GetAllocator());
	}

	public ~this(){

		readonly VkAllocationCallbacks* allocationCallbacks = m_Device.GetAllocationCallbacks();

		if (m_Handle != .Null)
		    VulkanNative.vkDestroyPipelineLayout(m_Device, m_Handle, allocationCallbacks);

		for (ref VkDescriptorSetLayout handle in ref m_DescriptorSetLayouts)
		    VulkanNative.vkDestroyDescriptorSetLayout(m_Device, handle, allocationCallbacks);

		m_StaticSamplers.Clear();

		Deallocate!(m_Device.GetAllocator(), m_StaticSamplers);
		Deallocate!(m_Device.GetAllocator(), m_DescriptorSetLayouts);
		m_RuntimeBindingInfo.Dispose();
	}

	public static implicit operator VkPipelineLayout(Self self) => self.m_Handle;
	public DeviceVK GetDevice() => m_Device;

	public Result Create(PipelineLayoutDesc pipelineLayoutDesc)
	{
	    if (pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.ALL_GRAPHICS))
	        m_PipelineBindPoint = .VK_PIPELINE_BIND_POINT_GRAPHICS;
	
	    if (pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.COMPUTE))
	        m_PipelineBindPoint = .VK_PIPELINE_BIND_POINT_COMPUTE;
	
	    if (pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.ALL_RAY_TRACING))
	        m_PipelineBindPoint = .VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR;
	
	    uint32[(uint32)DescriptorType.MAX_NUM] bindingOffsets = .();
	    FillBindingOffsets(pipelineLayoutDesc.ignoreGlobalSPIRVOffsets, &bindingOffsets);
	
	    ReserveStaticSamplers(pipelineLayoutDesc);
	
	    m_DescriptorSetLayouts.Reserve(pipelineLayoutDesc.descriptorSetNum);
	    for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
	        CreateSetLayout(pipelineLayoutDesc.descriptorSets[i], &bindingOffsets);
	
	    VkPushConstantRange* pushConstantRanges = ALLOCATE_SCRATCH!<VkPushConstantRange>(m_Device, pipelineLayoutDesc.pushConstantNum);
	    FillPushConstantRanges(pipelineLayoutDesc, pushConstantRanges);
	
	    VkPipelineLayoutCreateInfo pipelineLayoutCreateInfo = .(){ sType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
	    pipelineLayoutCreateInfo.setLayoutCount = pipelineLayoutDesc.descriptorSetNum;
	    pipelineLayoutCreateInfo.pSetLayouts = m_DescriptorSetLayouts.Ptr;
	    pipelineLayoutCreateInfo.pushConstantRangeCount = pipelineLayoutDesc.pushConstantNum;
	    pipelineLayoutCreateInfo.pPushConstantRanges = pushConstantRanges;
	
	    readonly VkResult result = VulkanNative.vkCreatePipelineLayout(m_Device, &pipelineLayoutCreateInfo, m_Device.GetAllocationCallbacks(), &m_Handle);
	
	    RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, Result.FAILURE,
	        "Can't create a pipeline layout: vkCreatePipelineLayout returned {0}.", (int32)result);
	
	    FREE_SCRATCH!(m_Device, pushConstantRanges, pipelineLayoutDesc.pushConstantNum);
	
	    FillRuntimeBindingInfo(pipelineLayoutDesc, &bindingOffsets);
	
	    return Result.SUCCESS;
	}

	public readonly ref RuntimeBindingInfo GetRuntimeBindingInfo() => ref m_RuntimeBindingInfo;
	public VkDescriptorSetLayout GetDescriptorSetLayout(uint32 index) => m_DescriptorSetLayouts[index];
	public VkPipelineBindPoint GetPipelineBindPoint() => m_PipelineBindPoint;

	public void SetDebugName(char8* name)
	{
    m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_PIPELINE_LAYOUT, (uint64)m_Handle, name);
	}
}