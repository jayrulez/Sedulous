using System;
namespace Sedulous.RHI;

/// <summary>
/// This class represents a buffer resource.
/// </summary>
public abstract class Buffer : GraphicsResource
{
	/// <summary>
	/// Counter that represents every time this buffer is updated.
	/// </summary>
	private int32 updateCounter;

	/// <summary>
	/// Gets the buffer description.
	/// </summary>
	public readonly BufferDescription Description;

	/// <summary>
	/// Gets the counter that increments every time this buffer is updated.
	/// </summary>
	public int32 UpdateCounter => updateCounter;

	/// <summary>
	/// Gets or sets a string identifying this instance. It can be used in graphics debugging tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Buffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The buffer description.</param>
	protected this(GraphicsContext context, in BufferDescription description)
		: base(context)
	{
		Description = description;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Buffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	protected this(GraphicsContext context)
		: base(context)
	{
	}

	/// <summary>
	/// Increments the update counter.
	/// </summary>
	internal void Touch()
	{
		updateCounter++;
	}
}
