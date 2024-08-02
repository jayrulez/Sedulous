namespace Sedulous.RHI;

/// <summary>
/// Abstract class that offers the capabilities of the graphics context.
/// </summary>
public abstract class GraphicsContextCapabilities
{
	/// <summary>
	/// Gets a value indicating whether this graphics context support compute shaders.
	/// </summary>
	public abstract bool IsComputeShaderSupported { get; }

	/// <summary>
	/// Gets a value indicating whether we need to flip projection matrix on Render Target.
	/// </summary>
	public abstract bool FlipProjectionRequired { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context uses row major matrices by default.
	/// </summary>
	public abstract MatrixMajorness MatrixMajorness { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports Multi Render Target (MRT).
	/// </summary>
	public abstract bool IsMRTSupported { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports Shadow Maps.
	/// </summary>
	public abstract bool IsShadowMapSupported { get; }

	/// <summary>
	/// Gets the depth range in clip space.
	/// </summary>
	public abstract ClipDepth ClipDepth { get; }

	/// <summary>
	/// Gets the multiview strategy supported by this graphic context.
	/// </summary>
	public abstract MultiviewStrategy MultiviewStrategy { get; }

	/// <summary>
	/// Gets a value indicating whether this graphics context supports Raytracing.
	/// </summary>
	public abstract bool IsRaytracingSupported { get; }
}
