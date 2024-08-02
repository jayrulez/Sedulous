namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Describes the properties of a ray dispatch operation initiated with a call to DispatchRays.
/// </summary>
struct DispatchRaysDescription
{
	/// <summary>
	/// The width of the generation shader thread grid.
	/// </summary>
	public uint32 Width;

	/// <summary>
	/// The height of the generation shader thread grid.
	/// </summary>
	public uint32 Height;

	/// <summary>
	/// The depth of the generation shader thread grid.
	/// </summary>
	public uint32 Depth;
}