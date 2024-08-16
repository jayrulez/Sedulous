using Bulkan;
namespace Sedulous.RAL.VK;

class VKTimelineSemaphore : Fence
{
	public VKDevice m_device;
	public VkSemaphore m_timeline_semaphore;

	public this(VKDevice device, uint64 initial_value)
	{
		m_device = device;

		VkSemaphoreTypeCreateInfo timeline_create_info = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO };
		timeline_create_info.initialValue = initial_value;
		timeline_create_info.semaphoreType = VkSemaphoreType.eTimeline;
		VkSemaphoreCreateInfo create_info = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
		create_info.pNext = &timeline_create_info;
		VulkanNative.vkCreateSemaphore(m_device.GetDevice(), &create_info, null, &m_timeline_semaphore);
	}
	public override uint64 GetCompletedValue()
	{
		uint64 completedValue = ?;
		VulkanNative.vkGetSemaphoreCounterValue(m_device.GetDevice(), m_timeline_semaphore, &completedValue);
		return completedValue;
	}

	public override void Wait(uint64 value)
	{
		var value;
		VkSemaphoreWaitInfo wait_info = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_WAIT_INFO };
		wait_info.semaphoreCount = 1;
		wait_info.pSemaphores = &m_timeline_semaphore;
		wait_info.pValues = &value;
		VulkanNative.vkWaitSemaphores(m_device.GetDevice(), &wait_info, uint64.MaxValue);
	}

	public override void Signal(uint64 value)
	{
		VkSemaphoreSignalInfo signal_info = .() { sType = .VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO };
		signal_info.semaphore = m_timeline_semaphore;
		signal_info.value = value;
		VulkanNative.vkSignalSemaphore(m_device.GetDevice(), &signal_info);
	}

	public readonly ref VkSemaphore GetFence()
	{
		return ref m_timeline_semaphore;
	}
}