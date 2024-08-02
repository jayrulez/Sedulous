using System;

namespace Sedulous.RHI;

/// <summary>
/// Specifies the types of CPU access allowed for a resource.
/// </summary>
public enum ResourceCpuAccess : uint8
{
	/// <summary>
	/// None (default value).
	/// </summary>
	None = 0,
	/// <summary>
	/// The CPU can be write this resource.
	/// </summary>
	Write = 1,
	/// <summary>
	/// the CPU can be read this resources.
	/// </summary>
	Read = 2
}
