using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, normal, and texture coordinates.
/// </summary>
public struct VertexPositionNormalTexture
{
	/// <summary>
	/// Vertex positions.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex normal.
	/// </summary>
	public Vector3 Normal;

	/// <summary>
	/// The vertex texture coordinates.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="normal">The normal vector.</param>
	/// <param name="texCoord">The texture coordinate.</param>
	public this(Vector3 position, Vector3 normal, Vector2 texCoord)
	{
		Position = position;
		Normal = normal;
		TexCoord = texCoord;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal)).Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord));
	}
}
