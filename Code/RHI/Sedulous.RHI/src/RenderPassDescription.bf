using System;

namespace Sedulous.RHI;

/// <summary>
/// Structure specifying render pass begin info.
/// </summary>
public struct RenderPassDescription
{
	/// <summary>
	/// The frameBuffer containing the attachments that are used with the renderpass.
	/// </summary>
	public FrameBuffer FrameBuffer;

	/// <summary>
	/// Array that contains clear values for each attachment.
	/// </summary>
	public ClearValue ClearValue;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.RenderPassDescription" /> struct.
	/// </summary>
	/// <param name="frameBuffer">The frameBuffer containing the attachments that are used with the renderpass.</param>
	/// <param name="clearValue">That contains clear values for each attachment.</param>
	public this(FrameBuffer frameBuffer, ClearValue clearValue)
	{
		if (/*frameBuffer.ColorTargets != null && clearValue.ColorValues != null &&*/ frameBuffer.ColorTargets.Count != clearValue.ColorValues.Count)
		{
			Runtime.ArgumentError(scope $"The number of framebuffer color targets {frameBuffer.ColorTargets.Count} must be equal the number of clear color values {clearValue.ColorValues.Count}");
		}
		FrameBuffer = frameBuffer;
		ClearValue = clearValue;
	}
}
