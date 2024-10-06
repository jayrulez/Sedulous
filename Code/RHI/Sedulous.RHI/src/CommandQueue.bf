using System;

namespace Sedulous.RHI;

/// <summary>
/// A pool of <see cref="M:Sedulous.RHI.CommandQueue.CommandBuffer" /> objects.
/// </summary>
public abstract class CommandQueue : IDisposable
{
	/// <summary>
	/// Size of the command buffer array.
	/// </summary>
	public const int32 CommandBufferArraySize = 64;

	/// <summary>
	/// Gets or sets a string identifying this instance. It can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Gets the next <see cref="M:Sedulous.RHI.CommandQueue.CommandBuffer" />.
	/// </summary>
	/// <returns>A CommandBuffer.</returns>
	public abstract CommandBuffer CommandBuffer();

	/// <summary>
	/// Submits a list of <see cref="M:Sedulous.RHI.CommandQueue.CommandBuffer" /> to be executed by the GPU.
	/// </summary>
	public abstract void Submit();

	/// <summary>
	/// Wait for all command buffers to be executed.
	/// </summary>
	public abstract void WaitIdle();

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
