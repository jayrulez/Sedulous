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
		abstract class InputAssembler : GFXObject
		{
			public this()
				: base(ObjectType.INPUT_ASSEMBLER)
			{
			}

			public void initialize(in InputAssemblerInfo info)
			{
				_attributes = info.attributes;
				_vertexBuffers = info.vertexBuffers;
				_indexBuffer = info.indexBuffer;
				_indirectBuffer = info.indirectBuffer;
				_attributesHash = computeAttributesHash();

				if (_indexBuffer != null)
				{
					_drawInfo.indexCount = _indexBuffer.getCount();
					_drawInfo.firstIndex = 0;
				}
				else if (!_vertexBuffers.IsEmpty)
				{
					_drawInfo.vertexCount = _vertexBuffers[0].getCount();
					_drawInfo.firstVertex = 0;
					_drawInfo.vertexOffset = 0;
				}

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_attributes.Clear();
				_attributesHash = 0;

				_vertexBuffers.Clear();
				_indexBuffer = null;
				_indirectBuffer = null;

				_drawInfo = DrawInfo();
			}

			[Inline] public readonly ref VertexAttributeList getAttributes() { return ref _attributes; }
			[Inline] public readonly ref BufferList getVertexBuffers() { return ref _vertexBuffers; }
			[Inline] public Buffer getIndexBuffer() { return _indexBuffer; }
			[Inline] public Buffer getIndirectBuffer() { return _indirectBuffer; }
			[Inline] public HashType getAttributesHash() { return _attributesHash; }

			[Inline] public readonly ref DrawInfo getDrawInfo() { return ref _drawInfo; }
			[Inline] public void setDrawInfo(in DrawInfo info) { _drawInfo = info; }

			[Inline] public void setVertexCount(uint32 count) { _drawInfo.vertexCount = count; }
			[Inline] public void setFirstVertex(uint32 first) { _drawInfo.firstVertex = first; }
			[Inline] public void setIndexCount(uint32 count) { _drawInfo.indexCount = count; }
			[Inline] public void setFirstIndex(uint32 first) { _drawInfo.firstIndex = first; }
			[Inline] public void setVertexOffset(int32 offset) { _drawInfo.vertexOffset = offset; }
			[Inline] public void setInstanceCount(uint32 count) { _drawInfo.instanceCount = count; }
			[Inline] public void setFirstInstance(uint32 first) { _drawInfo.firstInstance = first; }

			[Inline] public uint32 getVertexCount() { return _drawInfo.vertexCount; }
			[Inline] public uint32 getFirstVertex() { return _drawInfo.firstVertex; }
			[Inline] public uint32 getIndexCount() { return _drawInfo.indexCount; }
			[Inline] public uint32 getFirstIndex() { return _drawInfo.firstIndex; }
			[Inline] public uint32 getVertexOffset() { return (uint32)_drawInfo.vertexOffset; }
			[Inline] public uint32 getInstanceCount() { return _drawInfo.instanceCount; }
			[Inline] public uint32 getFirstInstance() { return _drawInfo.firstInstance; }

			protected abstract void doInit(in InputAssemblerInfo info);
			protected abstract void doDestroy();

			protected HashType computeAttributesHash()
			{
				HashType seed = (uint32)(_attributes.Count) * 6;
				for (var attribute in _attributes)
				{
					HashCode.Mix(seed, attribute.name.GetHashCode());
					HashCode.Mix(seed, attribute.format.Underlying.GetHashCode());
					HashCode.Mix(seed, attribute.isNormalized.GetHashCode());
					HashCode.Mix(seed, attribute.stream);
					HashCode.Mix(seed, attribute.isInstanced.GetHashCode());
					HashCode.Mix(seed, attribute.location);
				}
				return seed;
			}

			protected VertexAttributeList _attributes;
			protected HashType _attributesHash = 0;

			protected BufferList _vertexBuffers;
			protected Buffer _indexBuffer =  null;
			protected Buffer _indirectBuffer =  null;

			protected DrawInfo _drawInfo;
		}
	} // namespace gfx
} // namespace cc
