using System;

namespace Sedulous.RHI;

/// <summary>
/// The resource that has been mapped.
/// </summary>
public struct MappedResource
{
	/// <summary>
	/// The resource that has been mapped.
	/// </summary>
	public readonly GraphicsResource Resource;

	/// <summary>
	/// Identifies the <see cref="T:Sedulous.RHI.MapMode" /> that was used to map the resource.
	/// </summary>
	public readonly MapMode Mode;

	/// <summary>
	/// A pointer to the start of the mapped data region.
	/// </summary>
	public readonly void* Data;

	/// <summary>
	/// The total size in bytes of the mapped data region.
	/// </summary>
	public readonly uint32 SizeInBytes;

	/// <summary>
	/// For <see cref="T:Sedulous.RHI.Texture" /> resources, this subresource is mapped.
	/// For <see cref="T:Sedulous.RHI.Buffer" /> resources, this field has no meaning.
	/// </summary>
	public readonly uint32 SubresourceIndex;

	/// <summary>
	/// For <see cref="T:Sedulous.RHI.Texture" /> resources, this is the number of bytes between each row of texels.
	/// For <see cref="T:Sedulous.RHI.Buffer" /> resources, this field has no meaning.
	/// </summary>
	public readonly uint32 RowPitch;

	/// <summary>
	/// For <see cref="T:Sedulous.RHI.Texture" /> resources, this represents the number of bytes between each slice of a 3D texture.
	/// For <see cref="T:Sedulous.RHI.Buffer" /> resources, this field has no meaning.
	/// </summary>
	public readonly uint32 SlicePitch;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.MappedResource" /> struct.
	/// </summary>
	/// <param name="resource">The resource that has been mapped.</param>
	/// <param name="mode">The map mode used to map the resource.</param>
	/// <param name="data">A pointer to the start of the mapped data region.</param>
	/// <param name="sizeInBytes">The total size, in bytes, of the mapped data region.</param>
	public this(GraphicsResource resource, MapMode mode, void* data, uint32 sizeInBytes)
	{
		Resource = resource;
		Data = data;
		Mode = mode;
		SizeInBytes = sizeInBytes;
		SubresourceIndex = 0;
		RowPitch = 0;
		SlicePitch = 0;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.MappedResource" /> struct.
	/// </summary>
	/// <param name="resource">The resource that has been mapped.</param>
	/// <param name="mode">The map mode used to map the resource.</param>
	/// <param name="data">A pointer to the start of the mapped data region.</param>
	/// <param name="sizeInBytes">The total size, in bytes, of the mapped data region.</param>
	/// <param name="subResourceIndex">The index of the subresource.</param>
	/// <param name="rowPitch">The number of bytes per row.</param>
	/// <param name="slicePitch">The number of bytes per slice.</param>
	public this(GraphicsResource resource, MapMode mode, void* data, uint32 sizeInBytes, uint32 subResourceIndex, uint32 rowPitch, uint32 slicePitch)
	{
		Resource = resource;
		Data = data;
		Mode = mode;
		SizeInBytes = sizeInBytes;
		SubresourceIndex = subResourceIndex;
		RowPitch = rowPitch;
		SlicePitch = slicePitch;
	}
}
