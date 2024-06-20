using System;

namespace Sedulous.RHI;

/// <summary>
/// This class represent the GPU graphics pipeline.
/// </summary>
abstract class PipelineState : IDisposable
{
	/// <summary>
	/// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
