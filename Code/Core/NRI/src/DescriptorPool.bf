namespace NRI;

interface DescriptorPool
{
	public void SetDebugName(char8* name);

	public Result AllocateDescriptorSets(PipelineLayout pipelineLayout, uint32 setIndex, DescriptorSet* descriptorSets, uint32 instanceNum, uint32 physicalDeviceMask, uint32 variableDescriptorNum);
	public void Reset();
}