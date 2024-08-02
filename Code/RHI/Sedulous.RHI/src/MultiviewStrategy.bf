namespace Sedulous.RHI;

/// <summary>
/// Indicates the strategy supported to render multiple views.
/// </summary>
public enum MultiviewStrategy
{
	/// <summary>
	/// Multiview is not supported in this device.
	/// </summary>
	Unsupported,
	/// <summary>
	/// Multiview is specified by output vertex RenderTargetIndex semantic, in combination with DrawInstancing.
	/// </summary>
	/// <remarks>
	/// Currently only supported on DX11
	/// </remarks>
	RenderTargetIndex,
	/// <summary>
	/// Multiview is specified using a vertex shader input ViewID. Additionally, you need to specify how many views do you want to render in the Framebuffer.
	/// </summary>
	/// <remarks>
	/// Supported on OpenGLES 3.0 or greater, WebGL2, Vulkan and DX12 in SM6.1.
	/// </remarks>
	ViewIndex
}
