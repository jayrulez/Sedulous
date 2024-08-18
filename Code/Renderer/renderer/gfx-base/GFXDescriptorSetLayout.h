/****************************************************************************
 Copyright (c) 2019-2023 Xiamen Yaji Software Co., Ltd.

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

#include "GFXObject.h"
#include "base/RefCounted.h"

namespace cc {
	namespace gfx {

		class CC_DLL DescriptorSetLayout : public GFXObject, public RefCounted {
		public:
			DescriptorSetLayout()
				: GFXObject(ObjectType::DESCRIPTOR_SET_LAYOUT) {
			}
			~DescriptorSetLayout() override;

			void initialize(const DescriptorSetLayoutInfo& info) {
				_bindings = info.bindings;
				auto bindingCount = utils::toUint(_bindings.size());
				_descriptorCount = 0U;

				if (bindingCount) {
					uint32_t maxBinding = 0U;
					ccstd::vector<uint32_t> flattenedIndices(bindingCount);
					for (uint32_t i = 0U; i < bindingCount; i++) {
						const DescriptorSetLayoutBinding& binding = _bindings[i];
						if (binding.binding > maxBinding) maxBinding = binding.binding;
						flattenedIndices[i] = _descriptorCount;
						_descriptorCount += binding.count;
					}

					_bindingIndices.resize(maxBinding + 1, INVALID_BINDING);
					_descriptorIndices.resize(maxBinding + 1, INVALID_BINDING);
					for (uint32_t i = 0U; i < bindingCount; i++) {
						const DescriptorSetLayoutBinding& binding = _bindings[i];
						_bindingIndices[binding.binding] = i;
						_descriptorIndices[binding.binding] = flattenedIndices[i];
						if (hasFlag(DESCRIPTOR_DYNAMIC_TYPE, binding.descriptorType)) {
							for (uint32_t j = 0U; j < binding.count; ++j) {
								_dynamicBindings.push_back(binding.binding);
							}
						}
					}
				}

				doInit(info);
			}
			void destroy() {
				doDestroy();

				_bindings.clear();
				_descriptorCount = 0U;
				_bindingIndices.clear();
				_descriptorIndices.clear();
			}

			inline const DescriptorSetLayoutBindingList& getBindings() const { return _bindings; }
			inline const ccstd::vector<uint32_t>& getDynamicBindings() const { return _dynamicBindings; }
			inline const ccstd::vector<uint32_t>& getBindingIndices() const { return _bindingIndices; }
			inline const ccstd::vector<uint32_t>& getDescriptorIndices() const { return _descriptorIndices; }
			inline uint32_t getDescriptorCount() const { return _descriptorCount; }

		protected:
			virtual void doInit(const DescriptorSetLayoutInfo& info) = 0;
			virtual void doDestroy() = 0;

			DescriptorSetLayoutBindingList _bindings;
			uint32_t _descriptorCount = 0U;
			ccstd::vector<uint32_t> _bindingIndices;
			ccstd::vector<uint32_t> _descriptorIndices;
			ccstd::vector<uint32_t> _dynamicBindings;
		};

	} // namespace gfx
} // namespace cc
