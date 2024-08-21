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

#pragma once

#include <memory>
#include "VKStd.h"
#include "gfx-base/GFXQueue.h"

namespace cc {
	namespace gfx {

		struct CCVKGPUQueue;

		class CC_VULKAN_API CCVKQueue final : public Queue {
		public:
			CCVKQueue() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKQueue() {
				destroy();
			}

			void submit(CommandBuffer* const* cmdBuffs, uint32 count) {
				CCVKDevice* device = CCVKDevice::getInstance();
				_gpuQueue->commandBuffers.clear();

#if BARRIER_DEDUCTION_LEVEL >= BARRIER_DEDUCTION_LEVEL_BASIC
				device->gpuBarrierManager()->update(device->gpuTransportHub());
#endif
				device->gpuBufferHub()->flush(device->gpuTransportHub());

				if (!device->gpuTransportHub()->empty(false)) {
					_gpuQueue->commandBuffers.push_back(device->gpuTransportHub()->packageForFlight(false));
				}

				for (uint32 i = 0U; i < count; ++i) {
					auto* cmdBuff = static_cast<CCVKCommandBuffer*>(cmdBuffs[i]);
					if (!cmdBuff->_pendingQueue.empty()) {
						_gpuQueue->commandBuffers.push_back(cmdBuff->_pendingQueue.front());
						cmdBuff->_pendingQueue.pop();

						_numDrawCalls += cmdBuff->_numDrawCalls;
						_numInstances += cmdBuff->_numInstances;
						_numTriangles += cmdBuff->_numTriangles;
					}
				}

				if (!device->gpuTransportHub()->empty(true)) {
					_gpuQueue->commandBuffers.push_back(device->gpuTransportHub()->packageForFlight(true));
				}

				size_t waitSemaphoreCount = _gpuQueue->lastSignaledSemaphores.size();
				VkSemaphore signal = waitSemaphoreCount ? device->gpuSemaphorePool()->alloc() : VK_NULL_HANDLE;
				_gpuQueue->submitStageMasks.resize(waitSemaphoreCount, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT);

				VkSubmitInfo submitInfo{ VK_STRUCTURE_TYPE_SUBMIT_INFO };
				submitInfo.waitSemaphoreCount = utils::toUint(waitSemaphoreCount);
				submitInfo.pWaitSemaphores = _gpuQueue->lastSignaledSemaphores.data();
				submitInfo.pWaitDstStageMask = _gpuQueue->submitStageMasks.data();
				submitInfo.commandBufferCount = utils::toUint(_gpuQueue->commandBuffers.size());
				submitInfo.pCommandBuffers = &_gpuQueue->commandBuffers[0];
				submitInfo.signalSemaphoreCount = waitSemaphoreCount ? 1 : 0;
				submitInfo.pSignalSemaphores = &signal;

				VkFence vkFence = device->gpuFencePool()->alloc();
				VK_CHECK(vkQueueSubmit(_gpuQueue->vkQueue, 1, &submitInfo, vkFence));

				_gpuQueue->lastSignaledSemaphores.assign(1, signal);
			}

			inline CCVKGPUQueue* gpuQueue() const { return _gpuQueue.get(); }

		protected:
			friend class CCVKDevice;

			void doInit(const QueueInfo& info) {
				_gpuQueue = std::make_unique<CCVKGPUQueue>();
				_gpuQueue->type = _type;
				cmdFuncCCVKGetDeviceQueue(CCVKDevice::getInstance(), _gpuQueue.get());
			}
			void doDestroy() {
				_gpuQueue = null;
			}

			std::unique_ptr<CCVKGPUQueue> _gpuQueue;

			uint32 _numDrawCalls = 0;
			uint32 _numInstances = 0;
			uint32 _numTriangles = 0;
		};

	} // namespace gfx
} // namespace cc
