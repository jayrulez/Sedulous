using Bulkan;
using System;
namespace Sedulous.RAL.VK;

class VKAdapter : Adapter
{
	private VKInstance m_instance;
	private VkPhysicalDevice m_physical_device = .Null;
	private String m_name = new .() ~ delete _;

	public this(VKInstance instance, VkPhysicalDevice physical_device)
	{
		m_instance = instance;
		m_physical_device = physical_device;

		VkPhysicalDeviceProperties properties = .();
		VulkanNative.vkGetPhysicalDeviceProperties(m_physical_device, &properties);
		m_name.Set(scope .(&properties.deviceName));
	}

	public override readonly ref String GetName()
	{
		return ref m_name;
	}

	public override Result<void> CreateDevice(out Device device)
	{
		device = new VKDevice(this);
		return .Ok;
	}

	public override void DestroyDevice(ref Device device)
	{
		if (VKDevice vkDevice = device.As<VKDevice>())
		{
			delete vkDevice;
			device = null;
		}
	}

	public readonly ref VKInstance GetInstance()
	{
		return ref m_instance;
	}

	public VkPhysicalDevice GetPhysicalDevice()
	{
		return m_physical_device;
	}
}