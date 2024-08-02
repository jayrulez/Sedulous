using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Abstract class used to have the same interface for swapchainframebuffer and framebuffer objects.
/// </summary>
public abstract class VKFrameBufferBase : FrameBuffer
{
	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKFrameBufferBase" /> class.
	/// </summary>
	/// <param name="depthTarget">The depthtarget attachment.</param>
	/// <param name="colorTargets">The colortarget attachment.</param>
	/// <param name="disposeAttachments">Whether the attachment texture should be destroy with this object or not.</param>
	public this(FrameBufferAttachment? depthTarget, FrameBufferColorAttachmentList colorTargets, bool disposeAttachments)
		: base(depthTarget, colorTargets, disposeAttachments)
	{
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKFrameBufferBase" /> class.
	/// </summary>
	public this()
	{
	}

	/// <summary>
	/// Transition framebuffer to intermediate layout.
	/// </summary>
	/// <param name="cb">The command buffer to execute this change.</param>
	public abstract void TransitionToIntermedialLayout(VkCommandBuffer cb);

	/// <summary>
	/// Transition to ready to use layout.
	/// </summary>
	/// <param name="cb">The command buffer to execute this change.</param>
	public abstract void TransitionToFinalLayout(VkCommandBuffer cb);
}
