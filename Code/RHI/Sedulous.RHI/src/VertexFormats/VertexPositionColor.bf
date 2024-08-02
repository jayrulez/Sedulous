using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// A vertex format structure containing vertex position and color.
/// </summary>
public struct VertexPositionColor
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
	/// Vertex format of this vertex.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColor" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	/// <param name="color">The color.</param>
	public this(Vector3 position, Color color)
	{
		Position = position;
		Color = color;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPositionColor" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription().Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position)).Add(ElementDescription(ElementFormat.UByte4Normalized, ElementSemanticType.Color));
	}
}
