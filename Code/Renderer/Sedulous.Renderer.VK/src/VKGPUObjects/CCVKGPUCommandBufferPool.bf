using Bulkan;
using System.Collections;
using Sedulous.Foundation.Collections;
using System;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Command buffer pool based on VkCommandPools, always try to reuse previous allocations first.
		 */
class CCVKGPUCommandBufferPool
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
	}

	public ~this()
	{
		for (var it in _pools)
		{
			ref CommandBufferPool pool = ref it.value;
			if (pool.vkCommandPool != .Null)
			{
				VulkanNative.vkDestroyCommandPool(_device.vkDevice, pool.vkCommandPool, null);
				pool.vkCommandPool = .Null;
				delete pool;
				pool = null;
			}
			for (var item in pool.usedCommandBuffers) item.Clear();
			for (var item in pool.commandBuffers) item.Clear();
		}
		_pools.Clear();
	}

	public uint32 getHash(uint32 queueFamilyIndex)
	{
		return (queueFamilyIndex << 10) | _device.curBackBufferIndex;
	}
	public static uint32 getBackBufferIndex(uint32 hash)
	{
		return hash & ((1 << 10) - 1);
	}

	public void request(CCVKGPUCommandBuffer gpuCommandBuffer)
	{
		uint32 hash = getHash(gpuCommandBuffer.queueFamilyIndex);

		if (_device.curBackBufferIndex != _lastBackBufferIndex)
		{
			reset();
			_lastBackBufferIndex = _device.curBackBufferIndex;
		}

		if (!_pools.ContainsKey(hash))
		{
			VkCommandPoolCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO };
			createInfo.queueFamilyIndex = gpuCommandBuffer.queueFamilyIndex;
			createInfo.flags = .VK_COMMAND_POOL_CREATE_TRANSIENT_BIT;
			VK_CHECK!(VulkanNative.vkCreateCommandPool(_device.vkDevice, &createInfo, null, &_pools[hash].vkCommandPool));
		}
		ref CommandBufferPool pool = ref _pools[hash];

		ref CachedArray<VkCommandBuffer> availableList = ref pool.commandBuffers[(int)gpuCommandBuffer.level];
		if (availableList.Size() != 0)
		{
			gpuCommandBuffer.vkCommandBuffer = availableList.Pop();
		}
		else
		{
			VkCommandBufferAllocateInfo allocateInfo = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO };
			allocateInfo.commandPool = pool.vkCommandPool;
			allocateInfo.commandBufferCount = 1;
			allocateInfo.level = gpuCommandBuffer.level;
			VK_CHECK!(VulkanNative.vkAllocateCommandBuffers(_device.vkDevice, &allocateInfo, &gpuCommandBuffer.vkCommandBuffer));
		}
	}

	public void _yield(CCVKGPUCommandBuffer gpuCommandBuffer)
	{
		if (gpuCommandBuffer.vkCommandBuffer != .Null)
		{
			uint32 hash = getHash(gpuCommandBuffer.queueFamilyIndex);
			Runtime.Assert(_pools.ContainsKey(hash)); // Wrong command pool to yield?

			ref CommandBufferPool pool = ref _pools[hash];
			pool.usedCommandBuffers[(int)gpuCommandBuffer.level].Push(gpuCommandBuffer.vkCommandBuffer);
			gpuCommandBuffer.vkCommandBuffer = .Null;
		}
	}

	public void reset()
	{
		for (var it in _pools)
		{
			if (getBackBufferIndex(it.key) != _device.curBackBufferIndex)
			{
				continue;
			}
			ref CommandBufferPool pool = ref it.value;

			bool needsReset = false;
			for (uint32 i = 0U; i < 2U; ++i)
			{
				ref CachedArray<VkCommandBuffer> usedList = ref pool.usedCommandBuffers[i];
				if (usedList.Size() != 0)
				{
					pool.commandBuffers[i].Concat(usedList);
					usedList.Clear();
					needsReset = true;
				}
			}
			if (needsReset)
			{
				VK_CHECK!(VulkanNative.vkResetCommandPool(_device.vkDevice, pool.vkCommandPool, 0));
			}
		}
	}

	private class CommandBufferPool
	{
		public VkCommandPool vkCommandPool = .Null;
		public CachedArray<VkCommandBuffer>[2] commandBuffers = .(new .(), new .()) ~ { delete _[0]; delete _[0]; delete _[1]; };
		public CachedArray<VkCommandBuffer>[2] usedCommandBuffers = .(new .(), new .()) ~ { delete _[0]; delete _[0]; delete _[1]; };
	}

	private CCVKGPUDevice _device = null;
	private uint32 _lastBackBufferIndex = 0U;

	private Dictionary<uint32, CommandBufferPool> _pools;
}