		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUBufferBarrier {
			VkPipelineStageFlags srcStageMask = 0U;
			VkPipelineStageFlags dstStageMask = 0U;
			VkBufferMemoryBarrier vkBarrier{};

			ccstd::vector<ThsvsAccessType> prevAccesses;
			ccstd::vector<ThsvsAccessType> nextAccesses;

			ThsvsBufferBarrier barrier{};
		};