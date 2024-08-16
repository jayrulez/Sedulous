using Bulkan;
using System;
namespace Sedulous.RAL.VK;

static
{
	public static VkImageViewType GetImageViewType(ViewDimension dimension)
	{
		switch (dimension) {
		case ViewDimension.kTexture1D:
			return VkImageViewType.VK_IMAGE_VIEW_TYPE_1D;
		case ViewDimension.kTexture1DArray:
			return VkImageViewType.VK_IMAGE_VIEW_TYPE_1D_ARRAY;
		case ViewDimension.kTexture2D,
			ViewDimension.kTexture2DMS:
			return VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
		case ViewDimension.kTexture2DArray,
			ViewDimension.kTexture2DMSArray:
			return VkImageViewType.VK_IMAGE_VIEW_TYPE_2D_ARRAY;
		case ViewDimension.kTexture3D:
			return VkImageViewType.VK_IMAGE_VIEW_TYPE_3D;
		case ViewDimension.kTextureCube:
			return VkImageViewType.eCube;
		case ViewDimension.kTextureCubeArray:
			return VkImageViewType.eCubeArray;
		default:
			Runtime.Assert(false);
			return default;
		}
	}
}

class VKView : View
{
	private VKDevice m_device;
	private VKResource m_resource;
	private ViewDesc m_view_desc;
	private VkImageView m_image_view;
	private VkBufferView m_buffer_view;
	private VKGPUDescriptorPoolRange m_range;
	private VkDescriptorImageInfo m_descriptor_image = .();
	private VkDescriptorBufferInfo m_descriptor_buffer = .();
	private VkWriteDescriptorSetAccelerationStructureKHR m_descriptor_acceleration_structure = .() { sType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR };
	private VkWriteDescriptorSet m_descriptor = .() { sType = .VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET };

	public this(VKDevice device, VKResource resource, in ViewDesc view_desc)
	{
		m_device = device;
		m_resource = resource;
		m_view_desc = view_desc;

		if (resource != null)
		{
			CreateView();
		}

		if (view_desc.bindless)
		{
			VkDescriptorType type = GetDescriptorType(view_desc.view_type);
			VKGPUBindlessDescriptorPoolTyped pool = device.GetGPUBindlessDescriptorPool(type);
			m_range = pool.Allocate(1);

			m_descriptor.dstSet = m_range.GetDescriptorSet();
			m_descriptor.dstArrayElement = m_range.GetOffset();
			m_descriptor.descriptorType = type;
			m_descriptor.dstBinding = 0;
			m_descriptor.descriptorCount = 1;
			VulkanNative.vkUpdateDescriptorSets(m_device.GetDevice(), 1, &m_descriptor, 0, null);
		}
	}

	public override Resource GetResource()
	{
		return m_resource;
	}
	public override uint32 GetDescriptorId()
	{
		if (m_range != null)
		{
			return m_range.GetOffset();
		}
		return uint32(-1);
	}
	public override uint32 GetBaseMipLevel()
	{
		return m_view_desc.base_mip_level;
	}
	public override uint32 GetLevelCount()
	{
		return Math.Min<uint32>(m_view_desc.level_count, m_resource.GetLevelCount() - m_view_desc.base_mip_level);
	}
	public override uint32 GetBaseArrayLayer()
	{
		return m_view_desc.base_array_layer;
	}

	public override uint32 GetLayerCount()
	{
		return Math.Min<uint32>(m_view_desc.layer_count, m_resource.GetLayerCount() - m_view_desc.base_array_layer);
	}

	public VkImageView GetImageView()
	{
		return m_image_view;
	}
	public VkWriteDescriptorSet GetDescriptor()
	{
		return m_descriptor;
	}

	private void CreateView()
	{
		switch (m_view_desc.view_type) {
		case ViewType.kSampler:
			m_descriptor_image.sampler = m_resource.sampler.res;
			m_descriptor.pImageInfo = &m_descriptor_image;
			break;
		case ViewType.kTexture:
			{
				CreateImageView();
				m_descriptor_image.imageLayout = VkImageLayout.eShaderReadOnlyOptimal;
				m_descriptor_image.imageView = m_image_view;
				m_descriptor.pImageInfo = &m_descriptor_image;
				break;
			}
		case ViewType.kRWTexture:
			{
				CreateImageView();
				m_descriptor_image.imageLayout = VkImageLayout.eGeneral;
				m_descriptor_image.imageView = m_image_view;
				m_descriptor.pImageInfo = &m_descriptor_image;
				break;
			}
		case ViewType.kAccelerationStructure:
			{
				m_descriptor_acceleration_structure.accelerationStructureCount = 1;
				m_descriptor_acceleration_structure.pAccelerationStructures = &m_resource.acceleration_structure_handle;
				m_descriptor.pNext = &m_descriptor_acceleration_structure;
				break;
			}
		case ViewType.kShadingRateSource,
			ViewType.kRenderTarget,
			ViewType.kDepthStencil:
			{
				CreateImageView();
				break;
			}
		case ViewType.kConstantBuffer,
			ViewType.kStructuredBuffer,
			ViewType.kRWStructuredBuffer:
			m_descriptor_buffer.buffer = m_resource.buffer.res;
			m_descriptor_buffer.offset = m_view_desc.offset;
			m_descriptor_buffer.range = m_view_desc.buffer_size;
			m_descriptor.pBufferInfo = &m_descriptor_buffer;
			break;
		case ViewType.kBuffer,
			ViewType.kRWBuffer:
			CreateBufferView();
			m_descriptor.pTexelBufferView = &m_buffer_view;
			break;
		default:
			Runtime.Assert(false);
			break;
		}
	}

	private void CreateImageView()
	{
		VkImageViewCreateInfo image_view_desc = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO };
		image_view_desc.image = m_resource.image.res;
		image_view_desc.format = m_resource.image.format;
		image_view_desc.viewType = GetImageViewType(m_view_desc.dimension);
		image_view_desc.subresourceRange.baseMipLevel = GetBaseMipLevel();
		image_view_desc.subresourceRange.levelCount = GetLevelCount();
		image_view_desc.subresourceRange.baseArrayLayer = GetBaseArrayLayer();
		image_view_desc.subresourceRange.layerCount = GetLayerCount();
		image_view_desc.subresourceRange.aspectMask = m_device.GetAspectFlags(image_view_desc.format);

		if (image_view_desc.subresourceRange.aspectMask & (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT) != 0)
		{
			if (m_view_desc.plane_slice == 0)
			{
				image_view_desc.subresourceRange.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT;
			} else
			{
				image_view_desc.subresourceRange.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT;
				image_view_desc.components.g = VkComponentSwizzle.eR;
			}
		}

		VulkanNative.vkCreateImageView(m_device.GetDevice(), &image_view_desc, null, &m_image_view);
	}

	private void CreateBufferView()
	{
		VkBufferViewCreateInfo buffer_view_desc = .() { sType = .VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO };
		buffer_view_desc.buffer = m_resource.buffer.res;
		buffer_view_desc.format = (VkFormat)m_view_desc.buffer_format;
		buffer_view_desc.offset = m_view_desc.offset;
		buffer_view_desc.range = m_view_desc.buffer_size;
		VulkanNative.vkCreateBufferView(m_device.GetDevice(), &buffer_view_desc, null, &m_buffer_view);
	}
}