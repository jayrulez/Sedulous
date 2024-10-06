using System;

namespace Sedulous.RHI;

/// <summary>
/// Specifies the types of CPU access allowed for a resource.
/// </summary>
public enum ResourceCpuAccess : uint8
{
	/// <summary>
	/// No value (default).
	/// </summary>
	None = 0,
	/// <summary>
	/// The CPU can write to this resource.
	/// </summary>
	Write = 1,
	/// <summary>
	/// The CPU can read this resource.
	/// </summary>
	Read = 2
}
