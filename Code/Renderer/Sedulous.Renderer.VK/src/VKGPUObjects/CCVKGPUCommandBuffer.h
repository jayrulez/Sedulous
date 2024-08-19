		struct CCVKGPUCommandBuffer : public CCVKGPUDeviceObject {
			VkCommandBuffer vkCommandBuffer = VK_NULL_HANDLE;
			VkCommandBufferLevel level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
			uint32_t queueFamilyIndex = 0U;
			bool began = false;
			mutable ccstd::unordered_set<VkBuffer> recordedBuffers;
		};