namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Acceleration Structure AABB Geometry.
/// </summary>
class AccelerationStructureAABBs : AccelerationStructureGeometry
{
	/// <summary>
	/// Number of AABB in buffer.
	/// </summary>
	public uint64 Count;

	/// <summary>
	/// Buffer with AABB data.
	/// </summary>
	public Buffer AABBs;

	/// <summary>
	/// AABB stride size.
	/// </summary>
	public uint32 Stride;

	/// <summary>
	/// AABB offset.
	/// </summary>
	public uint32 Offset;
}
