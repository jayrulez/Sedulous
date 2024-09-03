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

		abstract class RenderPass : GraphicsObject
		{
			public this()
				: base(ObjectType.RENDER_PASS)
			{
			}

			public static HashType computeHash(in RenderPassInfo info)
			{
				return info.GetHashCode();
			}

			public void initialize(in RenderPassInfo info)
			{
				_colorAttachments = info.colorAttachments;
				_depthStencilAttachment = info.depthStencilAttachment;
				_depthStencilResolveAttachment = info.depthStencilResolveAttachment;
				_subpasses = info.subpasses;
				_dependencies = info.dependencies;
				_hash = computeHash();

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_colorAttachments.Clear();
				_subpasses.Clear();
				_hash = 0;
			}

			[Inline] public readonly ref ColorAttachmentList getColorAttachments() { return ref _colorAttachments; }
			[Inline] public readonly ref DepthStencilAttachment getDepthStencilAttachment() { return ref _depthStencilAttachment; }
			[Inline] public readonly ref DepthStencilAttachment getDepthStencilResolveAttachment() { return ref _depthStencilResolveAttachment; }
			[Inline] public readonly ref SubpassInfoList getSubpasses() { return ref _subpasses; }
			[Inline] public readonly ref SubpassDependencyList getDependencies() { return ref _dependencies; }
			[Inline] public HashType getHash() { return _hash; }

			// Based on render pass compatibility
			protected HashType computeHash()
			{
				HashType seed = (uint32)(_colorAttachments.Count) * 2 + 3;
				for (ColorAttachment ca in _colorAttachments)
				{
					seed = HashCode.Mix(seed, ca.GetHashCode());
				}
				seed = HashCode.Mix(seed, _depthStencilAttachment.GetHashCode());
				seed = HashCode.Mix(seed, _depthStencilResolveAttachment.GetHashCode());
				
				//seed = HashCode.Mix(seed, _subpasses);
				if(_subpasses != null)
				{
					for(int i = 0; i < _subpasses.Count; i++)
					{
						seed = HashCode.Mix(seed, _subpasses[i].GetHashCode());
					}
				}
				return seed;
			}

			protected abstract void doInit(in RenderPassInfo info);
			protected abstract void doDestroy();

			protected ColorAttachmentList _colorAttachments;
			protected DepthStencilAttachment _depthStencilAttachment;
			protected DepthStencilAttachment _depthStencilResolveAttachment;
			protected SubpassInfoList _subpasses;
			protected SubpassDependencyList _dependencies;
			protected HashType _hash = 0;
		}
