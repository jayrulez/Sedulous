using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, normal, and texture coordinates.
/// </summary>
public struct VertexPositionNormalDualTexture
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
	/// Vertex texture coordinates.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Second vertex's texture coordinate.
	/// </summary>
	public Vector2 TexCoord2;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalDualTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="normal">The normal.</param>
	/// <param name="texCoord">The first texture coordinate.</param>
	/// <param name="texCoord2">The second texture coordinate.</param>
	public this(Vector3 position, Vector3 normal, Vector2 texCoord, Vector2 texCoord2)
	{
		Position = position;
		Normal = normal;
		TexCoord = texCoord;
		TexCoord2 = texCoord2;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalDualTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal)).Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord))
			.Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord, 1));
	}
}
