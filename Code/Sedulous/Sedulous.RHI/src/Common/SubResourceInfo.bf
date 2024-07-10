namespace Sedulous.RHI;

/// <summary>
/// Struct containing the sub resource info.
/// </summary>
struct SubResourceInfo
{
	/// <summary>
	/// The size in bytes.
	/// </summary>
	public uint32 SizeInBytes;

	/// <summary>
	/// The offset.
	/// </summary>
	public uint64 Offset;

	/// <summary>
	/// The row pitch.
	/// </summary>
	public uint32 RowPitch;

	/// <summary>
	/// The slice pitch.
	/// </summary>
	public uint32 SlicePitch;

	/// <summary>
	/// The mip width.
	/// </summary>
	public uint32 MipWidth;

	/// <summary>
	/// The mip height.
	/// </summary>
	public uint32 MipHeight;

	/// <summary>
	/// The mip depth.
	/// </summary>
	public uint32 MipDepth;

	/// <summary>
	/// The mip level.
	/// </summary>
	public uint32 MipLevel;

	/// <summary>
	/// The array layer.
	/// </summary>
	public uint32 ArrayLayer;
}