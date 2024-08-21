using Bulkan;
using System.Collections;
using Bulkan.Utilities;
		namespace Sedulous.Renderer.VK.Internal;

		struct CCVKGPUGeneralBarrier {
			public VkPipelineStageFlags srcStageMask = 0U;
			public VkPipelineStageFlags dstStageMask = 0U;
			public VkMemoryBarrier vkBarrier = .(){sType = .VK_STRUCTURE_TYPE_MEMORY_BARRIER};

			public List<ThsvsAccessType> prevAccesses = new .() ~ delete _;
			public List<ThsvsAccessType> nextAccesses = new .() ~ delete _;

			public ThsvsGlobalBarrier barrier = .();
		}