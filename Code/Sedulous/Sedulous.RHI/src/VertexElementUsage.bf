namespace Sedulous.RHI;

/// <summary>
/// Specifies the vertex element usage.
/// </summary>
enum VertexElementUsage
{
	/// <summary>
	/// Used for position.
	/// </summary>
	Position,
	/// <summary>
	/// Used for color.
	/// </summary>
	Color,
	/// <summary>
	/// Used for texture coordinate.
	/// </summary>
	TextureCoordinate,
	/// <summary>
	/// Used for normal.
	/// </summary>
	Normal,
	/// <summary>
	/// Used for binormal.
	/// </summary>
	Binormal,
	/// <summary>
	/// Used for tangent.
	/// </summary>
	Tangent,
	/// <summary>
	/// Used for blend indices.
	/// </summary>
	BlendIndices,
	/// <summary>
	/// Used for blend weights.
	/// </summary>
	BlendWeight,
	/// <summary>
	/// Used for depth.
	/// </summary>
	Depth,
	/// <summary>
	/// Used for fog.
	/// </summary>
	Fog,
	/// <summary>
	/// Used for point size.
	/// </summary>
	PointSize,
	/// <summary>
	/// Used for sample.
	/// </summary>
	Sample,
	/// <summary>
	/// Used for tesellation factor.
	/// </summary>
	TessellateFactor
}
