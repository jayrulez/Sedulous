using System;

namespace Sedulous.RHI;

/// <summary>
/// A resource interface provides common actions on all resources.
/// </summary>
abstract class GraphicsResource : IDisposable
{
	/// <summary>
	/// Holds if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// The device context reference.
	/// </summary>
	public GraphicsContext Context;

	/// <summary>
	/// Gets the native pointer.
	/// </summary>
	public abstract void* NativePointer { get; }

	/// <summary>
	/// Gets a value indicating whether the graphic resource has been disposed.
	/// </summary>
	public bool Disposed => disposed;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.GraphicsResource" /> class.
	/// </summary>
	/// <param name="context">The device context.</param>
	protected this(GraphicsContext context)
	{
		Context = context;
	}

	/// <summary>
	/// Dispose this instance.
	/// </summary>
	public abstract void Dispose();
}
