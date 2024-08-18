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

		class CC_DLL DescriptorSet : public GFXObject, public RefCounted {
		public:
			DescriptorSet()
				: GFXObject(ObjectType::DESCRIPTOR_SET) {
			}
			~DescriptorSet() override;

			void initialize(const DescriptorSetInfo& info) {
				CC_ASSERT(info.layout);

				_layout = info.layout;
				uint32_t descriptorCount = _layout->getDescriptorCount();
				_buffers.resize(descriptorCount);
				_textures.resize(descriptorCount);
				_samplers.resize(descriptorCount);

				doInit(info);
			}
			void destroy() {
				doDestroy();

				_layout = nullptr;
				// have to clear these or else it might not be properly updated when reused
				_buffers.clear();
				_textures.clear();
				_samplers.clear();
			}

			virtual void update() = 0;
			virtual void forceUpdate() = 0;

			virtual void bindBuffer(uint32_t binding, Buffer* buffer, uint32_t index, AccessFlags flags) {
				const uint32_t descriptorIndex = _layout->getDescriptorIndices()[binding] + index;
				const uint32_t newId = getObjectID(buffer);
				if (_buffers[descriptorIndex].id != newId) {
					_buffers[descriptorIndex].ptr = buffer;
					_buffers[descriptorIndex].id = newId;
					_buffers[descriptorIndex].flags = flags;
					_isDirty = true;
				}
			}
			virtual void bindSampler(uint32_t binding, Sampler* sampler, uint32_t index) {
				const uint32_t descriptorIndex = _layout->getDescriptorIndices()[binding] + index;
				const uint32_t newId = getObjectID(sampler);
				if (_samplers[descriptorIndex].id != newId) {
					_samplers[descriptorIndex].ptr = sampler;
					_samplers[descriptorIndex].id = newId;
					_isDirty = true;
				}
			}
			virtual void bindTexture(uint32_t binding, Texture* texture, uint32_t index, AccessFlags flags) {
				const uint32_t descriptorIndex = _layout->getDescriptorIndices()[binding] + index;
				const uint32_t newId = getObjectID(texture);
				if (_textures[descriptorIndex].id != newId) {
					_textures[descriptorIndex].ptr = texture;
					_textures[descriptorIndex].id = newId;
					_textures[descriptorIndex].flags = flags;
					_isDirty = true;
				}
			}

			void bindBuffer(uint32_t binding, Buffer* buffer, uint32_t index) {
				bindBuffer(binding, buffer, index, AccessFlagBit::NONE);
			}
			void bindTexture(uint32_t binding, Texture* texture, uint32_t index) {
				bindTexture(binding, texture, index, AccessFlagBit::NONE);
			}

			// Functions invoked by JSB adapter
			bool bindBufferJSB(uint32_t binding, Buffer* buffer, uint32_t index) {
				bindBuffer(binding, buffer, index);
				return _isDirty;
			}
			bool bindTextureJSB(uint32_t binding, Texture* texture, uint32_t index, AccessFlags flags) {
				bindTexture(binding, texture, index, flags);
				return _isDirty;
			}
			bool bindSamplerJSB(uint32_t binding, Sampler* sampler, uint32_t index) {
				bindSampler(binding, sampler, index);
				return _isDirty;
			}

			Buffer* getBuffer(uint32_t binding, uint32_t index) {
				const ccstd::vector<uint32_t>& descriptorIndices = _layout->getDescriptorIndices();
				if (binding >= descriptorIndices.size()) return nullptr;
				const uint32_t descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _buffers.size()) return nullptr;
				return _buffers[descriptorIndex].ptr;
			}
			Texture* getTexture(uint32_t binding, uint32_t index) {
				const ccstd::vector<uint32_t>& descriptorIndices = _layout->getDescriptorIndices();
				if (binding >= descriptorIndices.size()) return nullptr;
				const uint32_t descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _textures.size()) return nullptr;
				return _textures[descriptorIndex].ptr;
			}

			Sampler* getSampler(uint32_t binding, uint32_t index) {
				const ccstd::vector<uint32_t>& descriptorIndices = _layout->getDescriptorIndices();
				if (binding >= descriptorIndices.size()) return nullptr;
				const uint32_t descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _samplers.size()) return nullptr;
				return _samplers[descriptorIndex].ptr;
			}

			inline const DescriptorSetLayout* getLayout() const { return _layout; }

			inline void bindBuffer(uint32_t binding, Buffer* buffer) { bindBuffer(binding, buffer, 0U); }
			inline void bindTexture(uint32_t binding, Texture* texture) { bindTexture(binding, texture, 0U); }
			inline void bindSampler(uint32_t binding, Sampler* sampler) { bindSampler(binding, sampler, 0U); }
			inline Buffer* getBuffer(uint32_t binding) const { return getBuffer(binding, 0U); }
			inline Texture* getTexture(uint32_t binding) const { return getTexture(binding, 0U); }
			inline Sampler* getSampler(uint32_t binding) const { return getSampler(binding, 0U); }

		protected:
			virtual void doInit(const DescriptorSetInfo& info) = 0;
			virtual void doDestroy() = 0;

			template <typename T>
			struct ObjectWithId {
				T* ptr = nullptr;
				uint32_t id = INVALID_OBJECT_ID;
				AccessFlags flags = AccessFlagBit::NONE;
			};

			const DescriptorSetLayout* _layout = nullptr;
			ccstd::vector<ObjectWithId<Buffer>> _buffers;
			ccstd::vector<ObjectWithId<Texture>> _textures;
			ccstd::vector<ObjectWithId<Sampler>> _samplers;

			bool _isDirty = false;
		};

	} // namespace gfx
} // namespace cc
