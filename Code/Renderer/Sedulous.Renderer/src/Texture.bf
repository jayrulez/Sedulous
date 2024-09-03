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

		abstract class Texture : GraphicsObject
		{
			private static uint32 getLevelCount(uint32 width, uint32 height)
			{
				return uint32(Math.Floor(Math.Log(Math.Max(width, height), 2))) + 1;
			}

			public this()
				: base(ObjectType.TEXTURE)
			{
			}

			public static HashType computeHash(in TextureInfo info)
			{
				return info.GetHashCode();
			}
			public static HashType computeHash(in TextureViewInfo info)
			{
				return info.GetHashCode();
			}

			public void initialize(in TextureInfo info)
			{
				_info = info;
				_size = formatSize(_info.format, _info.width, _info.height, _info.depth);
				_hash = computeHash(info);

				_viewInfo.texture = this;
				_viewInfo.format = _info.format;
				_viewInfo.type = _info.type;
				_viewInfo.baseLayer = 0;
				_viewInfo.layerCount = _info.layerCount;
				_viewInfo.baseLevel = 0;
				_viewInfo.levelCount = _info.levelCount;

				doInit(info);
			}
			public void initialize(in TextureViewInfo info)
			{
				_info = info.texture.getInfo();
				_viewInfo = info;

				_isTextureView = true;
				_size = formatSize(_info.format, _info.width, _info.height, _info.depth);
				_hash = computeHash(info);

				doInit(info);
			}
			public void resize(uint32 width, uint32 height)
			{
				if (_info.width != width || _info.height != height)
				{
					if (_info.levelCount == getLevelCount(_info.width, _info.height))
					{
						_info.levelCount = getLevelCount(width, height);
					}
					else if (_info.levelCount > 1)
					{
						_info.levelCount = Math.Min(_info.levelCount, getLevelCount(width, height));
					}

					uint32 size = formatSize(_info.format, width, height, _info.depth);
					doResize(width, height, size);

					_info.width = width;
					_info.height = height;
					_size = size;
					_hash = computeHash(this);
				}
			}
			public void destroy()
			{
				doDestroy();

				_info = TextureInfo();
				_viewInfo = TextureViewInfo();

				_isTextureView = false;
				_hash = _size = 0;
			}

			[Inline] public readonly ref TextureInfo getInfo() { return ref _info; }
			[Inline] public readonly ref TextureViewInfo getViewInfo() { return ref _viewInfo; }

			[Inline] public bool isTextureView() { return _isTextureView; }
			[Inline] public uint32 getSize() { return _size; }
			[Inline] public HashType getHash() { return _hash; }

			// convenient getter for common usages
			[Inline] public Format getFormat() { return _isTextureView ? _viewInfo.format : _info.format; }
			[Inline] public uint32 getWidth() { return _info.width; }
			[Inline] public uint32 getHeight() { return _info.height; }

			public virtual Texture getRaw() { return this; }

			public virtual uint32 getGLTextureHandle() { return 0; }

			protected abstract void doInit(in TextureInfo info);
			protected abstract void doInit(in TextureViewInfo info);
			protected abstract void doDestroy();
			protected abstract void doResize(uint32 width, uint32 height, uint32 size);

			protected static HashType computeHash(in Texture texture)
			{
				HashType hash = texture.isTextureView() ? computeHash(texture.getViewInfo()) : computeHash(texture.getInfo());
				if (texture._swapchain != null)
				{
					hash = HashCode.Mix(hash, texture._swapchain.getObjectID());
					hash = HashCode.Mix(hash, texture._swapchain.getGeneration());
				}
				return hash;
			}

			protected static void initialize(in SwapchainTextureInfo info, ref Texture @out)
			{
				updateTextureInfo(info, ref @out);
				@out.doInit(info);
			}
			protected static void updateTextureInfo(in SwapchainTextureInfo info, ref Texture @out)
			{
				@out._info.type = TextureType.TEX2D;
				@out._info.format = info.format;
				@out._info.width = info.width;
				@out._info.height = info.height;
				@out._info.layerCount = 1;
				@out._info.levelCount = 1;
				@out._info.depth = 1;
				@out._info.samples = SampleCount.X1;
				@out._info.flags = TextureFlagBit.NONE;
				@out._info.usage = TextureUsageBit.SAMPLED | (GFX_FORMAT_INFOS[int(info.format)].hasDepth
					? TextureUsageBit.DEPTH_STENCIL_ATTACHMENT
					: TextureUsageBit.COLOR_ATTACHMENT);
				@out._swapchain = info.swapchain;
				@out._size = formatSize(info.format, info.width, info.height, 1);
				@out._hash = computeHash(@out);

				@out._viewInfo.texture = @out;
				@out._viewInfo.format = @out._info.format;
				@out._viewInfo.type = @out._info.type;
				@out._viewInfo.baseLayer = 0;
				@out._viewInfo.layerCount = @out._info.layerCount;
				@out._viewInfo.baseLevel = 0;
				@out._viewInfo.levelCount = @out._info.levelCount;
				@out._viewInfo.basePlane = 0;
				@out._viewInfo.planeCount = info.format == Format.DEPTH_STENCIL ? 2 : 1;
			}
			protected abstract void doInit(in SwapchainTextureInfo info);

			protected TextureInfo _info;
			protected TextureViewInfo _viewInfo;

			protected Swapchain _swapchain =  null;
			protected bool _isTextureView =  false;
			protected uint32 _size =  0;
			protected HashType _hash =  0;
		}
