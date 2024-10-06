namespace Sedulous.RHI;

/// <summary>
/// The stencil operations that can be performed during depth and stencil testing.
/// </summary>
public enum StencilOperation : uint8
{
	/// <summary>
	/// Keeps the existing stencil data.
	/// </summary>
	Keep = 1,
	/// <summary>
	/// Sets the stencil data to 0.
	/// </summary>
	Zero,
	/// <summary>
	/// Sets the stencil data to the reference value.
	/// </summary>
	Replace,
	/// <summary>
	/// Increments the stencil value by 1 and clamps the result.
	/// </summary>
	IncrementSaturation,
	/// <summary>
	/// Decrements the stencil value by 1 and clamps the result.
	/// </summary>
	DecrementSaturation,
	/// <summary>
	/// Inverts the stencil data.
	/// </summary>
	Invert,
	/// <summary>
	/// Increments the stencil value by 1 and wraps the result if necessary.
	/// </summary>
	Increment,
	/// <summary>
	/// Decrements the stencil value by 1, and wraps the result if necessary.
	/// </summary>
	Decrement
}
