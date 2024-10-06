using Bulkan;

namespace Sedulous.RHI.Vulkan;

internal struct VKQueueFamilyIndices
{
	public int32 GraphicsFamily;

	public int32 Presentfamily;

	public int32 CopyFamily;

	public int32 ComputeFamily;

	/// <summary>
	/// Finds the queue families supported.
	/// </summary>
	/// <param name="context">The graphics context object.</param>
	/// <param name="physicalDevice">The physical device object.</param>
	/// <param name="surface">The desired surface type.</param>
	/// <returns>The supported queue family indices.</returns>
	public static VKQueueFamilyIndices FindQueueFamilies(VKGraphicsContext context, VkPhysicalDevice physicalDevice, VkSurfaceKHR? surface)
	{
		VKQueueFamilyIndices indices = default(VKQueueFamilyIndices);
		indices.GraphicsFamily = -1;
		indices.Presentfamily = -1;
		indices.CopyFamily = -1;
		indices.ComputeFamily = -1;
		uint32 queueFamilyCount = 0;
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, null);
		VkQueueFamilyProperties* queueFamilies = scope VkQueueFamilyProperties[(int32)queueFamilyCount]*;
		VulkanNative.vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, queueFamilies);
		VkBool32 presentSupported = default(VkBool32);
		for (int i = 0; i < queueFamilyCount; i++)
		{
			VkQueueFamilyProperties q = queueFamilies[i];
			if (surface.HasValue)
			{
				VulkanNative.vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice, (uint32)i, surface.Value, &presentSupported);
				if (indices.Presentfamily < 0 && q.queueCount != 0 && (bool)presentSupported)
				{
					indices.Presentfamily = (int32)i;
				}
			}
			if (q.queueCount != 0 && (q.queueFlags & VkQueueFlags.VK_QUEUE_GRAPHICS_BIT) != 0)
			{
				indices.GraphicsFamily = (int32)i;
			}
			if (q.queueCount != 0 && (q.queueFlags & VkQueueFlags.VK_QUEUE_TRANSFER_BIT) != 0)
			{
				indices.CopyFamily = (int32)i;
			}
			if (q.queueCount != 0 && (q.queueFlags & VkQueueFlags.VK_QUEUE_COMPUTE_BIT) != 0)
			{
				indices.ComputeFamily = (int32)i;
			}
		}
		return indices;
	}
}
