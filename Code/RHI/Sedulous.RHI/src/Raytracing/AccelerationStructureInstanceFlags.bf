using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Ray tracing instance flags.
/// </summary>
public enum AccelerationStructureInstanceFlags
{
	/// <summary>
	/// No options specified.
	/// </summary>
	None = 0,
	/// <summary>
	/// Disables front/back-face culling for this instance.
	/// </summary>
	TriangleCullDisable = 1,
	/// <summary>
	/// This flag reverses front and back facing.
	/// </summary>
	TriangleFrontCounterclockwise = 2,
	/// <summary>
	/// Applied to all geometries in the bottom-level acceleration structure referenced by the instance
	/// </summary>
	ForceOpaque = 3,
	/// <summary>
	/// Applies to any of the geometries in the bottom-level acceleration structure referenced by the instance
	/// </summary>
	ForceNonOpaque = 4
}
