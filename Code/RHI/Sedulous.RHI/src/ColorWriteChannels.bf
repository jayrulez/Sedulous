using System;

namespace Sedulous.RHI;

/// <summary>
/// Identifies which components of each pixel of a render target are writable during blending.
/// </summary>
public enum ColorWriteChannels
{
	/// <summary>
	/// None of the data is stored.
	/// </summary>
	None = 0,
	/// <summary>
	/// Allows data to be stored in the red component.
	/// </summary>
	Red = 1,
	/// <summary>
	/// Allows data to be stored in the green component.
	/// </summary>
	Green = 2,
	/// <summary>
	/// Allows data to be stored in the blue component.
	/// </summary>
	Blue = 4,
	/// <summary>
	/// Allows data to be stored in the alpha component.
	/// </summary>
	Alpha = 8,
	/// <summary>
	/// Allows data to be stored in all components.
	/// </summary>
	All = 0xF
}
