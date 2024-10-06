using System;

namespace Sedulous.RHI;

/// <summary>
/// This class represents the GPU graphics pipeline.
/// </summary>
public abstract class PipelineState : IDisposable
{
	/// <summary>
	/// Performs tasks defined by the application associated with freeing, releasing, or resetting unmanaged resources.
	/// </summary>
	public abstract void Dispose();
}
