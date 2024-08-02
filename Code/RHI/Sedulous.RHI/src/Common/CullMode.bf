namespace Sedulous.RHI;

/// <summary>
/// Specifies polygon culling mode.
/// </summary>
enum CullMode : uint8
{
	/// <summary>
	/// Always draw all triangles.
	/// </summary>
	None = 1,
	/// <summary>
	/// Do not draw triangles that are front-facing.
	/// </summary>
	Front,
	/// <summary>
	/// Do not draw triangles that are back-facing.
	/// </summary>
	Back
}
