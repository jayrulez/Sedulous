using System;

namespace Sedulous.RHI;

/// <summary>
/// This class describes the elements inside a <see cref="T:Sedulous.RHI.ResourceLayout" />.
/// </summary>
abstract class ResourceSet : IDisposable
{
	/// <summary>
	/// The resourceSet description <see cref="T:Sedulous.RHI.ResourceSetDescription" />.
	/// </summary>
	public readonly ResourceSetDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceSet" /> class.
	/// </summary>
	/// <param name="description">The resourceSet description.</param>
	public this(ref ResourceSetDescription description)
	{
		Description = description;
	}

	/// <summary>
	/// /// Frees managed and unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
