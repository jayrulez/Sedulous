namespace Sedulous.RHI;

/// <summary>
/// The depth stencil state default values.
/// </summary>
enum DepthStencilStateEnum : uint8
{
	/// <summary>
	/// Depth disable
	/// </summary>
	None,
	/// <summary>
	/// Depth enable and writemask enable.
	/// </summary>
	ReadAndWrite,
	/// <summary>
	/// Depth enable but writemask zero.
	/// </summary>
	Read,
	/// <summary>
	/// Custom value
	/// </summary>
	Custom
}
