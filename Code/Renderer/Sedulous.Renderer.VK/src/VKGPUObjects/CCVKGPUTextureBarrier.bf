using Bulkan;
using Bulkan.Utilities;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

struct CCVKGPUTextureBarrier
{
	public VkPipelineStageFlags srcStageMask = 0U;
	public VkPipelineStageFlags dstStageMask = 0U;
	public VkImageMemoryBarrier vkBarrier = .() { sType = .VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER };

	public List<ThsvsAccessType> prevAccesses;
	public List<ThsvsAccessType> nextAccesses;

	public ThsvsImageBarrier barrier = .();
}