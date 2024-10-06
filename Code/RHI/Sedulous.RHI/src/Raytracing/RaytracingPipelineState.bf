namespace Sedulous.RHI.Raytracing;

/// <summary>
/// This class represents the GPU ray tracing pipeline.
/// </summary>
public abstract class RaytracingPipelineState : PipelineState
{
	/// <summary>
	/// Indicates whether the instance is disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// Gets the ray tracing pipeline state description.
	/// </summary>
	public readonly RaytracingPipelineDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Raytracing.RaytracingPipelineState" /> class.
	/// </summary>
	/// <param name="description">The pipeline state description.</param>
	public this(in RaytracingPipelineDescription description)
	{
		Description = description;
	}
}
