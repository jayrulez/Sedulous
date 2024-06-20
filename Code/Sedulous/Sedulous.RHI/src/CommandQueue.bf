using System;

namespace Sedulous.RHI;

/// <summary>
/// A pool of <see cref="M:Sedulous.RHI.CommandQueue.CommandBuffer" />.
/// </summary>
abstract class CommandQueue : IDisposable
{
	/// <summary>
	/// The command buffer array size.
	/// </summary>
	public const int32 CommandBufferArraySize = 64;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Gets the next <see cref="M:Sedulous.RHI.CommandQueue.CommandBuffer" />.
	/// </summary>
	/// <returns>The CommandBuffer.</returns>
	public abstract CommandBuffer CommandBuffer();

	/// <summary>
	/// Submits a CommandBuffer list to be executed by the GPU.
	/// </summary>
	public abstract void Submit();

	/// <summary>
	/// Wait for all command buffers are executed.
	/// </summary>
	public abstract void WaitIdle();

	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
