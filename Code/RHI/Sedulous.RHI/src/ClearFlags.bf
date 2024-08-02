using System;

namespace Sedulous.RHI;

/// <summary>
/// Specifies <see cref="T:Sedulous.RHI.FrameBuffer" /> clearing modes.
/// </summary>
public enum ClearFlags
{
	/// <summary>
	/// Do not clear.
	/// </summary>
	None = 0,
	/// <summary>
	/// Clear color target.
	/// </summary>
	Target = 1,
	/// <summary>
	/// Clear depth target.
	/// </summary>
	Depth = 2,
	/// <summary>
	/// Clear the stencil target
	/// </summary>
	Stencil = 4,
	/// <summary>
	/// Clear color, depth and stencil target
	/// </summary>
	All = 7
}
