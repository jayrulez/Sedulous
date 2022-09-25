using Win32.Graphics.Direct3D12;
using NRI.D3DCommon;
using System;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class BufferD3D12 : Buffer
{
	private DeviceD3D12 m_Device;
	private D3D12_RESOURCE_DESC m_BufferDesc = .();
	private uint32 m_StructureStride = 0;
	private ComPtr<ID3D12Resource> m_Buffer;

	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_Buffer.Dispose();
	}

	public static implicit operator ID3D12Resource*(Self self) => self.m_Buffer.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(BufferDesc bufferDesc)
	{
		m_BufferDesc.Dimension = .D3D12_RESOURCE_DIMENSION_BUFFER;
		m_BufferDesc.Alignment = D3D12_DEFAULT_RESOURCE_PLACEMENT_ALIGNMENT; // 64KB
		m_BufferDesc.Width = bufferDesc.size;
		m_BufferDesc.Height = 1;
		m_BufferDesc.DepthOrArraySize = 1;
		m_BufferDesc.MipLevels = 1;
		m_BufferDesc.SampleDesc.Count = 1;
		m_BufferDesc.Layout = .D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
		m_BufferDesc.Flags = GetBufferFlags(bufferDesc.usageMask);

		m_StructureStride = bufferDesc.structureStride;

		return Result.SUCCESS;
	}

	public Result Create(BufferD3D12Desc bufferDesc)
	{
		m_StructureStride = bufferDesc.structureStride;
		Initialize((ID3D12Resource*)bufferDesc.d3d12Resource);
		return Result.SUCCESS;
	}

	public void Initialize(ID3D12Resource* resource)
	{
		m_Buffer = resource;
		m_BufferDesc = resource.GetDesc();
	}

	public Result BindMemory(MemoryD3D12 memory, uint64 offset, bool isAccelerationStructureBuffer = false)
	{
		/*readonly ref*/ D3D12_HEAP_DESC heapDesc = /*ref*/ memory.GetHeapDesc();
		D3D12_RESOURCE_STATES initialState = .D3D12_RESOURCE_STATE_COMMON;

		if (heapDesc.Properties.Type == .D3D12_HEAP_TYPE_UPLOAD)
			initialState |= .D3D12_RESOURCE_STATE_GENERIC_READ;
		else if (heapDesc.Properties.Type == .D3D12_HEAP_TYPE_READBACK)
			initialState |= .D3D12_RESOURCE_STATE_COPY_DEST;

	//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		if (isAccelerationStructureBuffer)
			initialState |= .D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE;
	//#endif

		if (memory.RequiresDedicatedAllocation())
		{
			HRESULT hr = ((ID3D12Device*)m_Device).CreateCommittedResource(
				&heapDesc.Properties,
				.D3D12_HEAP_FLAG_CREATE_NOT_ZEROED,
				&m_BufferDesc,
				initialState,
				null,
				ID3D12Resource.IID,
				(void**)(&m_Buffer)
				);

			if (FAILED(hr))
			{
				REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateCommittedResource() failed, error code: 0x{0:X}.", hr);
				return Result.FAILURE;
			}
		}
		else
		{
			HRESULT hr = ((ID3D12Device*)m_Device).CreatePlacedResource(
				memory,
				offset,
				&m_BufferDesc,
				initialState,
				null,
				ID3D12Resource.IID,
				(void**)(&m_Buffer)
				);

			if (FAILED(hr))
			{
				REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreatePlacedResource() failed, error code: 0x{0:X}.", hr);
				return Result.FAILURE;
			}
		}

		return Result.SUCCESS;
	}

	public uint64 GetByteSize() => m_BufferDesc.Width;
	public uint32 GetStructureStride() => m_StructureStride;
	public D3D12_GPU_VIRTUAL_ADDRESS GetPointerGPU() => m_Buffer->GetGPUVirtualAddress();

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_Buffer, scope String(name));
	}

	public uint64 GetBufferNativeObject(uint32 physicalDeviceIndex)
	{
	    //MaybeUnused(physicalDeviceIndex);

	    return (uint64)(int)(void*)((ID3D12Resource*)((BufferD3D12)this));
	}

	public void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc)
	{
		m_Device.GetMemoryInfo(memoryLocation, m_BufferDesc, ref memoryDesc);
	}

	public void* Map(uint64 offset, uint64 size)
	{
		var size;
		uint8* data = null;

		if (size == WHOLE_SIZE)
			size =  m_BufferDesc.Width;

		D3D12_RANGE range = .() { Begin = (uint)offset, End = (uint)(offset + size) };
		HRESULT hr = m_Buffer->Map(0, &range, (void**)&data);
		if (FAILED(hr))
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Resource::Map() failed, error code: 0x{0:X}.", hr);

		return data + offset;
	}

	public void Unmap()
	{
		m_Buffer->Unmap(0, null);
	}
}