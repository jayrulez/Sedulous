namespace Sedulous.RHI;

/// <summary>
/// Specifies polygon depth boas.
/// </summary>
enum DepthBias : uint8
{
	/// <summary>
	/// Zero depth bias
	/// </summary>
	Zero,
	/// <summary>
	/// Positive depth bias
	/// </summary>
	Positive,
	/// <summary>
	/// Negative depth bias
	/// </summary>
	Negative
}