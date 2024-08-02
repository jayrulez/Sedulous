namespace Sedulous.RHI;

/// <summary>
/// Specifies the type of query.
/// </summary>
public enum QueryType
{
	/// <summary>
	/// Indicates the query is for high definition GPU and CPU timestamps.
	/// </summary>
	Timestamp,
	/// <summary>
	/// Indicates the query is for depth/stencil occlusion counts.
	/// </summary>
	Occlusion,
	/// <summary>
	/// Indicates the query is for a binary depth/stencil occlusion statistics.
	/// </summary>
	BinaryOcclusion
}
