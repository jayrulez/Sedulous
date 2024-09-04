using System.Collections;
using Bulkan;
using static Bulkan.VulkanNative;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Manages descriptor set update events, across all back buffer instances.
		 */
class CCVKGPUDescriptorSetHub
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
		_setsToBeUpdated.Resize(device.backBufferCount);
		for(int i = 0; i < _setsToBeUpdated.Count; i++)
		{
			_setsToBeUpdated[i] = new .();
		}
		//if (device.minorVersion > 0)
		{
			_updateFn = => VulkanNative.vkUpdateDescriptorSetWithTemplate;
		}
		//else
		//{
		//	_updateFn =  =>VulkanNative.vkUpdateDescriptorSetWithTemplateKHR;
		//}
	}

	public void record(CCVKGPUDescriptorSet gpuDescriptorSet)
	{
		update(gpuDescriptorSet);
		for (uint32 i = 0U; i < _device.backBufferCount; ++i)
		{
			if (i == _device.curBackBufferIndex)
			{
				_setsToBeUpdated[i].Remove(gpuDescriptorSet);
			}
			else
			{
				_setsToBeUpdated[i].Add(gpuDescriptorSet);
			}
		}
	}

	public void erase(CCVKGPUDescriptorSet gpuDescriptorSet)
	{
		for (uint32 i = 0U; i < _device.backBufferCount; ++i)
		{
			if (_setsToBeUpdated[i].Contains(gpuDescriptorSet))
			{
				_setsToBeUpdated[i].Remove(gpuDescriptorSet);
			}
		}
	}

	public void flush()
	{
		ref DescriptorSetList sets = ref _setsToBeUpdated[_device.curBackBufferIndex];
		for (var set in sets)
		{
			update(set);
		}
		sets.Clear();
	}

	public void updateBackBufferCount(uint32 backBufferCount)
	{
		_setsToBeUpdated.Resize(backBufferCount);
	}

	private void update(CCVKGPUDescriptorSet gpuDescriptorSet)
	{
		readonly ref CCVKGPUDescriptorSet.Instance instance = ref gpuDescriptorSet.instances[_device.curBackBufferIndex];
		if (gpuDescriptorSet.gpuLayout.vkDescriptorUpdateTemplate != .Null)
		{
			_updateFn(_device.vkDevice, instance.vkDescriptorSet,
				gpuDescriptorSet.gpuLayout.vkDescriptorUpdateTemplate, instance.descriptorInfos.Ptr);
		}
		else
		{
			readonly ref List<VkWriteDescriptorSet> entries = ref instance.descriptorUpdateEntries;
			VulkanNative.vkUpdateDescriptorSets(_device.vkDevice, uint32(entries.Count), entries.Ptr, 0, null);
		}
	}

	private typealias DescriptorSetList = HashSet<CCVKGPUDescriptorSet>;

	private CCVKGPUDevice _device = null;
	private List<DescriptorSetList> _setsToBeUpdated = new .() ~ delete _;
	private vkUpdateDescriptorSetWithTemplateFunction _updateFn = null;
}