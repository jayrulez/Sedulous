using System;
using System.Collections;
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

		abstract class CommandBuffer : GFXObject
		{
			public this()
				: base(ObjectType.COMMAND_BUFFER)
			{
			}

			public void initialize(in CommandBufferInfo info)
			{
				_type = info.type;
				_queue = info.queue;

				doInit(info);
			}
			public void destroy()
			{
				doDestroy();

				_type = CommandBufferType.PRIMARY;
				_queue = null;
			}

			public abstract void begin(RenderPass renderPass, uint32 subpass, Framebuffer frameBuffer);
			public abstract void end();
			public abstract void beginRenderPass(RenderPass renderPass, Framebuffer fbo, in Rect renderArea, Color* colors, float depth, uint32 stencil, CommandBuffer* secondaryCBs, uint32 secondaryCBCount);
			public abstract void endRenderPass();
			public abstract void insertMarker(in MarkerInfo marker);
			public abstract void beginMarker(in MarkerInfo marker);
			public abstract void endMarker();
			public abstract void bindPipelineState(PipelineState pso);
			public abstract void bindDescriptorSet(uint32 set, DescriptorSet descriptorSet, uint32 dynamicOffsetCount, uint32* dynamicOffsets);
			public abstract void bindInputAssembler(InputAssembler ia);
			public abstract void setViewport(in Viewport vp);
			public abstract void setScissor(in Rect rect);
			public abstract void setLineWidth(float width);
			public abstract void setDepthBias(float constant, float clamp, float slope);
			public abstract void setBlendConstants(in Color constants);
			public abstract void setDepthBound(float minBounds, float maxBounds);
			public abstract void setStencilWriteMask(StencilFace face, uint32 mask);
			public abstract void setStencilCompareMask(StencilFace face, uint32 @ref, uint32 mask);
			public abstract void nextSubpass();
			public abstract void draw(in DrawInfo info);
			public abstract void updateBuffer(Buffer buff, void* data, uint32 size);
			public abstract void copyBuffersToTexture(in uint8** buffers, Texture texture, in BufferTextureCopy* regions, uint32 count);
			public abstract void blitTexture(Texture srcTexture, Texture dstTexture, in TextureBlit* regions, uint32 count, Filter filter);
			public abstract void copyTexture(Texture srcTexture, Texture dstTexture, in TextureCopy* regions, uint32 count);
			public abstract void resolveTexture(Texture srcTexture, Texture dstTexture, in TextureCopy* regions, uint32 count);
			public abstract void execute(CommandBuffer* cmdBuffs, uint32 count);
			public abstract void dispatch(in DispatchInfo info);
			public abstract void beginQuery(QueryPool queryPool, uint32 id);
			public abstract void endQuery(QueryPool queryPool, uint32 id);
			public abstract void resetQueryPool(QueryPool queryPool);
			public virtual void completeQueryPool(QueryPool queryPool) { }

			public typealias CustomCommand = function void(void*);
			public virtual void customCommand(CustomCommand cmd) { }

			// barrier: excutionBarrier
			// bufferBarriers: array of BufferBarrier*, descriptions of access of buffers
			// buffers: array of MTL/VK/GLES buffers
			// bufferBarrierCount: number of barrier, should be equal to number of buffers
			// textureBarriers: array of TextureBarrier*, descriptions of access of textures
			// textures: array of MTL/VK/GLES textures
			// textureBarrierCount: number of barrier, should be equal to number of textures
			public abstract void pipelineBarrier(GeneralBarrier barrier, BufferBarrier* bufferBarriers, Buffer* buffers, uint32 bufferBarrierCount, TextureBarrier* textureBarriers, Texture* textures, uint32 textureBarrierCount);

			[Inline] public void begin()
			{
				begin(null, 0, null);
			}
			[Inline] public void begin(RenderPass renderPass)
			{
				begin(renderPass, 0, null);
			}
			[Inline] public void begin(RenderPass renderPass, uint32 subpass)
			{
				begin(renderPass, subpass, null);
			}

			[Inline] public void updateBuffer(Buffer buff, void* data)
			{
				updateBuffer(buff, data, buff.getSize());
			}

			[Inline] public void execute(in CommandBufferList cmdBuffs, uint32 count)
			{
				execute(cmdBuffs.Ptr, count);
			}

			[Inline] public void bindDescriptorSet(uint32 set, DescriptorSet descriptorSet)
			{
				bindDescriptorSet(set, descriptorSet, 0, null);
			}
			[Inline] public void bindDescriptorSet(uint32 set, DescriptorSet descriptorSet, in List<uint32> dynamicOffsets)
			{
				bindDescriptorSet(set, descriptorSet, (uint32)dynamicOffsets.Count, dynamicOffsets.Ptr);
			}

			[Inline] public void beginRenderPass(RenderPass renderPass, Framebuffer fbo, in Rect renderArea, in ColorList colors, float depth, uint32 stencil, in CommandBufferList secondaryCBs)
			{
				beginRenderPass(renderPass, fbo, renderArea, colors.Ptr, depth, stencil, secondaryCBs.Ptr, uint32(secondaryCBs.Count));
			}
			[Inline] public void beginRenderPass(RenderPass renderPass, Framebuffer fbo, in Rect renderArea, in ColorList colors, float depth, uint32 stencil)
			{
				beginRenderPass(renderPass, fbo, renderArea, colors.Ptr, depth, stencil, null, 0);
			}
			[Inline] public void beginRenderPass(RenderPass renderPass, Framebuffer fbo, in Rect renderArea, in Color* colors, float depth, uint32 stencil)
			{
				beginRenderPass(renderPass, fbo, renderArea, colors, depth, stencil, null, 0);
			}

			[Inline] public void draw(InputAssembler ia)
			{
				draw(ia.getDrawInfo());
			}
			[Inline] public void copyBuffersToTexture(in BufferDataList buffers, Texture texture, in BufferTextureCopyList regions)
			{
				copyBuffersToTexture(buffers.Ptr, texture, regions.Ptr, uint32(regions.Count));
			}

			[Inline] public void blitTexture(Texture srcTexture, Texture dstTexture, in TextureBlitList regions, Filter filter)
			{
				blitTexture(srcTexture, dstTexture, regions.Ptr, uint32(regions.Count), filter);
			}

			[Inline] public void pipelineBarrier(in GeneralBarrier barrier)
			{
				pipelineBarrier(barrier, null, null, 0, null, null, 0);
			}
			[Inline] public void pipelineBarrier(in GeneralBarrier barrier, in BufferBarrierList bufferBarriers, in BufferList buffers, in TextureBarrierList textureBarriers, in TextureList textures)
			{
				pipelineBarrier(barrier, bufferBarriers.Ptr, buffers.Ptr, uint32(bufferBarriers.Count), textureBarriers.Ptr, textures.Ptr, uint32(textureBarriers.Count));
			}

			[Inline] public CommandQueue getQueue() { return _queue; }
			[Inline] public CommandBufferType getType() { return _type; }

			public virtual uint32 getNumDrawCalls() { return _numDrawCalls; }
			public virtual uint32 getNumInstances() { return _numInstances; }
			public virtual uint32 getNumTris() { return _numTriangles; }

			protected abstract void doInit(in CommandBufferInfo info);
			protected abstract void doDestroy();

			protected CommandQueue _queue = null;
			protected CommandBufferType _type = CommandBufferType.PRIMARY;

			protected uint32 _numDrawCalls = 0;
			protected uint32 _numInstances = 0;
			protected uint32 _numTriangles = 0;
		}
