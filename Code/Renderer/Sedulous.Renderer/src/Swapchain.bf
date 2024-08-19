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


		struct SwapchainTextureInfo {
			public Swapchain swapchain =  null ;
			public Format format =  Format.UNKNOWN ;
			public uint32 width =  0 ;
			public uint32 height =  0 ;
		}

		abstract class Swapchain : GFXObject {
		public this() : base(ObjectType.SWAPCHAIN) {
			}

			public void initialize(in SwapchainInfo info) {
				_windowId = info.windowId;
				_windowHandle = info.windowHandle;
				_vsyncMode = info.vsyncMode;

				doInit(info);
			}
			public void destroy() {
				doDestroy();

				_windowHandle = null;
				_windowId = 0;
			}

			/**
			 * Resize the swapchain with the given metric.
			 * Note that you should invoke this function iff when there is actual
			 * size or orientation changes, with the up-to-date information about
			 * the underlying surface.
			 *
			 * @param width The width of the surface in oriented screen space
			 * @param height The height of the surface in oriented screen space
			 * @param transform The orientation of the surface
			 */
			public void resize(uint32 width, uint32 height, SurfaceTransform transform) {
				doResize(width, height, transform);
			}

			[Inline] public void destroySurface(){
			doDestroySurface();
			_windowHandle = null;
		}

			[Inline] public void createSurface(void* windowHandle){
			_windowHandle = windowHandle;
			doCreateSurface(windowHandle);
		}

			[Inline] public uint32 getWindowId() { return _windowId; }
			[Inline] public void* getWindowHandle() { return _windowHandle; }
			[Inline] public VsyncMode getVSyncMode() { return _vsyncMode; }

			[Inline] public Texture getColorTexture() { return _colorTexture; }
			[Inline] public Texture getDepthStencilTexture() { return _depthStencilTexture; }

			[Inline] public SurfaceTransform getSurfaceTransform() { return _transform; }
			[Inline] public uint32 getWidth() { return _colorTexture.getWidth(); }
			[Inline] public uint32 getHeight() { return _colorTexture.getHeight(); }
			[Inline] public uint32 getGeneration() { return _generation; }

			protected abstract void doInit(in SwapchainInfo info);
			protected abstract void doDestroy();
			protected abstract void doResize(uint32 width, uint32 height, SurfaceTransform transform);
			protected abstract void doDestroySurface();
			protected abstract void doCreateSurface(void* windowHandle);

			[Inline] protected static void initTexture(in SwapchainTextureInfo info, ref Texture texture){
			Texture.[Friend]initialize(info, ref texture);
		}

			[Inline] protected static void updateTextureInfo(in SwapchainTextureInfo info, ref Texture texture){
			Texture.[Friend]updateTextureInfo(info, ref texture);
		}

			protected uint32 _windowId =  0 ;
			protected void* _windowHandle =  null ;
			protected VsyncMode _vsyncMode =  VsyncMode.RELAXED ;
			protected SurfaceTransform _transform =  SurfaceTransform.IDENTITY ;
			protected bool _preRotationEnabled =  false ;
			protected uint32 _generation =  0 ;

			protected Texture _colorTexture;
			protected Texture _depthStencilTexture;
		}
