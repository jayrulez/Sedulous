using System;
using Bulkan;
using Sedulous.RHI;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// The Vulkan implementation of a ResourceSet object.
/// </summary>
public class VKResourceSet : ResourceSet
{
	/// <summary>
	/// The Vulkan descriptor allocation token.
	/// </summary>
	public readonly VKDescriptorAllocationToken DescriptorAllocationToken;

	/// <summary>
	/// The number of dynamic buffers.
	/// </summary>
	public readonly uint32 DynamicBufferCount;

	/// <summary>
	/// List of storage textures (RWTexture).
	/// </summary>
	internal List<VKTexture> StorageTextures;

	/// <summary>
	/// List of normal textures.
	/// </summary>
	internal List<VKTexture> Textures;

	private readonly VKResourceCounts descriptorCounts;

	private VKGraphicsContext vkContext;

	private bool disposed;

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
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_DESCRIPTOR_SET, DescriptorAllocationToken.DescriptorSet.Handle, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKResourceSet" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The resource set description.</param>
	public this(VKGraphicsContext context, in ResourceSetDescription description)
		: base(description)
	{
		vkContext = context;
		VKResourceLayout vkLayout = description.Layout as VKResourceLayout;
		descriptorCounts = vkLayout.ResourceCounts;
		DescriptorAllocationToken = vkContext.DescriptorPool.Allocate(vkLayout.DescriptorSetLayout, vkLayout.ResourceCounts);
		StorageTextures = new List<VKTexture>();
		Textures = new List<VKTexture>();
		uint32 descriptorWriteCount = (uint32)description.Resources.Count;
		VkWriteDescriptorSet* descriptorWrites = scope VkWriteDescriptorSet[(int32)descriptorWriteCount]*;
		VkDescriptorBufferInfo* bufferInfos = scope VkDescriptorBufferInfo[(int32)descriptorWriteCount]*;
		VkDescriptorImageInfo* imageInfos = scope VkDescriptorImageInfo[(int32)descriptorWriteCount]*;
		VkWriteDescriptorSetAccelerationStructureKHR* asInfos = scope VkWriteDescriptorSetAccelerationStructureKHR[(int32)descriptorWriteCount]*;
		DynamicBufferCount = 0;
		VkWriteDescriptorSet* currentDescriptorWrites = descriptorWrites;
		VkDescriptorImageInfo* currentImageInfos = imageInfos;
		uint32 count = 0;
		for (uint32 i = 0; i < descriptorWriteCount; i++)
		{
			bool isValid = true;
			LayoutElementDescription elem = vkLayout.Description.Elements[i];
			VkDescriptorType type = elem.Type.ToVulkan(elem.AllowDynamicOffset);
			switch (type)
			{
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
				 VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
				 VkDescriptorType.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC,
				 VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC:
			{
				VkDescriptorBufferInfo* currentBufferInfo = bufferInfos + i;
				VKBuffer buffer = description.Resources[i] as VKBuffer;
				isValid = buffer != null;
				if (isValid)
				{
					currentBufferInfo.buffer = buffer.NativeBuffer;
					currentBufferInfo.range = ((elem.Range == 0) ? uint64.MaxValue : ((uint64)elem.Range));
					currentDescriptorWrites.pBufferInfo = currentBufferInfo;
					if (elem.AllowDynamicOffset)
					{
						DynamicBufferCount++;
					}
				}
				break;
			}
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE:
			{
				VKTexture texture = description.Resources[i] as VKTexture;
				isValid = texture != null;
				if (isValid)
				{
					currentImageInfos.imageView = texture.ImageView;
					currentImageInfos.sampler = VkSampler.Null;
					currentImageInfos.imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
					currentDescriptorWrites.pImageInfo = currentImageInfos;
					Textures.Add(texture);
				}
				break;
			}
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE:
			{
				VKTexture image = description.Resources[i] as VKTexture;
				isValid = image != null;
				if (isValid)
				{
					currentImageInfos.imageView = image.ImageView;
					currentImageInfos.imageLayout = VkImageLayout.VK_IMAGE_LAYOUT_GENERAL;
					currentDescriptorWrites.pImageInfo = currentImageInfos;
					StorageTextures.Add(image);
				}
				break;
			}
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_SAMPLER:
			{
				VKSamplerState sampler = (description.Resources[i] as VKSamplerState) ?? (context.DefaultSampler as VKSamplerState);
				isValid = sampler != null;
				if (isValid)
				{
					currentImageInfos.imageView = VkImageView.Null;
					currentImageInfos.sampler = sampler.NativeSampler;
					currentDescriptorWrites.pImageInfo = currentImageInfos;
				}
				break;
			}
			case VkDescriptorType.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR:
			{
				VkWriteDescriptorSetAccelerationStructureKHR currentASInfo = asInfos[i];
				VKTopLevelAS tlas = description.Resources[i] as VKTopLevelAS;
				isValid = tlas != null;
				if (isValid)
				{
					currentASInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR;
					currentASInfo.accelerationStructureCount = 1;
					VkAccelerationStructureKHR tlasPointer = tlas.TopLevelAS;
					currentASInfo.pAccelerationStructures = &tlasPointer;
					currentDescriptorWrites.pNext = &currentASInfo;
				}
				break;
			}
			default: break;
			}
			if (isValid)
			{
				uint32 binding = VKHelpers.GetBinding(elem);
				currentDescriptorWrites.sType = VkStructureType.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
				currentDescriptorWrites.descriptorCount = 1;
				currentDescriptorWrites.descriptorType = type;
				currentDescriptorWrites.dstBinding = binding;
				currentDescriptorWrites.dstSet = DescriptorAllocationToken.DescriptorSet;
				currentDescriptorWrites++;
				currentImageInfos++;
				count++;
			}
		}
		VulkanNative.vkUpdateDescriptorSets(vkContext.VkDevice, count, descriptorWrites, 0, null);
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
				vkContext.DescriptorPool.Free(DescriptorAllocationToken, descriptorCounts);
			}
			disposed = true;
		}
	}
}
