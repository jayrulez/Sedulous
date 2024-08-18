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

		class CC_DLL Shader : public GFXObject, public RefCounted {
		public:
			Shader()
				: GFXObject(ObjectType::SHADER) {
			}
			~Shader() override;

			void initialize(const ShaderInfo& info) {
				_name = info.name;
				_stages = info.stages;
				_attributes = info.attributes;
				_blocks = info.blocks;
				_buffers = info.buffers;
				_samplerTextures = info.samplerTextures;
				_samplers = info.samplers;
				_textures = info.textures;
				_images = info.images;
				_subpassInputs = info.subpassInputs;
				_hash = info.hash;
				doInit(info);
			}
			void destroy() {
				doDestroy();

				_stages.clear();
				_attributes.clear();
				_blocks.clear();
				_buffers.clear();
				_samplerTextures.clear();
				_samplers.clear();
				_textures.clear();
				_images.clear();
				_subpassInputs.clear();
			}

			inline const ccstd::string& getName() const { return _name; }
			inline const ShaderStageList& getStages() const { return _stages; }
			inline const AttributeList& getAttributes() const { return _attributes; }
			inline const UniformBlockList& getBlocks() const { return _blocks; }
			inline const UniformStorageBufferList& getBuffers() const { return _buffers; }
			inline const UniformSamplerTextureList& getSamplerTextures() const { return _samplerTextures; }
			inline const UniformSamplerList& getSamplers() const { return _samplers; }
			inline const UniformTextureList& getTextures() const { return _textures; }
			inline const UniformStorageImageList& getImages() const { return _images; }
			inline const UniformInputAttachmentList& getSubpassInputs() const { return _subpassInputs; }

		protected:
			virtual void doInit(const ShaderInfo& info) = 0;
			virtual void doDestroy() = 0;

			ccstd::string _name;
			ShaderStageList _stages;
			AttributeList _attributes;
			UniformBlockList _blocks;
			UniformStorageBufferList _buffers;
			UniformSamplerTextureList _samplerTextures;
			UniformSamplerList _samplers;
			UniformTextureList _textures;
			UniformStorageImageList _images;
			UniformInputAttachmentList _subpassInputs;
			ccstd::hash_t _hash = 0;
		};

	} // namespace gfx
} // namespace cc
