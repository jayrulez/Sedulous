namespace Sedulous.RHI;

/// <summary>
/// Default known values for <see cref="T:Sedulous.RHI.RasterizerStateDescription" />.
/// </summary>
public static class RasterizerStates
{
	/// <summary>
	/// Culls primitives with clockwise winding order.
	/// </summary>
	public static readonly RasterizerStateDescription CullFront;

	/// <summary>
	/// Culls primitives with a counterclockwise winding order.
	/// </summary>
	public static readonly RasterizerStateDescription CullBack;

	/// <summary>
	/// Does not cull primitives.
	/// </summary>
	public static readonly RasterizerStateDescription None;

	/// <summary>
	/// Culls primitives with a clockwise winding order and enables the wireframe.
	/// </summary>
	public static readonly RasterizerStateDescription WireframeCullFront;

	/// <summary>
	/// Culls primitives with a counter-clockwise winding order and enables wireframe mode.
	/// </summary>
	public static readonly RasterizerStateDescription WireframeCullBack;

	/// <summary>
	/// Do not cull primitives, and enable wireframe.
	/// </summary>
	public static readonly RasterizerStateDescription WireframeCullNone;

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.RasterizerStates" /> class.
	/// </summary>
	static this()
	{
		CullFront = RasterizerStateDescription.Default;
		CullFront.CullMode = CullMode.Front;
		CullBack = RasterizerStateDescription.Default;
		None = RasterizerStateDescription.Default;
		None.CullMode = CullMode.None;
		WireframeCullFront = RasterizerStateDescription.Default;
		WireframeCullFront.CullMode = CullMode.Front;
		WireframeCullFront.FillMode = FillMode.Wireframe;
		WireframeCullBack = RasterizerStateDescription.Default;
		WireframeCullBack.FillMode = FillMode.Wireframe;
		WireframeCullNone = RasterizerStateDescription.Default;
		WireframeCullNone.CullMode = CullMode.None;
		WireframeCullNone.FillMode = FillMode.Wireframe;
	}
}
