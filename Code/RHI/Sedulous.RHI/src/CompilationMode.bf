using System;

namespace Sedulous.RHI;

/// <summary>
/// An enum.
/// </summary>
public enum CompilationMode : uint8
{
	/// <summary>
	/// Shaders are compiled without special parameters.
	/// </summary>
	None = 0,
	/// <summary>
	/// Shaders are compiled with debug information.
	/// </summary>
	Debug = 1,
	/// <summary>
	/// Shaders are compiled with optimizations.
	/// </summary>
	Release = 2
}
