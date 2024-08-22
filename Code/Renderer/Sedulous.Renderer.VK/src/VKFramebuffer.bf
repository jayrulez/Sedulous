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


class CCVKFramebuffer : Framebuffer
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	[Inline] public CCVKGPUFramebuffer gpuFBO() { return _gpuFBO; }

	protected override void doInit(in FramebufferInfo info)
	{
		_gpuFBO = new CCVKGPUFramebuffer();
		_gpuFBO.gpuRenderPass = ((CCVKRenderPass)_renderPass).gpuRenderPass();

		_gpuFBO.gpuColorViews.Resize(_colorTextures.Count);
		for (int i = 0; i < _colorTextures.Count; ++i)
		{
			var colorTex = (CCVKTexture)_colorTextures[i];
			_gpuFBO.gpuColorViews[i] = colorTex.gpuTextureView();
		}

		if (_depthStencilTexture != null)
		{
			var depthTex = (CCVKTexture)_depthStencilTexture;
			_gpuFBO.gpuDepthStencilView = depthTex.gpuTextureView();
		}

		if (_depthStencilResolveTexture != null)
		{
			var depthTex = (CCVKTexture)_depthStencilResolveTexture;
			_gpuFBO.gpuDepthStencilResolveView = depthTex.gpuTextureView();
		}

		cmdFuncCCVKCreateFramebuffer(CCVKDevice.getInstance(), _gpuFBO);
	}
	protected override void doDestroy()
	{
		_gpuFBO = null;
	}

	protected CCVKGPUFramebuffer _gpuFBO;
}
