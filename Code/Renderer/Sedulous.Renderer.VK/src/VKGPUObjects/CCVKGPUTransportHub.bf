using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Transport hub for data traveling between host and devices.
		 * Record all transfer commands until batched submission.
		 */
		 // #define ASYNC_BUFFER_UPDATE
class CCVKGPUTransportHub
{
	public this(CCVKGPUDevice device, CCVKGPUQueue queue)
	{
		_device = device;
		_queue = queue;

		_earlyCmdBuff.level = .VK_COMMAND_BUFFER_LEVEL_PRIMARY;
		_earlyCmdBuff.queueFamilyIndex = _queue.queueFamilyIndex;

		_lateCmdBuff.level = .VK_COMMAND_BUFFER_LEVEL_PRIMARY;
		_lateCmdBuff.queueFamilyIndex = _queue.queueFamilyIndex;

		VkFenceCreateInfo createInfo = .() { sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO };
		VK_CHECK!(VulkanNative.vkCreateFence(_device.vkDevice, &createInfo, null, &_fence));
	}

	public ~this()
	{
		if (_fence != .Null)
		{
			VulkanNative.vkDestroyFence(_device.vkDevice, _fence, null);
			_fence = .Null;
		}
	}

	public bool empty(bool late)
	{
		readonly CCVKGPUCommandBuffer cmdBuff = late ? _lateCmdBuff : _earlyCmdBuff;

		return cmdBuff.vkCommandBuffer == .Null;
	}

	public void checkIn<TFunc>(TFunc record, bool immediateSubmission = false, bool late = false) where TFunc : delegate void(CCVKGPUCommandBuffer)
	{
		CCVKGPUCommandBufferPool commandBufferPool = _device.getCommandBufferPool();
		CCVKGPUCommandBuffer cmdBuff = late ? _lateCmdBuff : _earlyCmdBuff;

		if (cmdBuff.vkCommandBuffer == .Null)
		{
			commandBufferPool.request(cmdBuff);
			VkCommandBufferBeginInfo beginInfo = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
			beginInfo.flags = .VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
			VK_CHECK!(VulkanNative.vkBeginCommandBuffer(cmdBuff.vkCommandBuffer, &beginInfo));
		}

		record(cmdBuff);

		if (immediateSubmission)
		{
			VK_CHECK!(VulkanNative.vkEndCommandBuffer(cmdBuff.vkCommandBuffer));
			VkSubmitInfo submitInfo = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
			submitInfo.commandBufferCount = 1;
			submitInfo.pCommandBuffers = &cmdBuff.vkCommandBuffer;
			VK_CHECK!(VulkanNative.vkQueueSubmit(_queue.vkQueue, 1, &submitInfo, _fence));
			VK_CHECK!(VulkanNative.vkWaitForFences(_device.vkDevice, 1, &_fence, VulkanNative.VK_TRUE, DEFAULT_TIMEOUT));
			VulkanNative.vkResetFences(_device.vkDevice, 1, &_fence);
			commandBufferPool.yield(cmdBuff);
			cmdBuff.vkCommandBuffer = .Null;
		}
	}

	public VkCommandBuffer packageForFlight(bool late)
	{
		CCVKGPUCommandBuffer cmdBuff = late ? _lateCmdBuff : _earlyCmdBuff;

		VkCommandBuffer vkCommandBuffer = cmdBuff.vkCommandBuffer;
		if (vkCommandBuffer != .Null)
		{
			VK_CHECK!(VulkanNative.vkEndCommandBuffer(vkCommandBuffer));
			_device.getCommandBufferPool().@yield(cmdBuff);
		}
		return vkCommandBuffer;
	}

	private CCVKGPUDevice _device = null;

	private CCVKGPUQueue _queue = null;
	private CCVKGPUCommandBuffer _earlyCmdBuff;
	private CCVKGPUCommandBuffer _lateCmdBuff;
	private VkFence _fence = .Null;
}