		struct CCVKAccessInfo {
			VkPipelineStageFlags stageMask{ 0 };
			VkAccessFlags accessMask{ 0 };
			VkImageLayout imageLayout{ VK_IMAGE_LAYOUT_UNDEFINED };
			bool hasWriteAccess{ false };
		};