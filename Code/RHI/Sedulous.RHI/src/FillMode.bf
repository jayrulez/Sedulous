namespace Sedulous.RHI;

/// <summary>
/// Primitive fill mode.
/// </summary>
public enum FillMode : uint8
{
	/// <summary>
	/// Draw lines connecting the vertices. Adjacent vertices are not drawn.
	/// </summary>
	Wireframe = 2,
	/// <summary>
	/// Fill the triangles formed by the vertices. Adjacent vertices are not drawn.
	/// </summary>
	Solid
}
