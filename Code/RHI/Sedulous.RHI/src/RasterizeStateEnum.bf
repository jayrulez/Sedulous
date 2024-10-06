namespace Sedulous.RHI;

/// <summary>
/// Enumeration of the rasterizer states.
/// </summary>
public enum RasterizeStateEnum
{
	/// <summary>
	/// Culls primitives with a clockwise winding order.
	/// </summary>
	CullFront,
	/// <summary>
	/// Culls primitives with a counter-clockwise winding order.
	/// </summary>
	CullBack,
	/// <summary>
	/// Do not cull primitives.
	/// </summary>
	None,
	/// <summary>
	/// Culls primitives with a clockwise winding order and enables wireframe mode.
	/// </summary>
	WireframeCullFront,
	/// <summary>
	/// Culls primitives with a counter-clockwise winding order and enables wireframe.
	/// </summary>
	WireframeCullBack,
	/// <summary>
	/// Do not cull primitives and enable wireframe.
	/// </summary>
	WireframeCullNone,
	/// <summary>
	/// Custom value.
	/// </summary>
	Custom
}
