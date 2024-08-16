using Bulkan;
using System.Collections;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkDescriptorType GetDescriptorType(ViewType view_type)
	{
		switch (view_type) {
		case ViewType.kConstantBuffer:
			return VkDescriptorType.eUniformBuffer;
		case ViewType.kSampler:
			return VkDescriptorType.eSampler;
		case ViewType.kTexture:
			return VkDescriptorType.eSampledImage;
		case ViewType.kRWTexture:
			return VkDescriptorType.eStorageImage;
		case ViewType.kBuffer:
			return VkDescriptorType.eUniformTexelBuffer;
		case ViewType.kRWBuffer:
			return VkDescriptorType.eStorageTexelBuffer;
		case ViewType.kStructuredBuffer:
			return VkDescriptorType.eStorageBuffer;
		case ViewType.kRWStructuredBuffer:
			return VkDescriptorType.eStorageBuffer;
		case ViewType.kAccelerationStructure:
			return VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR;
		default:
			break;
		}
		Runtime.Assert(false);
		return default;
	}

	public static VkShaderStageFlags ShaderType2Bit(ShaderType type)
	{
		switch (type) {
		case ShaderType.kVertex:
			return VkShaderStageFlags.VK_SHADER_STAGE_VERTEX_BIT;
		case ShaderType.kPixel:
			return VkShaderStageFlags.VK_SHADER_STAGE_FRAGMENT_BIT;
		case ShaderType.kGeometry:
			return VkShaderStageFlags.VK_SHADER_STAGE_GEOMETRY_BIT;
		case ShaderType.kCompute:
			return VkShaderStageFlags.VK_SHADER_STAGE_COMPUTE_BIT;
		case ShaderType.kAmplification:
			return VkShaderStageFlags.VK_SHADER_STAGE_TASK_BIT_EXT;
		case ShaderType.kMesh:
			return VkShaderStageFlags.VK_SHADER_STAGE_MESH_BIT_EXT;
		case ShaderType.kLibrary:
			return VkShaderStageFlags.VK_SHADER_STAGE_ALL;
		default:
			Runtime.Assert(false);
			return default;
		}
	}
}

class VKBindingSetLayout : BindingSetLayout
{
	private VKDevice m_device;
	private Dictionary<uint32, VkDescriptorType> m_bindless_type = new .() ~ delete _;
	private List<VkDescriptorSetLayout> m_descriptor_set_layouts = new .() ~ delete _;
	private List<Dictionary<VkDescriptorType, uint>> m_descriptor_count_by_set = new .() ~ delete _;
	private VkPipelineLayout m_pipeline_layout;

	public this(VKDevice device, Span<BindKey> descs)
	{
		m_device = device;


		Dictionary<uint32, List<VkDescriptorSetLayoutBinding>> bindings_by_set = scope .();
		Dictionary<uint32, List<VkDescriptorBindingFlags>> bindings_flags_by_set = scope .();

		for (var bind_key in descs)
		{
			if (!bindings_by_set.ContainsKey(bind_key.space))
			{
				bindings_by_set.Add(bind_key.space, scope:: .());
			}

			if (!bindings_flags_by_set.ContainsKey(bind_key.space))
			{
				bindings_flags_by_set.Add(bind_key.space, scope:: .());
			}

			VkDescriptorSetLayoutBinding binding = .();
			binding.binding = bind_key.slot;
			binding.descriptorType = GetDescriptorType(bind_key.view_type);
			binding.descriptorCount = bind_key.count;
			binding.stageFlags = ShaderType2Bit(bind_key.shader_type);

			VkDescriptorBindingFlags binding_flag = .None;
			if (bind_key.count == uint32.MaxValue)
			{
				binding.descriptorCount = device.GetMaxDescriptorSetBindings(binding.descriptorType);
				binding_flag = VkDescriptorBindingFlags.VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT;
				m_bindless_type.Add(bind_key.space, binding.descriptorType);
				binding.stageFlags = VkShaderStageFlags.VK_SHADER_STAGE_ALL;
			}

			bindings_flags_by_set[bind_key.space].Add(binding_flag);
			bindings_by_set[bind_key.space].Add(binding);
		}

		for (var set_desc in bindings_by_set)
		{
			VkDescriptorSetLayoutCreateInfo layout_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
			layout_info.bindingCount = (uint32)set_desc.value.Count;
			layout_info.pBindings = set_desc.value.Ptr;

			VkDescriptorSetLayoutBindingFlagsCreateInfo layout_flags_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO };
			layout_flags_info.bindingCount = (uint32)bindings_flags_by_set[set_desc.key].Count;
			layout_flags_info.pBindingFlags = bindings_flags_by_set[set_desc.key].Ptr;
			layout_info.pNext = &layout_flags_info;

			uint set_num = set_desc.key;
			if (m_descriptor_set_layouts.Count <= (int)set_num)
			{
				m_descriptor_set_layouts.Resize(int(set_num + 1));
				m_descriptor_count_by_set.Resize(int(set_num + 1));
			}

			var descriptor_set_layout = m_descriptor_set_layouts[(int)set_num];
			VulkanNative.vkCreateDescriptorSetLayout(device.GetDevice(), &layout_info, null, &descriptor_set_layout);

			var descriptor_count = m_descriptor_count_by_set[(int)set_num];
			for (var binding in set_desc.value)
			{
				if (!descriptor_count.ContainsKey(binding.descriptorType))
					descriptor_count.Add(binding.descriptorType, 0);
				descriptor_count[binding.descriptorType] += binding.descriptorCount;
			}
		}

		List<VkDescriptorSetLayout> descriptor_set_layouts = scope .();
		for (var descriptor_set_layout in m_descriptor_set_layouts)
		{
			if (descriptor_set_layout == .Null)
			{
				VkDescriptorSetLayoutCreateInfo layout_info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO };
				VulkanNative.vkCreateDescriptorSetLayout(device.GetDevice(), &layout_info, null, &descriptor_set_layout);
			}

			descriptor_set_layouts.Add(descriptor_set_layout);
		}

		VkPipelineLayoutCreateInfo pipeline_layout_info = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO };
		pipeline_layout_info.setLayoutCount = (uint32)descriptor_set_layouts.Count;
		pipeline_layout_info.pSetLayouts = descriptor_set_layouts.Ptr;

		VulkanNative.vkCreatePipelineLayout(device.GetDevice(), &pipeline_layout_info, null, &m_pipeline_layout);
	}

	public readonly ref Dictionary<uint32, VkDescriptorType> GetBindlessType()
	{
		return ref m_bindless_type;
	}

	public readonly ref List<VkDescriptorSetLayout> GetDescriptorSetLayouts()
	{
		return ref m_descriptor_set_layouts;
	}
	public readonly ref List<Dictionary<VkDescriptorType, uint>> GetDescriptorCountBySet()
	{
		return ref m_descriptor_count_by_set;
	}
	public VkPipelineLayout GetPipelineLayout()
	{
		return m_pipeline_layout;
	}
}