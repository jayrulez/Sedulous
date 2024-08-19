using System;
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

namespace cc
{
	namespace gfx
	{
		abstract class Shader : GFXObject
		{
			public this()
				: base(ObjectType.SHADER)
			{
			}

			public void initialize(in ShaderInfo info)
			{
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
			public void destroy()
			{
				doDestroy();

				_stages.Clear();
				_attributes.Clear();
				_blocks.Clear();
				_buffers.Clear();
				_samplerTextures.Clear();
				_samplers.Clear();
				_textures.Clear();
				_images.Clear();
				_subpassInputs.Clear();
			}

			[Inline] public readonly ref String getName() { return ref _name; }
			[Inline] public readonly ref ShaderStageList getStages() { return ref _stages; }
			[Inline] public readonly ref VertexAttributeList getAttributes() { return ref _attributes; }
			[Inline] public readonly ref UniformBlockList getBlocks() { return ref _blocks; }
			[Inline] public readonly ref UniformStorageBufferList getBuffers() { return ref _buffers; }
			[Inline] public readonly ref UniformSamplerTextureList getSamplerTextures() { return ref _samplerTextures; }
			[Inline] public readonly ref UniformSamplerList getSamplers() { return ref _samplers; }
			[Inline] public readonly ref UniformTextureList getTextures() { return ref _textures; }
			[Inline] public readonly ref UniformStorageImageList getImages() { return ref _images; }
			[Inline] public readonly ref UniformInputAttachmentList getSubpassInputs() { return ref _subpassInputs; }

			protected abstract void doInit(in ShaderInfo info);
			protected abstract void doDestroy();

			protected String _name;
			protected ShaderStageList _stages;
			protected VertexAttributeList _attributes;
			protected UniformBlockList _blocks;
			protected UniformStorageBufferList _buffers;
			protected UniformSamplerTextureList _samplerTextures;
			protected UniformSamplerList _samplers;
			protected UniformTextureList _textures;
			protected UniformStorageImageList _images;
			protected UniformInputAttachmentList _subpassInputs;
			protected HashType _hash = 0;
		}
	} // namespace gfx
} // namespace cc
