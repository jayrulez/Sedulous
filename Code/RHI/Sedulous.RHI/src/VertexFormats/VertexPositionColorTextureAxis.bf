using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// Represents a vertex with position, color, texture coordinate and axis size.
/// </summary>
public struct VertexPositionColorTextureAxis
{
	/// <summary>
	/// Vertex position.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex color.
	/// </summary>
	public Color Color;

	/// <summary>
	/// Vertex texture coordinate.
	/// </summary>
	public Vector2 TexCoord;

	/// <summary>
	/// Vertex axis size.
	/// </summary>
	public Vector4 AxisSize;

	/// <summary>
	/// Vertex format.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColorTextureAxis" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="color">The color.</param>
	/// <param name="texCoord">The texture coordinate.</param>
	/// <param name="axisSize">The axis size.</param>
	public this(Vector3 position, Color color, Vector2 texCoord, Vector4 axisSize)
	{
		Position = position;
		Color = color;
		TexCoord = texCoord;
		AxisSize = axisSize;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColorTextureAxis" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.UByte4Normalized, ElementSemanticType.Color)).Add(ElementDescription(ElementFormat.Float2, ElementSemanticType.TexCoord))
			.Add(ElementDescription(ElementFormat.Float4, ElementSemanticType.TexCoord, 1));
	}
}
