using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, normal and texture coordinate.
/// </summary>
public struct VertexPositionNormalColorTexture
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
	/// Vertex color.
	/// </summary>
	public Color Color;

	/// <summary>
	/// Vertex texture coordinate.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalColorTexture" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="normal">The normal.</param>
	/// <param name="color">The color.</param>
	/// <param name="texCoord">The tex coord.</param>
	public this(Vector3 position, Vector3 normal, Color color, Vector2 texCoord)
	{
		Position = position;
		Normal = normal;
		Color = color;
		TexCoord = texCoord;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionNormalColorTexture" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Normal)).Add(ElementDescription(ElementFormat.UByte4Normalized, ElementSemanticType.Color))
			.Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord));
	}
}
