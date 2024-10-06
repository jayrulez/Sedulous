namespace Sedulous.RHI;

/// <summary>
/// The default values for the depth stencil state.
/// </summary>
public enum DepthStencilStateEnum : uint8
{
	/// <summary>
	/// Disables the depth
	/// </summary>
	None,
	/// <summary>
	/// Depth enable and write mask enable.
	/// </summary>
	ReadAndWrite,
	/// <summary>
	/// Depth enabled but write mask set to zero.
	/// </summary>
	Read,
	/// <summary>
	/// Custom value.
	/// </summary>
	Custom
}
