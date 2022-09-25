namespace NRI;

interface Texture
{
	public void SetDebugName(char8* name);
	
	public void GetMemoryInfo(MemoryLocation memoryLocation, ref MemoryDesc memoryDesc);

	public uint64 GetTextureNativeObject(uint32 physicalDeviceIndex);
}