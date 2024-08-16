using Bulkan;
using System.Collections;
using System;
namespace Sedulous.RAL.VK;

class VKFramebuffer : FramebufferBase
{
	private VkFramebuffer m_framebuffer;
	private VkExtent2D m_extent;

	public this(VKDevice device, in FramebufferDesc desc)
		: base(desc)
	{
		m_extent = .(desc.width, desc.height);

		VkFramebufferCreateInfo framebuffer_info = .() { sType = .VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO };
		List<VkImageView> attachment_views = scope .();
		framebuffer_info.layers = 1;
		delegate void(View view) add_view = scope [&] (view) =>
			{
				if (view == null)
				{
					return;
				}
				VKView vk_view = view.As<VKView>();
				Resource resource = vk_view.GetResource();
				if (resource == null)
				{
					return;
				}
				attachment_views.Add(vk_view.GetImageView());

				VKResource vk_resource = resource.As<VKResource>();
				framebuffer_info.layers = Math.Max(framebuffer_info.layers, vk_resource.image.array_layers);
			};
		for (var rtv in desc.colors)
		{
			add_view(rtv);
		}
		add_view(desc.depth_stencil);
		add_view(desc.shading_rate_image);

		framebuffer_info.width = m_extent.width;
		framebuffer_info.height = m_extent.height;
		framebuffer_info.renderPass = desc.render_pass.As<VKRenderPass>().GetRenderPass();
		framebuffer_info.attachmentCount = (uint32)attachment_views.Count;
		framebuffer_info.pAttachments = attachment_views.Ptr;
		VulkanNative.vkCreateFramebuffer(device.GetDevice(), &framebuffer_info, null, &m_framebuffer);
	}

	public VkFramebuffer GetFramebuffer()
	{
		return m_framebuffer;
	}

	public VkExtent2D GetExtent()
	{
		return m_extent;
	}
}