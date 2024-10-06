using System;
namespace Sedulous.RHI;

/// <summary>
/// This class represents the GPU graphics pipeline.
/// </summary>
public abstract class ComputePipelineState : PipelineState
{
	/// <summary>
	/// Gets the compute pipeline state description.
	/// </summary>
	public readonly ComputePipelineDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugging tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ComputePipelineState" /> class.
	/// </summary>
	/// <param name="description">The pipeline state description.</param>
	protected this(in ComputePipelineDescription description)
	{
		Description = description;
	}
}
