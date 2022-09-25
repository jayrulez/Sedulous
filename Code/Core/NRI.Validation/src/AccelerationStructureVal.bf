using System;
namespace NRI.Validation;

class AccelerationStructureVal : AccelerationStructure,  DeviceObjectVal<AccelerationStructure>
{
	MemoryVal m_Memory = null;

	public this(DeviceVal device, AccelerationStructure accelerationStructure) : base(device, accelerationStructure)
	{
	}

	public ~this()
	{
		if (m_Memory != null)
			m_Memory.UnbindAccelerationStructure(this);

		m_Device.DestroyAccelerationStructure(m_ImplObject);
	}

	public bool IsBoundToMemory()
		{ return m_Memory != null; }

	public void SetBoundToMemory(MemoryVal memory)
		{ m_Memory = memory; }

	public void GetMemoryInfo(ref MemoryDesc memoryDesc)
	{
		m_ImplObject.GetMemoryInfo(ref memoryDesc);
		m_Device.RegisterMemoryType(memoryDesc.type, MemoryLocation.DEVICE);
	}

	public uint64 GetUpdateScratchBufferSize()
	{
		return m_ImplObject.GetUpdateScratchBufferSize();
	}

	public uint64 GetBuildScratchBufferSize()
	{
		return m_ImplObject.GetBuildScratchBufferSize();
	}

	public uint64 GetHandle(uint32 physicalDeviceIndex)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_Memory != null, 0,
			"Can't get AccelerationStructure handle: AccelerationStructure is not bound to memory.");

		return m_ImplObject.GetHandle(physicalDeviceIndex);
	}

	public Result CreateDescriptor(uint32 physicalDeviceIndex, out Descriptor descriptor)
	{
		descriptor = ?;
		RETURN_ON_FAILURE!(m_Device.GetLogger(), physicalDeviceIndex < m_Device.GetPhysicalDeviceNum(), Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'physicalDeviceIndex' is invalid.");

		Descriptor descriptorImpl = null;
		readonly Result result = m_ImplObject.CreateDescriptor(physicalDeviceIndex, out descriptorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is nullptr.");
			descriptor = (Descriptor)Allocate!<DescriptorVal>(m_Device.GetAllocator(), m_Device, descriptorImpl, ResourceType.ACCELERATION_STRUCTURE);
		}

		return result;
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
}