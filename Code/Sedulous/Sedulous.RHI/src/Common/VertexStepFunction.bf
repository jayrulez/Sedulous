namespace Sedulous.RHI;

/// <summary>
/// The frequency with which the vertex function fetches attributes data.
/// </summary>
enum VertexStepFunction
{
	/// <summary>
	/// Input data is per-vertex data.
	/// </summary>
	PerVertexData,
	/// <summary>
	/// Input data is per-instance data.
	/// </summary>
	PerInstanceData
}
