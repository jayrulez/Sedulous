using Sedulous.Foundation.Mathematics;
namespace Sedulous.RHI.Raytracing;

/// <summary>
/// This data structure is used in GPU memory during acceleration structure build.
/// This struct definition is useful if generating instance data on the CPU first then uploading to the GPU.
/// But apps are also free to generate instance descriptions directly into GPU memory from compute shaders for instance, following the same layout.
/// </summary>
struct AccelerationStructureInstance
{
	/// <summary>
	/// Flags from <see cref="T:Sedulous.RHI.Raytracing.AccelerationStructureInstanceFlags" /> to apply to the instance.
	/// </summary>
	public AccelerationStructureInstanceFlags Flags;

	/// <summary>
	/// A 4x4 transform matrix in row major layout representing the instance-to-world transformation.
	/// </summary>
	public Matrix Transform4x4;

	/// <summary>
	/// An arbitrary 24-bit value that can be accessed via InstanceID() in shader.
	/// </summary>
	public uint32 InstanceID;

	/// <summary>
	/// An 8-bit mask assigned to the instance, which can be used to include/reject groups of instances on a per-ray basis.
	/// </summary>
	public uint8 InstanceMask;

	/// <summary>
	/// Per-instance contribution to add into shader table indexing to select the hit group to use.
	/// It is the offset of the instance inside the sahder-binding-table.
	/// </summary>
	public uint32 InstanceContributionToHitGroupIndex;

	/// <summary>
	/// the bottom-level acceleration structure that is being instanced.
	/// </summary>
	public BottomLevelAS BottonLevel;
}
