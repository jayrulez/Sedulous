		struct CCVKGPUGeneralBarrier {
			VkPipelineStageFlags srcStageMask = 0U;
			VkPipelineStageFlags dstStageMask = 0U;
			VkMemoryBarrier vkBarrier{};

			ccstd::vector<ThsvsAccessType> prevAccesses;
			ccstd::vector<ThsvsAccessType> nextAccesses;

			ThsvsGlobalBarrier barrier{};
		};