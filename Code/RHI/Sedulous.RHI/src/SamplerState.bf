using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// This class represent a sampler state.
/// </summary>
public abstract class SamplerState : GraphicsResource
{
	/// <summary>
	/// The sampler state description.
	/// </summary>
	public readonly SamplerStateDescription Description;


	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.SamplerState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The sampler state description.</param>
	protected this(GraphicsContext context, in SamplerStateDescription description)
		: base(context)
	{
		Description = description;
	}
}
