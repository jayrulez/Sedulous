using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUPipelineLayout : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		cmdFuncCCVKDestroyPipelineLayout(CCVKDevice.getInstance().gpuDevice(), this);
	}

	public List<CCVKGPUDescriptorSetLayout> setLayouts = new .() ~ delete _;

	public VkPipelineLayout vkPipelineLayout = .Null;

	// helper storage
	public List<uint32> dynamicOffsetOffsets = new .() ~ delete _;
	public uint32 dynamicOffsetCount;
}