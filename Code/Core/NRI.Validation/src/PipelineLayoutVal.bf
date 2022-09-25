using System.Collections;
using System;
namespace NRI.Validation;

class PipelineLayoutVal : PipelineLayout, DeviceObjectVal<PipelineLayout>
{
	private PipelineLayoutDesc m_PipelineLayoutDesc;
	private List<DescriptorSetDesc> m_DescriptorSets;
	private List<PushConstantDesc> m_PushConstants;
	private List<DescriptorRangeDesc> m_DescriptorRangeDescs;
	private List<StaticSamplerDesc> m_StaticSamplerDescs;
	private List<DynamicConstantBufferDesc> m_DynamicConstantBufferDescs;

	public this(DeviceVal device, PipelineLayout pipelineLayout, PipelineLayoutDesc pipelineLayoutDesc) : base(device, pipelineLayout)
	{
		m_DescriptorSets = Allocate!<List<DescriptorSetDesc>>(m_Device.GetAllocator());
		m_PushConstants = Allocate!<List<PushConstantDesc>>(m_Device.GetAllocator());
		m_DescriptorRangeDescs = Allocate!<List<DescriptorRangeDesc>>(m_Device.GetAllocator());
		m_StaticSamplerDescs = Allocate!<List<StaticSamplerDesc>>(m_Device.GetAllocator());
		m_DynamicConstantBufferDescs = Allocate!<List<DynamicConstantBufferDesc>>(m_Device.GetAllocator());

		m_PipelineLayoutDesc = pipelineLayoutDesc;


		uint32 descriptorRangeDescNum = 0;
		uint32 staticSamplerDescNum = 0;
		uint32 dynamicConstantBufferDescNum = 0;

		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
		{
			descriptorRangeDescNum += pipelineLayoutDesc.descriptorSets[i].rangeNum;
			staticSamplerDescNum += pipelineLayoutDesc.descriptorSets[i].staticSamplerNum;
			dynamicConstantBufferDescNum += pipelineLayoutDesc.descriptorSets[i].dynamicConstantBufferNum;
		}

		m_DescriptorSets.Insert(0, Span<DescriptorSetDesc>(pipelineLayoutDesc.descriptorSets, pipelineLayoutDesc.descriptorSetNum));

		m_PushConstants.Insert(0, Span<PushConstantDesc>(pipelineLayoutDesc.pushConstants, pipelineLayoutDesc.pushConstantNum));

		m_DescriptorRangeDescs.Reserve(descriptorRangeDescNum);
		m_StaticSamplerDescs.Reserve(staticSamplerDescNum);
		m_DynamicConstantBufferDescs.Reserve(dynamicConstantBufferDescNum);

		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
		{
			readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[i];

			m_DescriptorSets[i].ranges = m_DescriptorRangeDescs.Ptr + m_DescriptorRangeDescs.Count;
			m_DescriptorSets[i].staticSamplers = m_StaticSamplerDescs.Ptr + m_StaticSamplerDescs.Count;
			m_DescriptorSets[i].dynamicConstantBuffers = m_DynamicConstantBufferDescs.Ptr + m_DynamicConstantBufferDescs.Count;

			m_DescriptorRangeDescs.AddRange(Span<DescriptorRangeDesc>(descriptorSetDesc.ranges, descriptorSetDesc.rangeNum));

			m_StaticSamplerDescs.AddRange(Span<StaticSamplerDesc>(descriptorSetDesc.staticSamplers, descriptorSetDesc.staticSamplerNum));

			m_DynamicConstantBufferDescs.AddRange(Span<DynamicConstantBufferDesc>(descriptorSetDesc.dynamicConstantBuffers, descriptorSetDesc.dynamicConstantBufferNum));
		}

		m_PipelineLayoutDesc = pipelineLayoutDesc;

		m_PipelineLayoutDesc.descriptorSets = m_DescriptorSets.Ptr;
		m_PipelineLayoutDesc.pushConstants = m_PushConstants.Ptr;
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_PushConstants);
		Deallocate!(m_Device.GetAllocator(), m_DescriptorRangeDescs);
		Deallocate!(m_Device.GetAllocator(), m_StaticSamplerDescs);
		Deallocate!(m_Device.GetAllocator(), m_DynamicConstantBufferDescs);
		Deallocate!(m_Device.GetAllocator(), m_DescriptorSets);
	}

	public readonly ref PipelineLayoutDesc GetPipelineLayoutDesc() => ref m_PipelineLayoutDesc;

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
}