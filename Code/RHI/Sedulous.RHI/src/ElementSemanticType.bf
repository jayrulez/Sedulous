namespace Sedulous.RHI;

/// <summary>
/// The semantic meaning of a vertex element.
/// </summary>
public enum ElementSemanticType : uint8
{
	/// <summary>
	/// Describes a position.
	/// </summary>
	Position,
	/// <summary>
	/// Describes a texture coordinate.
	/// </summary>
	TexCoord,
	/// <summary>
	/// Describes a normal vector.
	/// </summary>
	Normal,
	/// <summary>
	/// Describes a tangent vector.
	/// </summary>
	Tangent,
	/// <summary>
	/// Describe a binormal vector.
	/// </summary>
	Binormal,
	/// <summary>
	/// Describe a color.
	/// </summary>
	Color,
	/// <summary>
	/// Blend indices
	/// </summary>
	BlendIndices,
	/// <summary>
	/// Blend weights
	/// </summary>
	BlendWeight,
	/// <summary>
	/// Auxiliar value to count all semantics
	/// </summary>
	Count
}
