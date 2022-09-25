using Bulkan;
namespace NRI.Vulkan;

class QueueSemaphoreVK : QueueSemaphore
{
	private VkSemaphore m_Handle = .Null;
	private DeviceVK m_Device;
	private bool m_OwnsNativeObjects = false;

	public this(DeviceVK device)
	{
		m_Device = device;
	}

	public ~this()
	{
		if (m_Handle != .Null && m_OwnsNativeObjects)
			VulkanNative.vkDestroySemaphore(m_Device, m_Handle, m_Device.GetAllocationCallbacks());
	}

	public static implicit operator VkSemaphore(Self self) => self.m_Handle;
	public DeviceVK GetDevice() => m_Device;
	public Result Create()
	{
		m_OwnsNativeObjects = true;

		/*readonly*/ VkSemaphoreCreateInfo semaphoreInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
				pNext = null,
				flags = /*(VkSemaphoreCreateFlags)*/ 0
			};

		readonly VkResult result = VulkanNative.vkCreateSemaphore(m_Device, &semaphoreInfo, m_Device.GetAllocationCallbacks(), &m_Handle);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a semaphore: vkCreateSemaphore returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public Result Create(NRIVkSemaphore vkSemaphore)
	{
		m_OwnsNativeObjects = false;
		m_Handle = (VkSemaphore)vkSemaphore;

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_SEMAPHORE, (uint64)m_Handle, name);
	}
}