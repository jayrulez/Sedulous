using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Flags specifying additional parameters for building acceleration structures.
/// </summary>
public enum AccelerationStructureGeometryFlags
{
	/// <summary>
	/// No options are specified.
	/// </summary>
	None = 0,
	/// <summary>
	/// When rays encounter this geometry, the geometry acts as if no hit shader is present.
	/// It is recommended to use this flag liberally, as it can enable important ray processing optimizations.
	/// </summary>
	Opaque = 1,
	/// <summary>
	/// By default, the system is free to trigger an any-hit shader more than once for a given ray-primitive intersection.
	/// This flexibility helps improve the traversal efficiency of acceleration structures in certain cases.
	/// </summary>
	NoDuplicateAnyhitInverseOcation = 2
}
