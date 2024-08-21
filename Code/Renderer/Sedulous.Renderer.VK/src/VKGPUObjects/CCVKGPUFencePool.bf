using Bulkan;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * A simple pool for reusing fences.
		 */
class CCVKGPUFencePool
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
	}

	public ~this()
	{
		for (VkFence fence in _fences)
		{
			VulkanNative.vkDestroyFence(_device.vkDevice, fence, null);
		}
		_fences.Clear();
		_count = 0;
	}

	public VkFence alloc()
	{
		if (_count < _fences.Count)
		{
			return _fences[_count++];
		}

		VkFence fence = .Null;
		VkFenceCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
		VK_CHECK!(VulkanNative.vkCreateFence(_device.vkDevice, &createInfo, null, &fence));
		_fences.Add(fence);
		_count++;

		return fence;
	}

	public void reset()
	{
		if (_count != 0)
		{
			VK_CHECK!(VulkanNative.vkResetFences(_device.vkDevice, _count, _fences.Ptr));
			_count = 0;
		}
	}

	public VkFence* data()
	{
		return _fences.Ptr;
	}

	public uint32 size()
	{
		return _count;
	}

	private CCVKGPUDevice _device = null;
	private uint32 _count = 0U;
	private List<VkFence> _fences;
}