using System;
namespace Sedulous.RHI;

/// <summary>
/// This class represent the GPU graphics pipeline.
/// </summary>
abstract class GraphicsPipelineState : PipelineState
{
	/// <summary>
	/// Gets the graphics pipelinestate description.
	/// </summary>
	public readonly GraphicsPipelineDescription Description;

	/// <summary>
	/// Invalidates the current viewport.
	/// </summary>
	public bool InvalidatedViewport;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.GraphicsPipelineState" /> class.
	/// </summary>
	/// <param name="description">The pipelineState description.</param>
	protected this(ref GraphicsPipelineDescription description)
	{
		Description = description;
	}
}
