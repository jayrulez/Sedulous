using Sedulous.Renderer.VK.Internal;
using System;
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

class CCVKInputAssembler : InputAssembler
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	[Inline] public CCVKGPUInputAssembler gpuInputAssembler() { return _gpuInputAssembler; }

	protected override void doInit(in InputAssemblerInfo info)
	{
		int vbCount = _vertexBuffers.Count;

		_gpuInputAssembler = new CCVKGPUInputAssembler();
		_gpuInputAssembler.attributes = _attributes;
		_gpuInputAssembler.gpuVertexBuffers.Resize(vbCount);

		var hub = CCVKDevice.getInstance().gpuIAHub();
		for (int i = 0U; i < vbCount; ++i)
		{
			var vb = (CCVKBuffer)_vertexBuffers[i];
			_gpuInputAssembler.gpuVertexBuffers[i] = vb.gpuBufferView();
			hub.connect(_gpuInputAssembler, _gpuInputAssembler.gpuVertexBuffers[i]);
		}

		if (info.indexBuffer != null)
		{
			_gpuInputAssembler.gpuIndexBuffer = ((CCVKBuffer)info.indexBuffer).gpuBufferView();
			hub.connect(_gpuInputAssembler, _gpuInputAssembler.gpuIndexBuffer);
		}

		if (info.indirectBuffer != null)
		{
			_gpuInputAssembler.gpuIndirectBuffer = ((CCVKBuffer)info.indirectBuffer).gpuBufferView();
			hub.connect(_gpuInputAssembler, _gpuInputAssembler.gpuIndirectBuffer);
		}

		_gpuInputAssembler.vertexBuffers.Resize(vbCount);
		_gpuInputAssembler.vertexBufferOffsets.Resize(vbCount);

		CCVKGPUDevice gpuDevice = CCVKDevice.getInstance().gpuDevice();
		for (int i = 0U; i < vbCount; i++)
		{
			_gpuInputAssembler.vertexBuffers[i] = _gpuInputAssembler.gpuVertexBuffers[i].gpuBuffer.vkBuffer;
			_gpuInputAssembler.vertexBufferOffsets[i] = _gpuInputAssembler.gpuVertexBuffers[i].getStartOffset(gpuDevice.curBackBufferIndex);
		}
	}
	protected override void doDestroy()
	{
		_gpuInputAssembler = null;
	}

	protected CCVKGPUInputAssembler _gpuInputAssembler;
}
