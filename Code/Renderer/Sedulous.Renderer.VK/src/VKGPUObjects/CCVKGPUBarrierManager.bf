using System.Collections;
using Bulkan.Utilities;
using Bulkan;
using System;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUBarrierManager
{
	public this(CCVKGPUDevice device)
	{
		_device = device;
	}

	public void checkIn(CCVKGPUBuffer gpuBuffer)
	{
		_buffersToBeChecked.Add(gpuBuffer);
	}

	public void checkIn(CCVKGPUTexture gpuTexture, ThsvsAccessType* newTypes = null, uint32 newTypeCount = 0)
	{
		ref List<ThsvsAccessType> target = ref gpuTexture.renderAccessTypes;
		for (uint32 i = 0U; i < newTypeCount; ++i)
		{
			if (!target.Contains(newTypes[i]))
			{
				target.Add(newTypes[i]);
			}
		}
		_texturesToBeChecked.Add(gpuTexture);
	}

	private static List<ThsvsAccessType> prevAccesses = new .() ~ delete _;
	private static List<ThsvsAccessType> nextAccesses = new .() ~ delete _;
	private static List<VkImageMemoryBarrier> vkImageBarriers = new .() ~ delete _;

	public void update(CCVKGPUTransportHub transportHub)
	{
		if (_buffersToBeChecked.IsEmpty && _texturesToBeChecked.IsEmpty) return;

		VkPipelineStageFlags srcStageMask = .VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
		VkPipelineStageFlags dstStageMask = .VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
		vkImageBarriers.Clear();
		prevAccesses.Clear();
		nextAccesses.Clear();

		for (CCVKGPUBuffer gpuBuffer in _buffersToBeChecked)
		{
			ref List<ThsvsAccessType> render = ref gpuBuffer.renderAccessTypes;
			if (gpuBuffer.transferAccess == .THSVS_ACCESS_NONE) continue;
			if (!prevAccesses.Contains(gpuBuffer.transferAccess))
			{
				prevAccesses.Add(gpuBuffer.transferAccess);
			}
			nextAccesses.AddRange(render);
			gpuBuffer.transferAccess = .THSVS_ACCESS_NONE;
		}

		VkMemoryBarrier vkBarrier;
		VkMemoryBarrier* pVkBarrier = null;
		if (!prevAccesses.IsEmpty)
		{
			ThsvsGlobalBarrier globalBarrier = .();
			globalBarrier.prevAccessCount = uint32(prevAccesses.Count);
			globalBarrier.pPrevAccesses = prevAccesses.Ptr;
			globalBarrier.nextAccessCount = uint32(nextAccesses.Count);
			globalBarrier.pNextAccesses = nextAccesses.Ptr;
			VkPipelineStageFlags tempSrcStageMask = 0;
			VkPipelineStageFlags tempDstStageMask = 0;
			thsvsGetVulkanMemoryBarrier(globalBarrier, &tempSrcStageMask, &tempDstStageMask, &vkBarrier);
			srcStageMask |= tempSrcStageMask;
			dstStageMask |= tempDstStageMask;
			pVkBarrier = &vkBarrier;
		}

		ThsvsImageBarrier imageBarrier = .();
		imageBarrier.discardContents = false;
		imageBarrier.prevLayout = .THSVS_IMAGE_LAYOUT_OPTIMAL;
		imageBarrier.nextLayout = .THSVS_IMAGE_LAYOUT_OPTIMAL;
		imageBarrier.srcQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
		imageBarrier.dstQueueFamilyIndex = VulkanNative.VK_QUEUE_FAMILY_IGNORED;
		imageBarrier.subresourceRange.levelCount = VulkanNative.VK_REMAINING_MIP_LEVELS;
		imageBarrier.subresourceRange.layerCount = VulkanNative.VK_REMAINING_ARRAY_LAYERS;
		imageBarrier.prevAccessCount = 1;

		for (CCVKGPUTexture gpuTexture in _texturesToBeChecked)
		{
			ref List<ThsvsAccessType> render = ref gpuTexture.renderAccessTypes;
			if (gpuTexture.transferAccess == .THSVS_ACCESS_NONE || render.IsEmpty) continue;
			ref List<ThsvsAccessType> current = ref gpuTexture.currentAccessTypes;
			imageBarrier.pPrevAccesses = &gpuTexture.transferAccess;
			imageBarrier.nextAccessCount = uint32(render.Count);
			imageBarrier.pNextAccesses = render.Ptr;
			imageBarrier.image = gpuTexture.vkImage;
			imageBarrier.subresourceRange.aspectMask = gpuTexture.aspectMask;

			VkPipelineStageFlags tempSrcStageMask = 0;
			VkPipelineStageFlags tempDstStageMask = 0;
			vkImageBarriers.Add(.());
			thsvsGetVulkanImageMemoryBarrier(imageBarrier, &tempSrcStageMask, &tempDstStageMask, &vkImageBarriers.Back);
			srcStageMask |= tempSrcStageMask;
			dstStageMask |= tempDstStageMask;

			// don't override any other access changes since this barrier always happens first
			if (current.Count == 1 && current[0] == gpuTexture.transferAccess)
			{
				current = render;
			}
			gpuTexture.transferAccess = .THSVS_ACCESS_NONE;
		}

		if (pVkBarrier != null || !vkImageBarriers.IsEmpty)
		{
			transportHub.checkIn(scope [&] (gpuCommandBuffer) =>
				{
					VulkanNative.vkCmdPipelineBarrier(gpuCommandBuffer.vkCommandBuffer, srcStageMask, dstStageMask, 0, pVkBarrier != null ? 1 : 0, pVkBarrier, 0, null, uint32(vkImageBarriers.Count), vkImageBarriers.Ptr);
				});
		}

		_buffersToBeChecked.Clear();
		_texturesToBeChecked.Clear();
	}

	[Inline] public void cancel(CCVKGPUBuffer gpuBuffer) { _buffersToBeChecked.Remove(gpuBuffer); }
	[Inline] public void cancel(CCVKGPUTexture gpuTexture) { _texturesToBeChecked.Remove(gpuTexture); }

	private HashSet<CCVKGPUBuffer> _buffersToBeChecked;
	private HashSet<CCVKGPUTexture> _texturesToBeChecked;
	private CCVKGPUDevice _device = null;
}