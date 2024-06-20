namespace Sedulous.RHI.Raytracing;

/// <summary>
/// This class represent the GPU raytracing pipeline.
/// </summary>
abstract class RaytracingPipelineState : PipelineState
{
	/// <summary>
	/// Whether the instance is disposed or not.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// Gets the raytracing pipelinestate description.
	/// </summary>
	public readonly RaytracingPipelineDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Raytracing.RaytracingPipelineState" /> class.
	/// </summary>
	/// <param name="description">The pipelineState description.</param>
	public this(ref RaytracingPipelineDescription description)
	{
		Description = description;
	}
}
