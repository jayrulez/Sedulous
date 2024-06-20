namespace Sedulous.RHI;

/// <summary>
/// Default known values for <see cref="T:Sedulous.RHI.DepthStencilStateDescription" />.
/// </summary>
public static class DepthStencilStates
{
	/// <summary>
	/// Depth disable.
	/// </summary>
	public static readonly DepthStencilStateDescription None;

	/// <summary>
	/// Depth enable and writemask enable.
	/// </summary>
	public static readonly DepthStencilStateDescription ReadWrite;

	/// <summary>
	/// Depth enable but writemask zero.
	/// </summary>
	public static readonly DepthStencilStateDescription Read;

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.DepthStencilStates" /> class.
	/// </summary>
	static this()
	{
		None = DepthStencilStateDescription.Default;
		None.DepthEnable = false;
		None.DepthWriteMask = false;

		ReadWrite = DepthStencilStateDescription.Default;

		Read = DepthStencilStateDescription.Default;
		Read.DepthWriteMask = false;
	}
}
