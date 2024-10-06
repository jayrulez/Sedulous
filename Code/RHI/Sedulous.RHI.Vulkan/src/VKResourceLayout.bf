using System;
using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// The Vulkan implementation of a ResourceLayout object.
/// </summary>
public class VKResourceLayout : ResourceLayout
{
	/// <summary>
	/// The Vulkan descriptor set layout struct.
	/// </summary>
	public readonly VkDescriptorSetLayout DescriptorSetLayout;

	internal readonly VKResourceCounts ResourceCounts;

	private readonly VKGraphicsContext vkContext;

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
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT, DescriptorSetLayout.Handle, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKResourceLayout" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The layout description.</param>
	public this(VKGraphicsContext context, in ResourceLayoutDescription description)
		: base(description)
	{
		vkContext = context;
		VkDescriptorSetLayoutCreateInfo info = VkDescriptorSetLayoutCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO
		};
		VkDescriptorSetLayoutBinding* bindings = scope VkDescriptorSetLayoutBinding[description.Elements.Count]*;
		uint32 constantBufferCount = 0;
		uint32 textureCount = 0;
		uint32 samplerCount = 0;
		uint32 storageBufferCount = 0;
		uint32 storageImageCount = 0;
		uint32 accelerationStructureCount = 0;
		for (uint32 i = 0; i < description.Elements.Count; i++)
		{
			LayoutElementDescription elem = description.Elements[i];
			uint32 binding = VKHelpers.GetBinding(elem);
			bindings[i].binding = binding;
			bindings[i].descriptorCount = 1;
			bindings[i].descriptorType = elem.Type.ToVulkan(elem.AllowDynamicOffset);
			bindings[i].stageFlags = elem.Stages.ToVulkan();
			switch (elem.Type.ToVulkan())
			{
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER:
				constantBufferCount++;
				break;
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
				textureCount++;
				break;
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
				samplerCount++;
				break;
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER:
				storageBufferCount++;
				break;
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
				storageImageCount++;
				break;
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
				accelerationStructureCount++;
				break;

			default: break;
			}
		}
		ResourceCounts = VKResourceCounts(constantBufferCount, textureCount, samplerCount, storageBufferCount, storageImageCount, accelerationStructureCount);
		info.bindingCount = (uint32)description.Elements.Count;
		info.pBindings = bindings;
		VkDescriptorSetLayout newDescriptorSetLayout = default(VkDescriptorSetLayout);
		VulkanNative.vkCreateDescriptorSetLayout(vkContext.VkDevice, &info, null, &newDescriptorSetLayout);
		DescriptorSetLayout = newDescriptorSetLayout;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged resources and, optionally, managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				VulkanNative.vkDestroyDescriptorSetLayout(vkContext.VkDevice, DescriptorSetLayout, null);
			}
			disposed = true;
		}
	}
}
