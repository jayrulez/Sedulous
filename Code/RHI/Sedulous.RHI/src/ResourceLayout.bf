using System;

namespace Sedulous.RHI;

/// <summary>
/// This class represents a set of bindable resources.
/// </summary>
public abstract class ResourceLayout : IDisposable
{
	/// <summary>
	/// The description of the resource layout.
	/// </summary>
	public readonly ResourceLayoutDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Releases managed and unmanaged resources.
	/// </summary>
	public abstract void Dispose();

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceLayout" /> class.
	/// </summary>
	/// <param name="description">The resource layout description.</param>
	public this(in ResourceLayoutDescription description)
	{
		Description = description;
	}
}
