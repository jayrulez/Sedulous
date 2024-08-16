using Bulkan;
using System;
namespace Sedulous.RAL.VK;

class VKComputePipeline : VKPipeline
{
	private ComputePipelineDesc m_desc;

	public this(VKDevice device, in ComputePipelineDesc desc)
		: base(device, desc.program, desc.layout)
	{
		m_desc = desc;

		VkComputePipelineCreateInfo pipeline_info = .() { sType = .VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO };
		Runtime.Assert(m_shader_stage_create_info.Count == 1);
		pipeline_info.stage = m_shader_stage_create_info.Front;
		pipeline_info.layout = m_pipeline_layout;
		VulkanNative.vkCreateComputePipelines(m_device.GetDevice(), .Null, 1, &pipeline_info, null, &m_pipeline);
	}

	public override PipelineType GetPipelineType()
	{
		return PipelineType.kCompute;
	}
}