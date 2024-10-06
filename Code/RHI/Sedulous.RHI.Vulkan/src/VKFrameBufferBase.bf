using Bulkan;
using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

/// <summary>
/// Abstract class used to provide the same interface for swapchain framebuffer and framebuffer objects.
/// </summary>
public abstract class VKFrameBufferBase : FrameBuffer
{
	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKFrameBufferBase" /> class.
	/// </summary>
	/// <param name="depthTarget">The depth target attachment.</param>
	/// <param name="colorTargets">The color target attachment.</param>
	/// <param name="disposeAttachments">Indicates whether the attachment texture should be destroyed with this object or not.</param>
	public this(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments)
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
	/// Transitions the framebuffer to an intermediate layout.
	/// </summary>
	/// <param name="cb">The command buffer to execute this change.</param>
	public abstract void TransitionToIntermedialLayout(VkCommandBuffer cb);

	/// <summary>
	/// Transition to a ready-to-use layout.
	/// </summary>
	/// <param name="cb">The command buffer to execute this change.</param>
	public abstract void TransitionToFinalLayout(VkCommandBuffer cb);
}
