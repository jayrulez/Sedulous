using System;
using System.Text;
using Bulkan;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;
using Sedulous.Foundation.Mathematics;
using Sedulous.Foundation.Utilities;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// The Vulkan implementation of a command buffer object.
/// </summary>
public class VKCommandBuffer : CommandBuffer
{
	internal VkCommandBuffer CommandBuffer;

	private VKGraphicsContext context;

	private VKCommandQueue commandQueue;

	private VKFrameBufferBase activeFrameBuffer;

	private VKGraphicsPipelineState currentGraphicsPipelineState;

	private VKComputePipelineState currentComputePipelineState;

	private VKRaytracingPipelineState currentRaytracingPipelineState;

	private PipelineState activePipelineState;

	private VkRect2D[] rawRectangles;

	private VkViewport[] rawViewports;

	private VkBuffer[] vertexBuffers;

	private uint64[] vertexOffsets;

	private VkCommandPool commandPool;

	private String name = new .() ~ delete _;

	private bool disposed;

	/// <inheritdoc />
	protected override GraphicsContext GraphicsContext => context;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value ?? String.Empty);
			context.SetDebugName(VkObjectType.VK_OBJECT_TYPE_COMMAND_BUFFER, (uint64)(int)CommandBuffer.Handle, scope $"{name}_CommandBuffer");
			context.SetDebugName(VkObjectType.VK_OBJECT_TYPE_COMMAND_POOL, commandPool.Handle, scope $"{name}_CommandPool");
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKCommandBuffer" /> class.
	/// </summary>
	/// <param name="context">Graphics Context.</param>
	/// <param name="queue">The commandqueue for this commandbuffer.</param>
	public this(VKGraphicsContext context, VKCommandQueue queue)
	{
		this.context = context;
		commandQueue = queue;
		VkCommandPoolCreateInfo poolInfo = VkCommandPoolCreateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
			flags = VkCommandPoolCreateFlags.VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
		};
		switch (commandQueue.QueueType)
		{
		case CommandQueueType.Graphics:
			poolInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.GraphicsFamily;
			break;
		case CommandQueueType.Compute:
			poolInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.ComputeFamily;
			break;
		case CommandQueueType.Copy:
			poolInfo.queueFamilyIndex = (uint32)this.context.QueueIndices.CopyFamily;
			break;
		}
		VkDevice vkDevice = this.context.VkDevice;
		VkCommandPool newCommandPool = default(VkCommandPool);
		VulkanNative.vkCreateCommandPool(vkDevice, &poolInfo, null, &newCommandPool);
		commandPool = newCommandPool;
		VkCommandBufferAllocateInfo info = VkCommandBufferAllocateInfo()
		{
			sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
			commandPool = commandPool,
			commandBufferCount = 1,
			level = VkCommandBufferLevel.VK_COMMAND_BUFFER_LEVEL_PRIMARY
		};
		VkCommandBuffer newCommandBuffer = default(VkCommandBuffer);
		VulkanNative.vkAllocateCommandBuffers(vkDevice, &info, &newCommandBuffer);
		CommandBuffer = newCommandBuffer;
	}

	/// <inheritdoc />
	protected override void BeginRenderPassInternal(ref RenderPassDescription description)
	{
		FrameBuffer frameBuffer = description.FrameBuffer;
		ClearValue clearValue = description.ClearValue;
		if (clearValue.Flags == ClearFlags.None)
		{
			FrameBufferColorAttachmentList colorTargets = frameBuffer.ColorTargets;
			for (FrameBufferAttachment attachment in colorTargets)
			{
				(attachment.Texture as VKTexture).TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, 0, 1, 0, 1);
			}
			if (frameBuffer.DepthStencilTarget.HasValue)
			{
				(frameBuffer.DepthStencilTarget.Value.Texture as VKTexture).TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL, 0, 1, 0, 1);
			}
		}
		if (activeFrameBuffer == null || activeFrameBuffer != frameBuffer)
		{
			if (activeFrameBuffer != null && activeFrameBuffer != frameBuffer)
			{
				activeFrameBuffer.TransitionToFinalLayout(CommandBuffer);
			}
			if (frameBuffer is VKSwapChainFrameBuffer)
			{
				activeFrameBuffer = frameBuffer as VKSwapChainFrameBuffer;
			}
			else
			{
				activeFrameBuffer = frameBuffer as VKFrameBuffer;
			}
		}
		VkRenderPassBeginInfo renderPassBeginInfo = default(VkRenderPassBeginInfo);
		renderPassBeginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
		renderPassBeginInfo.renderArea = VkRect2D(frameBuffer.Width, frameBuffer.Height);
		VKSwapChainFrameBuffer currentFrameBuffer = frameBuffer as VKSwapChainFrameBuffer;
		if (currentFrameBuffer != null)
		{
			renderPassBeginInfo.framebuffer = currentFrameBuffer.CurrentBackBuffer;
			currentFrameBuffer.FrameBuffers[0].GetRenderPass(clearValue.Flags, out renderPassBeginInfo.renderPass);
		}
		else
		{
			VKFrameBuffer rtFrameBuffer = frameBuffer as VKFrameBuffer;
			if (rtFrameBuffer != null)
			{
				renderPassBeginInfo.framebuffer = rtFrameBuffer.NativeFrameBuffer;
				rtFrameBuffer.GetRenderPass(clearValue.Flags, out renderPassBeginInfo.renderPass);
			}
		}
		VulkanNative.vkCmdBeginRenderPass(CommandBuffer, &renderPassBeginInfo, VkSubpassContents.VK_SUBPASS_CONTENTS_INLINE);
		VkClearValue vkClearValue = default(VkClearValue);
		if ((clearValue.Flags & ClearFlags.Target) == ClearFlags.Target)
		{
			for (uint32 i = 0; i < frameBuffer.ColorTargets.Count; i++)
			{
				Vector4 colorValue = clearValue.ColorValues[i];
				vkClearValue.color = VkClearColorValue(colorValue.X, colorValue.Y, colorValue.Z, colorValue.W);
				VkClearAttachment vkClearAttachment = default(VkClearAttachment);
				vkClearAttachment.colorAttachment = i;
				vkClearAttachment.aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT;
				vkClearAttachment.clearValue = vkClearValue;
				VkClearAttachment clearAttachment = vkClearAttachment;
				Texture colorTexture = frameBuffer.ColorTargets[i].AttachmentTexture;
				VkClearRect vkClearRect = default(VkClearRect);
				vkClearRect.baseArrayLayer = 0;
				vkClearRect.layerCount = 1;
				vkClearRect.rect = VkRect2D(0, 0, colorTexture.Description.Width, colorTexture.Description.Height);
				VkClearRect clearRect = vkClearRect;
				VulkanNative.vkCmdClearAttachments(CommandBuffer, 1, &clearAttachment, 1, &clearRect);
			}
		}
		if ((clearValue.Flags & ClearFlags.Depth) == ClearFlags.Depth || (clearValue.Flags & ClearFlags.Stencil) == ClearFlags.Stencil)
		{
			bool hasStencil = Helpers.IsStencilFormat(frameBuffer.DepthStencilTarget.Value.AttachmentTexture.Description.Format);
			VkClearAttachment vkClearAttachment = default(VkClearAttachment);
			vkClearAttachment.aspectMask = (hasStencil ? (VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT | VkImageAspectFlags.VK_IMAGE_ASPECT_STENCIL_BIT) : VkImageAspectFlags.VK_IMAGE_ASPECT_DEPTH_BIT);
			vkClearAttachment.clearValue = VkClearValue()
			{
				depthStencil = VkClearDepthStencilValue()
				{
					depth = clearValue.Depth,
					stencil = clearValue.Stencil
				}
			};
			VkClearAttachment clearAttachment = vkClearAttachment;
			Texture depthTexture = frameBuffer.DepthStencilTarget.Value.AttachmentTexture;
			VkClearRect vkClearRect = default(VkClearRect);
			vkClearRect.baseArrayLayer = 0;
			vkClearRect.layerCount = 1;
			vkClearRect.rect = VkRect2D(0, 0, depthTexture.Description.Width, depthTexture.Description.Height);
			VkClearRect clearRect = vkClearRect;
			VulkanNative.vkCmdClearAttachments(CommandBuffer, 1, &clearAttachment, 1, &clearRect);
		}
	}

	/// <inheritdoc />
	protected override void EndRenderPassInternal()
	{
		VulkanNative.vkCmdEndRenderPass(CommandBuffer);
		activeFrameBuffer.TransitionToIntermedialLayout(CommandBuffer);
	}

	/// <inheritdoc />
	public override void Begin()
	{
		if (base.State == CommandBufferState.Recording)
		{
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "Begin cannot be called again until End has been successfully called");
		}
		VkCommandBufferBeginInfo beginInfo = default(VkCommandBufferBeginInfo);
		beginInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
		beginInfo.flags = VkCommandBufferUsageFlags.VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
		VulkanNative.vkBeginCommandBuffer(CommandBuffer, &beginInfo);
		activeFrameBuffer = null;
		base.State = CommandBufferState.Recording;
	}

	/// <inheritdoc />
	protected override void EndInternal()
	{
		activeFrameBuffer?.TransitionToFinalLayout(CommandBuffer);
		activeFrameBuffer = null;
		if (base.State == CommandBufferState.Initial)
		{
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "End was called, but Begin has not yet been called. You mush call Begin successfully before you can call End.");
		}
		VulkanNative.vkEndCommandBuffer(CommandBuffer);
		base.State = CommandBufferState.Executable;
	}

	/// <inheritdoc />
	public override void Reset()
	{
		base.State = CommandBufferState.Initial;
	}

	/// <inheritdoc />
	public override void Commit()
	{
		if (base.State == CommandBufferState.Commited)
		{
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "This commandbuffer was already committed.");
		}
		if (base.State != CommandBufferState.Executable)
		{
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "You mush record some command before to execute a commandbuffer. Call begin...end methods before to commit.");
		}
		commandQueue.CommitCommandBuffer(this);
		base.State = CommandBufferState.Commited;
	}

	/// <inheritdoc />
	public override void Dispatch(uint32 threadGroupCountX, uint32 threadGroupCountY, uint32 threadGroupCountZ)
	{
		VulkanNative.vkCmdDispatch(CommandBuffer, threadGroupCountX, threadGroupCountY, threadGroupCountZ);
	}

	/// <inheritdoc />
	public override void DispatchIndirect(Buffer argBuffer, uint32 offset)
	{
		VKBuffer buffer = argBuffer as VKBuffer;
		VulkanNative.vkCmdDispatchIndirect(CommandBuffer, buffer.NativeBuffer, offset);
	}

	/// <inheritdoc />
	public override void Draw(uint32 vertexCount, uint32 startVertexLocation = 0)
	{
		VulkanNative.vkCmdDraw(CommandBuffer, vertexCount, 1, startVertexLocation, 0);
	}

	/// <inheritdoc />
	public override void DrawIndexed(uint32 indexCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0)
	{
		VulkanNative.vkCmdDrawIndexed(CommandBuffer, indexCount, 1, startIndexLocation, (int32)baseVertexLocation, 0);
	}

	/// <inheritdoc />
	public override void DrawIndexedInstanced(uint32 indexCountPerInstance, uint32 instanceCount, uint32 startIndexLocation = 0, uint32 baseVertexLocation = 0, uint32 startInstanceLocation = 0)
	{
		VulkanNative.vkCmdDrawIndexed(CommandBuffer, indexCountPerInstance, instanceCount, startIndexLocation, (int32)baseVertexLocation, startInstanceLocation);
	}

	/// <inheritdoc />
	public override void DrawIndexedInstancedIndirect(Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
	{
		if ((argBuffer.Description.Flags & BufferFlags.IndirectBuffer) == 0)
		{
			GraphicsContext.ValidationLayer?.Notify("Vulkan", "DrawIndexedInstancedIndirect must be an argBuffer with IndirectBuffer flag");
		}
		VKBuffer buffer = argBuffer as VKBuffer;
		VulkanNative.vkCmdDrawIndexedIndirect(CommandBuffer, buffer.NativeBuffer, offset, drawCount, stride);
	}

	/// <inheritdoc />
	public override void DrawInstanced(uint32 vertexCountPerInstance, uint32 instanceCount, uint32 startVertexLocation = 0, uint32 startInstanceLocation = 0)
	{
		VulkanNative.vkCmdDraw(CommandBuffer, vertexCountPerInstance, instanceCount, startVertexLocation, startInstanceLocation);
	}

	/// <inheritdoc />
	public override void DrawInstancedIndirect(Buffer argBuffer, uint32 offset, uint32 drawCount, uint32 stride)
	{
		VKBuffer buffer = argBuffer as VKBuffer;
		VulkanNative.vkCmdDrawIndirect(CommandBuffer, buffer.NativeBuffer, offset, drawCount, stride);
	}

	/// <inheritdoc />
	protected override void SetIndexBufferInternal(Buffer buffer, IndexFormat format = IndexFormat.UInt16, uint32 offset = 0)
	{
		VKBuffer vkBuffer = buffer as VKBuffer;
		VkIndexType vkFormat = format.ToVulkan();
		VulkanNative.vkCmdBindIndexBuffer(CommandBuffer, vkBuffer.NativeBuffer, offset, vkFormat);
	}

	/// <inheritdoc />
	protected override void SetGraphicsPipelineStateInternal(GraphicsPipelineState pipeline)
	{
		VKGraphicsPipelineState newPipeline = pipeline as VKGraphicsPipelineState;
		VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, newPipeline.NativePipeline);
		currentGraphicsPipelineState = newPipeline;
		activePipelineState = newPipeline;
		if (!currentGraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
		{
			VkRect2D maxSccisorSize = VkRect2D(0, 0, 15360, 8640);
			VulkanNative.vkCmdSetScissor(CommandBuffer, 0, 1, &maxSccisorSize);
		}
	}

	/// <inheritdoc />
	protected override void SetComputePipelineStateInternal(ComputePipelineState pipeline)
	{
		VKComputePipelineState newPipeline = pipeline as VKComputePipelineState;
		VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, newPipeline.NativePipeline);
		currentComputePipelineState = newPipeline;
		activePipelineState = newPipeline;
	}

	/// <inheritdoc />
	protected override void SetRaytracingPipelineStateInternal(RaytracingPipelineState pipeline)
	{
		VKRaytracingPipelineState newPipeline = pipeline as VKRaytracingPipelineState;
		VulkanNative.vkCmdBindPipeline(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR, newPipeline.NativePipeline);
		currentRaytracingPipelineState = newPipeline;
		activePipelineState = newPipeline;
	}

	/// <inheritdoc />
	protected override void SetResourceSetInternal(ResourceSet resourceSet, uint32 index, uint32[] offsets)
	{
		VKResourceSet vkResourceSet = resourceSet as VKResourceSet;
		for (int i = 0; i < vkResourceSet.StorageTextures.Count; i++)
		{
			VKTexture storageImage = vkResourceSet.StorageTextures[i];
			storageImage.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_GENERAL, 0, storageImage.Description.MipLevels, 0, storageImage.Description.ArraySize);
		}
		for (int i = 0; i < vkResourceSet.Textures.Count; i++)
		{
			VKTexture textureImage = vkResourceSet.Textures[i];
			textureImage.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 0, textureImage.Description.MipLevels, 0, textureImage.Description.ArraySize);
		}
		VkDescriptorSet nativeResourceSet = vkResourceSet.DescriptorAllocationToken.DescriptorSet;
		uint32* dynamicOffsets = scope uint32[(int32)vkResourceSet.DynamicBufferCount]*;
		if (vkResourceSet.DynamicBufferCount != 0 && offsets != null)
		{
			if (offsets.Count < vkResourceSet.DynamicBufferCount)
			{
				GraphicsContext.ValidationLayer?.Notify("Vulkan", "offsets error.");
			}
			else
			{
				for (int i = 0; i < vkResourceSet.DynamicBufferCount; i++)
				{
					dynamicOffsets[i] = offsets[i];
				}
			}
		}
		if (activePipelineState is VKGraphicsPipelineState)
		{
			VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_GRAPHICS, currentGraphicsPipelineState.NativePipelineLayout, 0, 1, &nativeResourceSet, vkResourceSet.DynamicBufferCount, dynamicOffsets);
		}
		else if (activePipelineState is VKComputePipelineState)
		{
			VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_COMPUTE, currentComputePipelineState.NativePipelineLayout, 0, 1, &nativeResourceSet, vkResourceSet.DynamicBufferCount, dynamicOffsets);
		}
		else if (activePipelineState is VKRaytracingPipelineState)
		{
			VulkanNative.vkCmdBindDescriptorSets(CommandBuffer, VkPipelineBindPoint.VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR, currentRaytracingPipelineState.NativePipelineLayout, 0, 1, &nativeResourceSet, vkResourceSet.DynamicBufferCount, dynamicOffsets);
		}
		else
		{
			context.ValidationLayer.Notify("VK", "PipelineState type not supported!");
		}
	}

	/// <inheritdoc />
	public override void SetScissorRectangles(Rectangle[] rectangles)
	{
		VKGraphicsPipelineState vKGraphicsPipelineState = currentGraphicsPipelineState;
		if (vKGraphicsPipelineState == null || vKGraphicsPipelineState.Description.RenderStates.RasterizerState.ScissorEnable)
		{
			ArrayHelpers.EnsureArraySize(ref rawRectangles, rectangles.Count);
			for (int i = 0; i < rectangles.Count; i++)
			{
				Rectangle rectangle = rectangles[i];
				rawRectangles[i] = VkRect2D(rectangle.X, rectangle.Y, rectangle.Width, rectangle.Height);
			}
			VkRect2D* pointer = rawRectangles.Ptr;
			{
				VulkanNative.vkCmdSetScissor(CommandBuffer, 0, (uint32)rectangles.Count, pointer);
			}
		}
	}

	/// <inheritdoc />
	protected override void SetVertexBufferInternal(uint32 slot, Buffer buffer, uint32 offset = 0)
	{
		VKBuffer obj = buffer as VKBuffer;
		uint64 nativeOffset = offset;
		VkBuffer pBuffer = obj.NativeBuffer;
		VulkanNative.vkCmdBindVertexBuffers(CommandBuffer, slot, 1, &pBuffer, &nativeOffset);
	}

	/// <inheritdoc />
	protected override void SetVertexBuffersInternal(Buffer[] buffers, int32[] offsets)
	{
		ArrayHelpers.EnsureArraySize(ref vertexBuffers, buffers.Count);
		ArrayHelpers.EnsureArraySize(ref vertexOffsets, buffers.Count);
		for (int i = 0; i < buffers.Count; i++)
		{
			vertexBuffers[i] = (buffers[i] as VKBuffer).NativeBuffer;
			vertexOffsets[i] = (uint64)((offsets != null) ? offsets[i] : 0);
		}
		VkBuffer* buffersPointer = vertexBuffers.Ptr;
		{
			uint64* pOffsets = vertexOffsets.Ptr;
			{
				VulkanNative.vkCmdBindVertexBuffers(CommandBuffer, 0, (uint32)buffers.Count, buffersPointer, pOffsets);
			}
		}
	}

	/// <inheritdoc />
	public override void SetViewports(Viewport[] viewports)
	{
		ArrayHelpers.EnsureArraySize(ref rawViewports, viewports.Count);
		for (int i = 0; i < viewports.Count; i++)
		{
			Viewport viewport = viewports[i];
			float viewportY = (context.ClipSpaceYInvertedSupported ? (viewport.Height + viewport.Y) : viewport.Y);
			float viewportHeight = (context.ClipSpaceYInvertedSupported ? (0f - viewport.Height) : viewport.Height);
			rawViewports[i] = VkViewport()
			{
				x = viewport.X,
				y = viewportY,
				width = viewport.Width,
				height = viewportHeight,
				minDepth = viewport.MinDepth,
				maxDepth = viewport.MaxDepth
			};
		}
		VkViewport* viewportPointer = rawViewports.Ptr;
		{
			VulkanNative.vkCmdSetViewport(CommandBuffer, 0, (uint32)rawViewports.Count, viewportPointer);
		}
	}

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="buffer">The buffer.</param>
	public override void ResourceBarrierUnorderedAccessView(Buffer buffer)
	{
		VkBufferMemoryBarrier barrier = default(VkBufferMemoryBarrier);
		barrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
		barrier.buffer = (buffer as VKBuffer).NativeBuffer;
		barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
		barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
		barrier.srcQueueFamilyIndex = uint32.MaxValue;
		barrier.dstQueueFamilyIndex = uint32.MaxValue;
		barrier.size = uint64.MaxValue;
		VulkanNative.vkCmdPipelineBarrier(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 1, &barrier, 0, null);
	}

	/// <summary>
	/// Sets a resource barrier for a texture.
	/// </summary>
	/// <param name="texture">The texture.</param>
	public override void ResourceBarrierUnorderedAccessView(Texture texture)
	{
		VkImageMemoryBarrier barrier = default(VkImageMemoryBarrier);
		barrier.sType = VkStructureType.VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
		barrier.image = (texture as VKTexture).NativeImage;
		barrier.srcAccessMask = VkAccessFlags.VK_ACCESS_NONE;
		barrier.dstAccessMask = VkAccessFlags.VK_ACCESS_SHADER_READ_BIT | VkAccessFlags.VK_ACCESS_SHADER_WRITE_BIT;
		barrier.srcQueueFamilyIndex = uint32.MaxValue;
		barrier.dstQueueFamilyIndex = uint32.MaxValue;
		VulkanNative.vkCmdPipelineBarrier(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VkDependencyFlags.None, 0, null, 0, null, 1, &barrier);
	}

	/// <inheritdoc />
	public override void GenerateMipmaps(Texture texture)
	{
		VKTexture vkTexture = texture as VKTexture;
		TextureDescription description = vkTexture.Description;
		vkTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, 0, 1, 0, description.ArraySize);
		vkTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, description.MipLevels - 1, 0, description.ArraySize);
		uint32 blitCount = description.MipLevels - 1;
		VkImageBlit* regions = scope VkImageBlit[(int32)blitCount]*;
		for (uint32 level = 1; level < description.MipLevels; level++)
		{
			uint32 blitIndex = level - 1;
			regions[blitIndex].srcSubresource = VkImageSubresourceLayers()
			{
				aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
				baseArrayLayer = 0,
				layerCount = description.ArraySize,
				mipLevel = 0
			};
			regions[blitIndex].srcOffsets[0] = default(VkOffset3D);
			regions[blitIndex].srcOffsets[1] = VkOffset3D()
			{
				x = (int32)description.Width,
				y = (int32)description.Height,
				z = (int32)description.Depth
			};
			regions[blitIndex].dstSubresource = VkImageSubresourceLayers()
			{
				aspectMask = VkImageAspectFlags.VK_IMAGE_ASPECT_COLOR_BIT,
				baseArrayLayer = 0,
				layerCount = description.ArraySize,
				mipLevel = level
			};
			regions[blitIndex].dstOffsets[0] = default(VkOffset3D);
			Helpers.GetMipDimensions(description, level, var width, var height, var depth);
			regions[blitIndex].dstOffsets[1] = VkOffset3D()
			{
				x = (int32)width,
				y = (int32)height,
				z = (int32)depth
			};
		}
		VkFormatProperties vkFormatProperties = default(VkFormatProperties);
		VulkanNative.vkGetPhysicalDeviceFormatProperties(context.VkPhysicalDevice, vkTexture.Format, &vkFormatProperties);
		VkFilter filter = VkFilter.VK_FILTER_NEAREST;
		if ((vkFormatProperties.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_EXT) != 0)
		{
			filter = VkFilter.VK_FILTER_CUBIC_EXT;
		}
		else if ((vkFormatProperties.optimalTilingFeatures & VkFormatFeatureFlags.VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT) != 0)
		{
			filter = VkFilter.VK_FILTER_LINEAR;
		}
		VulkanNative.vkCmdBlitImage(CommandBuffer, vkTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vkTexture.NativeImage, VkImageLayout.VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, blitCount, regions, filter);
		if ((description.Flags & TextureFlags.ShaderResource) != 0)
		{
			vkTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 0, 1, 0, description.ArraySize);
			vkTexture.TransitionImageLayout(CommandBuffer, VkImageLayout.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, 1, description.MipLevels - 1, 0, description.ArraySize);
		}
	}

	/// <inheritdoc />
	protected override void CopyBufferDataToInternal(Buffer origin, Buffer destination, uint32 sizeInBytes, uint32 sourceOffset = 0, uint32 destinationOffset = 0)
	{
		(origin as VKBuffer).CopyTo(CommandBuffer, commandQueue.QueueType, destination, sizeInBytes, sourceOffset, destinationOffset);
	}

	/// <inheritdoc />
	protected override void CopyTextureDataToInternal(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 width, uint32 height, uint32 depth, uint32 layerCount)
	{
		(source as VKTexture).CopyTo(CommandBuffer, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, width, height, depth, layerCount);
	}

	/// <inheritdoc />
	protected override void Blit(Texture source, uint32 sourceX, uint32 sourceY, uint32 sourceZ, uint32 sourceMipLevel, uint32 sourceBasedArrayLayer, Texture destination, uint32 destinationX, uint32 destinationY, uint32 destinationZ, uint32 destinationMipLevel, uint32 destinationBasedArrayLayer, uint32 layerCount)
	{
		(source as VKTexture).Blit(CommandBuffer, sourceX, sourceY, sourceZ, sourceMipLevel, sourceBasedArrayLayer, destination, destinationX, destinationY, destinationZ, destinationMipLevel, destinationBasedArrayLayer, layerCount);
	}

	/// <inheritdoc />
	protected override void UpdateBufferDataInternal(Buffer buffer, void* source, uint32 sourceSizeInBytes, uint32 destinationOffsetInBytes = 0)
	{
		(buffer as VKBuffer).SetData(CommandBuffer, source, sourceSizeInBytes, destinationOffsetInBytes);
	}

	/// <inheritdoc />
	public override void BeginDebugMarker(String label)
	{
		if (context.DebugMarkerEnabled && !String.IsNullOrEmpty(label))
		{
			VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT = default(VkDebugUtilsLabelEXT);
			vkDebugUtilsLabelEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT;
			vkDebugUtilsLabelEXT.pLabelName = label.CStr();
			VkDebugUtilsLabelEXT labelInfo = vkDebugUtilsLabelEXT;
			VulkanNative.vkCmdBeginDebugUtilsLabelEXT(CommandBuffer, &labelInfo);
		}
	}

	/// <inheritdoc />
	public override void EndDebugMarker()
	{
		if (context.DebugMarkerEnabled)
		{
			VulkanNative.vkCmdEndDebugUtilsLabelEXT(CommandBuffer);
		}
	}

	/// <inheritdoc />
	public override void InsertDebugMarker(String label)
	{
		if (context.DebugMarkerEnabled && !String.IsNullOrEmpty(label))
		{
			VkDebugUtilsLabelEXT vkDebugUtilsLabelEXT = default(VkDebugUtilsLabelEXT);
			vkDebugUtilsLabelEXT.sType = VkStructureType.VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT;
			vkDebugUtilsLabelEXT.pLabelName = label.CStr();
			VkDebugUtilsLabelEXT labelInfo = vkDebugUtilsLabelEXT;
			VulkanNative.vkCmdInsertDebugUtilsLabelEXT(CommandBuffer, &labelInfo);
		}
	}

	/// <inheritdoc />
	public override void WriteTimestamp(QueryHeap heap, uint32 index)
	{
		VKQueryHeap vkheap = (VKQueryHeap)heap;
		VulkanNative.vkCmdWriteTimestamp(CommandBuffer, VkPipelineStageFlags.VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, vkheap.nativeQueryHeap, index);
	}

	/// <inheritdoc />
	public override void BeginQuery(QueryHeap heap, uint32 index)
	{
		VKQueryHeap vkheap = (VKQueryHeap)heap;
		switch (heap.Description.Type)
		{
		case QueryType.Occlusion:
			VulkanNative.vkCmdBeginQuery(CommandBuffer, vkheap.nativeQueryHeap, index, VkQueryControlFlags.VK_QUERY_CONTROL_PRECISE_BIT);
			break;
		case QueryType.BinaryOcclusion:
			VulkanNative.vkCmdBeginQuery(CommandBuffer, vkheap.nativeQueryHeap, index, VkQueryControlFlags.None);
			break;
		default: break;
		}
	}

	/// <inheritdoc />
	public override void EndQuery(QueryHeap heap, uint32 index)
	{
		VKQueryHeap vkheap = (VKQueryHeap)heap;
		VulkanNative.vkCmdEndQuery(CommandBuffer, vkheap.nativeQueryHeap, index);
	}

	/// <inheritdoc />
	public override BottomLevelAS BuildRaytracingAccelerationStructure(BottomLevelASDescription description)
	{
		var description;
		return new VKBottomLevelAS(context, CommandBuffer, ref description);
	}

	/// <inheritdoc />
	public override TopLevelAS BuildRaytracingAccelerationStructure(TopLevelASDescription description)
	{
		var description;
		return new VKTopLevelAS(context, CommandBuffer, ref description);
	}

	/// <inheritdoc />
	public override void UpdateRaytracingAccelerationStructure(ref TopLevelAS tlas, TopLevelASDescription newDescription)
	{
		var newDescription;
		((VKTopLevelAS)tlas).UpdateAccelerationStructure(CommandBuffer, ref newDescription);
	}

	/// <inheritdoc />
	public override void DispatchRays(DispatchRaysDescription description)
	{
		VKShaderTable shaderBindingTable = currentRaytracingPipelineState.shaderBindingTable;
		VkStridedDeviceAddressRegionKHR vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
		vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetRayGenStartAddress();
		vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetRayGenStride();
		vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetRayGenSize();
		VkStridedDeviceAddressRegionKHR rayGenSBT = vkStridedDeviceAddressRegionKHR;
		vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
		vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetMissStartAddress();
		vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetMissStride();
		vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetMissSize();
		VkStridedDeviceAddressRegionKHR rayMissSBT = vkStridedDeviceAddressRegionKHR;
		vkStridedDeviceAddressRegionKHR = default(VkStridedDeviceAddressRegionKHR);
		vkStridedDeviceAddressRegionKHR.deviceAddress = shaderBindingTable.GetHitGroupStartAddress();
		vkStridedDeviceAddressRegionKHR.stride = shaderBindingTable.GetHitGroupStride();
		vkStridedDeviceAddressRegionKHR.size = shaderBindingTable.GetHitGroupSize();
		VkStridedDeviceAddressRegionKHR rayHitSBT = vkStridedDeviceAddressRegionKHR;
		VkStridedDeviceAddressRegionKHR rayCallableSBT = default(VkStridedDeviceAddressRegionKHR);
		VulkanNative.vkCmdTraceRaysKHR(CommandBuffer, &rayGenSBT, &rayMissSBT, &rayHitSBT, &rayCallableSBT, description.Width, description.Height, description.Depth);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing">
	/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
	/// </param>
	protected virtual void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				VulkanNative.vkDestroyCommandPool(context.VkDevice, commandPool, null);
			}
			disposed = true;
		}
	}
}
