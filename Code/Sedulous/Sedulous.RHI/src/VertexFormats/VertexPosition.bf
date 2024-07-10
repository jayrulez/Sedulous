using Sedulous.Foundation.Mathematics;
namespace Sedulous.RHI.VertexFormats;

/// <summary>
/// A vertex format structure containing vertex position and color.
/// </summary>
struct VertexPosition
{
	/// <summary>
	/// Vertex position.
	/// </summary>
	public Vector3 Position;

	/// <summary>
	/// Vertex format of this vertex.
	/// </summary>
	public static readonly LayoutDescription VertexFormat ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPosition" /> struct.
	/// </summary>
	/// <param name="position">The position.</param>
	public this(Vector3 position)
	{
		Position = position;
	}

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.VertexFormats.VertexPosition" /> struct.
	/// </summary>
	static this()
	{
		VertexFormat = new LayoutDescription()
			.Add(ElementDescription(ElementFormat.Float3, ElementSemanticType.Position));
	}
}