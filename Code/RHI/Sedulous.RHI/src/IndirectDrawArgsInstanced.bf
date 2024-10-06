namespace Sedulous.RHI;

/// <summary>
/// The arguments of an instance indirect draw call.
/// </summary>
public struct IndirectDrawArgsInstanced
{
	/// <summary>
	/// The vertex count per instance.
	/// </summary>
	public uint32 VertexCountPerInstance;

	/// <summary>
	/// The count of instances.
	/// </summary>
	public uint32 InstanceCount;

	/// <summary>
	/// The starting vertex location.
	/// </summary>
	public uint32 StartVertexLocation;

	/// <summary>
	/// The starting instance location.
	/// </summary>
	public uint32 StartInstanceLocation;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.IndirectDrawArgsInstanced" /> struct.
	/// </summary>
	/// <param name="vertexCountPerInstance">The vertex count per instance.</param>
	/// <param name="instanceCount">The instance count.</param>
	/// <param name="startVertexLocation">The start vertex location.</param>
	/// <param name="startInstanceLocation">The start instance location.</param>
	public this(uint32 vertexCountPerInstance, uint32 instanceCount, uint32 startVertexLocation, uint32 startInstanceLocation)
	{
		VertexCountPerInstance = vertexCountPerInstance;
		InstanceCount = instanceCount;
		StartVertexLocation = startVertexLocation;
		StartInstanceLocation = startInstanceLocation;
	}
}
