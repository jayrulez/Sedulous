namespace Sedulous.RHI;

/// <summary>
/// Specifies depth reading/writing mode.
/// </summary>
public enum DepthMode : uint8
{
	/// <summary>
	/// Read-only.
	/// </summary>
	Read,
	/// <summary>
	/// Reads and writes.
	/// </summary>
	Write,
	/// <summary>
	/// No depth mode available.
	/// </summary>
	None
}
