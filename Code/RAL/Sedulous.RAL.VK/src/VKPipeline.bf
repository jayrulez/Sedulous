using System.Collections;
using Bulkan;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkShaderStageFlags ExecutionModel2Bit(ShaderKind kind)
	{
		switch (kind) {
		case ShaderKind.kVertex:
			return VkShaderStageFlags.VK_SHADER_STAGE_VERTEX_BIT;
		case ShaderKind.kPixel:
			return VkShaderStageFlags.VK_SHADER_STAGE_FRAGMENT_BIT;
		case ShaderKind.kCompute:
			return VkShaderStageFlags.VK_SHADER_STAGE_COMPUTE_BIT;
		case ShaderKind.kGeometry:
			return VkShaderStageFlags.VK_SHADER_STAGE_GEOMETRY_BIT;
		case ShaderKind.kAmplification:
			return VkShaderStageFlags.VK_SHADER_STAGE_TASK_BIT_EXT;
		case ShaderKind.kMesh:
			return VkShaderStageFlags.VK_SHADER_STAGE_MESH_BIT_EXT;
		case ShaderKind.kRayGeneration:
			return VkShaderStageFlags.VK_SHADER_STAGE_RAYGEN_BIT_KHR;
		case ShaderKind.kIntersection:
			return VkShaderStageFlags.VK_SHADER_STAGE_INTERSECTION_BIT_KHR;
		case ShaderKind.kAnyHit:
			return VkShaderStageFlags.VK_SHADER_STAGE_ANY_HIT_BIT_KHR;
		case ShaderKind.kClosestHit:
			return VkShaderStageFlags.VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR;
		case ShaderKind.kMiss:
			return VkShaderStageFlags.VK_SHADER_STAGE_MISS_BIT_KHR;
		case ShaderKind.kCallable:
			return VkShaderStageFlags.VK_SHADER_STAGE_CALLABLE_BIT_KHR;
		default:
			Runtime.Assert(false);
			return default;
		}
	}
}

abstract class VKPipeline : Pipeline
{
	protected VKDevice m_device;

	private Queue<String> entry_point_names = new .() ~ delete _;
	protected List<VkPipelineShaderStageCreateInfo> m_shader_stage_create_info;
	private List<VkShaderModule> m_shader_modules;
	protected VkPipeline m_pipeline;
	protected VkPipelineLayout m_pipeline_layout;
	protected Dictionary<uint64, uint32> m_shader_ids;

	public this(VKDevice device,
		ShaderProgram program,
		in BindingSetLayout layout)
	{
		m_device = device;


		var vk_layout = layout.As<VKBindingSetLayout>();
		m_pipeline_layout = vk_layout.GetPipelineLayout();

		var shaders = program.GetShaders();
		for (var shader in shaders)
		{
			var blob = shader.GetBlob();
			VkShaderModuleCreateInfo shader_module_info = .() { sType = .VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO };
			shader_module_info.codeSize = (uint)blob.Count;
			shader_module_info.pCode = (uint32*)blob.Ptr;
			VkShaderModule shaderModule = .Null;
			VulkanNative.vkCreateShaderModule(m_device.GetDevice(), &shader_module_info, null, &shaderModule);
			m_shader_modules.Add(shaderModule);

			var reflection = shader.GetReflection();
			var entry_points = reflection.GetEntryPoints();
			for (var entry_point in entry_points)
			{
				m_shader_ids[shader.GetId(entry_point.name)] = (uint32)m_shader_stage_create_info.Count;
				VkPipelineShaderStageCreateInfo shader_stage_create_info = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO };
				shader_stage_create_info.stage = ExecutionModel2Bit(entry_point.kind);
				shader_stage_create_info.module = m_shader_modules.Back;
				String name = new .(entry_point.name);
				entry_point_names.Add(name);
				shader_stage_create_info.pName = name;
				m_shader_stage_create_info.Add(shader_stage_create_info);
			}
		}
	}

	public VkPipelineLayout GetPipelineLayout()
	{
		return m_pipeline_layout;
	}

	public VkPipeline GetPipeline()
	{
		return m_pipeline;
	}

	public override void GetRayTracingShaderGroupHandles(uint32 first_group, uint32 group_count, List<uint8> handles) { }
}