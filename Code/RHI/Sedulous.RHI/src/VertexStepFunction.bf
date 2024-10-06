namespace Sedulous.RHI;

/// <summary>
/// The frequency with which the vertex function fetches attribute data.
/// </summary>
public enum VertexStepFunction
{
	/// <summary>
	/// The input data is per-vertex data.
	/// </summary>
	PerVertexData,
	/// <summary>
	/// Input data is instance-specific data.
	/// </summary>
	PerInstanceData
}
