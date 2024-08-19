		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUSwapchain : public CCVKGPUDeviceObject {
			VkSurfaceKHR vkSurface = VK_NULL_HANDLE;
			VkSwapchainCreateInfoKHR createInfo{ VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR };

			uint32_t curImageIndex = 0U;
			VkSwapchainKHR vkSwapchain = VK_NULL_HANDLE;
			ccstd::vector<VkBool32> queueFamilyPresentables;
			VkResult lastPresentResult = VK_NOT_READY;

			// external references
			ccstd::vector<VkImage> swapchainImages;
		};