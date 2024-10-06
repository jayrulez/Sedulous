using System;
using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represents a native shader object in Metal.
/// </summary>
public class VKShader : Shader
{
	/// <summary>
	/// The native Vulkan shader object.
	/// </summary>
	public readonly VkShaderModule ShaderModule;

	private VkPipelineShaderStageCreateInfo? shaderStateInfo;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

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
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SHADER_MODULE, ShaderModule.Handle, name);
		}
	}

	/// <summary>
	/// Gets the ShaderStateInfo used in the pipeline state.
	/// </summary>
	public VkPipelineShaderStageCreateInfo ShaderStateInfo
	{
		get
		{
			if (!shaderStateInfo.HasValue)
			{
				shaderStateInfo = VkPipelineShaderStageCreateInfo()
				{
					sType = VkStructureType.VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
					stage = Description.Stage.ToVulkan(),
					module = ShaderModule,
					pName = Description.EntryPoint, // todo: ensure cstring
					pSpecializationInfo = null
				};
			}
			return shaderStateInfo.Value;
		}
	}

	/// <inheritdoc />
	public override void* NativePointer => (void*)(int)ShaderModule.Handle;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKShader" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The shader description.</param>
	public this(GraphicsContext context, in ShaderDescription description)
		: base(context, description)
	{
		vkContext = Context as VKGraphicsContext;
		VkDevice vkDevice = vkContext.VkDevice;
		VkShaderModuleCreateInfo nativeDescription = VkShaderModuleCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
		};
		nativeDescription.codeSize = (uint)description.ShaderBytes.Count;
		nativeDescription.pCode = (uint32*)description.ShaderBytes.Ptr;
		VkShaderModule newShader = default(VkShaderModule);
		VulkanNative.vkCreateShaderModule(vkDevice, &nativeDescription, null, &newShader);
		ShaderModule = newShader;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		if (!disposed)
		{
			disposed = true;
			VulkanNative.vkDestroyShaderModule(vkContext.VkDevice, ShaderModule, null);
		}
	}
}
