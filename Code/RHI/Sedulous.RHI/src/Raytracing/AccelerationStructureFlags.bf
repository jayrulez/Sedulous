using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Flags specifying additional parameters for acceleration structure builds.
/// </summary>
public enum AccelerationStructureFlags
{
	/// <summary>
	/// No options specified for the acceleration structure build.
	/// </summary>
	None = 0,
	/// <summary>
	/// Build the acceleration structure such that it supports future updates instead of the app having to entirely rebuild the structure.
	/// </summary>
	/// <remarks>
	/// This option may result in increased memory consumption, build times, and lower raytracing performance. Future updates, however,
	/// should be faster than building the equivalent acceleration structure from scratch.
	/// </remarks>
	AllowUpdate = 1,
	/// <summary>
	/// Enables the option to compact the acceleration structure.
	/// </summary>
	/// <remarks>
	/// This option may result in increased memory consumption and build times. After future compaction, however, the resulting acceleration structure
	/// should consume a smaller memory footprint than building the acceleration structure from scratch.
	/// </remarks>
	AllowCompactation = 2,
	/// <summary>
	/// Construct a high quality acceleration structure that maximizes raytracing performance at the expense of additional build time.
	/// </summary>
	/// <remarks>
	/// Typically, the implementation will take 2-3 times the build time than the default setting in order to get better tracing performance.
	/// </remarks>
	PreferFastTrace = 3,
	/// <summary>
	/// Construct a lower quality acceleration structure, trading raytracing performance for build speed.
	/// </summary>
	/// <remarks>
	/// Typically, the implementation will take 1/2 to 1/3 the build time than default setting, with a sacrifice in tracing performance.
	/// </remarks>
	PreferFastBuild = 4,
	/// <summary>
	/// Minimize the amount of scratch memory used during the acceleration structure build as well as the size of the result.
	/// </summary>
	/// <remarks>
	/// This option may result in increased build times and/or raytracing times.
	/// </remarks>
	MinimizeMemory = 5,
	/// <summary>
	/// Perform an acceleration structure update, as opposed to building from scratch.
	/// </summary>
	/// <remarks>
	/// This is faster than a full build, but can negatively impact raytracing performance, especially if the positions of the underlying
	/// objects have changed significantly from the original build of the acceleration structure before updates.
	/// </remarks>
	PerformUpdate = 6
}
