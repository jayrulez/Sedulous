namespace NRI;

interface DescriptorSet
{
	public void SetDebugName(char8* name);

	public void UpdateDescriptorRanges(uint32 physicalDeviceMask, uint32 baseRange, uint32 rangeNum, DescriptorRangeUpdateDesc* rangeUpdateDescs);
	public void UpdateDynamicConstantBuffers(uint32 physicalDeviceMask, uint32 baseBuffer, uint32 bufferNum, Descriptor* descriptors);
	public void Copy(DescriptorSetCopyDesc descriptorSetCopyDesc);
}