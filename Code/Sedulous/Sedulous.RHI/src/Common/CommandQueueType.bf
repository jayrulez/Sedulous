namespace Sedulous.RHI;

/// <summary>
/// Specifies the elements type of a CommandQueue.
/// </summary>
enum CommandQueueType
{
	/// <summary>
	/// Specifies a command buffer that the GPU can execute. A direct command list doesn't inherit any GPU state.
	/// </summary>
	Graphics = 0,
	/// <summary>
	/// Specifies a command buffer for computing.
	/// </summary>
	Compute = 2,
	/// <summary>
	/// Specifies a command buffer for copying (drawing).
	/// </summary>
	Copy = 3
}
