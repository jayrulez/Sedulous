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
#include "gfx-base/GFXRenderPass.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
	namespace gfx {

		class CC_VULKAN_API CCVKRenderPass final : public RenderPass {
		public:
			CCVKRenderPass() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKRenderPass() {
				destroy();
			}

			inline CCVKGPURenderPass* gpuRenderPass() const { return _gpuRenderPass; }

		protected:
			void doInit(const RenderPassInfo& info) {
				_gpuRenderPass = ccnew CCVKGPURenderPass;
				_gpuRenderPass->colorAttachments = _colorAttachments;
				_gpuRenderPass->depthStencilAttachment = _depthStencilAttachment;
				_gpuRenderPass->depthStencilResolveAttachment = _depthStencilResolveAttachment;
				_gpuRenderPass->subpasses = _subpasses;
				_gpuRenderPass->dependencies = _dependencies;

				// assign a dummy subpass if not specified
				uint32 colorCount = utils::toUint(_gpuRenderPass->colorAttachments.size());
				if (_gpuRenderPass->subpasses.empty()) {
					_gpuRenderPass->subpasses.emplace_back();
					auto& subpass = _gpuRenderPass->subpasses.back();
					subpass.colors.resize(_colorAttachments.size());
					for (uint32 i = 0U; i < _colorAttachments.size(); ++i) {
						subpass.colors[i] = i;
					}
					if (_depthStencilAttachment.format != Format::UNKNOWN) {
						subpass.depthStencil = colorCount;
					}
					if (_depthStencilResolveAttachment.format != Format::UNKNOWN) {
						subpass.depthStencilResolve = colorCount + 1;
					}
				}
				else {
					// unify depth stencil index
					for (auto& subpass : _gpuRenderPass->subpasses) {
						if (subpass.depthStencil != INVALID_BINDING && subpass.depthStencil >= colorCount) {
							subpass.depthStencil = colorCount;
						}
						if (subpass.depthStencilResolve != INVALID_BINDING && subpass.depthStencilResolve >= colorCount) {
							subpass.depthStencilResolve = colorCount + 1;
						}
					}
				}

				cmdFuncCCVKCreateRenderPass(CCVKDevice::getInstance(), _gpuRenderPass);
			}
			void doDestroy() {
				_gpuRenderPass = null;
			}

			IntrusivePtr<CCVKGPURenderPass> _gpuRenderPass;
		};

	} // namespace gfx
} // namespace cc
