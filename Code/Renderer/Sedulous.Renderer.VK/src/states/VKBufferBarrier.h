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

#pragma once

#include "../VKStd.h"
#include "gfx-base/states/GFXBufferBarrier.h"

namespace cc {
	namespace gfx {

		struct CCVKGPUBufferBarrier;

		class CC_VULKAN_API CCVKBufferBarrier : public BufferBarrier {
		public:
			explicit CCVKBufferBarrier(const BufferBarrierInfo& info) {
				_typedID = generateObjectID<decltype(this)>();

				_gpuBarrier = std::make_unique<CCVKGPUBufferBarrier>();
				getAccessTypes(info.prevAccesses, _gpuBarrier->prevAccesses);
				getAccessTypes(info.nextAccesses, _gpuBarrier->nextAccesses);

				_gpuBarrier->barrier.prevAccessCount = utils::toUint(_gpuBarrier->prevAccesses.size());
				_gpuBarrier->barrier.pPrevAccesses = _gpuBarrier->prevAccesses.data();
				_gpuBarrier->barrier.nextAccessCount = utils::toUint(_gpuBarrier->nextAccesses.size());
				_gpuBarrier->barrier.pNextAccesses = _gpuBarrier->nextAccesses.data();

				_gpuBarrier->barrier.offset = info.offset;
				_gpuBarrier->barrier.size = info.size;
				_gpuBarrier->barrier.srcQueueFamilyIndex = info.srcQueue
					? static_cast<CCVKQueue*>(info.srcQueue)->gpuQueue()->queueFamilyIndex
					: VK_QUEUE_FAMILY_IGNORED;
				_gpuBarrier->barrier.dstQueueFamilyIndex = info.dstQueue
					? static_cast<CCVKQueue*>(info.dstQueue)->gpuQueue()->queueFamilyIndex
					: VK_QUEUE_FAMILY_IGNORED;

				thsvsGetVulkanBufferMemoryBarrier(_gpuBarrier->barrier, &_gpuBarrier->srcStageMask, &_gpuBarrier->dstStageMask, &_gpuBarrier->vkBarrier);
			}
			~CCVKBufferBarrier() override = default;

			inline const CCVKGPUBufferBarrier* gpuBarrier() const { return _gpuBarrier.get(); }

		protected:
			std::unique_ptr<CCVKGPUBufferBarrier> _gpuBarrier;
		};

	} // namespace gfx
} // namespace cc