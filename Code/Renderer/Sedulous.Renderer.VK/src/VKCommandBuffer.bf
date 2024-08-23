using System.Collections;
using Bulkan;
using Sedulous.Renderer.VK.Internal;
using System;
using Bulkan.Utilities;

using static Bulkan.VulkanNative;
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

class CCVKCommandBuffer : CommandBuffer
{
	public this()
	{
		_typedID = generateObjectID<decltype(this)>();
	}
	public ~this()
	{
		destroy();
	}

	public override void begin(RenderPass renderPass, uint32 subpass, Framebuffer frameBuffer)
	{
		Runtime.Assert(!_gpuCommandBuffer.began);
		if (_gpuCommandBuffer.began) return;

		CCVKDevice.getInstance().gpuDevice().getCommandBufferPool().request(_gpuCommandBuffer);

		_curGPUPipelineState = null;
		_curGPUInputAssembler = null;
		_curGPUDescriptorSets.Resize(_curGPUDescriptorSets.Count, null);
		_curDynamicOffsetsArray.Resize(_curDynamicOffsetsArray.Count, default);
		_firstDirtyDescriptorSet = uint32.MaxValue;

		_numDrawCalls = 0;
		_numInstances = 0;
		_numTriangles = 0;

		VkCommandBufferBeginInfo beginInfo = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
		beginInfo.flags = .VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
		VkCommandBufferInheritanceInfo inheritanceInfo = .() { sType = .VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO };

		if (renderPass != null)
		{
			inheritanceInfo.renderPass = ((CCVKRenderPass)renderPass).gpuRenderPass().vkRenderPass;
			inheritanceInfo.subpass = subpass;
			if (frameBuffer != null)
			{
				CCVKGPUFramebuffer gpuFBO = ((CCVKFramebuffer)frameBuffer).gpuFBO();
				if (gpuFBO.isOffscreen)
				{
					inheritanceInfo.framebuffer = gpuFBO.vkFramebuffer;
				}
				else
				{
					inheritanceInfo.framebuffer = gpuFBO.vkFrameBuffers[gpuFBO.swapchain.curImageIndex];
				}
			}
			beginInfo.pInheritanceInfo = &inheritanceInfo;
			beginInfo.flags |= .VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT;
		}

		VK_CHECK!(vkBeginCommandBuffer(_gpuCommandBuffer.vkCommandBuffer, &beginInfo));

		_gpuCommandBuffer.began = true;
		_gpuCommandBuffer.recordedBuffers.Clear();
	}
	public override void end()
	{
		Runtime.Assert(_gpuCommandBuffer.began);
		if (!_gpuCommandBuffer.began) return;

		_curGPUFBO = null;
		_curGPUInputAssembler = null;
		_curDynamicStates.viewport.width = _curDynamicStates.viewport.height = _curDynamicStates.scissor.width = _curDynamicStates.scissor.height = 0U;
		VK_CHECK!(vkEndCommandBuffer(_gpuCommandBuffer.vkCommandBuffer));
		_gpuCommandBuffer.began = false;

		_pendingQueue.Add(_gpuCommandBuffer.vkCommandBuffer);
		CCVKDevice.getInstance().gpuDevice().getCommandBufferPool()._yield(_gpuCommandBuffer);
	}
	public override void beginRenderPass(RenderPass renderPass, Framebuffer fbo, in Rect renderArea, Color* colors, float depth, uint32 stencil, CommandBuffer* secondaryCBs, uint32 secondaryCBCount)
	{
		Runtime.Assert(_gpuCommandBuffer.began);
		CCVKDevice device = CCVKDevice.getInstance();
		if (!ENABLE_GRAPH_AUTO_BARRIER)
		{
			if (BARRIER_DEDUCTION_LEVEL >= BARRIER_DEDUCTION_LEVEL_BASIC)
			{
								// guard against RAW hazard
				VkMemoryBarrier vkBarrier = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
				vkBarrier.srcAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
				vkBarrier.dstAccessMask = .VK_ACCESS_UNIFORM_READ_BIT | .VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT;
				vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer,
					.VK_PIPELINE_STAGE_TRANSFER_BIT,
					.VK_PIPELINE_STAGE_VERTEX_INPUT_BIT | .VK_PIPELINE_STAGE_VERTEX_SHADER_BIT | .VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
					0, 1, &vkBarrier, 0, null, 0, null);
			}
		}
		else
		{
			var dependencies = renderPass.getDependencies();
			if (!dependencies.IsEmpty)
			{
				var frontBarrier = dependencies.Front;
				//pipelineBarrier(frontBarrier.generalBarrier, frontBarrier.bufferBarriers, frontBarrier.buffers, frontBarrier.bufferBarrierCount, frontBarrier.textureBarriers, frontBarrier.textures, frontBarrier.textureBarrierCount);
			}
		}

		_curGPUFBO = ((CCVKFramebuffer)fbo).gpuFBO();
		_curGPURenderPass = ((CCVKRenderPass)renderPass).gpuRenderPass();
		VkFramebuffer framebuffer = _curGPUFBO.vkFramebuffer;
		if (!_curGPUFBO.isOffscreen)
		{
			framebuffer = _curGPUFBO.vkFrameBuffers[_curGPUFBO.swapchain.curImageIndex];
		}

		ref List<VkClearValue> clearValues = ref _curGPURenderPass.clearValues;
		int attachmentCount = _curGPURenderPass.colorAttachments.Count;
		for (int i = 0U; i < attachmentCount; ++i)
		{
			clearValues[i].color = .() { float32 = .(colors[i].x, colors[i].y, colors[i].z, colors[i].w) };
		}

		if (_curGPURenderPass.depthStencilAttachment.format != Format.UNKNOWN)
		{
			clearValues[attachmentCount].depthStencil = .() { depth = depth, stencil = stencil };
		}
		if (_curGPURenderPass.depthStencilResolveAttachment.format != Format.UNKNOWN)
		{
			clearValues[attachmentCount + 1].depthStencil = .() { depth = depth, stencil = stencil };
		}

		Rect safeArea = .(
			Math.Min(renderArea.x, ((int32)_curGPUFBO.width)),
			Math.Min(renderArea.y, ((int32)_curGPUFBO.height)),
			Math.Min(renderArea.width, _curGPUFBO.width),
			Math.Min(renderArea.height, _curGPUFBO.height)
			);

		VkRenderPassBeginInfo passBeginInfo = .() { sType = .VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO };
		passBeginInfo.renderPass = _curGPURenderPass.vkRenderPass;
		passBeginInfo.framebuffer = framebuffer;
		passBeginInfo.clearValueCount = (uint32)clearValues.Count;
		passBeginInfo.pClearValues = clearValues.Ptr;
		passBeginInfo.renderArea.offset = .(safeArea.x, safeArea.y);
		passBeginInfo.renderArea.extent = .(safeArea.width, safeArea.height);

		vkCmdBeginRenderPass(_gpuCommandBuffer.vkCommandBuffer, &passBeginInfo, secondaryCBCount != 0 ? .VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS : .VK_SUBPASS_CONTENTS_INLINE);

		_secondaryRP = secondaryCBCount != 0;

		if (secondaryCBCount == 0)
		{
			VkViewport viewport = .((float)safeArea.x, (float)safeArea.y,
				(float)safeArea.width, (float)safeArea.height, 0.F, 1.F);
			vkCmdSetViewport(_gpuCommandBuffer.vkCommandBuffer, 0, 1, &viewport);
			_curDynamicStates.viewport = .(safeArea.x, safeArea.y, safeArea.width, safeArea.height);
			vkCmdSetScissor(_gpuCommandBuffer.vkCommandBuffer, 0, 1, &passBeginInfo.renderArea);
			_curDynamicStates.scissor = safeArea;
		}
		_currentSubPass = 0;
		_hasSubPassSelfDependency = false;
	}

	public override void endRenderPass()
	{
		Runtime.Assert(_gpuCommandBuffer.began);
		vkCmdEndRenderPass(_gpuCommandBuffer.vkCommandBuffer);

		var device = CCVKDevice.getInstance();
		CCVKGPUDevice gpuDevice = device.gpuDevice();
		int colorAttachmentCount = _curGPURenderPass.colorAttachments.Count;
		for (int i = 0U; i < colorAttachmentCount; ++i)
		{
			_curGPUFBO.gpuColorViews[i].gpuTexture.currentAccessTypes = _curGPURenderPass.getBarrier((uint)i, gpuDevice).nextAccesses;
		}

		if (_curGPURenderPass.depthStencilAttachment.format != Format.UNKNOWN)
		{
			_curGPUFBO.gpuDepthStencilView.gpuTexture.currentAccessTypes = _curGPURenderPass.getBarrier((uint)colorAttachmentCount, gpuDevice).nextAccesses;
		}

		_curGPUFBO = null;

		if (!ENABLE_GRAPH_AUTO_BARRIER)
		{
			if (BARRIER_DEDUCTION_LEVEL >= BARRIER_DEDUCTION_LEVEL_BASIC)
			{
								// guard against WAR hazard
				vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer,
					.VK_PIPELINE_STAGE_VERTEX_SHADER_BIT | .VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
					.VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, null, 0, null, 0, null);
			}
		}
		else
		{
			var dependencies = ref _curGPURenderPass.dependencies;
			if (!dependencies.IsEmpty)
			{
				var rearBarrier = ref _curGPURenderPass.dependencies.Back;
				//pipelineBarrier(rearBarrier.generalBarrier, rearBarrier.bufferBarriers, rearBarrier.buffers, rearBarrier.bufferBarrierCount, rearBarrier.textureBarriers, rearBarrier.textures, rearBarrier.textureBarrierCount);
			}
		}
	}
	public override void insertMarker(in MarkerInfo marker)
	{
		var context = CCVKDevice.getInstance().gpuContext();
		if (context.debugUtils)
		{
			_utilLabelInfo.pLabelName = marker.name;
			_utilLabelInfo.color[0] = marker.color.x;
			_utilLabelInfo.color[1] = marker.color.y;
			_utilLabelInfo.color[2] = marker.color.z;
			_utilLabelInfo.color[3] = marker.color.w;
			vkCmdInsertDebugUtilsLabelEXT(_gpuCommandBuffer.vkCommandBuffer, &_utilLabelInfo);
		}
		else if (context.debugReport)
		{
			_markerInfo.pMarkerName = marker.name;
			_markerInfo.color[0] = marker.color.x;
			_markerInfo.color[1] = marker.color.y;
			_markerInfo.color[2] = marker.color.z;
			_markerInfo.color[3] = marker.color.w;
			vkCmdDebugMarkerInsertEXT(_gpuCommandBuffer.vkCommandBuffer, &_markerInfo);
		}
	}
	public override void beginMarker(in MarkerInfo marker)
	{
		var context = CCVKDevice.getInstance().gpuContext();
		if (context.debugUtils)
		{
			_utilLabelInfo.pLabelName = marker.name;
			_utilLabelInfo.color[0] = marker.color.x;
			_utilLabelInfo.color[1] = marker.color.y;
			_utilLabelInfo.color[2] = marker.color.z;
			_utilLabelInfo.color[3] = marker.color.w;
			vkCmdBeginDebugUtilsLabelEXT(_gpuCommandBuffer.vkCommandBuffer, &_utilLabelInfo);
		}
		else if (context.debugReport)
		{
			_markerInfo.pMarkerName = marker.name;
			_markerInfo.color[0] = marker.color.x;
			_markerInfo.color[1] = marker.color.y;
			_markerInfo.color[2] = marker.color.z;
			_markerInfo.color[3] = marker.color.w;
			vkCmdDebugMarkerBeginEXT(_gpuCommandBuffer.vkCommandBuffer, &_markerInfo);
		}
	}
	public override void endMarker()
	{
		var context = CCVKDevice.getInstance().gpuContext();
		if (context.debugUtils)
		{
			vkCmdEndDebugUtilsLabelEXT(_gpuCommandBuffer.vkCommandBuffer);
		}
		else if (context.debugReport)
		{
			vkCmdDebugMarkerEndEXT(_gpuCommandBuffer.vkCommandBuffer);
		}
	}
	public override void bindPipelineState(PipelineState pso)
	{
		CCVKGPUPipelineState gpuPipelineState = ((CCVKPipelineState)pso).gpuPipelineState();

		if (_curGPUPipelineState != gpuPipelineState)
		{
			vkCmdBindPipeline(_gpuCommandBuffer.vkCommandBuffer, VK_PIPELINE_BIND_POINTS[(uint32)gpuPipelineState.bindPoint], gpuPipelineState.vkPipeline);
			_curGPUPipelineState = gpuPipelineState;
		}
	}
	public override void bindDescriptorSet(uint32 set, DescriptorSet descriptorSet, uint32 dynamicOffsetCount, uint32* dynamicOffsets)
	{
		Runtime.Assert(_curGPUDescriptorSets.Count > set);

		CCVKGPUDescriptorSet gpuDescriptorSet = ((CCVKDescriptorSet)descriptorSet).gpuDescriptorSet();

		if (_curGPUDescriptorSets[set] != gpuDescriptorSet)
		{
			_curGPUDescriptorSets[set] = gpuDescriptorSet;
			if (set < _firstDirtyDescriptorSet) _firstDirtyDescriptorSet = set;
		}
		if (dynamicOffsetCount != 0)
		{
			_curDynamicOffsetsArray[set].Set(Span<uint32>(dynamicOffsets, dynamicOffsetCount));
			if (set < _firstDirtyDescriptorSet) _firstDirtyDescriptorSet = set;
		}
		else if (!_curDynamicOffsetsArray[set].IsEmpty)
		{
			_curDynamicOffsetsArray[set].Resize(_curDynamicOffsetsArray[set].Count, 0);
		}
	}
	public override void bindInputAssembler(InputAssembler ia)
	{
		CCVKGPUInputAssembler gpuInputAssembler = ((CCVKInputAssembler)ia).gpuInputAssembler();

		if (_curGPUInputAssembler != gpuInputAssembler)
		{
			// buffers may be rebuilt(e.g. resize event) without IA's acknowledge
			uint32 vbCount = (uint32)gpuInputAssembler.gpuVertexBuffers.Count;
			if (gpuInputAssembler.vertexBuffers.Count < vbCount)
			{
				gpuInputAssembler.vertexBuffers.Resize(vbCount);
				gpuInputAssembler.vertexBufferOffsets.Resize(vbCount);
			}

			CCVKGPUDevice gpuDevice = CCVKDevice.getInstance().gpuDevice();
			for (uint32 i = 0U; i < vbCount; ++i)
			{
				gpuInputAssembler.vertexBuffers[i] = gpuInputAssembler.gpuVertexBuffers[i].gpuBuffer.vkBuffer;
				gpuInputAssembler.vertexBufferOffsets[i] = gpuInputAssembler.gpuVertexBuffers[i].getStartOffset(gpuDevice.curBackBufferIndex);
			}

			vkCmdBindVertexBuffers(_gpuCommandBuffer.vkCommandBuffer, 0, vbCount,
				gpuInputAssembler.vertexBuffers.Ptr, gpuInputAssembler.vertexBufferOffsets.Ptr);

			if (gpuInputAssembler.gpuIndexBuffer != null)
			{
				vkCmdBindIndexBuffer(_gpuCommandBuffer.vkCommandBuffer, gpuInputAssembler.gpuIndexBuffer.gpuBuffer.vkBuffer,
					gpuInputAssembler.gpuIndexBuffer.gpuBuffer.getStartOffset(gpuDevice.curBackBufferIndex), gpuInputAssembler.gpuIndexBuffer.gpuBuffer.stride == 4 ? .VK_INDEX_TYPE_UINT32 : .VK_INDEX_TYPE_UINT16);
			}
			_curGPUInputAssembler = gpuInputAssembler;
		}
	}
	public override void setViewport(in Viewport vp)
	{
		if (_curDynamicStates.viewport != vp)
		{
			_curDynamicStates.viewport = vp;

			VkViewport viewport = .((float)vp.left, (float)vp.top, (float)vp.width, (float)vp.height, vp.minDepth, vp.maxDepth);
			vkCmdSetViewport(_gpuCommandBuffer.vkCommandBuffer, 0, 1, &viewport);
		}
	}
	public override void setScissor(in Rect rect)
	{
		if (_curDynamicStates.scissor != rect)
		{
			_curDynamicStates.scissor = rect;

			VkRect2D scissor = .() { offset = .(rect.x, rect.y), extent = .(rect.width, rect.height) };
			vkCmdSetScissor(_gpuCommandBuffer.vkCommandBuffer, 0, 1, &scissor);
		}
	}
	public override void setLineWidth(float width)
	{
		if (_curDynamicStates.lineWidth.Equals(width))
		{
			_curDynamicStates.lineWidth = width;
			vkCmdSetLineWidth(_gpuCommandBuffer.vkCommandBuffer, width);
		}
	}
	public override void setDepthBias(float constant, float clamp, float slope)
	{
		if (!_curDynamicStates.depthBiasConstant.Equals(constant) ||
			!_curDynamicStates.depthBiasClamp.Equals(clamp) ||
			!_curDynamicStates.depthBiasSlope.Equals(slope))
		{
			_curDynamicStates.depthBiasConstant = constant;
			_curDynamicStates.depthBiasClamp = clamp;
			_curDynamicStates.depthBiasSlope = slope;
			vkCmdSetDepthBias(_gpuCommandBuffer.vkCommandBuffer, constant, clamp, slope);
		}
	}
	public override void setBlendConstants(in Color constants)
	{
		var constants;
		if (!_curDynamicStates.blendConstant.x.Equals(constants.x) ||
			!_curDynamicStates.blendConstant.y.Equals(constants.y) ||
			!_curDynamicStates.blendConstant.z.Equals(constants.z) ||
			!_curDynamicStates.blendConstant.w.Equals(constants.w))
		{
			_curDynamicStates.blendConstant.x = constants.x;
			_curDynamicStates.blendConstant.y = constants.y;
			_curDynamicStates.blendConstant.z = constants.z;
			_curDynamicStates.blendConstant.w = constants.w;
			vkCmdSetBlendConstants(_gpuCommandBuffer.vkCommandBuffer, constants.ToFloat4());
		}
	}
	public override void setDepthBound(float minBounds, float maxBounds)
	{
		if (!_curDynamicStates.depthMinBounds.Equals(minBounds) ||
			!_curDynamicStates.depthMaxBounds.Equals(maxBounds))
		{
			_curDynamicStates.depthMinBounds = minBounds;
			_curDynamicStates.depthMaxBounds = maxBounds;
			vkCmdSetDepthBounds(_gpuCommandBuffer.vkCommandBuffer, minBounds, maxBounds);
		}
	}
	public override void setStencilWriteMask(StencilFace face, uint32 mask)
	{
		ref DynamicStencilStates front = ref _curDynamicStates.stencilStatesFront;
		ref DynamicStencilStates back = ref _curDynamicStates.stencilStatesBack;
		if (face == StencilFace.ALL)
		{
			if (front.writeMask == mask && back.writeMask == mask) return;
			front.writeMask = back.writeMask = mask;
			vkCmdSetStencilWriteMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_AND_BACK, mask);
		}
		else if (face == StencilFace.FRONT)
		{
			if (front.writeMask == mask) return;
			front.writeMask = mask;
			vkCmdSetStencilWriteMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_BIT, mask);
		}
		else if (face == StencilFace.BACK)
		{
			if (back.writeMask == mask) return;
			back.writeMask = mask;
			vkCmdSetStencilWriteMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_BACK_BIT, mask);
		}
	}
	public override void setStencilCompareMask(StencilFace face, uint32 reference, uint32 mask)
	{
		ref DynamicStencilStates front = ref _curDynamicStates.stencilStatesFront;
		ref DynamicStencilStates back = ref _curDynamicStates.stencilStatesBack;
		if (face == StencilFace.ALL)
		{
			if (front.reference == reference && back.reference == reference &&
				front.compareMask == mask && back.compareMask == mask) return;
			front.reference = back.reference = reference;
			front.compareMask = back.compareMask = mask;
			vkCmdSetStencilReference(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_AND_BACK, reference);
			vkCmdSetStencilCompareMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_AND_BACK, mask);
		}
		else if (face == StencilFace.FRONT)
		{
			if (front.writeMask == mask && front.reference == reference) return;
			front.writeMask = mask;
			front.reference = reference;
			vkCmdSetStencilReference(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_BIT, reference);
			vkCmdSetStencilCompareMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_FRONT_BIT, mask);
		}
		else if (face == StencilFace.BACK)
		{
			if (back.writeMask == mask && back.reference == reference) return;
			back.writeMask = mask;
			back.reference = reference;
			vkCmdSetStencilReference(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_BACK_BIT, reference);
			vkCmdSetStencilCompareMask(_gpuCommandBuffer.vkCommandBuffer, .VK_STENCIL_FACE_BACK_BIT, mask);
		}
	}
	public override void nextSubpass()
	{
		vkCmdNextSubpass(_gpuCommandBuffer.vkCommandBuffer, _secondaryRP ? .VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS : .VK_SUBPASS_CONTENTS_INLINE);
		++_currentSubPass;
		Runtime.Assert(_currentSubPass < _curGPURenderPass.subpasses.Count);
		_hasSubPassSelfDependency = _curGPURenderPass.hasSelfDependency[_currentSubPass];
	}
	public override void draw(in DrawInfo info)
	{
		//CC_PROFILE(CCVKCmdBufDraw);
		if (_firstDirtyDescriptorSet < _curGPUDescriptorSets.Count)
		{
			bindDescriptorSets(.VK_PIPELINE_BIND_POINT_GRAPHICS);
		}

		var gpuIndirectBuffer = _curGPUInputAssembler.gpuIndirectBuffer;

		if (gpuIndirectBuffer != null)
		{
			uint32 drawInfoCount = gpuIndirectBuffer.range / gpuIndirectBuffer.gpuBuffer.stride;
			CCVKGPUDevice gpuDevice = CCVKDevice.getInstance().gpuDevice();
			VkDeviceSize offset = gpuIndirectBuffer.getStartOffset(gpuDevice.curBackBufferIndex);
			if (gpuDevice.useMultiDrawIndirect)
			{
				if (gpuIndirectBuffer.gpuBuffer.isDrawIndirectByIndex)
				{
					vkCmdDrawIndexedIndirect(_gpuCommandBuffer.vkCommandBuffer,
						gpuIndirectBuffer.gpuBuffer.vkBuffer,
						offset,
						drawInfoCount,
						sizeof(VkDrawIndexedIndirectCommand));
				}
				else
				{
					vkCmdDrawIndirect(_gpuCommandBuffer.vkCommandBuffer,
						gpuIndirectBuffer.gpuBuffer.vkBuffer,
						offset,
						drawInfoCount,
						sizeof(VkDrawIndirectCommand));
				}
			}
			else
			{
				if (gpuIndirectBuffer.gpuBuffer.isDrawIndirectByIndex)
				{
					for (uint64 j = 0U; j < drawInfoCount; ++j)
					{
						vkCmdDrawIndexedIndirect(_gpuCommandBuffer.vkCommandBuffer,
							gpuIndirectBuffer.gpuBuffer.vkBuffer,
							offset + j * sizeof(VkDrawIndexedIndirectCommand),
							1,
							sizeof(VkDrawIndexedIndirectCommand));
					}
				}
				else
				{
					for (uint64 j = 0U; j < drawInfoCount; ++j)
					{
						vkCmdDrawIndirect(_gpuCommandBuffer.vkCommandBuffer,
							gpuIndirectBuffer.gpuBuffer.vkBuffer,
							offset + j * sizeof(VkDrawIndirectCommand),
							1,
							sizeof(VkDrawIndirectCommand));
					}
				}
			}
		}
		else
		{
			uint32 instanceCount = Math.Max(info.instanceCount, 1U);
			bool hasIndexBuffer = _curGPUInputAssembler.gpuIndexBuffer != null && info.indexCount > 0;

			if (hasIndexBuffer)
			{
				vkCmdDrawIndexed(_gpuCommandBuffer.vkCommandBuffer, info.indexCount, instanceCount,
					info.firstIndex, info.vertexOffset, info.firstInstance);
			}
			else
			{
				vkCmdDraw(_gpuCommandBuffer.vkCommandBuffer, info.vertexCount, instanceCount,
					info.firstVertex, info.firstInstance);
			}

			++_numDrawCalls;
			_numInstances += info.instanceCount;
			if (_curGPUPipelineState != null)
			{
				uint32 indexCount = hasIndexBuffer ? info.indexCount : info.vertexCount;
				switch (_curGPUPipelineState.primitive) {
				case PrimitiveMode.TRIANGLE_LIST:
					_numTriangles += indexCount / 3 * instanceCount;
					break;
				case PrimitiveMode.TRIANGLE_STRIP,
					PrimitiveMode.TRIANGLE_FAN:
					_numTriangles += (indexCount - 2) * instanceCount;
					break;
				default: break;
				}
			}
		}
		if (_hasSubPassSelfDependency)
		{
			selfDependency();
		}
	}
	public override void updateBuffer(Buffer buffer, void* data, uint32 size)
	{
		//CC_PROFILE(CCVKCmdBufUpdateBuffer);
		CCVKGPUBuffer gpuBuffer = ((CCVKBuffer)buffer).gpuBuffer();
		cmdFuncCCVKUpdateBuffer(CCVKDevice.getInstance(), gpuBuffer, data, size, _gpuCommandBuffer);
	}
	public override void copyBuffersToTexture(in uint8** buffers, Texture texture, in BufferTextureCopy* regions, uint32 count)
	{
		cmdFuncCCVKCopyBuffersToTexture(CCVKDevice.getInstance(), buffers, ((CCVKTexture)texture).gpuTexture(), regions, count, _gpuCommandBuffer);
	}
	public override void blitTexture(Texture srcTexture, Texture dstTexture, in TextureBlit* regions, uint32 count, Filter filter)
	{
		VkImageAspectFlags srcAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImageAspectFlags dstAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImage srcImage = .Null;
		VkImage dstImage = .Null;
		VkImageLayout srcImageLayout = .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
		VkImageLayout dstImageLayout = .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;

		CCVKGPUTexture gpuTextureSrc = ((CCVKTexture)srcTexture).gpuTexture();
		srcAspectMask = gpuTextureSrc.aspectMask;
		if (gpuTextureSrc.swapchain != null)
		{
			srcImage = gpuTextureSrc.swapchainVkImages[gpuTextureSrc.swapchain.curImageIndex];
		}
		else
		{
			srcImage = gpuTextureSrc.vkImage;
		}

		CCVKGPUTexture gpuTextureDst = ((CCVKTexture)dstTexture).gpuTexture();
		dstAspectMask = gpuTextureDst.aspectMask;
		if (gpuTextureDst.swapchain != null)
		{
			dstImage = gpuTextureDst.swapchainVkImages[gpuTextureDst.swapchain.curImageIndex];

			VkImageMemoryBarrier barrier = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
			barrier.dstAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
			barrier.newLayout = .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
			barrier.srcQueueFamilyIndex = barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;

			barrier.image = dstImage;
			barrier.subresourceRange.aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
			barrier.subresourceRange.levelCount = barrier.subresourceRange.layerCount = 1;

			vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer,
				.VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, .VK_PIPELINE_STAGE_TRANSFER_BIT, .VK_DEPENDENCY_BY_REGION_BIT,
				0, null, 0, null, 1, &barrier);
		}
		else
		{
			dstImage = gpuTextureDst.vkImage;
		}

		_blitRegions.Resize(count);
		for (uint32 i = 0U; i < count; ++i)
		{
			readonly ref TextureBlit region = ref regions[i];
			_blitRegions[i].srcSubresource.aspectMask = srcAspectMask;
			_blitRegions[i].srcSubresource.mipLevel = region.srcSubres.mipLevel;
			_blitRegions[i].srcSubresource.baseArrayLayer = region.srcSubres.baseArrayLayer;
			_blitRegions[i].srcSubresource.layerCount = region.srcSubres.layerCount;
			_blitRegions[i].srcOffsets[0].x = region.srcOffset.x;
			_blitRegions[i].srcOffsets[0].y = region.srcOffset.y;
			_blitRegions[i].srcOffsets[0].z = region.srcOffset.z;
			_blitRegions[i].srcOffsets[1].x = ((int32)region.srcOffset.x + (int32)region.srcExtent.width);
			_blitRegions[i].srcOffsets[1].y = ((int32)region.srcOffset.y + (int32)region.srcExtent.height);
			_blitRegions[i].srcOffsets[1].z = ((int32)region.srcOffset.z + (int32)region.srcExtent.depth);

			_blitRegions[i].dstSubresource.aspectMask = dstAspectMask;
			_blitRegions[i].dstSubresource.mipLevel = region.dstSubres.mipLevel;
			_blitRegions[i].dstSubresource.baseArrayLayer = region.dstSubres.baseArrayLayer;
			_blitRegions[i].dstSubresource.layerCount = region.dstSubres.layerCount;
			_blitRegions[i].dstOffsets[0].x = region.dstOffset.x;
			_blitRegions[i].dstOffsets[0].y = region.dstOffset.y;
			_blitRegions[i].dstOffsets[0].z = region.dstOffset.z;
			_blitRegions[i].dstOffsets[1].x = (int32)(region.dstOffset.x + (int32)region.dstExtent.width);
			_blitRegions[i].dstOffsets[1].y = (int32)(region.dstOffset.y + (int32)region.dstExtent.height);
			_blitRegions[i].dstOffsets[1].z = (int32)(region.dstOffset.z + (int32)region.dstExtent.depth);
		}

		vkCmdBlitImage(_gpuCommandBuffer.vkCommandBuffer,
			srcImage, srcImageLayout,
			dstImage, dstImageLayout,
			count, _blitRegions.Ptr, VK_FILTERS[(uint32)filter]);

		if (gpuTextureDst.swapchain != null)
		{
			VkImageMemoryBarrier barrier = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };
			barrier.srcAccessMask = .VK_ACCESS_TRANSFER_WRITE_BIT;
			barrier.oldLayout = .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
			barrier.dstAccessMask = .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
			barrier.newLayout = .VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
			barrier.srcQueueFamilyIndex = barrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;

			barrier.image = dstImage;
			barrier.subresourceRange.aspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
			barrier.subresourceRange.levelCount = barrier.subresourceRange.layerCount = 1;

			vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer,
				.VK_PIPELINE_STAGE_TRANSFER_BIT, .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, .VK_DEPENDENCY_BY_REGION_BIT,
				0, null, 0, null, 1, &barrier);
		}
	}
	public override void copyTexture(Texture srcTexture, Texture dstTexture, in TextureCopy* regions, uint32 count)
	{
		VkImageAspectFlags srcAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImageAspectFlags dstAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImage srcImage = .Null;
		VkImage dstImage = .Null;

		delegate (VkImageAspectFlags, VkImage)(Texture texture) getImage = scope (texture) =>
			{
				CCVKGPUTexture gpuTexture = ((CCVKTexture)texture).gpuTexture();
				return gpuTexture.swapchain != null ? (gpuTexture.aspectMask, gpuTexture.swapchainVkImages[gpuTexture.swapchain.curImageIndex]) : (gpuTexture.aspectMask, gpuTexture.vkImage);
			};

		(srcAspectMask, srcImage) = getImage(srcTexture);
		(dstAspectMask, dstImage) = getImage(dstTexture);

		List<VkImageCopy> copyRegions = scope .(count);
		copyRegions.Resize(count, VkImageCopy());
		for (uint32 i = 0U; i < count; ++i)
		{
			readonly ref TextureCopy region = ref regions[i];
			var copyRegion = ref copyRegions[i];

			copyRegion.srcSubresource.aspectMask = srcAspectMask;
			copyRegion.srcSubresource.mipLevel = region.srcSubres.mipLevel;
			copyRegion.srcSubresource.baseArrayLayer = region.srcSubres.baseArrayLayer;
			copyRegion.srcSubresource.layerCount = region.srcSubres.layerCount;

			copyRegion.dstSubresource.aspectMask = dstAspectMask;
			copyRegion.dstSubresource.mipLevel = region.dstSubres.mipLevel;
			copyRegion.dstSubresource.baseArrayLayer = region.dstSubres.baseArrayLayer;
			copyRegion.dstSubresource.layerCount = region.dstSubres.layerCount;

			copyRegion.srcOffset.x = region.srcOffset.x;
			copyRegion.srcOffset.y = region.srcOffset.y;
			copyRegion.srcOffset.z = region.srcOffset.z;

			copyRegion.dstOffset.x = region.dstOffset.x;
			copyRegion.dstOffset.y = region.dstOffset.y;
			copyRegion.dstOffset.z = region.dstOffset.z;

			copyRegion.extent.width = region.extent.width;
			copyRegion.extent.height = region.extent.height;
			copyRegion.extent.depth = region.extent.depth;
		}
		vkCmdCopyImage(_gpuCommandBuffer.vkCommandBuffer, srcImage, .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, dstImage, .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, count, copyRegions.Ptr);
	}
	public override void resolveTexture(Texture srcTexture, Texture dstTexture, in TextureCopy* regions, uint32 count)
	{
		VkImageAspectFlags srcAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImageAspectFlags dstAspectMask = .VK_IMAGE_ASPECT_COLOR_BIT;
		VkImage srcImage = .Null;
		VkImage dstImage = .Null;

		delegate (VkImageAspectFlags, VkImage)(Texture texture) getImage = scope (texture) =>
			{
				CCVKGPUTexture gpuTexture = ((CCVKTexture)texture).gpuTexture();
				return gpuTexture.swapchain != null ? (gpuTexture.aspectMask, gpuTexture.swapchainVkImages[gpuTexture.swapchain.curImageIndex]) : (gpuTexture.aspectMask, gpuTexture.vkImage);
			};

		(srcAspectMask, srcImage) = getImage(srcTexture);
		(dstAspectMask, dstImage) = getImage(dstTexture);

		List<VkImageResolve> resolveRegions = scope .() { Count = count };
		for (uint32 i = 0U; i < count; ++i)
		{
			readonly ref TextureCopy region = ref regions[i];
			var resolveRegion = ref resolveRegions[i];

			resolveRegion.srcSubresource.aspectMask = srcAspectMask;
			resolveRegion.srcSubresource.mipLevel = region.srcSubres.mipLevel;
			resolveRegion.srcSubresource.baseArrayLayer = region.srcSubres.baseArrayLayer;
			resolveRegion.srcSubresource.layerCount = region.srcSubres.layerCount;

			resolveRegion.dstSubresource.aspectMask = dstAspectMask;
			resolveRegion.dstSubresource.mipLevel = region.dstSubres.mipLevel;
			resolveRegion.dstSubresource.baseArrayLayer = region.dstSubres.baseArrayLayer;
			resolveRegion.dstSubresource.layerCount = region.dstSubres.layerCount;

			resolveRegion.srcOffset.x = region.srcOffset.x;
			resolveRegion.srcOffset.y = region.srcOffset.y;
			resolveRegion.srcOffset.z = region.srcOffset.z;

			resolveRegion.dstOffset.x = region.dstOffset.x;
			resolveRegion.dstOffset.y = region.dstOffset.y;
			resolveRegion.dstOffset.z = region.dstOffset.z;

			resolveRegion.extent.width = region.extent.width;
			resolveRegion.extent.height = region.extent.height;
			resolveRegion.extent.depth = region.extent.depth;
		}
		vkCmdResolveImage(_gpuCommandBuffer.vkCommandBuffer, srcImage, .VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, dstImage, .VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, count, resolveRegions.Ptr);
	}
	public override void execute(CommandBuffer* cmdBuffs, uint32 count)
	{
		if (count == 0) return;
		_vkCommandBuffers.Resize(count);

		uint32 validCount = 0U;
		for (uint32 i = 0U; i < count; ++i)
		{
			var cmdBuff = (CCVKCommandBuffer)(cmdBuffs[i]);
			if (!cmdBuff._pendingQueue.IsEmpty)
			{
				_vkCommandBuffers[validCount++] = cmdBuff._pendingQueue.Front;
				cmdBuff._pendingQueue.PopFront();

				_numDrawCalls += cmdBuff._numDrawCalls;
				_numInstances += cmdBuff._numInstances;
				_numTriangles += cmdBuff._numTriangles;
			}
		}
		if (validCount != 0)
		{
			vkCmdExecuteCommands(_gpuCommandBuffer.vkCommandBuffer, validCount,
				_vkCommandBuffers.Ptr);
		}
	}
	public override void dispatch(in DispatchInfo info)
	{
		if (_firstDirtyDescriptorSet < _curGPUDescriptorSets.Count)
		{
			bindDescriptorSets(.VK_PIPELINE_BIND_POINT_COMPUTE);
		}

		if (info.indirectBuffer != null)
		{
			CCVKGPUDevice gpuDevice = CCVKDevice.getInstance().gpuDevice();
			var indirectBuffer = (CCVKBuffer)(info.indirectBuffer);
			vkCmdDispatchIndirect(_gpuCommandBuffer.vkCommandBuffer, indirectBuffer.gpuBuffer().vkBuffer,
				indirectBuffer.gpuBufferView().getStartOffset(gpuDevice.curBackBufferIndex) + info.indirectOffset);
		}
		else
		{
			vkCmdDispatch(_gpuCommandBuffer.vkCommandBuffer, info.groupCountX, info.groupCountY, info.groupCountZ);
		}
	}
	public override void pipelineBarrier(GeneralBarrier barrier, BufferBarrier* bufferBarriers, Buffer* buffers, uint32 bufferBarrierCount, TextureBarrier* textureBarriers, Texture* textures, uint32 textureBarrierCount)
	{
		VkPipelineStageFlags fullSrcStageMask = .VK_PIPELINE_STAGE_NONE;
		VkPipelineStageFlags fullDstStageMask = .VK_PIPELINE_STAGE_NONE;
		VkPipelineStageFlags splitSrcStageMask = .VK_PIPELINE_STAGE_NONE;
		VkPipelineStageFlags splitDstStageMask = .VK_PIPELINE_STAGE_NONE;
		VkMemoryBarrier* pMemoryBarrier = null;

		List<(uint32 first, VkImageMemoryBarrier second)> splitImageBarriers = scope .();
		List<(uint32 first, VkBufferMemoryBarrier second)> splitBufferBarriers = scope .();
		List<VkImageMemoryBarrier> fullImageBarriers = scope .();
		List<VkBufferMemoryBarrier> fullBufferBarriers = scope .();
		List<VkEvent> scheduledEvents = scope .();

		delegate void(GFXObject obj, VkPipelineStageFlags stageMask) signalEvent = scope [&] (obj, stageMask) =>
			{
				VkEvent event = .Null;
				if (!_availableEvents.IsEmpty)
				{
					event = _availableEvents.Front;
					_availableEvents.PopFront();
				}
				else
				{
					VkEventCreateInfo eventInfo = .()
						{
							sType = .VK_STRUCTURE_TYPE_EVENT_CREATE_INFO,
							pNext = null,
							flags = 0
						};
					VkResult res = vkCreateEvent(CCVKDevice.getInstance().gpuDevice().vkDevice,
						&eventInfo,
						null,
						&event);
					Runtime.Assert(res == .VK_SUCCESS);
				}
				vkCmdSetEvent(_gpuCommandBuffer.vkCommandBuffer, event, stageMask);
				_barrierEvents.Add(obj, event);
			};

		if (textureBarrierCount > 0)
		{
			for (uint32 i = 0U; i < textureBarrierCount; ++i)
			{
				var ccBarrier = (CCVKTextureBarrier)(textureBarriers[i]);
				var gpuBarrier = ccBarrier.gpuBarrier();
				var ccTexture = (CCVKTexture)(textures[i]);
				var gpuTexture = ccTexture.gpuTexture();

				if (ccBarrier.getInfo().type == BarrierType.SPLIT_BEGIN)
				{
					signalEvent(ccTexture, gpuBarrier.srcStageMask);
				}
				else
				{
					bool fullBarrier = ccBarrier.getInfo().type == BarrierType.FULL;
					bool missed = !_barrierEvents.ContainsKey(ccTexture);
					if (!fullBarrier && !missed)
					{
						//CC_ASSERT(_barrierEvents.find(ccTexture) != _barrierEvents.end());
						VkEvent event = _barrierEvents[ccTexture];
						scheduledEvents.Add(event);

						//gpuTexture.currentAccessTypes.assign(gpuBarrier.barrier.pNextAccesses, gpuBarrier.barrier.pNextAccesses + gpuBarrier.barrier.nextAccessCount);
						gpuTexture.currentAccessTypes.Set(Span<ThsvsAccessType>(gpuBarrier.barrier.pNextAccesses, gpuBarrier.barrier.nextAccessCount));
						var srcStageMask = (gpuBarrier.srcStageMask & .VK_PIPELINE_STAGE_HOST_BIT != 0) ? 0x0 : gpuBarrier.srcStageMask;
						(uint32 first, VkImageMemoryBarrier second) splitImageBarrier = (i, gpuBarrier.vkBarrier);
						splitImageBarrier.second.subresourceRange.aspectMask = gpuTexture.aspectMask;
						if (gpuTexture.swapchain != null)
						{
							splitImageBarrier.second.image = gpuTexture.swapchainVkImages[gpuTexture.swapchain.curImageIndex];
						}
						else
						{
							splitImageBarrier.second.image = gpuTexture.vkImage;
						}
						splitSrcStageMask |= gpuBarrier.srcStageMask;
						splitDstStageMask |= gpuBarrier.dstStageMask;
						splitImageBarriers.Add(splitImageBarrier);
					}
					else
					{
						gpuTexture.currentAccessTypes.Set(Span<ThsvsAccessType>(gpuBarrier.barrier.pNextAccesses, gpuBarrier.barrier.nextAccessCount));
						fullImageBarriers.Add(gpuBarrier.vkBarrier);
						fullImageBarriers.Back.srcAccessMask = missed ? .VK_ACCESS_NONE : fullImageBarriers.Back.srcAccessMask;
						fullImageBarriers.Back.subresourceRange.aspectMask = gpuTexture.aspectMask;
						if (gpuTexture.swapchain != null)
						{
							fullImageBarriers.Back.image = gpuTexture.swapchainVkImages[gpuTexture.swapchain.curImageIndex];
						}
						else
						{
							fullImageBarriers.Back.image = gpuTexture.vkImage;
						}
						fullSrcStageMask |= gpuBarrier.srcStageMask;
						fullDstStageMask |= gpuBarrier.dstStageMask;
					}
				}
			}
		}

		if (bufferBarrierCount > 0)
		{
			for (uint32 i = 0U; i < bufferBarrierCount; ++i)
			{
				var ccBarrier = (CCVKBufferBarrier)bufferBarriers[i];
				var gpuBarrier = ccBarrier.gpuBarrier();
				var ccBuffer = (CCVKBuffer)buffers[i];
				var gpuBuffer = ccBuffer.gpuBuffer();

				if (ccBarrier.getInfo().type == BarrierType.SPLIT_BEGIN)
				{
					signalEvent(ccBuffer, gpuBarrier.srcStageMask);
				}
				else
				{
					bool fullBarrier = ccBarrier.getInfo().type == BarrierType.FULL;
					bool missed = !_barrierEvents.ContainsKey(ccBuffer);
					if (!fullBarrier && !missed)
					{
						Runtime.Assert(_barrierEvents.ContainsKey(ccBuffer));
						VkEvent event = _barrierEvents[ccBuffer];
						scheduledEvents.Add(event);

						gpuBuffer.currentAccessTypes.Set(Span<ThsvsAccessType>(gpuBarrier.barrier.pNextAccesses, gpuBarrier.barrier.nextAccessCount));
						(uint32 first, VkBufferMemoryBarrier second) splitBarrier = (i, gpuBarrier.vkBarrier);
						splitBarrier.second.buffer = gpuBuffer.vkBuffer;
						splitSrcStageMask |= gpuBarrier.srcStageMask;
						splitDstStageMask |= gpuBarrier.dstStageMask;
						splitBufferBarriers.Add(splitBarrier);
					}
					else
					{
						gpuBuffer.currentAccessTypes.Set(Span<ThsvsAccessType>(gpuBarrier.barrier.pNextAccesses, gpuBarrier.barrier.nextAccessCount));
						fullBufferBarriers.Add(gpuBarrier.vkBarrier);
						fullBufferBarriers.Back.srcAccessMask = missed ? .VK_ACCESS_NONE : fullBufferBarriers.Back.srcAccessMask;
						fullBufferBarriers.Back.buffer = gpuBuffer.vkBuffer;
						fullSrcStageMask |= gpuBarrier.srcStageMask;
						fullDstStageMask |= gpuBarrier.dstStageMask;
					}
				}
			}
		}

		if (barrier != null)
		{
			var ccBarrier = (CCVKGeneralBarrier)barrier;
			var gpuBarrier = ccBarrier.gpuBarrier();
			fullSrcStageMask |= gpuBarrier.srcStageMask;
			fullDstStageMask |= gpuBarrier.dstStageMask;
			splitSrcStageMask |= gpuBarrier.srcStageMask;
			splitDstStageMask |= gpuBarrier.dstStageMask;
			pMemoryBarrier = &gpuBarrier.vkBarrier;
		}

		fullSrcStageMask = fullSrcStageMask.HasFlag(.VK_PIPELINE_STAGE_HOST_BIT) ? 0x0 : fullSrcStageMask;
		splitSrcStageMask = splitSrcStageMask.HasFlag(.VK_PIPELINE_STAGE_HOST_BIT) ? 0x0 : splitSrcStageMask;

		if (textureBarrierCount != 0 || bufferBarrierCount != 0 || barrier != null)
		{
			// split end detect
			if (!splitBufferBarriers.IsEmpty || !splitImageBarriers.IsEmpty)
			{
				{
					List<VkImageMemoryBarrier> vkImageBarriers = scope .() { Count = splitImageBarriers.Count };
					List<VkBufferMemoryBarrier> vkBufferBarriers = scope .() { Count = splitBufferBarriers.Count };
					for (int idx = 0; idx < splitImageBarriers.Count; ++idx)
					{
						vkImageBarriers[idx] = splitImageBarriers[idx].second;
					}
					for (int idx = 0; idx < splitBufferBarriers.Count; ++idx)
					{
						vkBufferBarriers[idx] = splitBufferBarriers[idx].second;
					}

					vkCmdWaitEvents(_gpuCommandBuffer.vkCommandBuffer, (uint32)scheduledEvents.Count, scheduledEvents.Ptr, splitSrcStageMask, splitDstStageMask, 0, null, (uint32)vkBufferBarriers.Count,
						vkBufferBarriers.Ptr, (uint32)vkImageBarriers.Count, vkImageBarriers.Ptr);
				}

				for (int i = 0; i < splitImageBarriers.Count; ++i)
				{ // NOLINT (range-based-for)
					var index = splitImageBarriers[i].first;
					VkEvent event = _barrierEvents[textures[index]];
					var ccBarrier = ((CCVKTextureBarrier)textureBarriers[index]);
					var gpuBarrier = ccBarrier.gpuBarrier();
					vkCmdResetEvent(_gpuCommandBuffer.vkCommandBuffer, event, gpuBarrier.dstStageMask);
					_barrierEvents.Remove(textures[index]);
					_availableEvents.Add(event);
				}

				for (int i = 0; i < splitBufferBarriers.Count; ++i)
				{ // NOLINT (range-based-for)
					var index = splitBufferBarriers[i].first;
					VkEvent event = _barrierEvents[buffers[index]];
					var ccBarrier = ((CCVKBufferBarrier)bufferBarriers[index]);
					var gpuBarrier = ccBarrier.gpuBarrier();
					vkCmdResetEvent(_gpuCommandBuffer.vkCommandBuffer, event, gpuBarrier.dstStageMask);
					_barrierEvents.Remove(buffers[index]);
					_availableEvents.Add(event);
				}
			}

			if (!fullBufferBarriers.IsEmpty || !fullImageBarriers.IsEmpty)
			{
				vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer, fullSrcStageMask, fullDstStageMask, 0, 0, pMemoryBarrier,
					(uint32)fullBufferBarriers.Count, fullBufferBarriers.Ptr, (uint32)fullImageBarriers.Count, fullImageBarriers.Ptr);
			}
		}
	}
	public override void beginQuery(QueryPool queryPool, uint32 id)
	{
		var vkQueryPool = ((CCVKQueryPool)queryPool);
		CCVKGPUQueryPool gpuQueryPool = vkQueryPool.gpuQueryPool();
		var queryId = (uint32)vkQueryPool.[Friend]_ids.Count;

		if (queryId < queryPool.getMaxQueryObjects())
		{
			vkCmdBeginQuery(_gpuCommandBuffer.vkCommandBuffer, gpuQueryPool.vkPool, queryId, 0);
		}
	}
	public override void endQuery(QueryPool queryPool, uint32 id)
	{
		var vkQueryPool = (CCVKQueryPool)queryPool;
		CCVKGPUQueryPool gpuQueryPool = vkQueryPool.gpuQueryPool();
		var queryId = (uint32)vkQueryPool.[Friend]_ids.Count;

		if (queryId < queryPool.getMaxQueryObjects())
		{
			vkCmdEndQuery(_gpuCommandBuffer.vkCommandBuffer, gpuQueryPool.vkPool, queryId);
			vkQueryPool.[Friend]_ids.Add(id);
		}
	}
	public override void resetQueryPool(QueryPool queryPool)
	{
		var vkQueryPool = (CCVKQueryPool)queryPool;
		CCVKGPUQueryPool gpuQueryPool = vkQueryPool.gpuQueryPool();

		vkCmdResetQueryPool(_gpuCommandBuffer.vkCommandBuffer, gpuQueryPool.vkPool, 0, queryPool.getMaxQueryObjects());
		vkQueryPool.[Friend]_ids.Clear();
	}
	public override void customCommand(CustomCommand cmd)
	{
		cmd((void*)_gpuCommandBuffer.vkCommandBuffer);
	}

	protected typealias ImageBarrierList = List<VkImageMemoryBarrier>;
	protected typealias BufferBarrierList = List<VkBufferMemoryBarrier>;

	protected override void doInit(in CommandBufferInfo info)
	{
		_gpuCommandBuffer = new CCVKGPUCommandBuffer();
		_gpuCommandBuffer.level = mapVkCommandBufferLevel(_type);
		_gpuCommandBuffer.queueFamilyIndex = ((CCVKQueue)_queue).gpuQueue().queueFamilyIndex;

		int setCount = CCVKDevice.getInstance().bindingMappingInfo().setIndices.Count;
		_curGPUDescriptorSets.Resize(setCount);
		_curVkDescriptorSets.Resize(setCount);
		_curDynamicOffsetsArray.Resize(setCount);
	}
	protected override void doDestroy()
	{
		if (_gpuCommandBuffer != null)
		{
			delegate void(VkEvent event) cleanEvent = scope (event) =>
				{
					var res = vkResetEvent(CCVKDevice.getInstance().gpuDevice().vkDevice, event);
					Runtime.Assert(res == .VK_SUCCESS);
					vkDestroyEvent(CCVKDevice.getInstance().gpuDevice().vkDevice, event, null);
				};
			while (!_availableEvents.IsEmpty)
			{
				VkEvent event = _availableEvents.Front;
				cleanEvent(event);
				_availableEvents.PopFront();
			}
			for (var pair in _barrierEvents)
			{
				cleanEvent(pair.value);
			}
		}

		_gpuCommandBuffer = null;
	}

	protected void bindDescriptorSets(VkPipelineBindPoint bindPoint)
	{
		CCVKDevice device = CCVKDevice.getInstance();
		CCVKGPUDevice gpuDevice = device.gpuDevice();
		CCVKGPUPipelineLayout pipelineLayout = _curGPUPipelineState.gpuPipelineLayout;
		readonly ref List<uint32> dynamicOffsetOffsets = ref pipelineLayout.dynamicOffsetOffsets;
		uint32 descriptorSetCount = (uint32)pipelineLayout.setLayouts.Count;
		_curDynamicOffsets.Resize(pipelineLayout.dynamicOffsetCount);

		uint32 dirtyDescriptorSetCount = descriptorSetCount - _firstDirtyDescriptorSet;
		for (uint32 i = _firstDirtyDescriptorSet; i < descriptorSetCount; ++i)
		{
			if (_curGPUDescriptorSets[i] != null)
			{
				readonly ref CCVKGPUDescriptorSet.Instance instance = ref _curGPUDescriptorSets[i].instances[gpuDevice.curBackBufferIndex];
				_curVkDescriptorSets[i] = instance.vkDescriptorSet;
			}
			else
			{
				_curVkDescriptorSets[i] = pipelineLayout.setLayouts[i].defaultDescriptorSet;
			}
			uint32 count = dynamicOffsetOffsets[i + 1] - dynamicOffsetOffsets[i];
			// CC_ASSERT(_curDynamicOffsetCounts[i] >= count);
			count = Math.Min(count, (uint32)_curDynamicOffsetsArray[i].Count);
			if (count > 0) Internal.MemCpy(&_curDynamicOffsets[dynamicOffsetOffsets[i]], _curDynamicOffsetsArray[i].Ptr, count * sizeof(uint32));
		}

		uint32 dynamicOffsetStartIndex = dynamicOffsetOffsets[_firstDirtyDescriptorSet];
		uint32 dynamicOffsetEndIndex = dynamicOffsetOffsets[_firstDirtyDescriptorSet + dirtyDescriptorSetCount];
		uint32 dynamicOffsetCount = dynamicOffsetEndIndex - dynamicOffsetStartIndex;
		vkCmdBindDescriptorSets(_gpuCommandBuffer.vkCommandBuffer,
			bindPoint, pipelineLayout.vkPipelineLayout,
			_firstDirtyDescriptorSet, dirtyDescriptorSetCount,
			&_curVkDescriptorSets[_firstDirtyDescriptorSet],
			dynamicOffsetCount, _curDynamicOffsets.Ptr + dynamicOffsetStartIndex);

		_firstDirtyDescriptorSet = uint32.MaxValue;
	}
	protected void selfDependency()
	{
		VkMemoryBarrier barrier = .() { sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER };
		barrier.srcAccessMask = .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
		barrier.dstAccessMask = .VK_ACCESS_INPUT_ATTACHMENT_READ_BIT | .VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

		vkCmdPipelineBarrier(_gpuCommandBuffer.vkCommandBuffer,
			.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT | .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
			.VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT | .VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
			.VK_DEPENDENCY_BY_REGION_BIT,
			1, &barrier, 0, null, 0, null);
	}

	protected CCVKGPUCommandBuffer _gpuCommandBuffer;

	protected CCVKGPUPipelineState _curGPUPipelineState;
	protected List<CCVKGPUDescriptorSet> _curGPUDescriptorSets;
	protected List<VkDescriptorSet> _curVkDescriptorSets;
	protected List<uint32> _curDynamicOffsets;
	protected List<List<uint32>> _curDynamicOffsetsArray;
	protected uint32 _firstDirtyDescriptorSet = uint32.MaxValue;

	protected CCVKGPUInputAssembler _curGPUInputAssembler;
	protected CCVKGPUFramebuffer _curGPUFBO;
	protected CCVKGPURenderPass _curGPURenderPass;

	protected bool _secondaryRP = false;
	protected bool _hasSubPassSelfDependency = false;
	protected uint32 _currentSubPass = 0;

	protected DynamicStates _curDynamicStates;

	// temp storage
	protected List<VkImageBlit> _blitRegions;
	protected List<VkCommandBuffer> _vkCommandBuffers;
	protected Queue<VkEvent> _availableEvents;
	protected Dictionary<GFXObject, VkEvent> _barrierEvents;

	protected Queue<VkCommandBuffer> _pendingQueue;
	protected VkDebugMarkerMarkerInfoEXT _markerInfo = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT, pNext = null };
	protected VkDebugUtilsLabelEXT _utilLabelInfo = .() { sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT, pNext = null };
}
