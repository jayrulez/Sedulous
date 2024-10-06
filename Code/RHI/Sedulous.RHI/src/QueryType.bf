namespace Sedulous.RHI;

/// <summary>
/// Specifies the type of the query.
/// </summary>
public enum QueryType
{
	/// <summary>
	/// Indicates that the query is for high-definition GPU and CPU timestamps.
	/// </summary>
	Timestamp,
	/// <summary>
	/// Indicates that the query is for depth/stencil occlusion counts.
	/// </summary>
	Occlusion,
	/// <summary>
	/// Indicates that the query is for binary depth/stencil occlusion statistics.
	/// </summary>
	BinaryOcclusion
}
