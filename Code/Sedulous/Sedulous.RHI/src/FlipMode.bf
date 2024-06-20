using System;

namespace Sedulous.RHI;

/// <summary>
/// Indicates the flip mode of a sprite, billboard, etc...
/// </summary>
//[Flags]
enum FlipMode : uint8
{
	/// <summary>
	/// No flip.
	/// </summary>
	None = 0,
	/// <summary>
	/// Horizontal flip.
	/// </summary>
	FlipHorizontally = 1,
	/// <summary>
	/// Vertical flip.
	/// </summary>
	FlipVertically = 2
}
