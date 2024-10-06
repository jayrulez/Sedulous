using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Foundation;
using Win32;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// Represents a DirectX query heap object.
/// </summary>
public class DX12QueryHeap : QueryHeap
{
	/// <summary>
	/// The DirectX 12 native object.
	/// </summary>
	public ID3D12QueryHeap* nativeQueryHeap;

	private DX12GraphicsContext dxContext;

	internal DX12Buffer readBackBuffer;

	/// <inheritdoc />
	public override void* NativePointer => nativeQueryHeap;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12QueryHeap" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The query heap description.</param>
	public this(DX12GraphicsContext context, in Sedulous.RHI.QueryHeapDescription description)
		: base(context, description)
	{
		dxContext = context;
		D3D12_QUERY_HEAP_DESC nativeDescription = D3D12_QUERY_HEAP_DESC()
		{
			Count = (uint32)description.QueryCount
		};
		switch (description.Type)
		{
		case QueryType.Timestamp:
			nativeDescription.Type = .D3D12_QUERY_HEAP_TYPE_TIMESTAMP;
			break;
		case QueryType.Occlusion,
			 QueryType.BinaryOcclusion:
			nativeDescription.Type = .D3D12_QUERY_HEAP_TYPE_OCCLUSION;
			break;
		}
		HRESULT result = dxContext.DXDevice.CreateQueryHeap(&nativeDescription, ID3D12QueryHeap.IID, (void**)&nativeQueryHeap);
		if (!SUCCEEDED(result))
		{
			Context.ValidationLayer?.Notify("DX12", "Error creating a new queryheap.");
		}
		BufferDescription bufferDescription = BufferDescription
		{
			Flags = BufferFlags.None,
			Usage = ResourceUsage.Staging,
			CpuAccess = ResourceCpuAccess.Read,
			SizeInBytes = description.QueryCount * 8
		};
		readBackBuffer = new DX12Buffer(dxContext, null, bufferDescription);
		readBackBuffer.Name = "Query Readback Buffer";
	}

	/// <inheritdoc />
	public override bool ReadData(uint32 startIndex, uint32 count, uint64[] results)
	{
		uint64 stride = 8uL;
		uint64 startOffset = startIndex * stride;
		uint32 sizeInBytes = count * (uint32)(int32)stride;
		MappedResource mappedResource = dxContext.MapMemory(readBackBuffer, MapMode.Read);
		Internal.MemCpy((void*)(int)((uint64)(int)(void*)results.Ptr + startOffset), (void*)(int)((uint64)(int)mappedResource.Data + startOffset), sizeInBytes);
		dxContext.UnmapMemory(readBackBuffer);
		return true;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and optionally managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				readBackBuffer?.Dispose();
				nativeQueryHeap?.Release();
			}
			disposed = true;
		}
	}
}
