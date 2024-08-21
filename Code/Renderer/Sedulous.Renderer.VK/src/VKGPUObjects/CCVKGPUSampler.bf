using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUSampler : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuDescriptorHub().disengage(this);
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}
	public void init()
	{
		cmdFuncCCVKCreateSampler(CCVKDevice.getInstance(), this);
	}

	public Filter minFilter = Filter.LINEAR;
	public Filter magFilter = Filter.LINEAR;
	public Filter mipFilter = Filter.NONE;
	public Address addressU = Address.WRAP;
	public Address addressV = Address.WRAP;
	public Address addressW = Address.WRAP;
	public uint32 maxAnisotropy = 0U;
	public ComparisonFunc cmpFunc = ComparisonFunc.NEVER;

	// descriptor infos
	public VkSampler vkSampler;
}