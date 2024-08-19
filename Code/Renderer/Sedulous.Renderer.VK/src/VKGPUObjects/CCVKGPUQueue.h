		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUQueue {
			QueueType type = QueueType::GRAPHICS;
			VkQueue vkQueue = VK_NULL_HANDLE;
			uint32_t queueFamilyIndex = 0U;
			ccstd::vector<uint32_t> possibleQueueFamilyIndices;
			ccstd::vector<VkSemaphore> lastSignaledSemaphores;
			ccstd::vector<VkPipelineStageFlags> submitStageMasks;
			ccstd::vector<VkCommandBuffer> commandBuffers;
		};