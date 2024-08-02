namespace Sedulous.RHI;

/// <summary>
/// The stencil operations that can be performed during depth-stencil testing.
/// </summary>
public enum StencilOperation : uint8
{
	/// <summary>
	/// Keep the existing stencil data.
	/// </summary>
	Keep = 1,
	/// <summary>
	/// Set the stencil data to 0.
	/// </summary>
	Zero,
	/// <summary>
	/// Set the stencil data to the reference value.
	/// </summary>
	Replace,
	/// <summary>
	/// Increment the stencil value by 1, and clamp the result.
	/// </summary>
	IncrementSaturation,
	/// <summary>
	/// Decrement the stencil value by 1, and clamp the result.
	/// </summary>
	DecrementSaturation,
	/// <summary>
	/// Invert the stencil data.
	/// </summary>
	Invert,
	/// <summary>
	/// Increment the stencil value by 1, and wrap the result if necessary.
	/// </summary>
	Increment,
	/// <summary>
	/// Decrement the stencil value by 1, and wrap the result if necessary.
	/// </summary>
	Decrement
}
