using System;
using Bulkan;
using Sedulous.RHI;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represents the a Vulkan samplerState object.
/// </summary>
public class VKSamplerState : SamplerState
{
	/// <summary>
	/// The native sampler state.
	/// </summary>
	public readonly VkSampler NativeSampler;

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
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_SAMPLER, NativeSampler.Handle, name);
		}
	}

	/// <inheritdoc />
	public override void* NativePointer
	{
		get
		{
			if (!(NativeSampler != VkSampler.Null))
			{
				return null;
			}
			return (void*)(int)NativeSampler.Handle;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKSamplerState" /> class.
	/// </summary>
	/// <param name="context">The graphics context. <see cref="T:Sedulous.RHI.GraphicsContext" />.</param>
	/// <param name="description">The sampler state description. <see cref="T:Sedulous.RHI.SamplerStateDescription" />.</param>
	public this(GraphicsContext context, ref SamplerStateDescription description)
		: base(context, ref description)
	{
		description.Filter.ToVulkan(var minFilter, var magFilter, var mipmapMode);
		VkSamplerCreateInfo nativeDescription = VkSamplerCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
			addressModeU = description.AddressU.ToVulkan(),
			addressModeV = description.AddressU.ToVulkan(),
			addressModeW = description.AddressU.ToVulkan(),
			minFilter = minFilter,
			magFilter = magFilter,
			mipmapMode = mipmapMode,
			compareEnable = (description.ComparisonFunc != ComparisonFunction.Never),
			compareOp = description.ComparisonFunc.ToVulkan(),
			anisotropyEnable = (description.Filter == TextureFilter.Anisotropic),
			maxAnisotropy = description.MaxAnisotropy,
			minLod = description.MinLOD,
			maxLod = description.MaxLOD,
			mipLodBias = description.MipLODBias,
			borderColor = description.BorderColor.ToVulkan()
		};
		vkContext = Context as VKGraphicsContext;
		VkSampler newSampler = default(VkSampler);
		VulkanNative.vkCreateSampler(vkContext.VkDevice, &nativeDescription, null, &newSampler);
		NativeSampler = newSampler;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		if (!disposed)
		{
			VulkanNative.vkDestroySampler(vkContext.VkDevice, NativeSampler, null);
			disposed = true;
		}
	}
}
