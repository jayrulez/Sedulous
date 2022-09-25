using Win32.Graphics.Direct3D12;
using NRI.D3DCommon;
using System;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class QueryPoolD3D12 : QueryPool
{
	private Result CreateReadbackBuffer(QueryPoolDesc queryPoolDesc)
	{
		m_QuerySize = sizeof(uint64);

		D3D12_RESOURCE_DESC resourceDesc = .();
		resourceDesc.Dimension = .D3D12_RESOURCE_DIMENSION_BUFFER;
		resourceDesc.Alignment = D3D12_DEFAULT_RESOURCE_PLACEMENT_ALIGNMENT;
		resourceDesc.Width = (uint64)queryPoolDesc.capacity * m_QuerySize;
		resourceDesc.Height = 1;
		resourceDesc.DepthOrArraySize = 1;
		resourceDesc.MipLevels = 1;
		resourceDesc.Layout = .D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
		resourceDesc.Flags = .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS;

		D3D12_HEAP_PROPERTIES heapProperties = .();
		heapProperties.Type = .D3D12_HEAP_TYPE_READBACK;

		HRESULT hr = ((ID3D12Device*)m_Device).CreateCommittedResource(&heapProperties, .D3D12_HEAP_FLAG_CREATE_NOT_ZEROED, &resourceDesc,
			.D3D12_RESOURCE_STATE_UNORDERED_ACCESS, null, ID3D12Resource.IID, (void**)(&m_ReadbackBuffer));

		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateCommittedResource() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	private DeviceD3D12 m_Device;
	private D3D12_QUERY_TYPE m_QueryType = (D3D12_QUERY_TYPE) - 1;
	private uint32 m_QuerySize = 0;
	private ComPtr<ID3D12QueryHeap> m_QueryHeap;
	private ComPtr<ID3D12Resource> m_ReadbackBuffer;


	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_ReadbackBuffer.Dispose();
		m_QueryHeap.Dispose();
	}

	public static implicit operator ID3D12QueryHeap*(Self self) => self.m_QueryHeap.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(QueryPoolDesc queryPoolDesc)
	{
		m_QueryType = NRI.D3D12.GetQueryType(queryPoolDesc.queryType);

		if (queryPoolDesc.queryType == QueryType.ACCELERATION_STRUCTURE_COMPACTED_SIZE)
			return CreateReadbackBuffer(queryPoolDesc);

		m_QuerySize = GetQueryElementSize(m_QueryType);

		D3D12_QUERY_HEAP_DESC desc;
		desc.Type = GetQueryHeapType(queryPoolDesc.queryType);
		desc.Count = queryPoolDesc.capacity;
		desc.NodeMask = NRI_TEMP_NODE_MASK;

		HRESULT hr = ((ID3D12Device*)m_Device).CreateQueryHeap(&desc, ID3D12QueryHeap.IID, (void**)(&m_QueryHeap));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateQueryHeap() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	public D3D12_QUERY_TYPE GetQueryType() => m_QueryType;
	public ID3D12Resource* GetReadbackBuffer() => m_ReadbackBuffer.GetInterface();

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_QueryHeap, scope String(name));
	}

	public uint32 GetQuerySize() => m_QuerySize;
}