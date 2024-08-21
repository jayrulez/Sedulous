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
#include "gfx-base/GFXShader.h"
#include "gfx-vulkan/VKGPUObjects.h"

namespace cc {
	namespace gfx {

		static{
			void initGpuShader(CCVKGPUShader* gpuShader) {
				cmdFuncCCVKCreateShader(CCVKDevice::getInstance(), gpuShader);

				// Clear shader source after they're uploaded to GPU
				for (auto& stage : gpuShader->gpuStages) {
					stage.source.clear();
					stage.source.shrink_to_fit();
				}

				gpuShader->initialized = true;
			}

		}

		class CC_VULKAN_API CCVKShader final : public Shader {
		public:
			CCVKShader() {
				_typedID = generateObjectID<decltype(this)>();
			}
			~CCVKShader() {
				destroy();
			}

			CCVKGPUShader* gpuShader() {
				if (!_gpuShader->initialized) {
					initGpuShader(_gpuShader);
				}
				return _gpuShader;
			}

		protected:
			void doInit(const ShaderInfo& info) {
				_gpuShader = ccnew CCVKGPUShader;
				_gpuShader->name = _name;
				_gpuShader->attributes = _attributes;
				for (ShaderStage& stage : _stages) {
					_gpuShader->gpuStages.emplace_back(CCVKGPUShaderStage{ stage.stage, stage.source });
				}
				for (auto& stage : _stages) {
					stage.source.clear();
					stage.source.shrink_to_fit();
				}
			}
			void doDestroy() {
				_gpuShader = null;
			}

			IntrusivePtr<CCVKGPUShader> _gpuShader;
		};

	} // namespace gfx
} // namespace cc
