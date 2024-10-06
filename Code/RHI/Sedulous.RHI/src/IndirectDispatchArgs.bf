namespace Sedulous.RHI;

/// <summary>
/// Struct representing the indirect dispatching of a Command Buffer.
/// </summary>
public struct IndirectDispatchArgs
{
	/// <summary>
	/// The thread group X size.
	/// </summary>
	public uint32 ThreadGroupCountX;

	/// <summary>
	/// The thread group Y size.
	/// </summary>
	public uint32 ThreadGroupCountY;

	/// <summary>
	/// The thread group Z-size.
	/// </summary>
	public uint32 ThreadGroupCountZ;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.IndirectDispatchArgs" /> struct.
	/// </summary>
	/// <param name="threadGroupCountX">The thread group count X size.</param>
	/// <param name="threadGroupCountY">The thread group count Y size.</param>
	/// <param name="threadGroupCountZ">The thread group count Z size.</param>
	public this(uint32 threadGroupCountX, uint32 threadGroupCountY, uint32 threadGroupCountZ)
	{
		ThreadGroupCountX = threadGroupCountX;
		ThreadGroupCountY = threadGroupCountY;
		ThreadGroupCountZ = threadGroupCountZ;
	}
}
