namespace Sedulous.RHI;

/// <summary>
/// Specifies the usage of the vertex element.
/// </summary>
public enum VertexElementUsage
{
	/// <summary>
	/// Used for positioning.
	/// </summary>
	Position,
	/// <summary>
	/// Used for color.
	/// </summary>
	Color,
	/// <summary>
	/// Used for texture coordinates.
	/// </summary>
	TextureCoordinate,
	/// <summary>
	/// Used for normal operation.
	/// </summary>
	Normal,
	/// <summary>
	/// Used for the binormal.
	/// </summary>
	Binormal,
	/// <summary>
	/// Used for tangents.
	/// </summary>
	Tangent,
	/// <summary>
	/// Used for blending indices.
	/// </summary>
	BlendIndices,
	/// <summary>
	/// Used for blending weights.
	/// </summary>
	BlendWeight,
	/// <summary>
	/// Used for depth measurement.
	/// </summary>
	Depth,
	/// <summary>
	/// Used for fog.
	/// </summary>
	Fog,
	/// <summary>
	/// Used for specifying the point size.
	/// </summary>
	PointSize,
	/// <summary>
	/// Used as a sample.
	/// </summary>
	Sample,
	/// <summary>
	/// Used for tessellation factor.
	/// </summary>
	TessellateFactor
}
