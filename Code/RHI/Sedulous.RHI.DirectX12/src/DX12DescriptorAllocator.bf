using System;
using Win32.Graphics.Direct3D12;
using Win32;
using Win32.Foundation;
using System.Threading;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// GPU memory allocator.
/// </summary>
internal class DX12DescriptorAllocator : IDisposable
{
	public ID3D12DescriptorHeap* Heap;

	public D3D12_DESCRIPTOR_HEAP_TYPE HeapType;

	public D3D12_CPU_DESCRIPTOR_HANDLE HeapStart;

	public uint32 descriptorCount;

	public uint32 maxDescriptorCount;

	public bool[] descriptorsAlive;
	public readonly Monitor descriptorsAliveMonitor = new .() ~ delete _;

	private uint32 descriptorSize;

	private uint32 lastAlloc;

	private DX12GraphicsContext context;

	public this(DX12GraphicsContext context, D3D12_DESCRIPTOR_HEAP_TYPE heapType, uint32 maxCount, D3D12_DESCRIPTOR_HEAP_FLAGS flags = D3D12_DESCRIPTOR_HEAP_FLAGS.D3D12_DESCRIPTOR_HEAP_FLAG_NONE)
	{
		HeapType = heapType;
		this.context = context;
		D3D12_DESCRIPTOR_HEAP_DESC heapDescription = D3D12_DESCRIPTOR_HEAP_DESC()
		{
			Flags = flags,
			Type = HeapType,
			NumDescriptors = maxCount,
			NodeMask = 0
		};
		HRESULT result = context.DXDevice.CreateDescriptorHeap(&heapDescription, ID3D12DescriptorHeap.IID, (void**)&Heap);
		if (!SUCCEEDED(result))
		{
			this.context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		HeapStart = Heap.GetCPUDescriptorHandleForHeapStart();
		descriptorSize = (uint32)context.DXDevice.GetDescriptorHandleIncrementSize(heapType);
		descriptorCount = 0;
		maxDescriptorCount = maxCount;
		descriptorsAlive = new bool[maxCount];
	}

	public D3D12_CPU_DESCRIPTOR_HANDLE Allocate()
	{
		if (descriptorCount == maxDescriptorCount)
		{
			context.ValidationLayer?.Notify("DX12", scope $"Warning: the heap {HeapType} is full.");
			return default(D3D12_CPU_DESCRIPTOR_HANDLE);
		}
		D3D12_CPU_DESCRIPTOR_HANDLE address = default(D3D12_CPU_DESCRIPTOR_HANDLE);
		using (descriptorsAliveMonitor.Enter())
		{
			while (descriptorsAlive[lastAlloc])
			{
				lastAlloc = (lastAlloc + 1) % maxDescriptorCount;
			}
			address.ptr = HeapStart.ptr + lastAlloc * descriptorSize;
			descriptorsAlive[lastAlloc] = true;
			descriptorCount++;
			return address;
		}
	}

	public void Free(D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle)
	{
		if ((int64)descriptorHandle.ptr < (int64)HeapStart.ptr || (int64)descriptorHandle.ptr >= (int64)HeapStart.ptr + (int64)(maxDescriptorCount * descriptorSize))
		{
			context.ValidationLayer?.Notify("DX12", "The descriptorHandle pointer is out of the heap.");
		}
		uint32 offset = (uint32)(descriptorHandle.ptr - HeapStart.ptr);
		offset /= descriptorSize;
		using (descriptorsAliveMonitor.Enter())
		{
			descriptorsAlive[offset] = false;
			if (descriptorCount != 0)
			{
				descriptorCount--;
			}
		}
	}

	public void Clear()
	{
		using (descriptorsAliveMonitor.Enter())
		{
			for (int i = 0; i < maxDescriptorCount; i++)
			{
				descriptorsAlive[i] = false;
			}
		}
		descriptorCount = 0;
	}

	/// <inheritdoc />
	public void Dispose()
	{
		Heap?.Release();
		Heap = null;
		descriptorsAlive = null;
	}
}
