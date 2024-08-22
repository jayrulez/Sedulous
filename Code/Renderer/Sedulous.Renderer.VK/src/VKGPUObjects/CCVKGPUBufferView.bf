using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUBufferView : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuDescriptorHub().disengage(this);
		CCVKDevice.getInstance().gpuIAHub().disengage(this);
	}
	public CCVKGPUBuffer gpuBuffer;
	public uint32 offset = 0U;
	public uint32 range = 0U;

	public uint8* mappedData()
	{
		return gpuBuffer.mappedData + offset;
	}

	public VkDeviceSize getStartOffset(uint32 curBackBufferIndex)
	{
		return (VkDeviceSize)gpuBuffer.getStartOffset(curBackBufferIndex) + offset;
	}
}