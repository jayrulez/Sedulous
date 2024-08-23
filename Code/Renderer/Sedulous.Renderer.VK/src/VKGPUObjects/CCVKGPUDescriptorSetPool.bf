using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Unlimited descriptor set pool, based on multiple fix-sized VkDescriptorPools.
		 */
class CCVKGPUDescriptorSetPool
{
	public ~this()
	{
		for (var pool in _pools)
		{
			VulkanNative.vkDestroyDescriptorPool(_device.vkDevice, pool, null);
		}
	}

	public void link(CCVKGPUDevice device, uint32 maxSetsPerPool, in List<VkDescriptorSetLayoutBinding> bindings, VkDescriptorSetLayout setLayout)
	{
		_device = device;
		_maxSetsPerPool = maxSetsPerPool;

		_setLayouts.Insert(0, scope List<VkDescriptorSetLayout>()..Resize(_maxSetsPerPool, setLayout));

		Dictionary<VkDescriptorType, uint32> typeMap = scope .();
		for (var vkBinding in bindings)
		{
			typeMap[vkBinding.descriptorType] += maxSetsPerPool * vkBinding.descriptorCount;
		}

		// minimal reserve for empty set layouts
		if (bindings.IsEmpty)
		{
			typeMap[.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER] = 1;
		}

		_poolSizes.Clear();
		for (var it in typeMap)
		{
			_poolSizes.Add(.() { type = it.key, descriptorCount = it.value });
		}
	}

	public VkDescriptorSet request()
	{
		if (_freeList.IsEmpty)
		{
			requestPool();
		}
		return pop();
	}

	public void requestPool()
	{
		VkDescriptorPoolCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO };
		createInfo.maxSets = _maxSetsPerPool;
		createInfo.poolSizeCount = uint32(_poolSizes.Count);
		createInfo.pPoolSizes = _poolSizes.Ptr;

		VkDescriptorPool descriptorPool = .Null;
		VK_CHECK!(VulkanNative.vkCreateDescriptorPool(_device.vkDevice, &createInfo, null, &descriptorPool));
		_pools.Add(descriptorPool);

		List<VkDescriptorSet> sets = scope .() { Count = _maxSetsPerPool };
		VkDescriptorSetAllocateInfo info = .() { sType = .VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO };
		info.pSetLayouts = _setLayouts.Ptr;
		info.descriptorSetCount = _maxSetsPerPool;
		info.descriptorPool = descriptorPool;
		VK_CHECK!(VulkanNative.vkAllocateDescriptorSets(_device.vkDevice, &info, sets.Ptr));

		_freeList.AddRange(sets);
	}

	public void _yield(VkDescriptorSet set)
	{
		_freeList.Add(set);
	}


	private VkDescriptorSet pop()
	{
		VkDescriptorSet output = .Null;
		if (!_freeList.IsEmpty)
		{
			output = _freeList.Back;
			_freeList.PopBack();
			return output;
		}
		return .Null;
	}

	private CCVKGPUDevice _device = null;

	private List<VkDescriptorPool> _pools;
	private List<VkDescriptorSet> _freeList;

	private List<VkDescriptorPoolSize> _poolSizes;
	private List<VkDescriptorSetLayout> _setLayouts;
	private uint32 _maxSetsPerPool = 0U;
}