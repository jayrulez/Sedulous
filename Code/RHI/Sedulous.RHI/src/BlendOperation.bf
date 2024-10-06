namespace Sedulous.RHI;

/// <summary>
/// RGB or alpha blending operation.
/// </summary>
public enum BlendOperation : uint8
{
	/// <summary>
	/// Adds source 1 and source 2.
	/// </summary>
	Add = 1,
	/// <summary>
	/// Subtracts source 1 from source 2.
	/// </summary>
	Substract,
	/// <summary>
	/// Subtracts source 2 from source 1.
	/// </summary>
	ReverseSubstract,
	/// <summary>
	/// Finds the minimum of source 1 and source 2.
	/// </summary>
	Min,
	/// <summary>
	/// Finds the maximum of source 1 and source 2.
	/// </summary>
	Max
}
