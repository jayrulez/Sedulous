using System;
using Sedulous.Renderer.VK.Internal;
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

class CCVKRenderPass : RenderPass
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	[Inline] public CCVKGPURenderPass gpuRenderPass() { return _gpuRenderPass; }

	protected override void doInit(in RenderPassInfo info)
	{
		_gpuRenderPass = new CCVKGPURenderPass();
		_gpuRenderPass.colorAttachments = _colorAttachments;
		_gpuRenderPass.depthStencilAttachment = _depthStencilAttachment;
		_gpuRenderPass.depthStencilResolveAttachment = _depthStencilResolveAttachment;
		_gpuRenderPass.subpasses = _subpasses;
		_gpuRenderPass.dependencies = _dependencies;

		// assign a dummy subpass if not specified
		uint32 colorCount = (uint32)_gpuRenderPass.colorAttachments.Count;
		if (_gpuRenderPass.subpasses.IsEmpty)
		{
			SubpassInfo subpass = .();
			subpass.colors.Resize(_colorAttachments.Count);
			for (uint32 i = 0U; i < _colorAttachments.Count; ++i)
			{
				subpass.colors[i] = i;
			}
			if (_depthStencilAttachment.format != Format.UNKNOWN)
			{
				subpass.depthStencil = colorCount;
			}
			if (_depthStencilResolveAttachment.format != Format.UNKNOWN)
			{
				subpass.depthStencilResolve = colorCount + 1;
			}
			_gpuRenderPass.subpasses.Add(subpass);
		}
		else
		{
			// unify depth stencil index
			for (var subpass in ref _gpuRenderPass.subpasses)
			{
				if (subpass.depthStencil != INVALID_BINDING && subpass.depthStencil >= colorCount)
				{
					subpass.depthStencil = colorCount;
				}
				if (subpass.depthStencilResolve != INVALID_BINDING && subpass.depthStencilResolve >= colorCount)
				{
					subpass.depthStencilResolve = colorCount + 1;
				}
			}
		}

		cmdFuncCCVKCreateRenderPass(CCVKDevice.getInstance(), _gpuRenderPass);
	}
	protected override void doDestroy()
	{
		_gpuRenderPass = null;
	}

	protected CCVKGPURenderPass _gpuRenderPass;
}
