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

#include "VKStd.h"
#include "gfx-base/GFXInputAssembler.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
	namespace gfx {

		struct CCVKGPUInputAssembler;

		class CC_VULKAN_API CCVKInputAssembler final : public InputAssembler {
		public:
			CCVKInputAssembler() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKInputAssembler() {
				destroy();
			}

			inline CCVKGPUInputAssembler* gpuInputAssembler() const { return _gpuInputAssembler; }

		protected:
			void doInit(const InputAssemblerInfo& info) {
				size_t vbCount = _vertexBuffers.size();

				_gpuInputAssembler = ccnew CCVKGPUInputAssembler;
				_gpuInputAssembler->attributes = _attributes;
				_gpuInputAssembler->gpuVertexBuffers.resize(vbCount);

				auto* hub = CCVKDevice::getInstance()->gpuIAHub();
				for (size_t i = 0U; i < vbCount; ++i) {
					auto* vb = static_cast<CCVKBuffer*>(_vertexBuffers[i]);
					_gpuInputAssembler->gpuVertexBuffers[i] = vb->gpuBufferView();
					hub->connect(_gpuInputAssembler, _gpuInputAssembler->gpuVertexBuffers[i].get());
				}

				if (info.indexBuffer) {
					_gpuInputAssembler->gpuIndexBuffer = static_cast<CCVKBuffer*>(info.indexBuffer)->gpuBufferView();
					hub->connect(_gpuInputAssembler, _gpuInputAssembler->gpuIndexBuffer.get());
				}

				if (info.indirectBuffer) {
					_gpuInputAssembler->gpuIndirectBuffer = static_cast<CCVKBuffer*>(info.indirectBuffer)->gpuBufferView();
					hub->connect(_gpuInputAssembler, _gpuInputAssembler->gpuIndirectBuffer.get());
				}

				_gpuInputAssembler->vertexBuffers.resize(vbCount);
				_gpuInputAssembler->vertexBufferOffsets.resize(vbCount);

				CCVKGPUDevice* gpuDevice = CCVKDevice::getInstance()->gpuDevice();
				for (size_t i = 0U; i < vbCount; i++) {
					_gpuInputAssembler->vertexBuffers[i] = _gpuInputAssembler->gpuVertexBuffers[i]->gpuBuffer->vkBuffer;
					_gpuInputAssembler->vertexBufferOffsets[i] = _gpuInputAssembler->gpuVertexBuffers[i]->getStartOffset(gpuDevice->curBackBufferIndex);
				}
			}
			void doDestroy() {
				_gpuInputAssembler = null;
			}

			IntrusivePtr<CCVKGPUInputAssembler> _gpuInputAssembler;
		};

	} // namespace gfx
} // namespace cc
