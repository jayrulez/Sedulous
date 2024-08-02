using Bulkan;
using Sedulous.RHI;
using System;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represents a native FrameBuffer object on Vulkan.
/// </summary>
public class VKFrameBuffer : VKFrameBufferBase
{
	/// <summary>
	/// The Vulkan frameBuffer struct.
	/// </summary>
	public VkFramebuffer NativeFrameBuffer;

	/// <summary>
	/// Default Render Passes.
	/// </summary>
	public VkRenderPass[] defaultRenderPasses;

	private List<VkImageView> imageViews;

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
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_FRAMEBUFFER, NativeFrameBuffer.Handle, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKFrameBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="depthTarget">The depth texture which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.DepthStencil" /> flag.</param>
	/// <param name="colorTargets">The array of color textures, all of which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.RenderTarget" /> flags.</param>
	/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
	public this(VKGraphicsContext context, FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments)
		: base(depthTarget, colorTargets, disposeAttachments)
	{
		vkContext = context;
		CreateDefaultPasses();
		imageViews = new List<VkImageView>();
		for (int i = 0; i < colorTargets.Count; i++)
		{
			FrameBufferAttachment colorTarget = ColorTargets[i];
			VKTexture colorTexture = colorTarget.AttachmentTexture as VKTexture;
			VkImageView colorImageView = CreateImageView(colorTexture, colorTarget.MipSlice, colorTarget.AttachedFirstSlice);
			imageViews.Add(colorImageView);
			VKTexture resolvedTexture = colorTarget.ResolvedTexture as VKTexture;
			if (resolvedTexture != null)
			{
				VkImageView msaaImageView = CreateImageView(resolvedTexture, colorTarget.MipSlice, colorTarget.AttachedFirstSlice);
				imageViews.Add(msaaImageView);
			}
		}
		bool isStencilFormat = false;
		if (depthTarget.HasValue)
		{
			VKTexture depthTexture = depthTarget.Value.AttachmentTexture as VKTexture;
			if (depthTexture.Description.Format == PixelFormat.D24_UNorm_S8_UInt || depthTexture.Description.Format == PixelFormat.D32_Float_S8X24_UInt)
			{
				isStencilFormat = true;
			}
			VkImageAspectFlags flags = (isStencilFormat ? (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT) : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			VkImageView depthImageView = CreateImageView(depthTexture, depthTarget.Value.MipSlice, depthTarget.Value.AttachedFirstSlice, flags, depthTexture: true);
			imageViews.Add(depthImageView);
			VKTexture resolvedDepthTexture = depthTarget.Value.ResolvedTexture as VKTexture;
			if (resolvedDepthTexture != null)
			{
				VkImageView msaaDepthImageView = CreateImageView(resolvedDepthTexture, depthTarget.Value.MipSlice, depthTarget.Value.AttachedFirstSlice, flags);
				imageViews.Add(msaaDepthImageView);
			}
		}
		VkFramebufferCreateInfo frameBufferInfo = VkFramebufferCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
			width = base.Width,
			height = base.Height,
			attachmentCount = (uint32)imageViews.Count
		};
		frameBufferInfo.pAttachments = imageViews.Ptr;
		frameBufferInfo.layers = 1;
		frameBufferInfo.renderPass = defaultRenderPasses[7];
		VkFramebuffer newFrameBuffer = default(VkFramebuffer);
		VulkanNative.vkCreateFramebuffer(context.VkDevice, &frameBufferInfo, null, &newFrameBuffer);
		NativeFrameBuffer = newFrameBuffer;
	}

	/// <summary>
	/// Generate a VKImageView from FrameBufferAttachment.
	/// </summary>
	/// <param name="vkTexture">Texture instance.</param>
	/// <param name="mipSlice">Miplevel slice.</param>
	/// <param name="firstSlice">First slice.</param>
	/// <param name="flags">Aspect flags.</param>
	/// <param name="depthTexture">This image view is a depth texture.</param>
	/// <returns>VkImageView instance.</returns>
	protected VkImageView CreateImageView(VKTexture vkTexture, uint32 mipSlice, uint32 firstSlice, VkImageAspectFlags flags = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT, bool depthTexture = false)
	{
		VkImageViewCreateInfo imageViewInfo = default(VkImageViewCreateInfo);
		imageViewInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
		imageViewInfo.image = vkTexture.NativeImage;
		imageViewInfo.format = vkTexture.Description.Format.ToVulkan(depthTexture);
		imageViewInfo.viewType = VkImageViewType.VK_IMAGE_VIEW_TYPE_2D;
		if (flags == VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT)
		{
			imageViewInfo.components.r = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			imageViewInfo.components.g = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			imageViewInfo.components.b = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
			imageViewInfo.components.a = VkComponentSwizzle.VK_COMPONENT_SWIZZLE_IDENTITY;
		}
		imageViewInfo.subresourceRange = VkImageSubresourceRange()
		{
			aspectMask = flags,
			baseMipLevel = mipSlice,
			levelCount = 1,
			baseArrayLayer = firstSlice,
			layerCount = base.ArraySize
		};
		VkImageView newImageView = default(VkImageView);
		VulkanNative.vkCreateImageView(vkContext.VkDevice, &imageViewInfo, null, &newImageView);
		return newImageView;
	}

	private void CreateDefaultPasses()
	{
		defaultRenderPasses = new VkRenderPass[8];
		for (int i = 0; i < defaultRenderPasses.Count; i++)
		{
			ClearFlags clearFlags = (ClearFlags)i;
			VkAttachmentLoadOp targetLoadOp = (clearFlags.HasFlag(ClearFlags.Target) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
			VkAttachmentLoadOp depthLoadOp = (clearFlags.HasFlag(ClearFlags.Depth) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
			VkAttachmentLoadOp stencilLoadOp = (clearFlags.HasFlag(ClearFlags.Stencil) ? VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD);
			defaultRenderPasses[(int32)clearFlags] = CreateRenderPasses(targetLoadOp, depthLoadOp, stencilLoadOp);
		}
	}

	internal void GetRenderPass(ClearFlags clearFlags, out VkRenderPass renderPass)
	{
		renderPass = defaultRenderPasses[(int32)clearFlags];
	}

	private VkRenderPass CreateRenderPasses(VkAttachmentLoadOp targetLoadOp, VkAttachmentLoadOp depthLoadOp, VkAttachmentLoadOp stencilLoadOp)
	{
		int colorTargetLength = ((!ColorTargets.IsEmpty) ? ColorTargets.Count : 0);
		int targetsCount = colorTargetLength;
		if (DepthStencilTarget.HasValue)
		{
			targetsCount++;
		}
		int attachmentCount = targetsCount * 2;
		uint32 currentAttachmentIndex = 0;
		uint32 colorAttachmentIndex = 0;
		uint32 resolvedAttachmentIndex = 0;
		VkAttachmentDescription* attachments = scope VkAttachmentDescription[attachmentCount]*;
		VkAttachmentReference* colorAttachmentReferences = scope VkAttachmentReference[colorTargetLength]*;
		VkAttachmentReference* resolveAttachmentReferences = scope VkAttachmentReference[colorTargetLength]*;
		if (!ColorTargets.IsEmpty)
		{
			for (int32 i = 0; i < colorTargetLength; i++)
			{
				FrameBufferAttachment frameBufferAttachment = ColorTargets[i];
				VKTexture colorTexture = frameBufferAttachment.AttachmentTexture as VKTexture;
				var (textureAttachment, textureAttachmentRef) = CreateAttachment(colorTexture.Description.Format.ToVulkan(depthFormat: false), colorTexture.Description.SampleCount.ToVulkan(), currentAttachmentIndex, targetLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, (targetLoadOp != VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE) ? VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL : VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
				attachments[currentAttachmentIndex++] = textureAttachment;
				colorAttachmentReferences[colorAttachmentIndex++] = textureAttachmentRef;
				VKTexture resolvedTexture = frameBufferAttachment.ResolvedTexture as VKTexture;
				if (resolvedTexture != null)
				{
					var (msaaTextureAttachment, msaaTextureAttachmentRef) = CreateAttachment(resolvedTexture.Description.Format.ToVulkan(depthFormat: false), resolvedTexture.Description.SampleCount.ToVulkan(), currentAttachmentIndex, targetLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE, (targetLoadOp != VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE) ? VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL : VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
					attachments[currentAttachmentIndex++] = msaaTextureAttachment;
					resolveAttachmentReferences[resolvedAttachmentIndex++] = msaaTextureAttachmentRef;
				}
			}
		}
		bool isStencilFormat = false;
		VkAttachmentReference depthAttachementReference = default(VkAttachmentReference);
		if (DepthStencilTarget.HasValue)
		{
			VKTexture depthTexture = DepthStencilTarget.Value.AttachmentTexture as VKTexture;
			if (depthTexture.Description.Format == PixelFormat.D24_UNorm_S8_UInt || depthTexture.Description.Format == PixelFormat.D32_Float_S8X24_UInt)
			{
				isStencilFormat = true;
			}
			VkImageLayout depthInitialLayout = ((depthLoadOp == VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD || stencilLoadOp == VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_LOAD) ? VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL : VkImageLayout.VK_IMAGE_LAYOUT_UNDEFINED);
			VkAttachmentDescription depthTextureAttachment = CreateAttachment(depthTexture.Description.Format.ToVulkan(depthFormat: true), depthTexture.Description.SampleCount.ToVulkan(), currentAttachmentIndex, depthLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, isStencilFormat ? stencilLoadOp : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, (!isStencilFormat) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, depthInitialLayout, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL).Attachment;
			VkAttachmentReference vkAttachmentReference = default(VkAttachmentReference);
			vkAttachmentReference.attachment = currentAttachmentIndex;
			vkAttachmentReference.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
			depthAttachementReference = vkAttachmentReference;
			attachments[currentAttachmentIndex++] = depthTextureAttachment;
			VKTexture resolvedDepthTexture = DepthStencilTarget.Value.ResolvedTexture as VKTexture;
			if (resolvedDepthTexture != null)
			{
				VkAttachmentDescription msaaDepthTextureAttachment = CreateAttachment(resolvedDepthTexture.Description.Format.ToVulkan(depthFormat: true), resolvedDepthTexture.Description.SampleCount.ToVulkan(), currentAttachmentIndex, depthLoadOp, VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, isStencilFormat ? stencilLoadOp : VkAttachmentLoadOp.VK_ATTACHMENT_LOAD_OP_DONT_CARE, (!isStencilFormat) ? VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_DONT_CARE : VkAttachmentStoreOp.VK_ATTACHMENT_STORE_OP_STORE, depthInitialLayout, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL).Attachment;
				vkAttachmentReference = default(VkAttachmentReference);
				vkAttachmentReference.attachment = currentAttachmentIndex;
				vkAttachmentReference.layout = VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
				attachments[currentAttachmentIndex++] = msaaDepthTextureAttachment;
			}
		}
		VkSubpassDescription vkSubpassDescription = default(VkSubpassDescription);
		vkSubpassDescription.pipelineBindPoint = VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS;
		VkSubpassDescription subpass = vkSubpassDescription;
		if (colorAttachmentIndex != 0)
		{
			subpass.colorAttachmentCount = colorAttachmentIndex;
			subpass.pColorAttachments = colorAttachmentReferences;
		}
		uint32 dependencyCount = 1;
		if (resolvedAttachmentIndex != 0)
		{
			subpass.pResolveAttachments = resolveAttachmentReferences;
			dependencyCount++;
		}
		if (DepthStencilTarget.HasValue)
		{
			subpass.pDepthStencilAttachment = &depthAttachementReference;
		}
		VkSubpassDependency* dependencies = scope VkSubpassDependency[(int32)dependencyCount]*;
		if (resolvedAttachmentIndex == 0)
		{
			*dependencies = VkSubpassDependency()
			{
				srcSubpass = uint32.MaxValue,
				dstSubpass = 0,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				srcAccessMask = VkAccessFlags.VK_ACCESS_NONE,
				dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT)
			};
		}
		else
		{
			*dependencies = VkSubpassDependency()
			{
				srcSubpass = uint32.MaxValue,
				dstSubpass = 0,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				srcAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
				dstAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
				dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
			};
			dependencies[1] = VkSubpassDependency()
			{
				srcSubpass = 0,
				dstSubpass = uint32.MaxValue,
				srcStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
				dstStageMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
				srcAccessMask = (VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VkAccessFlags.VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT),
				dstAccessMask = VkAccessFlags.VK_ACCESS_MEMORY_READ_BIT,
				dependencyFlags = VkDependencyFlags.VK_DEPENDENCY_BY_REGION_BIT
			};
		}
		VkRenderPassCreateInfo vkRenderPassCreateInfo = default(VkRenderPassCreateInfo);
		vkRenderPassCreateInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
		vkRenderPassCreateInfo.attachmentCount = currentAttachmentIndex;
		vkRenderPassCreateInfo.pAttachments = attachments;
		vkRenderPassCreateInfo.subpassCount = 1;
		vkRenderPassCreateInfo.pSubpasses = &subpass;
		vkRenderPassCreateInfo.dependencyCount = dependencyCount;
		vkRenderPassCreateInfo.pDependencies = dependencies;
		VkRenderPassCreateInfo renderPassInfo = vkRenderPassCreateInfo;
		VkRenderPassMultiviewCreateInfo renderPassMultiviewCI = default(VkRenderPassMultiviewCreateInfo);
		if (!ColorTargets.IsEmpty && ColorTargets[0].SliceCount > 1 && vkContext.Capabilities.MultiviewStrategy == MultiviewStrategy.ViewIndex)
		{
			uint32 mask = (uint32)((1 << (int32)ColorTargets[0].SliceCount) - 1);
			renderPassMultiviewCI.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO;
			renderPassMultiviewCI.subpassCount = 1;
			renderPassMultiviewCI.pViewMasks = &mask;
			renderPassMultiviewCI.correlationMaskCount = 1;
			renderPassMultiviewCI.pCorrelationMasks = &mask;
			renderPassInfo.pNext = &renderPassMultiviewCI;
		}
		VkRenderPass newRenderPass = default(VkRenderPass);
		VulkanNative.vkCreateRenderPass(vkContext.VkDevice, &renderPassInfo, null, &newRenderPass);
		return newRenderPass;
	}

	private (VkAttachmentDescription Attachment, VkAttachmentReference Reference) CreateAttachment(VkFormat format, VkSampleCountFlags samples, uint32 index, VkAttachmentLoadOp loadOp, VkAttachmentStoreOp storeOp, VkAttachmentLoadOp stencilLoadOp, VkAttachmentStoreOp stencilStoreOp, VkImageLayout initialLayout, VkImageLayout finalLayout)
	{
		VkAttachmentDescription vkAttachmentDescription = default(VkAttachmentDescription);
		vkAttachmentDescription.format = format;
		vkAttachmentDescription.samples = samples;
		vkAttachmentDescription.loadOp = loadOp;
		vkAttachmentDescription.storeOp = storeOp;
		vkAttachmentDescription.stencilLoadOp = stencilLoadOp;
		vkAttachmentDescription.stencilStoreOp = stencilStoreOp;
		vkAttachmentDescription.initialLayout = initialLayout;
		vkAttachmentDescription.finalLayout = finalLayout;
		VkAttachmentDescription item = vkAttachmentDescription;
		VkAttachmentReference textureAttachmentRef = VkAttachmentReference()
		{
			attachment = index,
			layout = finalLayout
		};
		return (item, textureAttachmentRef);
	}

	/// <inheritdoc />
	public override void TransitionToIntermedialLayout(VkCommandBuffer cb)
	{
		for (int i = 0; i < ColorTargets.Count; i++)
		{
			FrameBufferAttachment attachment = ColorTargets[i];
			(attachment.Texture as VKTexture).SetImageLayout(attachment.MipSlice, attachment.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
		}
		if (DepthStencilTarget.HasValue)
		{
			(DepthStencilTarget.Value.Texture as VKTexture).SetImageLayout(DepthStencilTarget.Value.MipSlice, DepthStencilTarget.Value.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
		}
	}

	/// <inheritdoc />
	public override void TransitionToFinalLayout(VkCommandBuffer cb)
	{
		for (int i = 0; i < ColorTargets.Count; i++)
		{
			FrameBufferAttachment attachment = ColorTargets[i];
			VKTexture texture = attachment.Texture as VKTexture;
			if ((texture.Description.Flags & TextureFlags.ShaderResource) != 0)
			{
				texture.TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, attachment.MipSlice, 1, attachment.FirstSlice, attachment.SliceCount);
			}
		}
		if (DepthStencilTarget.HasValue)
		{
			VKTexture depthTexture = DepthStencilTarget.Value.Texture as VKTexture;
			if ((depthTexture.Description.Flags & TextureFlags.ShaderResource) != 0)
			{
				depthTexture.TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, DepthStencilTarget.Value.MipSlice, 1, DepthStencilTarget.Value.FirstSlice, 1);
			}
		}
	}

	/// <inheritdoc />
	protected override void Dispose(bool disposing)
	{
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			VulkanNative.vkDestroyFramebuffer(vkContext.VkDevice, NativeFrameBuffer, null);
			for (int i = 0; i < defaultRenderPasses.Count; i++)
			{
				VulkanNative.vkDestroyRenderPass(vkContext.VkDevice, defaultRenderPasses[i], null);
			}
			delete defaultRenderPasses;

			for (VkImageView imageView in imageViews)
			{
				VulkanNative.vkDestroyImageView(vkContext.VkDevice, imageView, null);
			}
			delete imageViews;
			base.Dispose(disposing);
		}
		disposed = true;
	}
}
