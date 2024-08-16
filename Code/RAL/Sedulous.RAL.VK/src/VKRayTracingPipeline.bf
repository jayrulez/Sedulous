using System.Collections;
using Bulkan;
namespace Sedulous.RAL.VK;

class VKRayTracingPipeline : VKPipeline
{
	private RayTracingPipelineDesc m_desc;

	public this(VKDevice device, in RayTracingPipelineDesc desc)
		: base(device, desc.program, desc.layout)
	{
		m_desc = desc;

		List<VkRayTracingShaderGroupCreateInfoKHR> groups = scope .() { Count = m_desc.groups.Count };

		delegate uint32(uint64 id) get = scope [&] (id) =>
			{
				if (!m_shader_ids.ContainsKey(id))
				{
					return VulkanNative.VK_SHADER_UNUSED_KHR;
				}
				return m_shader_ids[id];
			};

		for (uint i = 0; i < (uint)m_desc.groups.Count; ++i)
		{
			var group = groups[(int)i];
			group.generalShader = VulkanNative.VK_SHADER_UNUSED_KHR;
			group.closestHitShader = VulkanNative.VK_SHADER_UNUSED_KHR;
			group.anyHitShader = VulkanNative.VK_SHADER_UNUSED_KHR;
			group.intersectionShader = VulkanNative.VK_SHADER_UNUSED_KHR;

			switch (m_desc.groups[(int)i].type) {
			case RayTracingShaderGroupType.kGeneral:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR;
				group.generalShader = get(m_desc.groups[(int)i].general);
				break;
			case RayTracingShaderGroupType.kTrianglesHitGroup:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR;
				group.closestHitShader = get(m_desc.groups[(int)i].closest_hit);
				group.anyHitShader = get(m_desc.groups[(int)i].any_hit);
				break;
			case RayTracingShaderGroupType.kProceduralHitGroup:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR;
				group.intersectionShader = get(m_desc.groups[(int)i].intersection);
				break;
			}
		}

		VkRayTracingPipelineCreateInfoKHR ray_pipeline_info = .() { sType = .VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR };
		ray_pipeline_info.stageCount = (uint32)m_shader_stage_create_info.Count;
		ray_pipeline_info.pStages = m_shader_stage_create_info.Ptr;
		ray_pipeline_info.groupCount = (uint32)groups.Count;
		ray_pipeline_info.pGroups = groups.Ptr;
		ray_pipeline_info.maxPipelineRayRecursionDepth = 1;
		ray_pipeline_info.layout = m_pipeline_layout;

		VulkanNative.vkCreateRayTracingPipelinesKHR(m_device.GetDevice(), .Null, .Null, 1, &ray_pipeline_info, null, &m_pipeline);
	}

	public override PipelineType GetPipelineType()
	{
		return PipelineType.kRayTracing;
	}

	public override void GetRayTracingShaderGroupHandles(uint32 first_group, uint32 group_count, List<uint8> shader_handles_storage)
	{
		shader_handles_storage.Resize(group_count * m_device.GetShaderGroupHandleSize());

		VulkanNative.vkGetRayTracingShaderGroupHandlesKHR(m_device.GetDevice(), m_pipeline, first_group, group_count, (uint32)shader_handles_storage.Count, shader_handles_storage.Ptr);
	}
}