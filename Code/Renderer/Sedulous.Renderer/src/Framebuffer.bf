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

namespace Sedulous.Renderer;


		abstract class Framebuffer : GFXObject
		{
			public this()
				: base(ObjectType.FRAMEBUFFER)
			{
			}

			public static HashType computeHash(in FramebufferInfo info)
			{
				return info.GetHashCode();
			}

			public void initialize(in FramebufferInfo info)
			{
				_renderPass = info.renderPass;
				_colorTextures = info.colorTextures;
				_depthStencilTexture = info.depthStencilTexture;
				_depthStencilResolveTexture = info.depthStencilResolveTexture;

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_renderPass = null;
				_colorTextures.Clear();
				_depthStencilTexture = null;
				_depthStencilResolveTexture = null;
			}

			[Inline] public RenderPass getRenderPass() { return _renderPass; }
			[Inline] public readonly ref TextureList getColorTextures() { return ref _colorTextures; }
			[Inline] public Texture getDepthStencilTexture() { return _depthStencilTexture; }
			[Inline] public Texture getDepthStencilResolveTexture() { return _depthStencilResolveTexture; }

			protected abstract void doInit(in FramebufferInfo info);
			protected abstract void doDestroy();

			// weak reference
			protected RenderPass _renderPass =  null;
			// weak reference
			protected TextureList _colorTextures;
			// weak reference
			protected Texture _depthStencilTexture =  null;
			protected Texture _depthStencilResolveTexture =  null;
		}
