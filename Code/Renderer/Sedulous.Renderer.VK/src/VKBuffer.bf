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

class CCVKBuffer : Buffer
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	public override void update(void* buffer, uint32 size)
	{
			//CC_PROFILE(CCVKBufferUpdate);
		cmdFuncCCVKUpdateBuffer(CCVKDevice.getInstance(), _gpuBuffer, buffer, size, null);
	}

	[Inline] public CCVKGPUBuffer gpuBuffer() { return _gpuBuffer; }
	[Inline] public CCVKGPUBufferView gpuBufferView() { return _gpuBufferView; }

	protected override void doInit(in BufferInfo info)
	{
		createBuffer(_size, _count);

		createBufferView(_size);
	}

	protected override void doInit(in BufferViewInfo info)
	{
		var buffer = (CCVKBuffer)info.buffer;
		_gpuBuffer = buffer.gpuBuffer();

		createBufferView(_size);
	}

	protected override void doDestroy()
	{
		_gpuBufferView = null;
		_gpuBuffer = null;
	}
	protected override void doResize(uint32 size, uint32 count)
	{
		createBuffer(size, count);

		// Hold reference to keep the old bufferView alive during DescriptorHub.update and IAHub.update.
		CCVKGPUBufferView oldBufferView = _gpuBufferView;
		createBufferView(size);
		CCVKDevice.getInstance().gpuDescriptorHub().update(oldBufferView, _gpuBufferView);
		CCVKDevice.getInstance().gpuIAHub().update(oldBufferView, _gpuBufferView);
	}

	protected void createBuffer(uint32 size, uint32 count)
	{
		_gpuBuffer = new CCVKGPUBuffer();
		_gpuBuffer.size = size;
		_gpuBuffer.count = count;

		_gpuBuffer.usage = _usage;
		_gpuBuffer.memUsage = _memUsage;
		_gpuBuffer.stride = _stride;
		_gpuBuffer.init();
	}
	protected void createBufferView(uint32 range)
	{
		_gpuBufferView = new CCVKGPUBufferView();
		_gpuBufferView.range = range;

		_gpuBufferView.gpuBuffer = _gpuBuffer;
		_gpuBufferView.offset = _offset;
	}

	protected CCVKGPUBuffer _gpuBuffer;
	protected CCVKGPUBufferView _gpuBufferView;
}
