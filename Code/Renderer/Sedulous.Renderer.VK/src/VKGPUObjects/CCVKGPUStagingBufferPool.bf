using Bulkan;
using System.Collections;
using System;
namespace Sedulous.Renderer.VK.Internal;

		/**
		 * Staging buffer pool, based on multiple fix-sized VkBuffer blocks.
		 */
class CCVKGPUStagingBufferPool
{
	public const uint32 CHUNK_SIZE = 16 * 1024 * 1024; // 16M per block by default

	public this(CCVKGPUDevice device)
	{
		_device = device;
	}

	public ~this()
	{
		_pool.Clear();
	}

	public CCVKGPUBufferView alloc(uint32 size) { return alloc(size, 1U); }

	public CCVKGPUBufferView alloc(uint32 size, uint32 alignment)
	{
		Runtime.Assert(size <= CHUNK_SIZE);

		int bufferCount = _pool.Count;
		Buffer* buffer = null;
		uint32 offset = 0U;
		for (int idx = 0U; idx < bufferCount; idx++)
		{
			Buffer* cur = &_pool[idx];
			offset = roundUp(cur.curOffset, alignment);
			if (size + offset <= CHUNK_SIZE)
			{
				buffer = cur;
				break;
			}
		}
		if (buffer == null)
		{
			_pool.Resize(bufferCount + 1);
			buffer = &_pool.Back;
			buffer.gpuBuffer = new CCVKGPUBuffer();
			buffer.gpuBuffer.size = CHUNK_SIZE;
			buffer.gpuBuffer.usage = BufferUsage.TRANSFER_SRC | BufferUsage.TRANSFER_DST;
			buffer.gpuBuffer.memUsage = MemoryUsage.HOST;
			buffer.gpuBuffer.init();
			offset = 0U;
		}
		var bufferView = new CCVKGPUBufferView();
		bufferView.gpuBuffer = buffer.gpuBuffer;
		bufferView.offset = offset;
		buffer.curOffset = offset + size;
		return bufferView;
	}

	public void reset()
	{
		for (Buffer buffer in _pool)
		{
			buffer.curOffset = 0U;
		}
	}

	private struct Buffer
	{
		public CCVKGPUBuffer gpuBuffer;
		public uint32 curOffset = 0U;
	};

	private CCVKGPUDevice _device = null;
	private List<Buffer> _pool = new .() ~ delete _;
}