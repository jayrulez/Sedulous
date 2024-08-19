		struct CCVKGPUTextureBarrier {
			VkPipelineStageFlags srcStageMask = 0U;
			VkPipelineStageFlags dstStageMask = 0U;
			VkImageMemoryBarrier vkBarrier{};

			ccstd::vector<ThsvsAccessType> prevAccesses;
			ccstd::vector<ThsvsAccessType> nextAccesses;

			ThsvsImageBarrier barrier{};
		};