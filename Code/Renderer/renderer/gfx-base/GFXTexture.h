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

		uint32_t getLevelCount(uint32_t width, uint32_t height) {
			return static_cast<uint32_t>(std::floor(std::log2(std::max(width, height)))) + 1;
		}

		class CC_DLL Texture : public GFXObject, public RefCounted {
		public:
			Texture()
				: GFXObject(ObjectType::TEXTURE) {
			}

			~Texture() override;

			static ccstd::hash_t computeHash(const TextureInfo& info) {
				return Hasher<TextureInfo>()(info);
			}
			static ccstd::hash_t computeHash(const TextureViewInfo& info) {
				return Hasher<TextureViewInfo>()(info);
			}

			void initialize(const TextureInfo& info) {
				_info = info;
				_size = formatSize(_info.format, _info.width, _info.height, _info.depth);
				_hash = computeHash(info);

				_viewInfo.texture = this;
				_viewInfo.format = _info.format;
				_viewInfo.type = _info.type;
				_viewInfo.baseLayer = 0;
				_viewInfo.layerCount = _info.layerCount;
				_viewInfo.baseLevel = 0;
				_viewInfo.levelCount = _info.levelCount;

				doInit(info);
			}
			void initialize(const TextureViewInfo& info) {
				_info = info.texture->getInfo();
				_viewInfo = info;

				_isTextureView = true;
				_size = formatSize(_info.format, _info.width, _info.height, _info.depth);
				_hash = computeHash(info);

				doInit(info);
			}
			void resize(uint32_t width, uint32_t height) {
				if (_info.width != width || _info.height != height) {
					if (_info.levelCount == getLevelCount(_info.width, _info.height)) {
						_info.levelCount = getLevelCount(width, height);
					}
					else if (_info.levelCount > 1) {
						_info.levelCount = std::min(_info.levelCount, getLevelCount(width, height));
					}

					uint32_t size = formatSize(_info.format, width, height, _info.depth);
					doResize(width, height, size);

					_info.width = width;
					_info.height = height;
					_size = size;
					_hash = computeHash(this);
				}
			}
			void destroy() {
				doDestroy();

				_info = TextureInfo();
				_viewInfo = TextureViewInfo();

				_isTextureView = false;
				_hash = _size = 0;
			}

			inline const TextureInfo& getInfo() const { return _info; }
			inline const TextureViewInfo& getViewInfo() const { return _viewInfo; }

			inline bool isTextureView() const { return _isTextureView; }
			inline uint32_t getSize() const { return _size; }
			inline ccstd::hash_t getHash() const { return _hash; }

			// convenient getter for common usages
			inline Format getFormat() const { return _isTextureView ? _viewInfo.format : _info.format; }
			inline uint32_t getWidth() const { return _info.width; }
			inline uint32_t getHeight() const { return _info.height; }

			virtual const Texture* getRaw() const { return this; }

			virtual uint32_t getGLTextureHandle() const noexcept { return 0; }

		protected:
			friend class Swapchain;

			virtual void doInit(const TextureInfo& info) = 0;
			virtual void doInit(const TextureViewInfo& info) = 0;
			virtual void doDestroy() = 0;
			virtual void doResize(uint32_t width, uint32_t height, uint32_t size) = 0;

			static ccstd::hash_t computeHash(const Texture* texture) {
				ccstd::hash_t hash = texture->isTextureView() ? computeHash(texture->getViewInfo()) : computeHash(texture->getInfo());
				if (texture->_swapchain) {
					ccstd::hash_combine(hash, texture->_swapchain->getObjectID());
					ccstd::hash_combine(hash, texture->_swapchain->getGeneration());
				}
				return hash;
			}

			static void initialize(const SwapchainTextureInfo& info, Texture* out) {
				updateTextureInfo(info, out);
				out->doInit(info);
			}
			static void updateTextureInfo(const SwapchainTextureInfo& info, Texture* out) {
				out->_info.type = TextureType::TEX2D;
				out->_info.format = info.format;
				out->_info.width = info.width;
				out->_info.height = info.height;
				out->_info.layerCount = 1;
				out->_info.levelCount = 1;
				out->_info.depth = 1;
				out->_info.samples = SampleCount::X1;
				out->_info.flags = TextureFlagBit::NONE;
				out->_info.usage = TextureUsageBit::SAMPLED | (GFX_FORMAT_INFOS[toNumber(info.format)].hasDepth
					? TextureUsageBit::DEPTH_STENCIL_ATTACHMENT
					: TextureUsageBit::COLOR_ATTACHMENT);
				out->_swapchain = info.swapchain;
				out->_size = formatSize(info.format, info.width, info.height, 1);
				out->_hash = computeHash(out);

				out->_viewInfo.texture = out;
				out->_viewInfo.format = out->_info.format;
				out->_viewInfo.type = out->_info.type;
				out->_viewInfo.baseLayer = 0;
				out->_viewInfo.layerCount = out->_info.layerCount;
				out->_viewInfo.baseLevel = 0;
				out->_viewInfo.levelCount = out->_info.levelCount;
				out->_viewInfo.basePlane = 0;
				out->_viewInfo.planeCount = info.format == gfx::Format::DEPTH_STENCIL ? 2 : 1;
			}
			virtual void doInit(const SwapchainTextureInfo& info) = 0;

			TextureInfo _info;
			TextureViewInfo _viewInfo;

			Swapchain* _swapchain{ nullptr };
			bool _isTextureView{ false };
			uint32_t _size{ 0U };
			ccstd::hash_t _hash{ 0U };
		};

	} // namespace gfx
} // namespace cc
