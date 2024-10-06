using System;

namespace Sedulous.RHI;

/// <summary>
/// This class describes the elements within a <see cref="T:Sedulous.RHI.ResourceLayout" />.
/// </summary>
public abstract class ResourceSet : IDisposable
{
	/// <summary>
	/// The description of the ResourceSet <see cref="T:Sedulous.RHI.ResourceSetDescription" />.
	/// </summary>
	public readonly ResourceSetDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceSet" /> class.
	/// </summary>
	/// <param name="description">The <see cref="T:Sedulous.RHI.ResourceSet" /> description.</param>
	public this(in ResourceSetDescription description)
	{
		Description = description;
	}

	/// <inheritdoc />
	public abstract void Dispose();
}
