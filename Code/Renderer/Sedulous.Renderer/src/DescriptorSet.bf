using System;
using System.Collections;
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

namespace Sedulous.Renderer;


		abstract class DescriptorSet : GFXObject {
			public this()
				: base(ObjectType.DESCRIPTOR_SET) {
			}

			public void initialize(in DescriptorSetInfo info) {
				Runtime.Assert(info.layout != null);

				_layout = info.layout;
				uint32 descriptorCount = _layout.getDescriptorCount();
				_buffers.Resize(descriptorCount);
				_textures.Resize(descriptorCount);
				_samplers.Resize(descriptorCount);

				doInit(info);
			}
			public void destroy() {
				doDestroy();

				_layout = null;
				// have to clear these or else it might not be properly updated when reused
				_buffers.Clear();
				_textures.Clear();
				_samplers.Clear();
			}

			public abstract void update();
			public abstract void forceUpdate();

			public virtual void bindBuffer(uint32 binding, Buffer buffer, uint32 index, AccessFlags flags) {
				readonly uint32 descriptorIndex = _layout.getDescriptorIndices()[binding] + index;
				readonly uint32 newId = getObjectID(buffer);
				if (_buffers[descriptorIndex].id != newId) {
					_buffers[descriptorIndex].ptr = buffer;
					_buffers[descriptorIndex].id = newId;
					_buffers[descriptorIndex].flags = flags;
					_isDirty = true;
				}
			}
			public virtual void bindSampler(uint32 binding, Sampler sampler, uint32 index) {
				readonly uint32 descriptorIndex = _layout.getDescriptorIndices()[binding] + index;
				readonly uint32 newId = getObjectID(sampler);
				if (_samplers[descriptorIndex].id != newId) {
					_samplers[descriptorIndex].ptr = sampler;
					_samplers[descriptorIndex].id = newId;
					_isDirty = true;
				}
			}
			public virtual void bindTexture(uint32 binding, Texture texture, uint32 index, AccessFlags flags) {
				readonly uint32 descriptorIndex = _layout.getDescriptorIndices()[binding] + index;
				readonly uint32 newId = getObjectID(texture);
				if (_textures[descriptorIndex].id != newId) {
					_textures[descriptorIndex].ptr = texture;
					_textures[descriptorIndex].id = newId;
					_textures[descriptorIndex].flags = flags;
					_isDirty = true;
				}
			}

			public void bindBuffer(uint32 binding, Buffer buffer, uint32 index) {
				bindBuffer(binding, buffer, index, AccessFlagBit.NONE);
			}
			public void bindTexture(uint32 binding, Texture texture, uint32 index) {
				bindTexture(binding, texture, index, AccessFlagBit.NONE);
			}

			// Functions invoked by JSB adapter
			public bool bindBufferJSB(uint32 binding, Buffer buffer, uint32 index) {
				bindBuffer(binding, buffer, index);
				return _isDirty;
			}
			public bool bindTextureJSB(uint32 binding, Texture texture, uint32 index, AccessFlags flags) {
				bindTexture(binding, texture, index, flags);
				return _isDirty;
			}
			public bool bindSamplerJSB(uint32 binding, Sampler sampler, uint32 index) {
				bindSampler(binding, sampler, index);
				return _isDirty;
			}

			public Buffer getBuffer(uint32 binding, uint32 index) {
				readonly ref List<uint32> descriptorIndices = ref _layout.getDescriptorIndices();
				if (binding >= descriptorIndices.Count) return null;
				readonly uint32 descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _buffers.Count) return null;
				return _buffers[descriptorIndex].ptr;
			}
			public Texture getTexture(uint32 binding, uint32 index) {
				readonly ref List<uint32> descriptorIndices = ref _layout.getDescriptorIndices();
				if (binding >= descriptorIndices.Count) return null;
				readonly uint32 descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _textures.Count) return null;
				return _textures[descriptorIndex].ptr;
			}

			public Sampler getSampler(uint32 binding, uint32 index) {
				readonly ref List<uint32> descriptorIndices = ref _layout.getDescriptorIndices();
				if (binding >= descriptorIndices.Count) return null;
				readonly uint32 descriptorIndex = descriptorIndices[binding] + index;
				if (descriptorIndex >= _samplers.Count) return null;
				return _samplers[descriptorIndex].ptr;
			}

			[Inline] public DescriptorSetLayout getLayout() { return _layout; }

			[Inline] public void bindBuffer(uint32 binding, Buffer buffer) { bindBuffer(binding, buffer, 0); }
			[Inline] public void bindTexture(uint32 binding, Texture texture) { bindTexture(binding, texture, 0); }
			[Inline] public void bindSampler(uint32 binding, Sampler sampler) { bindSampler(binding, sampler, 0); }
			[Inline] public Buffer getBuffer(uint32 binding) { return getBuffer(binding, 0); }
			[Inline] public Texture getTexture(uint32 binding) { return getTexture(binding, 0); }
			[Inline] public Sampler getSampler(uint32 binding) { return getSampler(binding, 0); }

			protected abstract void doInit(in DescriptorSetInfo info);
			protected abstract void doDestroy();

			protected struct ObjectWithId<T> where T : class {
				public T ptr = null;
				public uint32 id = INVALID_OBJECT_ID;
				public AccessFlags flags = AccessFlagBit.NONE;
			};

			protected DescriptorSetLayout _layout = null;
			protected List<ObjectWithId<Buffer>> _buffers;
			protected List<ObjectWithId<Texture>> _textures;
			protected List<ObjectWithId<Sampler>> _samplers;

			protected bool _isDirty = false;
		}
