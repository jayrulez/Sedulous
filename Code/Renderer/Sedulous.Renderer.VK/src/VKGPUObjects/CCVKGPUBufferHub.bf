using System.Collections;
using System;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Manages buffer update events, across all back buffer instances.
		 */
class CCVKGPUBufferHub
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
		_buffersToBeUpdated.Resize(device.backBufferCount);
	}

	public void record(CCVKGPUBuffer gpuBuffer, uint32 backBufferIndex, uint size, bool canMemcpy)
	{
		for (uint32 i = 0U; i < _device.backBufferCount; ++i)
		{
			if (i == backBufferIndex)
			{
				_buffersToBeUpdated[i].Remove(gpuBuffer);
			}
			else
			{
				_buffersToBeUpdated[i][gpuBuffer] = .() { srcIndex = backBufferIndex, size = size, canMemcpy = canMemcpy };
			}
		}
	}

	public void erase(CCVKGPUBuffer gpuBuffer)
	{
		for (uint32 i = 0U; i < _device.backBufferCount; ++i)
		{
			if (_buffersToBeUpdated[i].ContainsKey(gpuBuffer))
			{
				_buffersToBeUpdated[i].Remove(gpuBuffer);
			}
		}
	}

	public void updateBackBufferCount(uint32 backBufferCount)
	{
		_buffersToBeUpdated.Resize(backBufferCount);
	}

	public void flush(CCVKGPUTransportHub transportHub)
	{
		var buffers = ref _buffersToBeUpdated[_device.curBackBufferIndex];
		if (buffers.IsEmpty) return;

		bool needTransferCmds = false;
		for (var buffer in buffers)
		{
			if (buffer.value.canMemcpy)
			{
				uint8* src = buffer.key.mappedData + buffer.value.srcIndex * buffer.key.instanceSize;
				uint8* dst = buffer.key.mappedData + _device.curBackBufferIndex * buffer.key.instanceSize;
				Internal.MemCpy(dst, src, (int)buffer.value.size);
			}
			else
			{
				needTransferCmds = true;
			}
		}
		if (needTransferCmds)
		{
			transportHub.checkIn(scope [&] (gpuCommandBuffer) =>
				{
					VkBufferCopy region = .();
					for (var buffer in buffers)
					{
						if (buffer.value.canMemcpy) continue;
						region.srcOffset = buffer.key.getStartOffset(buffer.value.srcIndex);
						region.dstOffset = buffer.key.getStartOffset(_device.curBackBufferIndex);
						region.size = buffer.value.size;
						VulkanNative.vkCmdCopyBuffer(gpuCommandBuffer.vkCommandBuffer, buffer.key.vkBuffer, buffer.key.vkBuffer, 1, &region);
					}
				});
		}

		buffers.Clear();
	}

	private struct BufferUpdate
	{
		public uint32 srcIndex = 0U;
		public uint size = 0U;
		public bool canMemcpy = false;
	}

	private List<Dictionary<CCVKGPUBuffer, BufferUpdate>> _buffersToBeUpdated = new .() ~ delete _;

	private CCVKGPUDevice _device = null;
}