namespace Sedulous.RHI;

/// <summary>
/// Primary fill mode.
/// </summary>
public enum FillMode : uint8
{
	/// <summary>
	/// Draw lines connecting the vertices. Adjacent vertices are not connected.
	/// </summary>
	Wireframe = 2,
	/// <summary>
	/// Fills the triangles formed by the vertices. Adjacent vertices are not drawn.
	/// </summary>
	Solid
}
