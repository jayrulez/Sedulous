namespace Sedulous.RHI;

/// <summary>
/// Default known values for <see cref="T:Sedulous.RHI.RasterizerStateDescription" />.
/// </summary>
public static class RasterizerStates
{
	/// <summary>
	/// Cull primitives with clockwise winding order;.
	/// </summary>
	public static readonly RasterizerStateDescription CullFront;

	/// <summary>
	/// Cull primitives with counter-clockwise winding order.
	/// </summary>
	public static readonly RasterizerStateDescription CullBack;

	/// <summary>
	/// Not cull primitives.
	/// </summary>
	public static readonly RasterizerStateDescription None;

	/// <summary>
	/// Cull primitives with clockwise winding order and wireframe enable.
	/// </summary>
	public static readonly RasterizerStateDescription WireframeCullFront;

	/// <summary>
	/// Cull primitives with counter-clockwise winding order and wireframe enable.
	/// </summary>
	public static readonly RasterizerStateDescription WireframeCullBack;

	/// <summary>
	/// Not cull primitives and wireframe enable.
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
