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

class CCVKPipelineLayout : PipelineLayout
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	[Inline] public CCVKGPUPipelineLayout gpuPipelineLayout() { return _gpuPipelineLayout; }

	protected override void doInit(in PipelineLayoutInfo info)
	{
		_gpuPipelineLayout = new CCVKGPUPipelineLayout();

		uint32 offset = 0U;
		for (var setLayout in _setLayouts)
		{
			CCVKGPUDescriptorSetLayout gpuSetLayout = ((CCVKDescriptorSetLayout)setLayout).gpuDescriptorSetLayout();
			uint32 dynamicCount = (uint32)gpuSetLayout.dynamicBindings.Count;
			_gpuPipelineLayout.dynamicOffsetOffsets.Add(offset);
			_gpuPipelineLayout.setLayouts.Add(gpuSetLayout);
			offset += dynamicCount;
		}
		_gpuPipelineLayout.dynamicOffsetOffsets.Add(offset);
		_gpuPipelineLayout.dynamicOffsetCount = offset;

		cmdFuncCCVKCreatePipelineLayout(CCVKDevice.getInstance(), _gpuPipelineLayout);
	}
	protected override void doDestroy()
	{
		_gpuPipelineLayout = null;
	}

	protected CCVKGPUPipelineLayout _gpuPipelineLayout;
}
