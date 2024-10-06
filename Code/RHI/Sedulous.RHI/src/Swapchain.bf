using System;
using Sedulous.Platform;

namespace Sedulous.RHI;

/// <summary>
/// An instance of the SwapChain.
/// </summary>
public abstract class SwapChain : IDisposable
{
	/// <summary>
	/// Indicates if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// The device context reference.
	/// </summary>
	public GraphicsContext GraphicsContext;

	/// <summary>
	/// Gets the native SwapChain pointer. The default value is returned if the platform does not support it.
	/// </summary>
	public virtual void* NativeSwapChainPointer { get; }

	/// <summary>
	/// Gets or sets the description of the SwapChain.
	/// </summary>
	public SwapChainDescription SwapChainDescription { get; protected set; }

	/// <summary>
	/// Gets or sets the swap chain framebuffer.
	/// </summary>
	public FrameBuffer FrameBuffer { get; protected set; }

	/// <summary>
	/// Gets or sets a value indicating whether vertical synchronization is enabled or not.
	/// </summary>
	public virtual bool VerticalSync { get; set; }

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugging tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// The swapchain surface information has changed.
	/// </summary>
	/// <param name="surfaceInfo">The surface information.</param>
	public abstract void RefreshSurfaceInfo(SurfaceInfo surfaceInfo);

	/// <summary>
	/// Resizes the SwapChain.
	/// </summary>
	/// <param name="width">The new width.</param>
	/// <param name="height">The new height.</param>
	public abstract void ResizeSwapChain(uint32 width, uint32 height);

	/// <summary>
	/// Gets the current framebuffer texture.
	/// </summary>
	/// <returns>Framebuffer texture.</returns>
	public abstract Texture GetCurrentFramebufferTexture();

	/// <summary>
	/// This method is invoked when the frame starts.
	/// </summary>
	public virtual void InitFrame()
	{
	}

	/// <summary>
	/// Presents a rendered image to the user.
	/// </summary>
	public abstract void Present();

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
