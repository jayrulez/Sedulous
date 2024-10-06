using System;

namespace Sedulous.RHI;

/// <summary>
/// Provides access to data organized in 3D space.
/// </summary>
public struct DataBox
{
	/// <summary>
	/// Pointer to the data.
	/// </summary>
	public void* DataPointer;

	/// <summary>
	/// Gets the number of bytes per row.
	/// </summary>
	public uint32 RowPitch;

	/// <summary>
	/// Gets the number of bytes per slice (for a 3D texture, a slice is a 2D image).
	/// </summary>
	public uint32 SlicePitch;

	/// <summary>
	/// Gets a value indicating whether this instance is empty.
	/// </summary>
	/// <value><c>true</c> if this instance is empty; otherwise, <c>false</c>.</value>
	public bool IsEmpty
	{
		get
		{
			if (DataPointer == null && RowPitch == 0)
			{
				return SlicePitch == 0;
			}
			return false;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DataBox" /> struct from a void*.
	/// </summary>
	/// <param name="datapointer">The data pointer.</param>
	/// <param name="rowPitch">The row pitch.</param>
	/// <param name="slicePitch">The slice pitch.</param>
	public this(void* datapointer, uint32 rowPitch = 0, uint32 slicePitch = 0)
	{
		DataPointer = datapointer;
		RowPitch = rowPitch;
		SlicePitch = slicePitch;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DataBox" /> struct from a byte array.
	/// </summary>
	/// <param name="data">The data as a byte array.</param>
	/// <param name="rowPitch">The row pitch.</param>
	/// <param name="slicePitch">The slice pitch.</param>
	public this(uint8[] data, uint32 rowPitch = 0, uint32 slicePitch = 0)
	{
		DataPointer = data.Ptr;
		RowPitch = rowPitch;
		SlicePitch = slicePitch;
	}
}
