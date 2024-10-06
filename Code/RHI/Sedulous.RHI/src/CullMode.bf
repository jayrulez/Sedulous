namespace Sedulous.RHI;

/// <summary>
/// Specifies the polygon culling mode.
/// </summary>
public enum CullMode : uint8
{
	/// <summary>
	/// Always draws all triangles.
	/// </summary>
	None = 1,
	/// <summary>
	/// Does not draw front-facing triangles.
	/// </summary>
	Front,
	/// <summary>
	/// Do not draw triangles that are backfacing.
	/// </summary>
	Back
}
