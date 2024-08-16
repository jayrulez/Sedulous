using Bulkan;
using System.Collections;
using System;
namespace Sedulous.RAL.VK;

class VKRenderPass : RenderPass
{
	private RenderPassDesc m_desc;
	private VkRenderPass m_render_pass;

	public this(VKDevice device, in RenderPassDesc desc)
	{
		m_desc = desc;

		while (!m_desc.colors.IsEmpty && m_desc.colors.Back.format == Format.FORMAT_UNDEFINED)
		{
			m_desc.colors.PopBack();
		}

		List<VkAttachmentDescription2> attachment_descriptions = scope .();
		delegate void(ref VkAttachmentReference2 reference, Format format, VkImageLayout layout,
			RenderPassLoadOp load_op, RenderPassStoreOp store_op) add_attachment = scope [&] (reference, format, layout,
			load_op, store_op) =>
			{
				if (format == Format.FORMAT_UNDEFINED)
				{
					reference.attachment = VulkanNative.VK_ATTACHMENT_UNUSED;
					return;
				}
				VkAttachmentDescription2 description = .()
					{
						sType = .VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2,
						format = (VkFormat)format,
						samples = (VkSampleCountFlags)m_desc.sample_count,
						loadOp = Convert(load_op),
						storeOp = Convert(store_op),
						initialLayout = layout,
						finalLayout = layout
					};
				attachment_descriptions.Add(description);

				reference.attachment = uint32(attachment_descriptions.Count - 1);
				reference.layout = layout;
			};

		VkSubpassDescription2 sub_pass = .() { sType = .VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2 };
		sub_pass.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;

		List<VkAttachmentReference2> color_attachment_references = scope .();
		for (RenderPassColorDesc rtv in m_desc.colors)
		{
			VkAttachmentReference2 attachment = .();
			add_attachment(ref attachment, rtv.format, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
				rtv.load_op, rtv.store_op);
			color_attachment_references.Add(attachment);
		}

		sub_pass.colorAttachmentCount = (uint32)color_attachment_references.Count;
		sub_pass.pColorAttachments = color_attachment_references.Ptr;

		VkAttachmentReference2 depth_attachment_reference = .() { sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2 };
		if (m_desc.depth_stencil.format != Format.FORMAT_UNDEFINED)
		{
			add_attachment(ref depth_attachment_reference, m_desc.depth_stencil.format,
				VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, m_desc.depth_stencil.depth_load_op,
				m_desc.depth_stencil.depth_store_op);
			if (depth_attachment_reference.attachment != VulkanNative.VK_ATTACHMENT_UNUSED)
			{
				ref VkAttachmentDescription2 description = ref attachment_descriptions[depth_attachment_reference.attachment];
				description.stencilLoadOp = Convert(m_desc.depth_stencil.stencil_load_op);
				description.stencilStoreOp = Convert(m_desc.depth_stencil.stencil_store_op);
			}
			sub_pass.pDepthStencilAttachment = &depth_attachment_reference;
		}

		if (m_desc.shading_rate_format != Format.FORMAT_UNDEFINED)
		{
			VkAttachmentReference2 shading_rate_image_attachment_reference = .() { sType = .VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2 };
			add_attachment(ref shading_rate_image_attachment_reference, m_desc.shading_rate_format,
				VkImageLayout.VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR, RenderPassLoadOp.kLoad,
				RenderPassStoreOp.kStore);

			VkFragmentShadingRateAttachmentInfoKHR fragment_shading_rate_attachment_info = .() { sType = .VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR };
			fragment_shading_rate_attachment_info.pFragmentShadingRateAttachment = &shading_rate_image_attachment_reference;
			fragment_shading_rate_attachment_info.shadingRateAttachmentTexelSize.width =
				device.GetShadingRateImageTileSize();
			fragment_shading_rate_attachment_info.shadingRateAttachmentTexelSize.height =
				device.GetShadingRateImageTileSize();
			sub_pass.pNext = &fragment_shading_rate_attachment_info;
		}

		VkRenderPassCreateInfo2 render_pass_info = .() { sType = .VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2 };
		render_pass_info.attachmentCount = (uint32)attachment_descriptions.Count;
		render_pass_info.pAttachments = attachment_descriptions.Ptr;
		render_pass_info.subpassCount = 1;
		render_pass_info.pSubpasses = &sub_pass;

		VulkanNative.vkCreateRenderPass2(device.GetDevice(), &render_pass_info, null, &m_render_pass);
	}

	public override readonly ref RenderPassDesc GetDesc()
	{
		return ref m_desc;
	}

	public VkRenderPass GetRenderPass()
	{
		return m_render_pass;
	}

	private static VkAttachmentLoadOp Convert(RenderPassLoadOp op)
	{
		switch (op) {
		case RenderPassLoadOp.kLoad:
			return VkAttachmentLoadOp.eLoad;
		case RenderPassLoadOp.kClear:
			return VkAttachmentLoadOp.eClear;
		case RenderPassLoadOp.kDontCare:
			return VkAttachmentLoadOp.eDontCare;
		}
		//Runtime.Assert(false);
		//return VkAttachmentLoadOp.eLoad;
	}

	private static VkAttachmentStoreOp Convert(RenderPassStoreOp op)
	{
		switch (op) {
		case RenderPassStoreOp.kStore:
			return VkAttachmentStoreOp.eStore;
		case RenderPassStoreOp.kDontCare:
			return VkAttachmentStoreOp.eDontCare;
		}
		//Runtime.Assert(false);
		//return VkAttachmentStoreOp.eStore;
	}
}