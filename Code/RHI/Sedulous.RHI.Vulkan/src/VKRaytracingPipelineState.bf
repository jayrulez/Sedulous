using System;
using Bulkan;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Vulkan Raytracing pipeline state.
/// </summary>
public class VKRaytracingPipelineState : RaytracingPipelineState
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

	/// <summary>
	/// Generated shader binding table.
	/// </summary>
	public VKShaderTable shaderBindingTable;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKRaytracingPipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The raytracing pipeline state description.</param>
	public this(VKGraphicsContext context, in RaytracingPipelineDescription description)
		: base(description)
	{
		vkContext = context;
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
		List<VkPipelineShaderStageCreateInfo> stages = new List<VkPipelineShaderStageCreateInfo>();
		List<String> entryPoints = new List<String>();
		if (description.Shaders.RayGenerationShader != null)
		{
			VKShader rayGenerationShader = description.Shaders.RayGenerationShader as VKShader;
			stages.Add(rayGenerationShader.ShaderStateInfo);
			entryPoints.Add(rayGenerationShader.Description.EntryPoint);
		}
		if (description.Shaders.MissShader != null)
		{
			for (int i = 0; i < description.Shaders.MissShader.Count; i++)
			{
				VKShader missShader = description.Shaders.MissShader[i] as VKShader;
				stages.Add(missShader.ShaderStateInfo);
				entryPoints.Add(missShader.Description.EntryPoint);
			}
		}
		if (description.Shaders.ClosestHitShader != null)
		{
			for (int i = 0; i < description.Shaders.ClosestHitShader.Count; i++)
			{
				VKShader closestHitShader = description.Shaders.ClosestHitShader[i] as VKShader;
				stages.Add(closestHitShader.ShaderStateInfo);
				entryPoints.Add(closestHitShader.Description.EntryPoint);
			}
		}
		if (description.Shaders.AnyHitShader != null)
		{
			for (int i = 0; i < description.Shaders.AnyHitShader.Count; i++)
			{
				VKShader rayGenerationShader = description.Shaders.AnyHitShader[i] as VKShader;
				stages.Add(rayGenerationShader.ShaderStateInfo);
				entryPoints.Add(rayGenerationShader.Description.EntryPoint);
			}
		}
		if (description.Shaders.IntersectionShader != null)
		{
			for (int i = 0; i < description.Shaders.IntersectionShader.Count; i++)
			{
				VKShader intersectionShader = description.Shaders.IntersectionShader[i] as VKShader;
				stages.Add(intersectionShader.ShaderStateInfo);
				entryPoints.Add(intersectionShader.Description.EntryPoint);
			}
		}
		VkPipelineShaderStageCreateInfo* stagePointer = scope VkPipelineShaderStageCreateInfo[stages.Count]*;
		for (int32 i = 0; i < stages.Count; i++)
		{
			stagePointer[i] = stages[i];
		}
		VkRayTracingShaderGroupCreateInfoKHR* groups = scope VkRayTracingShaderGroupCreateInfoKHR[description.HitGroups.Count]*;
		for (int i = 0; i < description.HitGroups.Count; i++)
		{
			HitGroupDescription hitGroup = description.HitGroups[i];
			VkRayTracingShaderGroupCreateInfoKHR group = VkRayTracingShaderGroupCreateInfoKHR()
			{
				sType = VkStructureType.VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR
			};
			switch (hitGroup.Type)
			{
			case HitGroupDescription.HitGroupType.Triangles:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR;
				break;
			case HitGroupDescription.HitGroupType.Procedural:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR;
				break;
			default:
				group.type = VkRayTracingShaderGroupTypeKHR.VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR;
				break;
			}
			group.generalShader = ((hitGroup.GeneralEntryPoint != null) ? ((uint32)entryPoints.IndexOf(hitGroup.GeneralEntryPoint)) : uint32.MaxValue);
			group.closestHitShader = ((hitGroup.ClosestHitEntryPoint != null) ? ((uint32)entryPoints.IndexOf(hitGroup.ClosestHitEntryPoint)) : uint32.MaxValue);
			group.anyHitShader = ((hitGroup.AnyHitEntryPoint != null) ? ((uint32)entryPoints.IndexOf(hitGroup.AnyHitEntryPoint)) : uint32.MaxValue);
			group.intersectionShader = ((hitGroup.IntersectionEntryPoint != null) ? ((uint32)entryPoints.IndexOf(hitGroup.IntersectionEntryPoint)) : uint32.MaxValue);
			groups[i] = group;
		}
		VkRayTracingPipelineCreateInfoKHR pipelineInfo = VkRayTracingPipelineCreateInfoKHR()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR,
			stageCount = (uint32)stages.Count,
			pStages = stagePointer,
			groupCount = (uint32)description.HitGroups.Count,
			pGroups = groups,
			maxPipelineRayRecursionDepth = description.MaxTraceRecursionDepth,
			layout = newPipelineLayout
		};
		VkPipeline newPipeline = default(VkPipeline);
		VulkanNative.vkCreateRayTracingPipelinesKHR(context.VkDevice, VkDeferredOperationKHR.Null, VkPipelineCache.Null, 1, &pipelineInfo, null, &newPipeline);
		NativePipeline = newPipeline;
		CreateShaderBindingTable(context, description);
	}

	private void CreateShaderBindingTable(VKGraphicsContext context, in RaytracingPipelineDescription description)
	{
		shaderBindingTable = new VKShaderTable(context);
		RaytracingShaderStateDescription shaders = description.Shaders;
		String rayGenIdentifier = shaders.GetEntryPointByStage(ShaderStages.RayGeneration, .. scope .())[0];
		shaderBindingTable.AddRayGenProgram(rayGenIdentifier);
		List<String> missIdentifiers = shaders.GetEntryPointByStage(ShaderStages.Miss, .. scope .());
		for (int i = 0; i < missIdentifiers.Count; i++)
		{
			shaderBindingTable.AddMissProgram(missIdentifiers[i]);
		}
		HitGroupDescription[] hitgroups = description.HitGroups;
		for (int i = 0; i < hitgroups.Count; i++)
		{
			if (hitgroups[i].Type != 0)
			{
				String hitGroupIdentifier = hitgroups[i].Name;
				shaderBindingTable.AddHitGroupProgram(hitGroupIdentifier);
			}
		}
		shaderBindingTable.Generate(NativePipeline);
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
