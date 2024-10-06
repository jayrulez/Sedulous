namespace Sedulous.RHI;

/// <summary>
/// Specifies the element type of a <see cref="T:Sedulous.RHI.CommandQueue" />.
/// </summary>
public enum CommandQueueType
{
	/// <summary>
	/// Specifies a command buffer that the GPU can execute. A direct command list doesn't inherit any GPU state.
	/// </summary>
	Graphics = 0,
	/// <summary>
	/// Specifies a command buffer for computation.
	/// </summary>
	Compute = 2,
	/// <summary>
	/// Specifies a command buffer for copying (drawing data).
	/// </summary>
	Copy = 3
}
