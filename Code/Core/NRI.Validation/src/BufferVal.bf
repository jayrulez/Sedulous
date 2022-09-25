namespace NRI.Validation;

class BufferVal : Buffer,  DeviceObjectVal<Buffer>
{
	private MemoryVal m_Memory = null;
	private BufferDesc m_BufferDesc = .();
	private bool m_IsBoundToMemory = false;
	private bool m_IsMapped = false;

	public this(DeviceVal device, Buffer buffer, BufferDesc bufferDesc) : base(device, buffer)
	{
		m_BufferDesc = bufferDesc;
	}

	public ~this()
	{
		if (m_Memory != null)
			m_Memory.UnbindBuffer(this);
	}

	public readonly ref BufferDesc GetDesc() => ref m_BufferDesc;

	public uint64 GetBufferNativeObject(uint32 physicalDeviceIndex)
		{ return m_ImplObject.GetBufferNativeObject(physicalDeviceIndex); }

	public bool IsBoundToMemory()
		{ return m_IsBoundToMemory; }

	public void SetBoundToMemory()
		{ m_IsBoundToMemory = true; }

	public void SetBoundToMemory(MemoryVal memory)
	{
		m_Memory = memory;
		m_IsBoundToMemory = true;
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
	public void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc)
	{
		m_ImplObject.GetMemoryInfo(memoryLocation, ref memoryDesc);
		m_Device.RegisterMemoryType(memoryDesc.type, memoryLocation);
	}
	public void* Map(uint64 offset, uint64 size)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsBoundToMemory, (void*)null,
			"Can't map Buffer: Buffer is not bound to memory.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), !m_IsMapped, (void*)null,
			"Can't map Buffer: the buffer is already mapped.");

		m_IsMapped = true;

		return m_ImplObject.Map(offset, size);
	}

	public void Unmap()
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsMapped, void(),
			"Can't unmap Buffer: the buffer is not mapped.");

		m_IsMapped = false;

		m_ImplObject.Unmap();
	}
}