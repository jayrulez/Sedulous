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
#include "gfx-base/GFXDescriptorSetLayout.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
	namespace gfx {

		class CC_VULKAN_API CCVKDescriptorSetLayout final : public DescriptorSetLayout {
		public:
			CCVKDescriptorSetLayout() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKDescriptorSetLayout() {
				destroy();
			}

			inline CCVKGPUDescriptorSetLayout* gpuDescriptorSetLayout() const { return _gpuDescriptorSetLayout; }

		protected:
			static uint32 generateID() noexcept {
				static uint32 idGen = 10000;
				return idGen++;
			}

			void doInit(const DescriptorSetLayoutInfo& info) {
				_gpuDescriptorSetLayout = ccnew CCVKGPUDescriptorSetLayout;
				_gpuDescriptorSetLayout->id = generateID();
				_gpuDescriptorSetLayout->descriptorCount = _descriptorCount;
				_gpuDescriptorSetLayout->bindingIndices = _bindingIndices;
				_gpuDescriptorSetLayout->descriptorIndices = _descriptorIndices;
				_gpuDescriptorSetLayout->bindings = _bindings;

				for (auto& binding : _bindings) {
					if (hasAnyFlags(binding.descriptorType, DESCRIPTOR_DYNAMIC_TYPE)) {
						for (uint32 j = 0U; j < binding.count; j++) {
							_gpuDescriptorSetLayout->dynamicBindings.push_back(binding.binding);
						}
					}
				}

				cmdFuncCCVKCreateDescriptorSetLayout(CCVKDevice::getInstance(), _gpuDescriptorSetLayout);
			}
			void doDestroy() {
				_gpuDescriptorSetLayout = null;
			}

			IntrusivePtr<CCVKGPUDescriptorSetLayout> _gpuDescriptorSetLayout;
		};

	} // namespace gfx
} // namespace cc
