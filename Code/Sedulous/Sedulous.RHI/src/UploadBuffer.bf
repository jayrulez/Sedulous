using System;
using System.Threading;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// This abstract class represent and strategy to fast upload buffers to GPU.
/// </summary>
abstract class UploadBuffer : IDisposable
{
	/// <summary>
	/// Pointer to the begin of the buffer.
	/// </summary>
	public uint64 DataBegin;

	/// <summary>
	/// Pointer to the current buffer position.
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
	/// The total size in bytes of the uploadbuffer.
	/// </summary>
	public uint64 TotalSize;

	/// <summary>
	/// The graphics context instance.
	/// </summary>
	protected GraphicsContext context;

	private readonly Monitor bufferLock = new .() ~ delete _;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.UploadBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="size">The uploadBuffer size.</param>
	/// <param name="align">The uploadBuffer align if it is needed.</param>
	public this(GraphicsContext context, uint64 size, uint32 align)
	{
		this.context = context;
		Align = align;
		RefreshBuffer(size);
	}

	/// <summary>
	/// Refresh the native buffer used by the uploadbuffer with the new size.
	/// </summary>
	/// <param name="size">The new size of the buffer.</param>
	protected abstract void RefreshBuffer(uint64 size);

	/// <summary>
	/// Allocate the new data in the uploadbuffer.
	/// </summary>
	/// <param name="dataSize">The new data size.</param>
	/// <returns>The destination address to copy.</returns>
	public uint64 Allocate(uint64 dataSize)
	{
		uint64 returnValue = 0UL;
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
	/// Reset all pointers of the uploadbuffer.
	/// </summary>
	public void Clear()
	{
		using (bufferLock.Enter())
		{
			DataCurrent = DataBegin;
			Count = 0UL;
		}
	}

	/// <summary>
	/// Gets the native address data offset.
	/// </summary>
	/// <param name="address">The address of data.</param>
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
	/// Dispose all resource of this instance.
	/// </summary>
	public abstract void Dispose();
}
