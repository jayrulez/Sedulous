using System;

namespace Sedulous.RHI;

/// <summary>
/// Indicates the flip mode of a sprite, billboard, etc.
/// </summary>
public enum FlipMode : uint8
{
	/// <summary>
	/// No flipping.
	/// </summary>
	None = 0,
	/// <summary>
	/// Horizontally flips the image.
	/// </summary>
	FlipHorizontally = 1,
	/// <summary>
	/// Vertically flips the image.
	/// </summary>
	FlipVertically = 2
}
