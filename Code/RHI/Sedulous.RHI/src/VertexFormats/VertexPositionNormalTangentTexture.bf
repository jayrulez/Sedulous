using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, normal and texture coordinate.
/// </summary>
public struct VertexPositionNormalTangentTexture
{
	/// <summary>
	/// Vertex position.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex normal.
	/// </summary>
	public Vector3 Normal;

	/// <summary>
	/// Vertex normal.
	/// </summary>
	public Vector3 Tangent;

	/// <summary>
	/// Vertex texture coordinate.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTangentTexture" /> struct.
	/// </summary>
	/// <param name="position">The vertex position.</param>
	/// <param name="normal">The vertex normal.</param>
	/// <param name="tangent">The vertex tangent.</param>
	/// <param name="texCoord">the vertex texCoord.</param>
	public this(Vector3 position, Vector3 normal, Vector3 tangent, Vector2 texCoord)
	{
		Position = position;
		Normal = normal;
		Tangent = tangent;
		TexCoord = texCoord;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTangentTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Tangent))
			.Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord));
	}
}
