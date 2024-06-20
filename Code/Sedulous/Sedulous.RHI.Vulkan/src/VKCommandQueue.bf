using System;
using Bulkan;
using Sedulous.RHI;
using System.Collections;

using internal Sedulous.RHI.Vulkan;
using static Sedulous.RHI.Vulkan.VKExtensionsMethods;
namespace Sedulous.RHI.Vulkan;

/// <summary>
/// This class represent a queue where commandbuffers waits to be executing by the GPU.
/// </summary>
public class VKCommandQueue : CommandQueue
{
	private bool disposed;

	private VKGraphicsContext vkContext;

	private String name = new .() ~ delete _;

	private Queue<VKCommandBuffer> queue;

	private VKCommandBuffer[] executionArray;

	internal VkQueue CommandQueue;

	internal CommandQueueType QueueType;

	private int32 executionArraySize;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
			vkContext?.SetDebugName(VkObjectType.VK_OBJECT_TYPE_QUEUE, (uint64)CommandQueue.Handle, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Vulkan.VKCommandQueue" /> class.
	/// </summary>
	/// <param name="context">The graphics context instance.</param>
	/// <param name="queueType">The commandqueue elements type.</param>
	public this(VKGraphicsContext context, CommandQueueType queueType)
	{
		vkContext = context;
		queue = new Queue<VKCommandBuffer>();
		executionArray = new VKCommandBuffer[64];
		executionArraySize = 0;
		QueueType = queueType;
		uint32 familyIndex = 0;
		switch (queueType)
		{
		case CommandQueueType.Graphics:
			familyIndex = (uint32)vkContext.QueueIndices.GraphicsFamily;
			break;
		case CommandQueueType.Compute:
			familyIndex = (uint32)vkContext.QueueIndices.ComputeFamily;
			break;
		case CommandQueueType.Copy:
			familyIndex = (uint32)vkContext.QueueIndices.CopyFamily;
			break;
		}
		VkQueue newQueue = default(VkQueue);
		VulkanNative.vkGetDeviceQueue(vkContext.VkDevice, familyIndex, 0, &newQueue);
		CommandQueue = newQueue;
	}

	/// <inheritdoc />
	public override CommandBuffer CommandBuffer()
	{
		VKCommandBuffer commandBuffer;
		if (queue.Count == 0)
		{
			commandBuffer = new VKCommandBuffer(vkContext, this);
		}
		else
		{
			commandBuffer = queue.PopFront();
			VulkanNative.vkResetCommandBuffer(commandBuffer.CommandBuffer, VkCommandBufferResetFlags.None);
			commandBuffer.Reset();
		}
		return commandBuffer;
	}

	/// <inheritdoc />
	public override void Submit()
	{
		if (vkContext.BufferUploader.Count != 0 || vkContext.TextureUploader.Count != 0)
		{
			vkContext.SyncUpcopyQueue();
		}
		for (int i = 0; i < executionArraySize; i++)
		{
			VKCommandBuffer commandBuffer = executionArray[i];
			VkCommandBuffer nativeCommandBuffer = commandBuffer.CommandBuffer;
			VkPipelineStageFlags stateMask = VkPipelineStageFlags.VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
			VkSubmitInfo submitInfo = default(VkSubmitInfo);
			submitInfo.sType = VkStructureType.VK_STRUCTURE_TYPE_SUBMIT_INFO;
			submitInfo.commandBufferCount = 1;
			submitInfo.pCommandBuffers = &nativeCommandBuffer;
			submitInfo.pWaitDstStageMask = &stateMask;
			VulkanNative.vkQueueSubmit(CommandQueue, 1, &submitInfo, VkFence.Null);
			queue.Add(commandBuffer);
		}
		ClearExecutionArray();
	}

	/// <inheritdoc />
	public override void WaitIdle()
	{
		VulkanNative.vkQueueWaitIdle(CommandQueue);
	}

	/// <summary>
	/// Add a new commandbuffer ready to be executed.
	/// </summary>
	/// <param name="commandBuffer">The new commandbuffer.</param>
	internal void CommitCommandBuffer(VKCommandBuffer commandBuffer)
	{
		if (executionArray.Count == executionArraySize)
		{
			Array.Resize(ref executionArray, executionArray.Count + 64);
		}
		executionArray[executionArraySize++] = commandBuffer;
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	///  Clear the execution commandbuffer array.
	/// </summary>
	private void ClearExecutionArray()
	{
		for (int i = 0; i < executionArraySize; i++)
		{
			executionArray[i] = null;
		}
		executionArraySize = 0;
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing">
	/// <c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.
	/// </param>
	protected virtual void Dispose(bool disposing)
	{
		if (!disposed && disposing)
		{
			WaitIdle();
			while (queue.Count > 0)
			{
				queue.PopFront().Dispose();
			}
			disposed = true;
		}
	}
}
