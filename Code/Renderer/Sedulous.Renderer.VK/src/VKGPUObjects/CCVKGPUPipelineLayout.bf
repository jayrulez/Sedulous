using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUPipelineLayout : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		cmdFuncCCVKDestroyPipelineLayout(CCVKDevice.getInstance().gpuDevice(), this);
	}

	public List<CCVKGPUDescriptorSetLayout> setLayouts;

	public VkPipelineLayout vkPipelineLayout = .Null;

	// helper storage
	public List<uint32> dynamicOffsetOffsets;
	public uint32 dynamicOffsetCount;
}