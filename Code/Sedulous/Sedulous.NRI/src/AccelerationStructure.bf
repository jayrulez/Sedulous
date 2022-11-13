namespace Sedulous.NRI;

interface AccelerationStructure
{
	public void SetDebugName(char8* name);

	public Result CreateDescriptor(uint32 physicalDeviceMask, out Descriptor descriptor);

	public void GetMemoryInfo(ref MemoryDesc memoryDesc);
	public uint64 GetUpdateScratchBufferSize();
	public uint64 GetBuildScratchBufferSize();
	public uint64 GetHandle(uint32 physicalDeviceIndex);
	public uint64 GetNativeObject(uint32 physicalDeviceIndex); // ID3D12Resource* or VkAccelerationStructureKHR

}