namespace Sedulous.RHI;

/// <summary>
/// RGB or alpha blending operation.
/// </summary>
enum BlendOperation : uint8
{
	/// <summary>
	/// Add source 1 and source 2.
	/// </summary>
	Add = 1,
	/// <summary>
	/// Subtract source 1 from source 2.
	/// </summary>
	Substract,
	/// <summary>
	/// Subtract source 2 from source 1.
	/// </summary>
	ReverseSubstract,
	/// <summary>
	/// Find the minimum of source 1 and source 2.
	/// </summary>
	Min,
	/// <summary>
	/// Find the maximum of source 1 and source 2.
	/// </summary>
	Max
}
