using System;

namespace Sedulous.RHI;

static
{
	public static int GetHashCode(this ResourceLayout[] array)
	{
		int hashCode = 0;

		return hashCode;
	}
}

/// <summary>
/// This class represent a set of bindable resources.
/// </summary>
abstract class ResourceLayout : IDisposable
{
	/// <summary>
	/// The resource layout description.
	/// </summary>
	public readonly ResourceLayoutDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Frees managed and unmanaged resources.
	/// </summary>
	public abstract void Dispose();

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceLayout" /> class.
	/// </summary>
	/// <param name="description">The resource layout description.</param>
	public this(ref ResourceLayoutDescription description)
	{
		Description = description;
	}
}
