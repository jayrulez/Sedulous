using Bulkan;
using Sedulous.RHI;
using System;
using System.Collections;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// This class represents the swapchain FrameBuffer in Vulkan.
/// </summary>
public class VKSwapChainFrameBuffer : VKFrameBufferBase
{
	/// <summary>
	/// The color texture array of this <see cref="T:Sedulous.RHI.Vulkan.VKFrameBuffer" />.
	/// </summary>
	//public VkImage[] BackBufferImages;

	/// <summary>
	/// The depth texture of this <see cref="T:Sedulous.RHI.Vulkan.VKFrameBuffer" />.
	/// </summary>
	private VKTexture DepthTargetTexture;

	private VKTexture ResolvedDepthTexture;

	private List<VKTexture> BackBufferTextures = new .() ~ delete _;
	private List<VKTexture> ResolvedBackBufferTextures = new .() ~ delete _;

	/// <summary>
	/// The array of framebuffers linked to this swapchain.
	/// </summary>
	public VKFrameBuffer[] FrameBuffers;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	/// <summary>
	/// The active back buffer index.
	/// </summary>
	public int32 CurrentBackBufferIndex;

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
		}
	}

	/// <inheritdoc />
	public override ref FrameBufferAttachmentList ColorTargets
	{
		get
		{
			return ref FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		}
		protected set
		{
		}
	}

	/// <summary>
	/// Gets the current framebuffer based on the CurrentBackBufferIndex.
	/// </summary>
	public VkFramebuffer CurrentBackBuffer => FrameBuffers[CurrentBackBufferIndex].NativeFrameBuffer;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKSwapChainFrameBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="swapchain">The swapchain to create from.</param>
	public this(VKGraphicsContext context, VKSwapChain swapchain)
	{
		vkContext = context;
		SwapChainDescription description = swapchain.SwapChainDescription;
		base.Width = description.Width;
		base.Height = description.Height;
		base.IntermediateBufferAssociated = true;
		uint32 imageCount = 0;
		VulkanNative.vkGetSwapchainImagesKHR(context.VkDevice, swapchain.vkSwapChain, &imageCount, null);
		VkImage[] BackBufferImages = scope VkImage[imageCount];
		VulkanNative.vkGetSwapchainImagesKHR(context.VkDevice, swapchain.vkSwapChain, &imageCount, BackBufferImages.Ptr);

		TextureSampleCount sampleCount = swapchain.SwapChainDescription.SampleCount;
		TextureDescription depthDescription = TextureDescription()
		{
			Format = description.DepthStencilTargetFormat,
			ArraySize = 1,
			Faces = 1,
			MipLevels = 1,
			Width = description.Width,
			Height = description.Height,
			Depth = 1,
			SampleCount = TextureSampleCount.None,
			Flags = TextureFlags.DepthStencil
		};
		VKTexture depthTexture = (VKTexture)vkContext.Factory.CreateTexture(depthDescription);
		if (sampleCount != 0)
		{
			depthDescription.SampleCount = sampleCount;
			ResolvedDepthTexture = depthTexture;
			depthTexture = (VKTexture)vkContext.Factory.CreateTexture(depthDescription);
		}
		DepthTargetTexture = (VKTexture)depthTexture;
		DepthStencilTarget = FrameBufferAttachment(DepthTargetTexture, ResolvedDepthTexture);
		ColorTargets = .() {Count = 1};
		FrameBuffers = new VKFrameBuffer[imageCount];
		for (int i = 0; i < imageCount; i++)
		{
			TextureDescription colorTextureDescription = TextureDescription()
			{
				Format = swapchain.vkSurfaceFormat.format.FromVulkan(),
				ArraySize = 1,
				Faces = 1,
				MipLevels = 1,
				Depth = 1,
				Width = swapchain.SwapChainDescription.Width,
				Height = swapchain.SwapChainDescription.Height,
				SampleCount = TextureSampleCount.None,
				Flags = TextureFlags.RenderTarget
			};
			VKTexture newTexture = (VKTexture)VKTexture.FromVulkanImage(vkContext, colorTextureDescription, BackBufferImages[i]);
			VKTexture newResolvedTexture = null;
			if (sampleCount != 0)
			{
				colorTextureDescription.SampleCount = sampleCount;
				newResolvedTexture = newTexture;
				newTexture = (VKTexture)vkContext.Factory.CreateTexture(colorTextureDescription);
				ResolvedBackBufferTextures.Add(newResolvedTexture);
			}
			BackBufferTextures.Add(newTexture);
			FrameBufferAttachment frameAttachment = FrameBufferAttachment(newTexture, newResolvedTexture);
			VKFrameBuffer frameBuffer = new VKFrameBuffer(vkContext, DepthStencilTarget, .(frameAttachment), disposeAttachments: true);
			FrameBuffers[i] = frameBuffer;
		}
		base.OutputDescription = /*OutputDescription*/.CreateFromFrameBuffer(this);
	}

	/// <inheritdoc />
	public override void TransitionToIntermedialLayout(VkCommandBuffer cb)
	{
		FrameBufferAttachmentList colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		for (int i = 0; i < colorTargets.Count; i++)
		{
			FrameBufferAttachment attachment = colorTargets[i];
			(attachment.Texture as VKTexture).SetImageLayout(0, attachment.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
		}
	}

	/// <inheritdoc />
	public override void TransitionToFinalLayout(VkCommandBuffer cb)
	{
		FrameBufferAttachmentList colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		for (FrameBufferAttachment attachment in colorTargets)
		{
			(attachment.Texture as VKTexture).TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, 0, 1, 0, 1);
		}
	}

	/// <summary>
	/// Releases unmanaged and, optionally, managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	protected override void Dispose(bool disposing)
	{
		if (!disposed && disposing)
		{
			DepthTargetTexture?.Dispose();
			for (int i = 0; i < FrameBuffers.Count; i++)
			{
				FrameBuffers[i]?.Dispose();
				delete FrameBuffers[i];
			}
			delete FrameBuffers;
			if(DepthTargetTexture != null)
			{
				delete DepthTargetTexture;
			}
			if(ResolvedDepthTexture != null)
			{
				delete ResolvedDepthTexture;
			}
			for(var texture in BackBufferTextures)
			{
				delete texture;
			}
			for(var texture in ResolvedBackBufferTextures)
			{
				delete texture;
			}
		}
	}
}
