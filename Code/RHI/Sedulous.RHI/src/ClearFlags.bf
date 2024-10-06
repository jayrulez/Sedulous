using System;

namespace Sedulous.RHI;

/// <summary>
/// Specifies the clearing modes for <see cref="T:Sedulous.RHI.FrameBuffer" />.
/// </summary>
public enum ClearFlags
{
	/// <summary>
	/// Do not clear.
	/// </summary>
	None = 0,
	/// <summary>
	/// Clears the color target.
	/// </summary>
	Target = 1,
	/// <summary>
	/// Clears the depth target.
	/// </summary>
	Depth = 2,
	/// <summary>
	/// Clears the stencil target
	/// </summary>
	Stencil = 4,
	/// <summary>
	/// Clears color, depth, and stencil targets.
	/// </summary>
	All = 7
}
