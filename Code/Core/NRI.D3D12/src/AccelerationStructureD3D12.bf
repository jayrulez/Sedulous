using Win32.Graphics.Direct3D12;
using System.Collections;
namespace NRI.D3D12;

class AccelerationStructureD3D12 : AccelerationStructure
{
	private DeviceD3D12 m_Device;
	private D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO m_PrebuildInfo = .();
	private BufferD3D12 m_Buffer = null;


	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		if (m_Buffer != null)
			Deallocate!(m_Device.GetAllocator(), m_Buffer);
	}

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(AccelerationStructureDesc accelerationStructureDesc)
	{
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS accelerationStructureInputs = .();
		accelerationStructureInputs.Type = GetAccelerationStructureType(accelerationStructureDesc.type);
		accelerationStructureInputs.Flags = GetAccelerationStructureBuildFlags(accelerationStructureDesc.flags);
		accelerationStructureInputs.NumDescs = accelerationStructureDesc.instanceOrGeometryObjectNum;
		accelerationStructureInputs.DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY; // TODO:

		List<D3D12_RAYTRACING_GEOMETRY_DESC> geometryDescs = Allocate!<List<D3D12_RAYTRACING_GEOMETRY_DESC>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), geometryDescs); }
		geometryDescs.Resize(accelerationStructureDesc.instanceOrGeometryObjectNum);

		if (accelerationStructureInputs.Type == .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL && accelerationStructureDesc.instanceOrGeometryObjectNum > 0)
		{
			ConvertGeometryDescs(&geometryDescs[0], accelerationStructureDesc.geometryObjects, accelerationStructureDesc.instanceOrGeometryObjectNum);
			accelerationStructureInputs.pGeometryDescs = &geometryDescs[0];
		}

		((ID3D12Device5*)m_Device).GetRaytracingAccelerationStructurePrebuildInfo(&accelerationStructureInputs, &m_PrebuildInfo);

		BufferDesc bufferDesc = .();
		bufferDesc.size = m_PrebuildInfo.ResultDataMaxSizeInBytes;
		bufferDesc.usageMask = BufferUsageBits.SHADER_RESOURCE_STORAGE;

		m_Buffer = Allocate!<BufferD3D12>(m_Device.GetAllocator(), m_Device);
		Result result = m_Buffer.Create(bufferDesc);

		return result;
	}

	public void SetDebugName(char8* name)
	{
		m_Buffer.SetDebugName(name);
	}

	public Result CreateDescriptor(uint32 physicalDeviceMask, out Descriptor descriptor)
	{
		readonly AccelerationStructure accelerationStructure = (AccelerationStructure)this;
		Result result = m_Device.CreateDescriptor(accelerationStructure, out descriptor);

		return result;
	}

	public void GetMemoryInfo(ref MemoryDesc memoryDesc)
	{
		memoryDesc.size = m_PrebuildInfo.ResultDataMaxSizeInBytes;
		memoryDesc.alignment = D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BYTE_ALIGNMENT;
		memoryDesc.type = GetMemoryType(.D3D12_HEAP_TYPE_DEFAULT, .D3D12_HEAP_FLAG_ALLOW_ONLY_BUFFERS);
		memoryDesc.mustBeDedicated = false;
	}

	public uint64 GetUpdateScratchBufferSize()
	{
		return m_PrebuildInfo.UpdateScratchDataSizeInBytes;
	}

	public uint64 GetBuildScratchBufferSize()
	{
		return m_PrebuildInfo.ScratchDataSizeInBytes;
	}
	public Result BindMemory(Memory memory, uint64 offset)
	{
		Result result = m_Buffer.BindMemory((MemoryD3D12)memory, offset, true);

		return result;
	}

	public uint64 GetHandle(uint32 physicalDeviceIndex)
	{
		return m_Buffer.GetPointerGPU();
	}
}