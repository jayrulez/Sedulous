namespace NRI;

interface Descriptor
{
	public void SetDebugName(char8* name);

	public uint64 GetDescriptorNativeObject(uint32 physicalDeviceIndex);
}