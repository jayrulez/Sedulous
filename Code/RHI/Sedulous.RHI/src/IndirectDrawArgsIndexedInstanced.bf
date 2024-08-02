namespace Sedulous.RHI;

/// <summary>
/// Struct containing the info of an indirect indexed and instanced draw call.
/// </summary>
public struct IndirectDrawArgsIndexedInstanced
{
	/// <summary>
	/// The index count per instance.
	/// </summary>
	public uint32 IndexCountPerInstance;

	/// <summary>
	/// The instance count.
	/// </summary>
	public uint32 InstanceCount;

	/// <summary>
	/// The start index location.
	/// </summary>
	public uint32 StartIndexLocation;

	/// <summary>
	/// The base vertex location.
	/// </summary>
	public int32 BaseVertexLocation;

	/// <summary>
	/// The start instance location.
	/// </summary>
	public uint32 StartInstanceLocation;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.IndirectDrawArgsIndexedInstanced" /> struct.
	/// </summary>
	/// <param name="indexCountPerInstance"> The index count per instance.</param>
	/// <param name="instanceCount">The instance count.</param>
	/// <param name="startIndexLocation">The start index location.</param>
	/// <param name="baseVertexLocation">The base vertex location.</param>
	/// <param name="startInstanceLocation">The start instance location.</param>
	public this(uint32 indexCountPerInstance, uint32 instanceCount, uint32 startIndexLocation, int32 baseVertexLocation, uint32 startInstanceLocation)
	{
		IndexCountPerInstance = indexCountPerInstance;
		InstanceCount = instanceCount;
		StartIndexLocation = startIndexLocation;
		BaseVertexLocation = baseVertexLocation;
		StartInstanceLocation = startInstanceLocation;
	}
}
