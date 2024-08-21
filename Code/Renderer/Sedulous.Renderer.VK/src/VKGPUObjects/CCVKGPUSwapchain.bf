using Bulkan;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUSwapchain : CCVKGPUDeviceObject
{
	public VkSurfaceKHR vkSurface = .Null;
	public VkSwapchainCreateInfoKHR createInfo = .() { sType = .VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR };

	public uint32 curImageIndex = 0;
	public VkSwapchainKHR vkSwapchain = .Null;
	public List<VkBool32> queueFamilyPresentables = new .() ~ delete _;
	public VkResult lastPresentResult = .VK_NOT_READY;

	// external references
	public List<VkImage> swapchainImages = new .() ~ delete _;
}