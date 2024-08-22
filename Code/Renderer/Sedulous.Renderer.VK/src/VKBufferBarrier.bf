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

using Bulkan.Utilities;

class CCVKBufferBarrier : BufferBarrier
{
	public this(in BufferBarrierInfo info)
		: base(info)
	{
		_typedID = generateObjectID<decltype(this)>();

		_gpuBarrier = new CCVKGPUBufferBarrier();
		getAccessTypes(info.prevAccesses, ref _gpuBarrier.prevAccesses);
		getAccessTypes(info.nextAccesses, ref _gpuBarrier.nextAccesses);

		_gpuBarrier.barrier.prevAccessCount = (uint32)_gpuBarrier.prevAccesses.Count;
		_gpuBarrier.barrier.pPrevAccesses = _gpuBarrier.prevAccesses.Ptr;
		_gpuBarrier.barrier.nextAccessCount = (uint32)_gpuBarrier.nextAccesses.Count;
		_gpuBarrier.barrier.pNextAccesses = _gpuBarrier.nextAccesses.Ptr;

		_gpuBarrier.barrier.offset = (VkDeviceSize)info.offset;
		_gpuBarrier.barrier.size = (VkDeviceSize)info.size;
		_gpuBarrier.barrier.srcQueueFamilyIndex = info.srcQueue != null
			? ((CCVKQueue)info.srcQueue).gpuQueue().queueFamilyIndex
			: VulkanNative.VK_QUEUE_FAMILY_IGNORED;
		_gpuBarrier.barrier.dstQueueFamilyIndex = info.dstQueue != null
			? ((CCVKQueue)info.dstQueue).gpuQueue().queueFamilyIndex
			: VulkanNative.VK_QUEUE_FAMILY_IGNORED;

		thsvsGetVulkanBufferMemoryBarrier(_gpuBarrier.barrier, &_gpuBarrier.srcStageMask, &_gpuBarrier.dstStageMask, &_gpuBarrier.vkBarrier);
	}
	public ~this() { }

	[Inline] public CCVKGPUBufferBarrier gpuBarrier() { return _gpuBarrier; }

	protected CCVKGPUBufferBarrier _gpuBarrier;
}
