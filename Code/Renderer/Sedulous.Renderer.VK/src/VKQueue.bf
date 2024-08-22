using Sedulous.Renderer.VK.Internal;
using System;
using Bulkan;
/****************************************************************************
 Copyright (c) 2020-2023 Xiamen Yaji Software Co., Ltd.

 http://www.cocos.com

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
****************************************************************************/

namespace Sedulous.Renderer.VK;

class CCVKQueue : CommandQueue
{
	public this()
	{
		_typedID = generateObjectID<Self>();
	}
	public ~this()
	{
		destroy();
	}

	public override void submit(CommandBuffer* cmdBuffs, uint32 count)
	{
		CCVKDevice device = CCVKDevice.getInstance();
		_gpuQueue.commandBuffers.Clear();

		if (BARRIER_DEDUCTION_LEVEL >= BARRIER_DEDUCTION_LEVEL_BASIC)
		{
			device.gpuBarrierManager().update(device.gpuTransportHub());
		}
		device.gpuBufferHub().flush(device.gpuTransportHub());

		if (!device.gpuTransportHub().empty(false))
		{
			_gpuQueue.commandBuffers.Add(device.gpuTransportHub().packageForFlight(false));
		}

		for (uint32 i = 0U; i < count; ++i)
		{
			var cmdBuff = (CCVKCommandBuffer)cmdBuffs[i];
			if (!cmdBuff.[Friend]_pendingQueue.IsEmpty)
			{
				_gpuQueue.commandBuffers.Add(cmdBuff.[Friend]_pendingQueue.Front);
				cmdBuff.[Friend]_pendingQueue.PopFront();

				_numDrawCalls += cmdBuff.[Friend]_numDrawCalls;
				_numInstances += cmdBuff.[Friend]_numInstances;
				_numTriangles += cmdBuff.[Friend]_numTriangles;
			}
		}

		if (!device.gpuTransportHub().empty(true))
		{
			_gpuQueue.commandBuffers.Add(device.gpuTransportHub().packageForFlight(true));
		}

		int waitSemaphoreCount = _gpuQueue.lastSignaledSemaphores.Count;
		VkSemaphore signal = waitSemaphoreCount != 0 ? device.gpuSemaphorePool().alloc() : .Null;
		_gpuQueue.submitStageMasks.Resize(waitSemaphoreCount, .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

		VkSubmitInfo submitInfo = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		submitInfo.waitSemaphoreCount = (uint32)waitSemaphoreCount;
		submitInfo.pWaitSemaphores = _gpuQueue.lastSignaledSemaphores.Ptr;
		submitInfo.pWaitDstStageMask = _gpuQueue.submitStageMasks.Ptr;
		submitInfo.commandBufferCount = (uint32)_gpuQueue.commandBuffers.Count;
		submitInfo.pCommandBuffers = &_gpuQueue.commandBuffers[0];
		submitInfo.signalSemaphoreCount = waitSemaphoreCount != 0 ? 1 : 0;
		submitInfo.pSignalSemaphores = &signal;

		VkFence vkFence = device.gpuFencePool().alloc();
		VK_CHECK!(VulkanNative.vkQueueSubmit(_gpuQueue.vkQueue, 1, &submitInfo, vkFence));

		_gpuQueue.lastSignaledSemaphores..Clear().Resize(1, signal);
	}

	[Inline] public CCVKGPUQueue gpuQueue() { return _gpuQueue; }

	protected override void doInit(in QueueInfo info)
	{
		_gpuQueue = new CCVKGPUQueue();
		_gpuQueue.type = _type;
		cmdFuncCCVKGetDeviceQueue(CCVKDevice.getInstance(), _gpuQueue);
	}
	protected override void doDestroy()
	{
		_gpuQueue = null;
	}

	protected CCVKGPUQueue _gpuQueue;

	protected uint32 _numDrawCalls = 0;
	protected uint32 _numInstances = 0;
	protected uint32 _numTriangles = 0;
}
