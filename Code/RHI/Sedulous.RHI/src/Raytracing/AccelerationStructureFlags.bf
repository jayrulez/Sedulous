using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Flags specifying additional parameters for building acceleration structures.
/// </summary>
public enum AccelerationStructureFlags
{
	/// <summary>
	/// No options are specified for the acceleration structure build.
	/// </summary>
	None = 0,
	/// <summary>
	/// Builds the acceleration structure such that it supports future updates instead of requiring the app to entirely rebuild the structure.
	/// </summary>
	/// <remarks>
	/// This option may result in increased memory consumption, build times, and lower ray tracing performance. Future updates, however,
	/// should be faster than building the equivalent acceleration structure from scratch.
	/// </remarks>
	AllowUpdate = 1,
	/// <summary>
	/// Enables the option to compact the acceleration structure.
	/// </summary>
	/// <remarks>
	/// This option may result in increased memory consumption and build times. However, after compaction, the resulting acceleration structure
	/// should have a smaller memory footprint than building the acceleration structure from scratch.
	/// </remarks>
	AllowCompactation = 2,
	/// <summary>
	/// Constructs a high-quality acceleration structure that maximizes ray tracing performance at the expense of additional build time.
	/// </summary>
	/// <remarks>
	/// Typically, the implementation will take 2-3 times longer to build than the default setting in order to achieve better tracing performance.
	/// </remarks>
	PreferFastTrace = 3,
	/// <summary>
	/// Constructs a lower quality acceleration structure, trading ray tracing performance for build speed.
	/// </summary>
	/// <remarks>
	/// Typically, the implementation will take 1/2 to 1/3 of the build time compared to the default setting, with a sacrifice in tracing performance.
	/// </remarks>
	PreferFastBuild = 4,
	/// <summary>
	/// Minimizes the amount of scratch memory used during the acceleration structure build as well as the size of the result.
	/// </summary>
	/// <remarks>
	/// This option may result in increased build times and/or raytracing times.
	/// </remarks>
	MinimizeMemory = 5,
	/// <summary>
	/// Perform an acceleration structure update, as opposed to building from scratch.
	/// </summary>
	/// <remarks>
	/// This is faster than a full build, but it can negatively impact ray tracing performance, especially if the positions of the underlying
	/// objects have changed significantly from the original build of the acceleration structure before updates.
	/// </remarks>
	PerformUpdate = 6
}
