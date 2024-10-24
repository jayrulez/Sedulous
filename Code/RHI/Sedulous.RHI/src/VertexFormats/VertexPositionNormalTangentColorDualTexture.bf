using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, normal, and texture coordinates.
/// </summary>
public struct VertexPositionNormalTangentColorDualTexture
{
	/// <summary>
	/// Vertex position.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex normal vector.
	/// </summary>
	public Vector3 Normal;

	/// <summary>
	/// Vertex normal.
	/// </summary>
	public Vector3 Tangent;

	/// <summary>
	/// Vertex color.
	/// </summary>
	public Color Color;

	/// <summary>
	/// Vertex texture coordinates.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex texture coordinates.
	/// </summary>
	public Vector2 TexCoord2;

	/// <summary>
	/// Represents the vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTangentColorDualTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="normal">The normal.</param>
	/// <param name="tangent">The tangent.</param>
	/// <param name="color">The color.</param>
	/// <param name="texCoord">The texture coordinate.</param>
	/// <param name="texCoord2">The second texture coordinate.</param>
	public this(Vector3 position, Vector3 normal, Vector3 tangent, Color color, Vector2 texCoord, Vector2 texCoord2)
	{
		Position = position;
		Normal = normal;
		Tangent = tangent;
		Color = color;
		TexCoord = texCoord;
		TexCoord2 = texCoord2;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTangentColorDualTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Tangent))
			.Add(ElementDescription(ElementFormat.UByte4Normalized, ElementSemanticType.Color))
			.Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord))
			.Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord, 1));
	}
}
