namespace Sedulous.RHI;

/// <summary>
/// Abstract class that provides the capabilities of the graphics context.
/// </summary>
public abstract class GraphicsContextCapabilities
{
	/// <summary>
	/// Gets a value indicating whether this graphics context supports compute shaders.
	/// </summary>
	public abstract bool IsComputeShaderSupported { get; }

	/// <summary>
	/// Gets a value indicating whether we need to flip the projection matrix on the render target.
	/// </summary>
	public abstract bool FlipProjectionRequired { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context uses row-major matrices by default.
	/// </summary>
	public abstract MatrixMajorness MatrixMajorness { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports Multiple Render Targets (MRTs).
	/// </summary>
	public abstract bool IsMRTSupported { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports shadow maps.
	/// </summary>
	public abstract bool IsShadowMapSupported { get; }

	/// <summary>
	/// Gets the depth range in clip space.
	/// </summary>
	public abstract ClipDepth ClipDepth { get; }

	/// <summary>
	/// Gets the multi-view strategy supported by this graphics context.
	/// </summary>
	public abstract MultiviewStrategy MultiviewStrategy { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports raytracing.
	/// </summary>
	public abstract bool IsRaytracingSupported { get; }
}
