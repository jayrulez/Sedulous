namespace Sedulous.RHI;

/// <summary>
/// This class describes the elements inside a <see cref="T:Sedulous.RHI.ResourceLayout" />.
/// </summary>
public struct ResourceSetDescription
{
	/// <summary>
	/// The resourceLayout object <see cref="T:Sedulous.RHI.ResourceLayout" />.
	/// </summary>
	public ResourceLayout Layout;

	/// <summary>
	/// An array of <see cref="T:Sedulous.RHI.GraphicsResource" /> elements as Textures, ConstantBuffers, Samples.
	/// </summary>
	public GraphicsResource[] Resources;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ResourceSetDescription" /> struct.
	/// </summary>
	/// <param name="layout">The resourceLayout object.</param>
	/// <param name="resources">The list of resources.</param>
	public this(ResourceLayout layout, params GraphicsResource[] resources)
	{
		Layout = layout;
		Resources = resources;
	}
}
