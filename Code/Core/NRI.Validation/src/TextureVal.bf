namespace NRI.Validation;

class TextureVal : Texture, DeviceObjectVal<Texture>
{
	private MemoryVal m_Memory = null;
	bool m_IsBoundToMemory = false;
	TextureDesc m_TextureDesc = .();

	public this(DeviceVal device, Texture texture, TextureDesc textureDesc)
		: base(device, texture)
	{
		m_TextureDesc = textureDesc;
	}

	public ~this()
	{
		if (m_Memory != null)
			m_Memory.UnbindTexture(this);
	}

	public readonly ref TextureDesc GetDesc() => ref m_TextureDesc;

	public uint64 GetTextureNativeObject(uint32 physicalDeviceIndex)
		{ return m_ImplObject.GetTextureNativeObject(physicalDeviceIndex); }

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
}