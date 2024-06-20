using System;

namespace Sedulous.RHI;

/// <summary>
/// SwapChain instance.
/// </summary>
abstract class SwapChain : IDisposable
{
	/// <summary>
	/// Holds if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// The device context refenrece.
	/// </summary>
	public GraphicsContext GraphicsContext;

	/// <summary>
	/// Gets the native SwapChain pointer. Default value is returned if the platform does not support it.
	/// </summary>
	public virtual void* NativeSwapChainPointer { get; }

	/// <summary>
	/// Gets or sets the SwapChain description.
	/// </summary>
	public SwapChainDescription SwapChainDescription { get; protected set; }

	/// <summary>
	/// Gets or sets the swapchain Framebuffer.
	/// </summary>
	public FrameBuffer FrameBuffer { get; protected set; }

	/// <summary>
	/// Gets or sets a value indicating whether vertical synchronization is enable or not.
	/// </summary>
	public virtual bool VerticalSync { get; set; }

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// The swapchain surface info has changed.
	/// </summary>
	/// <param name="surfaceInfo">The surface info.</param>
	public abstract void RefreshSurfaceInfo(SurfaceInfo surfaceInfo);

	/// <summary>
	/// Resize SwapChain.
	/// </summary>
	/// <param name="width">New width.</param>
	/// <param name="height">New height.</param>
	public abstract void ResizeSwapChain(uint32 width, uint32 height);

	/// <summary>
	/// Gets the current Framebuffer Texture.
	/// </summary>
	/// <returns>Framebuffer texture.</returns>
	public abstract Texture GetCurrentFramebufferTexture();

	/// <summary>
	/// This methid is invoked when the frame is start..
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
