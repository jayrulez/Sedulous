using Bulkan;
namespace NRI.Vulkan;

class DeviceSemaphoreVK : DeviceSemaphore
{
	private VkFence m_Handle = .Null;
	private DeviceVK m_Device;
	private bool m_OwnsNativeObjects = false;


	public this(DeviceVK device)
	{
		m_Device = device;
	}

	public ~this()
	{
		if (m_Handle != .Null && m_OwnsNativeObjects)
			VulkanNative.vkDestroyFence(m_Device, m_Handle, m_Device.GetAllocationCallbacks());
	}

	public static implicit operator VkFence(Self self) => self.m_Handle;
	public DeviceVK GetDevice() => m_Device;

	public Result Create(bool signaled)
	{
		m_OwnsNativeObjects = true;

		/*readonly*/ VkFenceCreateInfo fenceInfo = .()
			{
				sType = .VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
				pNext = null,
				flags = signaled ? .VK_FENCE_CREATE_SIGNALED_BIT : (VkFenceCreateFlags)0
			};

		readonly VkResult result = VulkanNative.vkCreateFence(m_Device, &fenceInfo, m_Device.GetAllocationCallbacks(), &m_Handle);

		RETURN_ON_FAILURE!(m_Device.GetLogger(), result == .VK_SUCCESS, GetReturnCode(result),
			"Can't create a semaphore: vkCreateFence returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public Result Create(NRIVkSemaphore vkFence)
	{
		m_OwnsNativeObjects = false;
		m_Handle = (VkFence)vkFence;

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		m_Device.SetDebugNameToTrivialObject(.VK_OBJECT_TYPE_FENCE, (uint64)m_Handle, name);
	}
}