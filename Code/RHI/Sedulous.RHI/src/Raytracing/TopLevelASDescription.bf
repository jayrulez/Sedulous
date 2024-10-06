namespace Sedulous.RHI.Raytracing;

/// <summary>
/// The top-level acceleration structure description.
/// </summary>
public struct TopLevelASDescription
{
	/// <summary>
	/// The update flags.
	/// </summary>
	public AccelerationStructureFlags Flags;

	/// <summary>
	/// The instance buffer's offset.
	/// </summary>
	public uint32 Offset;

	/// <summary>
	/// The array of instance descriptions.
	/// </summary>
	public AccelerationStructureInstance[] Instances;
}
