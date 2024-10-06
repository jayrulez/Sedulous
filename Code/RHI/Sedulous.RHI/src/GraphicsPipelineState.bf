using System;
namespace Sedulous.RHI;

/// <summary>
/// This class represents the GPU graphics pipeline.
/// </summary>
public abstract class GraphicsPipelineState : PipelineState
{
	/// <summary>
	/// Gets the graphics pipeline state description.
	/// </summary>
	public readonly GraphicsPipelineDescription Description;

	/// <summary>
	/// Refreshes the current viewport.
	/// </summary>
	public bool InvalidatedViewport;

	/// <summary>
	/// Gets or sets a string identifying this instance. It can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.GraphicsPipelineState" /> class.
	/// </summary>
	/// <param name="description">The pipeline state description.</param>
	protected this(in GraphicsPipelineDescription description)
	{
		Description = description;
	}
}
