using System;
using Bulkan;
using Sedulous.RHI;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represents a native shader object on Metal.
/// </summary>
public class VKShader : Shader
{
	/// <summary>
	/// The native vulkan shader object.
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
	/// Gets the ShaderStateInfo using in the pipelinestate.
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
					pName = Description.EntryPoint.CStr(),
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
	public this(GraphicsContext context, ref ShaderDescription description)
		: base(context, ref description)
	{
		vkContext = Context as VKGraphicsContext;
		VkDevice vkDevice = vkContext.VkDevice;
		VkShaderModuleCreateInfo nativeDescription = VkShaderModuleCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
		};
		uint8* sourcePointer = description.ShaderBytes.Ptr;
		{
			nativeDescription.codeSize = (uint)description.ShaderBytes.Count;
			nativeDescription.pCode = (uint32*)sourcePointer;
			VkShaderModule newShader = default(VkShaderModule);
			VulkanNative.vkCreateShaderModule(vkDevice, &nativeDescription, null, &newShader);
			ShaderModule = newShader;
		}
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
