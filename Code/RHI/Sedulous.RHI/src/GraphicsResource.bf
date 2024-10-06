using System;

namespace Sedulous.RHI;

/// <summary>
/// A resource interface that provides common actions for all resources.
/// </summary>
public abstract class GraphicsResource : IDisposable
{
	/// <summary>
	/// Indicates if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// Reference to the device context.
	/// </summary>
	public GraphicsContext Context;

	/// <summary>
	/// Gets the native pointer.
	/// </summary>
	public abstract void* NativePointer { get; }

	/// <summary>
	/// Gets a value indicating whether the graphic resource has been disposed of.
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

	/// <inheritdoc />
	public abstract void Dispose();
}
