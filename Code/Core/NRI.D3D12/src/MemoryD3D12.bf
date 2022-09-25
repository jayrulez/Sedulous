using NRI.D3DCommon;
using Win32.Graphics.Direct3D12;
using System;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class MemoryD3D12 : Memory
{
	private DeviceD3D12 m_Device;
	private ComPtr<ID3D12Heap> m_Heap;
	private D3D12_HEAP_DESC m_HeapDesc = .();

	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_Heap.Dispose();
	}

	public static implicit operator ID3D12Heap*(Self self) => self.m_Heap.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(MemoryType memoryType, uint64 size)
	{
		D3D12_HEAP_DESC heapDesc = .();
		heapDesc.SizeInBytes = size;
		heapDesc.Properties.Type = GetHeapType(memoryType);
		heapDesc.Properties.CPUPageProperty = .D3D12_CPU_PAGE_PROPERTY_UNKNOWN;
		heapDesc.Properties.MemoryPoolPreference = .D3D12_MEMORY_POOL_UNKNOWN;
		heapDesc.Properties.CreationNodeMask = NRI_TEMP_NODE_MASK;
		heapDesc.Properties.VisibleNodeMask = NRI_TEMP_NODE_MASK;
		heapDesc.Alignment = 0;
		heapDesc.Flags = (size > 0 ? GetHeapFlags(memoryType) : .D3D12_HEAP_FLAG_NONE) | .D3D12_HEAP_FLAG_CREATE_NOT_ZEROED;

		if (NRI.D3D12.RequiresDedicatedAllocation(memoryType))
		{
			HRESULT hr = ((ID3D12Device*)m_Device).CreateHeap(&heapDesc, ID3D12Heap.IID, (void**)(&m_Heap));
			if (FAILED(hr))
			{
				REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateHeap() failed, error code: 0x{0:X}.", hr);
				return Result.FAILURE;
			}
		}

		m_HeapDesc = heapDesc;

		return Result.SUCCESS;
	}

	public Result Create(MemoryD3D12Desc memoryDesc)
	{
		m_Heap = (ID3D12Heap*)memoryDesc.d3d12Heap;
		m_HeapDesc = m_Heap->GetDesc();

		return Result.SUCCESS;
	}

	public bool RequiresDedicatedAllocation()
	{
		return m_Heap.GetInterface() != null ? false : true;
    }

	public readonly ref D3D12_HEAP_DESC GetHeapDesc() => ref m_HeapDesc;

	public void SetDebugName(char8* name)
	{
    	SET_D3D_DEBUG_OBJECT_NAME!(m_Heap, scope String(name));
	}
}