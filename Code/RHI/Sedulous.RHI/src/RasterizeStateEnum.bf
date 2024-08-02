namespace Sedulous.RHI;

/// <summary>
/// Enum of the rasterizer states.
/// </summary>
public enum RasterizeStateEnum
{
	/// <summary>
	/// Cull primitives with clockwise winding order,
	/// </summary>
	CullFront,
	/// <summary>
	/// Cull primitives with counter-clockwise winding order.
	/// </summary>
	CullBack,
	/// <summary>
	/// Not cull primitives.
	/// </summary>
	None,
	/// <summary>
	/// Cull primitives with clockwise winding order and wireframe enable.
	/// </summary>
	WireframeCullFront,
	/// <summary>
	/// Cull primitives with counter-clockwise winding order and wireframe enable.
	/// </summary>
	WireframeCullBack,
	/// <summary>
	/// Not cull primitives and wireframe enable.
	/// </summary>
	WireframeCullNone,
	/// <summary>
	/// Custom value
	/// </summary>
	Custom
}
