using System;
namespace Sedulous.RHI;

/// <summary>
/// This class represents a single shader program.
/// </summary>
public abstract class Shader : GraphicsResource
{
	/// <summary>
	/// Gets the shader's description.
	/// </summary>
	public readonly ShaderDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Shader" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The shader description.</param>
	protected this(GraphicsContext context, in ShaderDescription description)
		: base(context)
	{
		Description = description;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like hash tables.
	/// </returns>
	public int GetHashCode()
	{
		return Description.GetHashCode();
	}
}
