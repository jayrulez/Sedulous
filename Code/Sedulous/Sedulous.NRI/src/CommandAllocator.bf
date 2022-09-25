namespace Sedulous.NRI;

interface CommandAllocator
{
	public void SetDebugName(char8* name);

	public Result CreateCommandBuffer(out CommandBuffer commandBuffer);
	public void Reset();
}