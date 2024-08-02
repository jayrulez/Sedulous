using System;
using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represents a native pipelineState on Vulkan.
/// </summary>
public class VKComputePipelineState : ComputePipelineState
{
	/// <summary>
	/// The Vulkan native pipeline struct.
	/// </summary>
	public VkPipeline NativePipeline;

	/// <summary>
	/// The Vulkan native pipeline layout struct.
	/// </summary>
	public VkPipelineLayout NativePipelineLayout;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	private bool disposed;

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
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKComputePipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The compute pipeline state description.</param>
	public this(VKGraphicsContext context, ComputePipelineDescription description)
		: base(description)
	{
		vkContext = context;
		VkComputePipelineCreateInfo pipelineInfo = VkComputePipelineCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO
		};
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
		VkPipelineShaderStageCreateInfo shaderInfo = (description.shaderDescription.ComputeShader as VKShader).ShaderStateInfo;
		pipelineInfo.stage = shaderInfo;
		VkPipeline newPipeline = default(VkPipeline);
		VulkanNative.vkCreateComputePipelines(context.VkDevice, VkPipelineCache.Null, 1, &pipelineInfo, null, &newPipeline);
		NativePipeline = newPipeline;
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
			}
			disposed = true;
		}
	}
}
