using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with a position and a texture coordinate.
/// </summary>
public struct VertexPositionTexture
{
	/// <summary>
	/// Position of the vertex.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// The vertex texture coordinate.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="texCoord">The texture coordinate.</param>
	public this(Vector3 position, Vector2 texCoord)
	{
		Position = position;
		TexCoord = texCoord;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord));
	}
}
