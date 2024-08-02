using Sedulous.RHI;

namespace Sedulous.RHI.Vulkan;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;

/// <summary>
/// The OpenGL capabilities.
/// </summary>
public class VKCapabilities : GraphicsContextCapabilities
{
	private VKGraphicsContext vKGraphicsContext;

	/// <inheritdoc />
	public override bool IsComputeShaderSupported => true;

	/// <inheritdoc />
	public override bool FlipProjectionRequired => false;

	/// <inheritdoc />
	public override MatrixMajorness MatrixMajorness => /*MatrixMajorness*/.RowMajor;

	/// <inheritdoc />
	public override bool IsMRTSupported => true;

	/// <inheritdoc />
	public override bool IsShadowMapSupported => true;

	/// <inheritdoc />
	public override ClipDepth ClipDepth => /*ClipDepth*/.ZeroToOne;

	/// <inheritdoc />
	public override MultiviewStrategy MultiviewStrategy
	{
		get
		{
			if (vKGraphicsContext.DeviceExtensionsToEnable.Contains("VK_KHR_multiview"))
			{
				return /*MultiviewStrategy*/.ViewIndex;
			}
			return /*MultiviewStrategy*/.Unsupported;
		}
	}

	/// <inheritdoc />
	public override bool IsRaytracingSupported => vKGraphicsContext.raytracingSupported;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKCapabilities" /> class.
	/// </summary>
	/// <param name="vkGraphicsContext">The Vulkan Graphic context.</param>
	public this(VKGraphicsContext vkGraphicsContext)
	{
		vKGraphicsContext = vkGraphicsContext;
	}
}
