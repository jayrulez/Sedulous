using System;
using Sedulous.Foundation.Mathematics;
using System.Threading;

namespace Sedulous.RHI;

/// <summary>
/// This abstract class represents a strategy to quickly upload buffers to the GPU.
/// </summary>
public abstract class UploadBuffer : IDisposable
{
	/// <summary>
	/// Pointer to the beginning of the buffer.
	/// </summary>
	public uint64 DataBegin;

	/// <summary>
	/// Points to the current buffer position.
	/// </summary>
	public uint64 DataCurrent;

	/// <summary>
	/// Pointer to the end of the buffer.
	/// </summary>
	public uint64 DataEnd;

	/// <summary>
	/// Number of batched buffers.
	/// </summary>
	public uint64 Count;

	/// <summary>
	/// The buffer alignment.
	/// </summary>
	public uint32 Align;

	/// <summary>
	/// The total size in bytes of the upload buffer.
	/// </summary>
	public uint64 TotalSize;

	/// <summary>
	/// The instance of the graphics context.
	/// </summary>
	protected GraphicsContext context;

	private Monitor bufferLock = new .() ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.UploadBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="size">The size of the upload buffer.</param>
	/// <param name="align">The alignment of the upload buffer, if needed.</param>
	public this(GraphicsContext context, uint64 size, uint32 align)
	{
		this.context = context;
		Align = align;
		RefreshBuffer(size);
	}

	/// <summary>
	/// Refreshes the native buffer used by the upload buffer with the new size.
	/// </summary>
	/// <param name="size">The new size of the buffer.</param>
	protected abstract void RefreshBuffer(uint64 size);

	/// <summary>
	/// Allocates the new data in the upload buffer.
	/// </summary>
	/// <param name="dataSize">The new data size.</param>
	/// <returns>The destination address to copy to.</returns>
	public uint64 Allocate(uint64 dataSize)
	{
		uint64 returnValue = 0uL;
		using (bufferLock.Enter())
		{
			if (dataSize > TotalSize)
			{
				if (Count != 0)
				{
					context.SyncUpcopyQueue();
				}
				Dispose();
				uint64 newSize = MathUtil.NextPowerOfTwo(dataSize);
				RefreshBuffer(newSize);
			}
			if (DataCurrent + dataSize > DataEnd)
			{
				context.SyncUpcopyQueue();
			}
			if (Align != 0)
			{
				DataCurrent = Helpers.AlignUp(Align, DataCurrent);
			}
			returnValue = DataCurrent;
			DataCurrent += dataSize;
		}
		Count++;
		return returnValue;
	}

	/// <summary>
	/// Resets all pointers of the upload buffer.
	/// </summary>
	public void Clear()
	{
		using (bufferLock.Enter())
		{
			DataCurrent = DataBegin;
			Count = 0uL;
		}
	}

	/// <summary>
	/// Gets the native address data offset.
	/// </summary>
	/// <param name="address">The address of the data.</param>
	/// <returns>The address data offset.</returns>
	public uint64 CalculateOffset(uint64 address)
	{
		if (address < DataBegin || address > DataEnd)
		{
			context.ValidationLayer.Notify("UploadBuffer", "out of bounds");
		}
		return address - DataBegin;
	}

	/// <summary>
	/// Disposes all resources of this instance.
	/// </summary>
	public abstract void Dispose();
}
