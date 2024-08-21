using Bulkan;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * A simple pool for reusing semaphores.
		 */
class CCVKGPUSemaphorePool
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
	}

	public ~this()
	{
		for (VkSemaphore semaphore in _semaphores)
		{
			VulkanNative.vkDestroySemaphore(_device.vkDevice, semaphore, null);
		}
		_semaphores.Clear();
		_count = 0;
	}

	public VkSemaphore alloc()
	{
		if (_count < _semaphores.Count)
		{
			return _semaphores[_count++];
		}

		VkSemaphore semaphore = .Null;
		VkSemaphoreCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
		VK_CHECK!(VulkanNative.vkCreateSemaphore(_device.vkDevice, &createInfo, null, &semaphore));
		_semaphores.Add(semaphore);
		_count++;

		return semaphore;
	}

	public void reset()
	{
		_count = 0;
	}

	public uint32 size()
	{
		return _count;
	}

	private CCVKGPUDevice _device;
	private uint32 _count = 0U;
	private List<VkSemaphore> _semaphores;
}