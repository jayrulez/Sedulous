using Bulkan;
using System;
using System.Collections;
namespace Sedulous.RAL.VK;

class VKCommandQueue : CommandQueue
{
	private VKDevice m_device;
	private uint32 m_queue_family_index;
	private VkQueue m_queue;

	public this(VKDevice device, CommandListType type, uint32 queue_family_index)
	{
		m_device = device;
		m_queue_family_index = queue_family_index;

		VulkanNative.vkGetDeviceQueue(m_device.GetDevice(), m_queue_family_index, 0, &m_queue);
	}
	public override void Wait(in Fence fence, uint64 value)
	{
		var value;
		var vk_fence = fence.As<VKTimelineSemaphore>();
		VkTimelineSemaphoreSubmitInfo timeline_info = .() { sType = .VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO };
		timeline_info.waitSemaphoreValueCount = 1;
		timeline_info.pWaitSemaphoreValues = &value;

		VkSubmitInfo signal_submit_info = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		signal_submit_info.pNext = &timeline_info;
		signal_submit_info.waitSemaphoreCount = 1;
		var timelineSemaphore = vk_fence.GetFence();
		signal_submit_info.pWaitSemaphores = &timelineSemaphore;
		VkPipelineStageFlags wait_dst_stage_mask = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT;
		signal_submit_info.pWaitDstStageMask = &wait_dst_stage_mask;
		VulkanNative.vkQueueSubmit(m_queue, 1, &signal_submit_info, .Null);
	}

	public override void Signal(in Fence fence, uint64 value)
	{
		var value;
		var vk_fence = fence.As<VKTimelineSemaphore>();
		VkTimelineSemaphoreSubmitInfo timeline_info = .() { sType = .VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO };
		timeline_info.signalSemaphoreValueCount = 1;
		timeline_info.pSignalSemaphoreValues = &value;

		VkSubmitInfo signal_submit_info = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		signal_submit_info.pNext = &timeline_info;
		signal_submit_info.signalSemaphoreCount = 1;
		var timelineSemaphore = vk_fence.GetFence();
		signal_submit_info.pSignalSemaphores = &timelineSemaphore;
		VulkanNative.vkQueueSubmit(m_queue, 1, &signal_submit_info, .Null);
	}

	public override void ExecuteCommandLists(Span<CommandList> command_lists)
	{
		List<VkCommandBuffer> vk_command_lists = scope .();
		for (var command_list in command_lists)
		{
			if (command_list == null)
			{
				continue;
			}
			var vk_command_list = command_list.As<VKCommandList>();
			vk_command_lists.Add(vk_command_list.GetCommandList());
		}

		VkSubmitInfo submit_info = .() { sType = .VK_STRUCTURE_TYPE_SUBMIT_INFO };
		submit_info.commandBufferCount = (uint32)vk_command_lists.Count;
		submit_info.pCommandBuffers = vk_command_lists.Ptr;

		VkPipelineStageFlags wait_dst_stage_mask = VkPipelineStageFlags.VK_PIPELINE_STAGE_ALL_COMMANDS_BIT;
		submit_info.pWaitDstStageMask = &wait_dst_stage_mask;

		VulkanNative.vkQueueSubmit(m_queue, 1, &submit_info, .Null);
	}

	public ref VKDevice GetDevice()
	{
		return ref m_device;
	}

	public uint32 GetQueueFamilyIndex()
	{
		return m_queue_family_index;
	}

	public VkQueue GetQueue()
	{
		return m_queue;
	}
}