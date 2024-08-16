using System.Collections;
using Bulkan;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkCompareOp Convert(ComparisonFunc func)
	{
		switch (func) {
		case ComparisonFunc.kNever:
			return VkCompareOp.eNever;
		case ComparisonFunc.kLess:
			return VkCompareOp.eLess;
		case ComparisonFunc.kEqual:
			return VkCompareOp.eEqual;
		case ComparisonFunc.kLessEqual:
			return VkCompareOp.eLessOrEqual;
		case ComparisonFunc.kGreater:
			return VkCompareOp.eGreater;
		case ComparisonFunc.kNotEqual:
			return VkCompareOp.eNotEqual;
		case ComparisonFunc.kGreaterEqual:
			return VkCompareOp.eGreaterOrEqual;
		case ComparisonFunc.kAlways:
			return VkCompareOp.eAlways;
		default:
			Runtime.Assert(false);
			return VkCompareOp.eLess;
		}
	}

	public static VkStencilOp Convert(StencilOp op)
	{
		switch (op) {
		case StencilOp.kKeep:
			return VkStencilOp.eKeep;
		case StencilOp.kZero:
			return VkStencilOp.eZero;
		case StencilOp.kReplace:
			return VkStencilOp.eReplace;
		case StencilOp.kIncrSat:
			return VkStencilOp.eIncrementAndClamp;
		case StencilOp.kDecrSat:
			return VkStencilOp.eDecrementAndClamp;
		case StencilOp.kInvert:
			return VkStencilOp.eInvert;
		case StencilOp.kIncr:
			return VkStencilOp.eIncrementAndWrap;
		case StencilOp.kDecr:
			return VkStencilOp.eDecrementAndWrap;
		default:
			Runtime.Assert(false);
			return VkStencilOp.eKeep;
		}
	}

	public static VkStencilOpState Convert(in StencilOpDesc desc, uint8 read_mask, uint8 write_mask)
	{
		VkStencilOpState res = .();
		res.failOp = Convert(desc.fail_op);
		res.passOp = Convert(desc.pass_op);
		res.depthFailOp = Convert(desc.depth_fail_op);
		res.compareOp = Convert(desc.func);
		res.compareMask = read_mask;
		res.writeMask = write_mask;
		return res;
	}
}

class VKGraphicsPipeline : VKPipeline
{
	private GraphicsPipelineDesc m_desc;
	private List<VkVertexInputBindingDescription> m_binding_desc;
	private List<VkVertexInputAttributeDescription> m_attribute_desc;

	public this(VKDevice device, in GraphicsPipelineDesc desc)
		: base(device, desc.program, desc.layout)
	{
		m_desc = desc;

		if (desc.program.HasShader(ShaderType.kVertex))
		{
			CreateInputLayout(ref m_binding_desc, ref m_attribute_desc);
		}

		readonly ref RenderPassDesc render_pass_desc = ref m_desc.render_pass.GetDesc();

		VkPipelineVertexInputStateCreateInfo vertex_input_info = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO };
		vertex_input_info.vertexBindingDescriptionCount = (uint32)m_binding_desc.Count;
		vertex_input_info.pVertexBindingDescriptions = m_binding_desc.Ptr;
		vertex_input_info.vertexAttributeDescriptionCount = (uint32)m_attribute_desc.Count;
		vertex_input_info.pVertexAttributeDescriptions = m_attribute_desc.Ptr;

		VkPipelineInputAssemblyStateCreateInfo input_assembly = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO };
		input_assembly.topology = VkPrimitiveTopology.eTriangleList;
		input_assembly.primitiveRestartEnable = VulkanNative.VK_FALSE;

		VkPipelineViewportStateCreateInfo viewport_state = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO };
		viewport_state.viewportCount = 1;
		viewport_state.scissorCount = 1;

		VkPipelineRasterizationStateCreateInfo rasterizer = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO };
		rasterizer.depthClampEnable = VulkanNative.VK_FALSE;
		rasterizer.lineWidth = 1.0f;
		rasterizer.frontFace = VkFrontFace.eClockwise;
		rasterizer.depthBiasEnable = m_desc.rasterizer_desc.depth_bias != 0;
		rasterizer.depthBiasConstantFactor = m_desc.rasterizer_desc.depth_bias;
		switch (m_desc.rasterizer_desc.fill_mode) {
		case FillMode.kWireframe:
			rasterizer.polygonMode = VkPolygonMode.eLine;
			break;
		case FillMode.kSolid:
			rasterizer.polygonMode = VkPolygonMode.eFill;
			break;
		}
		switch (m_desc.rasterizer_desc.cull_mode) {
		case CullMode.kNone:
			rasterizer.cullMode = VkCullModeFlags.VK_CULL_MODE_NONE;
			break;
		case CullMode.kFront:
			rasterizer.cullMode = VkCullModeFlags.VK_CULL_MODE_FRONT_BIT;
			break;
		case CullMode.kBack:
			rasterizer.cullMode = VkCullModeFlags.VK_CULL_MODE_BACK_BIT;
			break;
		}

		VkPipelineColorBlendAttachmentState color_blend_attachment = .();
		color_blend_attachment.colorWriteMask = VkColorComponentFlags.VK_COLOR_COMPONENT_R_BIT | VkColorComponentFlags.VK_COLOR_COMPONENT_G_BIT |
			VkColorComponentFlags.VK_COLOR_COMPONENT_B_BIT | VkColorComponentFlags.VK_COLOR_COMPONENT_A_BIT;
		color_blend_attachment.blendEnable = m_desc.blend_desc.blend_enable;

		if (color_blend_attachment.blendEnable)
		{
			delegate VkBlendFactor(Blend type) convert = scope:: (type) =>
				{
					switch (type) {
					case Blend.kZero:
						return VkBlendFactor.eZero;
					case Blend.kSrcAlpha:
						return VkBlendFactor.eSrcAlpha;
					case Blend.kInvSrcAlpha:
						return VkBlendFactor.eOneMinusSrcAlpha;
					}
					//Runtime.FatalError("unsupported");
				};

			delegate VkBlendOp(BlendOp) convert_op = scope:: (type) =>
				{
					switch (type) {
					case BlendOp.kAdd:
						return VkBlendOp.eAdd;
					}
					//Runtime.FatalError("unsupported");
				};

			color_blend_attachment.srcColorBlendFactor = convert(m_desc.blend_desc.blend_src);
			color_blend_attachment.dstColorBlendFactor = convert(m_desc.blend_desc.blend_dest);
			color_blend_attachment.colorBlendOp = convert_op(m_desc.blend_desc.blend_op);
			color_blend_attachment.srcAlphaBlendFactor = convert(m_desc.blend_desc.blend_src_alpha);
			color_blend_attachment.dstAlphaBlendFactor = convert(m_desc.blend_desc.blend_dest_alpha);
			color_blend_attachment.alphaBlendOp = convert_op(m_desc.blend_desc.blend_op_alpha);
		}

		List<VkPipelineColorBlendAttachmentState> color_blend_attachments = scope .(render_pass_desc.colors.Count) { color_blend_attachment };

		VkPipelineColorBlendStateCreateInfo color_blending = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO };
		color_blending.logicOpEnable = VulkanNative.VK_FALSE;
		color_blending.logicOp = VkLogicOp.eAnd;
		color_blending.attachmentCount = (uint32)color_blend_attachments.Count;
		color_blending.pAttachments = color_blend_attachments.Ptr;

		VkPipelineMultisampleStateCreateInfo multisampling = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO };
		multisampling.rasterizationSamples = (VkSampleCountFlags)render_pass_desc.sample_count;
		multisampling.sampleShadingEnable = multisampling.rasterizationSamples != VkSampleCountFlags.VK_SAMPLE_COUNT_1_BIT;

		VkPipelineDepthStencilStateCreateInfo depth_stencil = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO };
		depth_stencil.depthTestEnable = m_desc.depth_stencil_desc.depth_test_enable;
		depth_stencil.depthWriteEnable = m_desc.depth_stencil_desc.depth_write_enable;
		depth_stencil.depthCompareOp = Convert(m_desc.depth_stencil_desc.depth_func);
		depth_stencil.depthBoundsTestEnable = m_desc.depth_stencil_desc.depth_bounds_test_enable;
		depth_stencil.stencilTestEnable = m_desc.depth_stencil_desc.stencil_enable;
		depth_stencil.back = Convert(m_desc.depth_stencil_desc.back_face, m_desc.depth_stencil_desc.stencil_read_mask,
			m_desc.depth_stencil_desc.stencil_write_mask);
		depth_stencil.front = Convert(m_desc.depth_stencil_desc.front_face, m_desc.depth_stencil_desc.stencil_read_mask,
			m_desc.depth_stencil_desc.stencil_write_mask);

		List<VkDynamicState> dynamic_state_enables = scope .()
			{
				VkDynamicState.eViewport,
				VkDynamicState.eScissor
			};

		if (m_device.IsVariableRateShadingSupported())
		{
			dynamic_state_enables.Add(VkDynamicState.VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR);
		}

		VkPipelineDynamicStateCreateInfo pipelineDynamicStateCreateInfo = .() { sType = .VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO };
		pipelineDynamicStateCreateInfo.pDynamicStates = dynamic_state_enables.Ptr;
		pipelineDynamicStateCreateInfo.dynamicStateCount = (uint32)dynamic_state_enables.Count;

		VkGraphicsPipelineCreateInfo pipeline_info = .() { sType = .VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO };
		pipeline_info.stageCount = (uint32)m_shader_stage_create_info.Count;
		pipeline_info.pStages = m_shader_stage_create_info.Ptr;
		pipeline_info.pVertexInputState = &vertex_input_info;
		pipeline_info.pInputAssemblyState = &input_assembly;
		pipeline_info.pViewportState = &viewport_state;
		pipeline_info.pRasterizationState = &rasterizer;
		pipeline_info.pMultisampleState = &multisampling;
		pipeline_info.pDepthStencilState = &depth_stencil;
		pipeline_info.pColorBlendState = &color_blending;
		pipeline_info.layout = m_pipeline_layout;
		pipeline_info.renderPass = GetRenderPass();
		pipeline_info.pDynamicState = &pipelineDynamicStateCreateInfo;

		VulkanNative.vkCreateGraphicsPipelines(m_device.GetDevice(), .Null, 1, &pipeline_info, null, &m_pipeline);
	}

	public override PipelineType GetPipelineType()
	{
		return PipelineType.kGraphics;
	}

	public VkRenderPass GetRenderPass()
	{
		return m_desc.render_pass.As<VKRenderPass>().GetRenderPass();
	}

	private void CreateInputLayout(ref List<VkVertexInputBindingDescription> binding_desc,
		ref List<VkVertexInputAttributeDescription> attribute_desc)
	{
		for (var vertex in m_desc.input)
		{
			VkVertexInputBindingDescription binding = .();
			VkVertexInputAttributeDescription attribute = .();
			attribute.location =  m_desc.program.GetShader(ShaderType.kVertex).GetInputLayoutLocation(vertex.semantic_name);
			attribute.binding = binding.binding = vertex.slot;
			binding.inputRate = VkVertexInputRate.eVertex;
			binding.stride = vertex.stride;
			attribute.format = (VkFormat)vertex.format;

			m_binding_desc.Add(binding);
			m_attribute_desc.Add(attribute);
		}
	}
}