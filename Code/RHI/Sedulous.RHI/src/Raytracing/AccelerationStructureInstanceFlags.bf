using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Raytracing instance flags.
/// </summary>
//[Flags]
enum AccelerationStructureInstanceFlags
{
	/// <summary>
	/// No options specified.
	/// </summary>
	None = 0,
	/// <summary>
	/// Disables front/back face culling for this instance.
	/// </summary>
	TriangleCullDisable = 1,
	/// <summary>
	/// This flag reverses front and back facings.
	/// </summary>
	TriangleFrontCounterclockwise = 2,
	/// <summary>
	/// Applied to all the geometries in the bottom-level acceleration structure referenced by the instance
	/// </summary>
	ForceOpaque = 3,
	/// <summary>
	/// Applied to any of the geometries in the bottom-level acceleration structure referenced by the instance
	/// </summary>
	ForceNonOpaque = 4
}
