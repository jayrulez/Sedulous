using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, color, and texture coordinates.
/// </summary>
public struct VertexPositionColorTexture
{
	/// <summary>
	/// Vertex's position.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex color.
	/// </summary>
	public Color Color;

	/// <summary>
	/// Vertex texture coordinates.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColorTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="color">The color.</param>
	/// <param name="texCoord">The texture coordinates.</param>
	public this(Vector3 position, Color color, Vector2 texCoord)
	{
		Position = position;
		Color = color;
		TexCoord = texCoord;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColorTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.UByte4Normalized, ElementSemanticType.Color)).Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord));
	}
}
