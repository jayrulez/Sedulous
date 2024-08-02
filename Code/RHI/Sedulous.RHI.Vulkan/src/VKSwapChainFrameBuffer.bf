using Bulkan;
using Sedulous.RHI;
using System;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represent the swapchain FrameBuffer on Vulkan.
/// </summary>
public class VKSwapChainFrameBuffer : VKFrameBufferBase
{
	/// <summary>
	/// The colors texture array of this <see cref="T:Sedulous.RHI.Vulkan.VKFrameBuffer" />.
	/// </summary>
	public VkImage[] BackBufferImages;

	/// <summary>
	/// The depth texture of this <see cref="T:Sedulous.RHI.Vulkan.VKFrameBuffer" />.
	/// </summary>
	public VKTexture DepthTargetTexture;

	/// <summary>
	/// The array of frambuffers linked to this swapchain.
	/// </summary>
	public VKFrameBuffer[] FrameBuffers;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	/// <summary>
	/// The active backBuffer index.
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
	public override FrameBufferColorAttachmentList ColorTargets
	{
		get
		{
			return FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		}
		protected set
		{
		}
	}

	/// <summary>
	/// Gets the current framebuffer based on CurrentBackBufferIndex.
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
		BackBufferImages = new VkImage[imageCount];
		VkImage* images = BackBufferImages.Ptr;
		{
			VulkanNative.vkGetSwapchainImagesKHR(context.VkDevice, swapchain.vkSwapChain, &imageCount, images);
		}
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
		Texture depthTexture = vkContext.Factory.CreateTexture(ref depthDescription);
		Texture resolvedDepthTexture = null;
		if (sampleCount != 0)
		{
			depthDescription.SampleCount = sampleCount;
			resolvedDepthTexture = depthTexture;
			depthTexture = vkContext.Factory.CreateTexture(ref depthDescription);
		}
		DepthStencilTarget = FrameBufferAttachment(depthTexture, resolvedDepthTexture);
		//ColorTargets = new FrameBufferAttachment[1];
		ColorTargets = .(){Count = 1};
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
			Texture newTexture = VKTexture.FromVulkanImage(vkContext, ref colorTextureDescription, BackBufferImages[i]);
			Texture newResolvedTexture = null;
			if (sampleCount != 0)
			{
				colorTextureDescription.SampleCount = sampleCount;
				newResolvedTexture = newTexture;
				newTexture = vkContext.Factory.CreateTexture(ref colorTextureDescription);
			}
			FrameBufferAttachment frameAttachment = FrameBufferAttachment(newTexture, newResolvedTexture);
			VKFrameBuffer frameBuffer = new VKFrameBuffer(vkContext, DepthStencilTarget, .(frameAttachment), disposeAttachments: true);
			FrameBuffers[i] = frameBuffer;
		}
		base.OutputDescription = /*OutputDescription*/.CreateFromFrameBuffer(this);
	}

	/// <inheritdoc />
	public override void TransitionToIntermedialLayout(VkCommandBuffer cb)
	{
		FrameBufferColorAttachmentList colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		for (int i = 0; i < colorTargets.Count; i++)
		{
			FrameBufferAttachment attachment = colorTargets[i];
			(attachment.Texture as VKTexture).SetImageLayout(0, attachment.FirstSlice, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL);
		}
	}

	/// <inheritdoc />
	public override void TransitionToFinalLayout(VkCommandBuffer cb)
	{
		FrameBufferColorAttachmentList colorTargets = FrameBuffers[CurrentBackBufferIndex].ColorTargets;
		for (FrameBufferAttachment attachment in colorTargets)
		{
			(attachment.Texture as VKTexture).TransitionImageLayout(cb, VkImageLayout.VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, 0, 1, 0, 1);
		}
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
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
			}
		}
	}
}
