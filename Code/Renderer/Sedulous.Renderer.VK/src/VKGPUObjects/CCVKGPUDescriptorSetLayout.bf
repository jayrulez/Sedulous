using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUDescriptorSetLayout : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		if (defaultDescriptorSet != .Null)
		{
			CCVKDevice.getInstance().gpuRecycleBin().collect(id, defaultDescriptorSet);
		}

		cmdFuncCCVKDestroyDescriptorSetLayout(CCVKDevice.getInstance().gpuDevice(), this);
	}

	public DescriptorSetLayoutBindingList bindings;
	public List<uint32> dynamicBindings;

	public List<VkDescriptorSetLayoutBinding> vkBindings;
	public VkDescriptorSetLayout vkDescriptorSetLayout = .Null;
	public VkDescriptorUpdateTemplate vkDescriptorUpdateTemplate = .Null;
	public VkDescriptorSet defaultDescriptorSet = .Null;

	public List<uint32> bindingIndices;
	public List<uint32> descriptorIndices;
	public uint32 descriptorCount = 0U;

	public uint32 id = 0U;
	public uint32 maxSetsPerPool = 10U;
}