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

#include "VKStd.h"
#include "gfx-base/GFXTexture.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
	namespace gfx {

		class CC_VULKAN_API CCVKTexture final : public Texture {
		public:
			CCVKTexture() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKTexture() {
				destroy();
			}

			inline CCVKGPUTexture* gpuTexture() const { return _gpuTexture; }
			inline CCVKGPUTextureView* gpuTextureView() const { return _gpuTextureView; }

		protected:
			friend class CCVKSwapchain;

			void doInit(const TextureInfo& info) {
				createTexture(_info.width, _info.height, _size);

				_viewInfo.planeCount = _info.format == Format::DEPTH_STENCIL ? 2 : 1;
				createTextureView();
			}

			void doInit(const TextureViewInfo& info) {
				_gpuTexture = static_cast<CCVKTexture*>(info.texture)->gpuTexture();

				createTextureView();
			}

			void doInit(const SwapchainTextureInfo& info) {
				createTexture(_info.width, _info.height, _size, false);
				createTextureView(false);
			}

			void doDestroy() {
				_gpuTexture = nullptr;
				_gpuTextureView = nullptr;
			}

			void doResize(uint32_t width, uint32_t height, uint32_t size) {
				if (!width || !height) return;
				createTexture(width, height, size);

				// Hold reference to keep the old textureView alive during DescriptorHub::update.
				IntrusivePtr<CCVKGPUTextureView> oldTextureView = _gpuTextureView;
				createTextureView();
				CCVKDevice::getInstance()->gpuDescriptorHub()->update(oldTextureView, _gpuTextureView);
			}

			void createTexture(uint32_t width, uint32_t height, uint32_t size, bool initGPUTexture = true) {
				_gpuTexture = ccnew CCVKGPUTexture;
				_gpuTexture->width = width;
				_gpuTexture->height = height;
				_gpuTexture->size = size;

				if (_swapchain != nullptr) {
					_gpuTexture->swapchain = static_cast<CCVKSwapchain*>(_swapchain)->gpuSwapchain();
					_gpuTexture->memoryAllocated = false;
				}

				_gpuTexture->type = _info.type;
				_gpuTexture->format = _info.format;
				_gpuTexture->usage = _info.usage;
				_gpuTexture->depth = _info.depth;
				_gpuTexture->arrayLayers = _info.layerCount;
				_gpuTexture->mipLevels = _info.levelCount;
				_gpuTexture->samples = _info.samples;
				_gpuTexture->flags = _info.flags;

				bool hasExternalFlag = hasFlag(_gpuTexture->flags, TextureFlagBit::EXTERNAL_NORMAL);
				if (hasExternalFlag) {
					_gpuTexture->externalVKImage = reinterpret_cast<VkImage>(_info.externalRes);
				}

				if (initGPUTexture) {
					_gpuTexture->init();
				}
			}

			void createTextureView(bool initGPUTextureView = true) {
				_gpuTextureView = ccnew CCVKGPUTextureView;
				_gpuTextureView->gpuTexture = _gpuTexture;
				_gpuTextureView->type = _viewInfo.type;
				_gpuTextureView->format = _viewInfo.format;
				_gpuTextureView->baseLevel = _viewInfo.baseLevel;
				_gpuTextureView->levelCount = _viewInfo.levelCount;
				_gpuTextureView->baseLayer = _viewInfo.baseLayer;
				_gpuTextureView->layerCount = _viewInfo.layerCount;
				_gpuTextureView->basePlane = _viewInfo.basePlane;
				_gpuTextureView->planeCount = _viewInfo.planeCount;

				if (initGPUTextureView) {
					_gpuTextureView->init();
				}
			}

			IntrusivePtr<CCVKGPUTexture> _gpuTexture;
			IntrusivePtr<CCVKGPUTextureView> _gpuTextureView;
		};

	} // namespace gfx
} // namespace cc