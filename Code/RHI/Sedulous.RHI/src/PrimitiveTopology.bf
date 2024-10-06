namespace Sedulous.RHI;

/// <summary>
/// Defines how the pipeline interprets vertex data bound to the input-assembler stage.
/// These primitive topology values determine how the vertex data is rendered on the screen.
/// </summary>
public enum PrimitiveTopology
{
	/// <summary>
	/// The IA stage has not been initialized with a primitive topology.
	/// </summary>
	Undefined = 0,
	/// <summary>
	/// Interprets the vertex data as a list of points.
	/// </summary>
	PointList = 1,
	/// <summary>
	/// Interprets the vertex data as a list of lines.
	/// </summary>
	LineList = 2,
	/// <summary>
	/// Interprets the vertex data as a line strip.
	/// </summary>
	LineStrip = 3,
	/// <summary>
	/// Interprets the vertex data as a list of triangles.
	/// </summary>
	TriangleList = 4,
	/// <summary>
	/// Interprets the vertex data as a triangle strip.
	/// </summary>
	TriangleStrip = 5,
	/// <summary>
	/// Interprets the vertex data as a list of lines with adjacency data.
	/// </summary>
	LineListWithAdjacency = 10,
	/// <summary>
	/// Interprets the vertex data as a line strip with adjacency data.
	/// </summary>
	LineStripWithAdjacency = 11,
	/// <summary>
	/// Interprets the vertex data as a list of triangles with adjacency data.
	/// </summary>
	TriangleListWithAdjacency = 12,
	/// <summary>
	/// Interprets the vertex data as a triangle strip with adjacency data.
	/// </summary>
	TriangleStripWithAdjacency = 13,
	/// <summary>
	/// Interprets the vertex data as a patch list.
	/// </summary>
	Patch_List = 33
}
