using System;
using Bulkan;
using Sedulous.RHI;
using System.Collections;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represents a native pipelineState on Vulkan.
/// </summary>
public class VKGraphicsPipelineState : GraphicsPipelineState
{
	/// <summary>
	/// The Vulkan native pipeline struct.
	/// </summary>
	public VkPipeline NativePipeline;

	/// <summary>
	/// The Vulkan native pipeline layout struct.
	/// </summary>
	public VkPipelineLayout NativePipelineLayout;

	internal bool ScissorEnabled;

	private VkRenderPass renderPass;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	private bool disposed;

	private VkSampleCountFlags sampleCount;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_PIPELINE, NativePipeline.Handle, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKGraphicsPipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The graphics pipeline state description.</param>
	public this(VKGraphicsContext context, ref GraphicsPipelineDescription description)
		: base(ref description)
	{
		vkContext = context;
		VkGraphicsPipelineCreateInfo pipelineInfo = VkGraphicsPipelineCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
		};
		VkPipelineRasterizationStateCreateInfo rasterizerState = VkPipelineRasterizationStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
		};
		bool frontFace = description.RenderStates.RasterizerState.FrontCounterClockwise ^ !context.ClipSpaceYInvertedSupported;
		rasterizerState.cullMode = description.RenderStates.RasterizerState.CullMode.ToVulkan();
		rasterizerState.polygonMode = description.RenderStates.RasterizerState.FillMode.ToVulkan();
		rasterizerState.frontFace = ((!frontFace) ? VkFrontFace.VK_FRONT_FACE_CLOCKWISE : VkFrontFace.VK_FRONT_FACE_COUNTER_CLOCKWISE);
		rasterizerState.lineWidth = 1f;
		rasterizerState.depthBiasEnable = true;
		rasterizerState.depthBiasConstantFactor = description.RenderStates.RasterizerState.DepthBias;
		rasterizerState.depthBiasSlopeFactor = description.RenderStates.RasterizerState.SlopeScaledDepthBias;
		rasterizerState.depthBiasClamp = description.RenderStates.RasterizerState.DepthBiasClamp;
		rasterizerState.depthClampEnable = !description.RenderStates.RasterizerState.DepthClipEnable;
		rasterizerState.rasterizerDiscardEnable = false;
		ScissorEnabled = description.RenderStates.RasterizerState.ScissorEnable;
		pipelineInfo.pRasterizationState = &rasterizerState;
		int32 renderTargetCount = (int32)description.Outputs.ColorAttachments.Count;
		VkPipelineColorBlendAttachmentState* colorBlendAttachments = scope VkPipelineColorBlendAttachmentState[renderTargetCount]*;
		BlendStateRenderTargetDescription renderTarget = description.RenderStates.BlendState.RenderTargets[0];
		BlendStateRenderTargetDescription* renderTargetBlendState = &renderTarget;
		for (int i = 0; i < renderTargetCount; i++)
		{
			colorBlendAttachments[i] = VkPipelineColorBlendAttachmentState()
			{
				blendEnable = renderTargetBlendState.BlendEnable,
				alphaBlendOp = renderTargetBlendState.BlendOperationAlpha.ToVulkan(),
				colorBlendOp = renderTargetBlendState.BlendOperationColor.ToVulkan(),
				srcColorBlendFactor = renderTargetBlendState.SourceBlendColor.ToVulkan(),
				dstColorBlendFactor = renderTargetBlendState.DestinationBlendColor.ToVulkan(),
				srcAlphaBlendFactor = renderTargetBlendState.SourceBlendAlpha.ToVulkan(),
				dstAlphaBlendFactor = renderTargetBlendState.DestinationBlendAlpha.ToVulkan(),
				colorWriteMask = renderTargetBlendState.ColorWriteChannels.ToVulkan()
			};
			if (description.RenderStates.BlendState.IndependentBlendEnable)
			{
				renderTargetBlendState++;
			}
		}
		VkPipelineColorBlendStateCreateInfo blendState = VkPipelineColorBlendStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
			attachmentCount = (uint32)renderTargetCount,
			pAttachments = colorBlendAttachments
		};
		if (description.RenderStates.BlendFactor.HasValue)
		{
			blendState.blendConstants[0] = description.RenderStates.BlendFactor.Value.X;
			blendState.blendConstants[1] = description.RenderStates.BlendFactor.Value.Y;
			blendState.blendConstants[2] = description.RenderStates.BlendFactor.Value.Z;
			blendState.blendConstants[3] = description.RenderStates.BlendFactor.Value.W;
		}
		pipelineInfo.pColorBlendState = &blendState;
		VkPipelineDepthStencilStateCreateInfo depthStencilState = VkPipelineDepthStencilStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
			depthTestEnable = description.RenderStates.DepthStencilState.DepthEnable,
			depthWriteEnable = description.RenderStates.DepthStencilState.DepthWriteMask,
			depthCompareOp = description.RenderStates.DepthStencilState.DepthFunction.ToVulkan(),
			stencilTestEnable = description.RenderStates.DepthStencilState.StencilEnable,
			minDepthBounds = 0f,
			maxDepthBounds = 1f,
			front = .()
			{
				compareOp = description.RenderStates.DepthStencilState.FrontFace.StencilFunction.ToVulkan(),
				depthFailOp = description.RenderStates.DepthStencilState.FrontFace.StencilDepthFailOperation.ToVulkan(),
				failOp = description.RenderStates.DepthStencilState.FrontFace.StencilFailOperation.ToVulkan(),
				passOp = description.RenderStates.DepthStencilState.FrontFace.StencilPassOperation.ToVulkan(),
				compareMask = description.RenderStates.DepthStencilState.StencilReadMask,
				writeMask = description.RenderStates.DepthStencilState.StencilWriteMask,
				reference = (uint32)description.RenderStates.StencilReference
			},
			back = .()
			{
				compareOp = description.RenderStates.DepthStencilState.BackFace.StencilFunction.ToVulkan(),
				depthFailOp = description.RenderStates.DepthStencilState.BackFace.StencilDepthFailOperation.ToVulkan(),
				failOp = description.RenderStates.DepthStencilState.BackFace.StencilFailOperation.ToVulkan(),
				passOp = description.RenderStates.DepthStencilState.BackFace.StencilPassOperation.ToVulkan(),
				compareMask = description.RenderStates.DepthStencilState.StencilReadMask,
				writeMask = description.RenderStates.DepthStencilState.StencilWriteMask,
				reference = (uint32)description.RenderStates.StencilReference
			}
		};
		pipelineInfo.pDepthStencilState = &depthStencilState;
		VkPipelineDynamicStateCreateInfo dynamicStateInfo = VkPipelineDynamicStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
		};
		VkDynamicState* dynamicStates = scope VkDynamicState[2]*;
		*dynamicStates = VkDynamicState.VK_DYNAMIC_STATE_VIEWPORT;
		dynamicStates[1] = VkDynamicState.VK_DYNAMIC_STATE_SCISSOR;
		dynamicStateInfo.dynamicStateCount = 2;
		dynamicStateInfo.pDynamicStates = dynamicStates;
		pipelineInfo.pDynamicState = &dynamicStateInfo;
		VkPipelineMultisampleStateCreateInfo multisampleInfo = VkPipelineMultisampleStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
		};
		sampleCount = description.Outputs.SampleCount.ToVulkan();
		multisampleInfo.rasterizationSamples = sampleCount;
		pipelineInfo.pMultisampleState = &multisampleInfo;
		VkPipelineInputAssemblyStateCreateInfo inputInfo = VkPipelineInputAssemblyStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
		};
		if (description.PrimitiveTopology >= PrimitiveTopology.Patch_List)
		{
			uint32 controlPoints = (uint32)(description.PrimitiveTopology - 33 + 1);
			VkPipelineTessellationStateCreateInfo tesselationInfo = VkPipelineTessellationStateCreateInfo()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO,
				patchControlPoints = controlPoints
			};
			inputInfo.topology = VkPrimitiveTopology.VK_PRIMITIVE_TOPOLOGY_PATCH_LIST;
			pipelineInfo.pTessellationState = &tesselationInfo;
		}
		else
		{
			inputInfo.topology = description.PrimitiveTopology.ToVulkan();
		}
		pipelineInfo.pInputAssemblyState = &inputInfo;
		List<VkPipelineShaderStageCreateInfo> stages = new List<VkPipelineShaderStageCreateInfo>();
		if (description.Shaders.VertexShader != null)
		{
			VKShader vertexShader = description.Shaders.VertexShader as VKShader;
			stages.Add(vertexShader.ShaderStateInfo);
		}
		if (description.Shaders.HullShader != null)
		{
			VKShader hullShader = description.Shaders.HullShader as VKShader;
			stages.Add(hullShader.ShaderStateInfo);
		}
		if (description.Shaders.DomainShader != null)
		{
			VKShader domainShader = description.Shaders.DomainShader as VKShader;
			stages.Add(domainShader.ShaderStateInfo);
		}
		if (description.Shaders.GeometryShader != null)
		{
			VKShader geometryShader = description.Shaders.GeometryShader as VKShader;
			stages.Add(geometryShader.ShaderStateInfo);
		}
		if (description.Shaders.PixelShader != null)
		{
			VKShader pixelShader = description.Shaders.PixelShader as VKShader;
			stages.Add(pixelShader.ShaderStateInfo);
		}
		VkPipelineShaderStageCreateInfo* stagePointer = scope VkPipelineShaderStageCreateInfo[stages.Count]*;
		for (int i = 0; i < stages.Count; i++)
		{
			stagePointer[i] = stages[i];
		}
		pipelineInfo.stageCount = (uint32)stages.Count;
		pipelineInfo.pStages = stagePointer;
		InputLayouts shaderInputLayout = description.Shaders.ShaderInputLayout;
		int32 bindingCount = (int32)((description.InputLayouts != null) ? description.InputLayouts.LayoutElements.Count : 0);
		int32 attributeCount = 0;
		if (shaderInputLayout != null && shaderInputLayout.LayoutElements.Count > 0)
		{
			attributeCount = (int32)shaderInputLayout.LayoutElements[0].Elements.Count;
		}
		else if (description.InputLayouts != null)
		{
			List<LayoutDescription> layoutElements = description.InputLayouts.LayoutElements;
			for (int i = 0; i < layoutElements.Count; i++)
			{
				attributeCount += (int32)layoutElements[i].Elements.Count;
			}
		}
		VkVertexInputBindingDescription* bindingDescriptions = scope VkVertexInputBindingDescription[bindingCount]*;
		VkVertexInputAttributeDescription* attributeDescriptions = scope VkVertexInputAttributeDescription[attributeCount]*;
		int32 targetIndex = 0;
		int32 targetLocation = 0;
		for (uint32 i = 0; i < description.InputLayouts?.LayoutElements.Count; i++)
		{
			LayoutDescription inputLayout = description.InputLayouts.LayoutElements[(int32)i];
			bindingDescriptions[i] = VkVertexInputBindingDescription()
			{
				binding = i,
				inputRate = ((inputLayout.StepRate != 0) ? VkVertexInputRate.VK_VERTEX_INPUT_RATE_INSTANCE : VkVertexInputRate.VK_VERTEX_INPUT_RATE_VERTEX),
				stride = inputLayout.Stride
			};
			for (int j = 0; j < inputLayout.Elements.Count; j++)
			{
				ElementDescription inputElement = inputLayout.Elements[j];
				if (shaderInputLayout != null)
				{
					if (shaderInputLayout.TryGetSlot(inputElement.Semantic, inputElement.SemanticIndex, var location))
					{
						attributeDescriptions[targetIndex++] = VkVertexInputAttributeDescription()
						{
							format = inputElement.Format.ToVulkan(),
							binding = i,
							location = (uint32)location,
							offset = (uint32)inputElement.Offset
						};
					}
				}
				else
				{
					attributeDescriptions[targetIndex++] = VkVertexInputAttributeDescription()
					{
						format = inputElement.Format.ToVulkan(),
						binding = i,
						location = (uint32)(targetLocation + j),
						offset = (uint32)inputElement.Offset
					};
				}
			}
			targetLocation += (int32)inputLayout.Elements.Count;
		}
		VkPipelineVertexInputStateCreateInfo vertexInputInfo = VkPipelineVertexInputStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
			vertexBindingDescriptionCount = (uint32)bindingCount,
			pVertexBindingDescriptions = bindingDescriptions,
			vertexAttributeDescriptionCount = (uint32)attributeCount,
			pVertexAttributeDescriptions = attributeDescriptions
		};
		pipelineInfo.pVertexInputState = &vertexInputInfo;
		VkPipelineViewportStateCreateInfo viewportInfo = VkPipelineViewportStateCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
			viewportCount = 1,
			scissorCount = 1
		};
		pipelineInfo.pViewportState = &viewportInfo;
		VkPipelineLayoutCreateInfo layoutInfo = VkPipelineLayoutCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
		};
		if (description.ResourceLayouts != null)
		{
			VkDescriptorSetLayout* layouts = scope VkDescriptorSetLayout[description.ResourceLayouts.Count]*;
			for (int i = 0; i < description.ResourceLayouts.Count; i++)
			{
				VKResourceLayout layout = description.ResourceLayouts[i] as VKResourceLayout;
				layouts[i] = layout.DescriptorSetLayout;
			}
			layoutInfo.setLayoutCount = (uint32)description.ResourceLayouts.Count;
			layoutInfo.pSetLayouts = layouts;
		}
		VkPipelineLayout newPipelineLayout = default(VkPipelineLayout);
		VulkanNative.vkCreatePipelineLayout(context.VkDevice, &layoutInfo, null, &newPipelineLayout);
		NativePipelineLayout = newPipelineLayout;
		pipelineInfo.layout = NativePipelineLayout;
		renderPass = CreateCompatibilityRenderPass(description.Outputs);
		pipelineInfo.renderPass = renderPass;
		VkPipeline newPipeline = default(VkPipeline);
		VulkanNative.vkCreateGraphicsPipelines(context.VkDevice, VkPipelineCache.Null, 1, &pipelineInfo, null, &newPipeline);
		NativePipeline = newPipeline;
	}

	private VkRenderPass CreateCompatibilityRenderPass(OutputDescription outputs)
	{
		VkAttachmentLoadOp loadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
		int32 attachmentCount = (int32)(outputs.DepthAttachment.HasValue ? (outputs.ColorAttachments.Count + 1) : outputs.ColorAttachments.Count) * 2;
		VkAttachmentDescription* attachments = scope VkAttachmentDescription[attachmentCount]*;
		VkAttachmentReference* colorAttachmentReferences = scope VkAttachmentReference[outputs.ColorAttachments.Count]*;
		VkAttachmentReference* resolveAttachmentReferences = scope VkAttachmentReference[outputs.ColorAttachments.Count]*;
		uint32 currentAttachmentIndex = 0;
		uint32 colorAttachmentIndex = 0;
		uint32 resolvedAttachmentIndex = 0;
		for (int i = 0; i < outputs.ColorAttachments.Count; i++)
		{
			/*ref*/ OutputAttachmentDescription reference = /*ref*/ outputs.ColorAttachments[i];
			VkFormat colorFormat = reference.Format.ToVulkan(depthFormat: false);
			var (textureAttachment, textureAttachmentRef) = CreateAttachment(colorFormat, sampleCount, currentAttachmentIndex, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
			attachments[currentAttachmentIndex++] = textureAttachment;
			colorAttachmentReferences[colorAttachmentIndex++] = textureAttachmentRef;
			if (reference.ResolveMSAA)
			{
				var (msaaTextureAttachment, msaaTextureAttachmentRef) = CreateAttachment(colorFormat, sampleCount, currentAttachmentIndex, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
				attachments[currentAttachmentIndex++] = msaaTextureAttachment;
				resolveAttachmentReferences[resolvedAttachmentIndex++] = msaaTextureAttachmentRef;
			}
		}
		bool isStencilFormat = false;
		VkAttachmentReference depthAttachementReference = default(VkAttachmentReference);
		if (outputs.DepthAttachment.HasValue)
		{
			OutputAttachmentDescription depthAttachment = outputs.DepthAttachment.Value;
			VkFormat depthFormat = depthAttachment.Format.ToVulkan(depthFormat: true);
			if (depthAttachment.Format == PixelFormat.D24_UNorm_S8_UInt || depthAttachment.Format == PixelFormat.D32_Float_S8X24_UInt)
			{
				isStencilFormat = true;
			}
			VkAttachmentDescription depthTextureAttachment = CreateAttachment(depthFormat, sampleCount, currentAttachmentIndex, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, (!isStencilFormat) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, isDepth: true).Description;
			VkAttachmentReference vkAttachmentReference = default(VkAttachmentReference);
			vkAttachmentReference.attachment = currentAttachmentIndex;
			vkAttachmentReference.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
			depthAttachementReference = vkAttachmentReference;
			attachments[currentAttachmentIndex++] = depthTextureAttachment;
			if (depthAttachment.ResolveMSAA)
			{
				VkAttachmentDescription msaaDepthTextureAttachment = CreateAttachment(depthFormat, sampleCount, currentAttachmentIndex, loadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, (!isStencilFormat) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, isDepth: true).Description;
				vkAttachmentReference = default(VkAttachmentReference);
				vkAttachmentReference.attachment = currentAttachmentIndex;
				vkAttachmentReference.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
				attachments[currentAttachmentIndex++] = msaaDepthTextureAttachment;
			}
		}
		VkSubpassDescription vkSubpassDescription = default(VkSubpassDescription);
		vkSubpassDescription.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
		VkSubpassDescription subpass = vkSubpassDescription;
		if (colorAttachmentIndex != 0)
		{
			subpass.colorAttachmentCount = colorAttachmentIndex;
			subpass.pColorAttachments = colorAttachmentReferences;
		}
		uint32 dependencyCount = 1;
		if (resolvedAttachmentIndex != 0)
		{
			subpass.pResolveAttachments = resolveAttachmentReferences;
			dependencyCount++;
		}
		if (outputs.DepthAttachment.HasValue)
		{
			subpass.pDepthStencilAttachment = &depthAttachementReference;
		}
		VkSubpassDependency* dependencies = scope VkSubpassDependency[(int32)dependencyCount]*;
		if (resolvedAttachmentIndex == 0)
		{
			*dependencies = VkSubpassDependency()
			{
				srcSubpass = uint32.MaxValue,
				dstSubpass = 0,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
				dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT)
			};
		}
		else
		{
			*dependencies = VkSubpassDependency()
			{
				srcSubpass = uint32.MaxValue,
				dstSubpass = 0,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
				dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
				dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
			};
			dependencies[1] = VkSubpassDependency()
			{
				srcSubpass = 0,
				dstSubpass = uint32.MaxValue,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
				srcAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
				dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
				dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
			};
		}
		VkRenderPassCreateInfo vkRenderPassCreateInfo = default(VkRenderPassCreateInfo);
		vkRenderPassCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
		vkRenderPassCreateInfo.attachmentCount = currentAttachmentIndex;
		vkRenderPassCreateInfo.pAttachments = attachments;
		vkRenderPassCreateInfo.subpassCount = 1;
		vkRenderPassCreateInfo.pSubpasses = &subpass;
		vkRenderPassCreateInfo.dependencyCount = dependencyCount;
		vkRenderPassCreateInfo.pDependencies = dependencies;
		VkRenderPassCreateInfo renderPassInfo = vkRenderPassCreateInfo;
		VkRenderPassMultiviewCreateInfo renderPassMultiviewCI = default(VkRenderPassMultiviewCreateInfo);
		if (outputs.ArraySliceCount > 1)
		{
			uint32 mask = (uint32)((1 << (int32)outputs.ArraySliceCount) - 1);
			renderPassMultiviewCI.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO;
			renderPassMultiviewCI.subpassCount = 1;
			renderPassMultiviewCI.pViewMasks = &mask;
			renderPassMultiviewCI.correlationMaskCount = 1;
			renderPassMultiviewCI.pCorrelationMasks = &mask;
			renderPassInfo.pNext = &renderPassMultiviewCI;
		}
		VkRenderPass newRenderPass = default(VkRenderPass);
		VulkanNative.vkCreateRenderPass(vkContext.VkDevice, &renderPassInfo, null, &newRenderPass);
		return newRenderPass;
	}

	private (VkAttachmentDescription Description, VkAttachmentReference Reference) CreateAttachment(VkFormat format, VkSampleCountFlags samples, uint32 index, VkAttachmentLoadOp loadOp, VkAttachmentStoreOp storeOp, VkAttachmentStoreOp stencilStoreOp, VkImageLayout finalLayout, bool isDepth = false)
	{
		VkAttachmentDescription vkAttachmentDescription = default(VkAttachmentDescription);
		vkAttachmentDescription.format = format;
		vkAttachmentDescription.samples = samples;
		vkAttachmentDescription.loadOp = loadOp;
		vkAttachmentDescription.storeOp = storeOp;
		vkAttachmentDescription.stencilLoadOp = VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE;
		vkAttachmentDescription.stencilStoreOp = stencilStoreOp;
		vkAttachmentDescription.initialLayout = VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED;
		vkAttachmentDescription.finalLayout = finalLayout;
		VkAttachmentDescription item = vkAttachmentDescription;
		VkAttachmentReference textureAttachmentRef = VkAttachmentReference()
		{
			attachment = index,
			layout = finalLayout
		};
		return (item, textureAttachmentRef);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				VulkanNative.vkDestroyPipelineLayout(vkContext.VkDevice, NativePipelineLayout, null);
				VulkanNative.vkDestroyPipeline(vkContext.VkDevice, NativePipeline, null);
				VulkanNative.vkDestroyRenderPass(vkContext.VkDevice, renderPass, null);
			}
			disposed = true;
		}
	}
}
