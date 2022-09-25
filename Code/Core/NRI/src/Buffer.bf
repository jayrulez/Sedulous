namespace NRI;

interface Buffer
{
	public void SetDebugName(char8* name);
	
	public void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc);
	public void* Map( uint64 offset, uint64 size);
	public void Unmap();

	public uint64 GetBufferNativeObject(uint32 physicalDeviceIndex);
}