using Bulkan;
using Bulkan.Utilities;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUBufferBarrier
{
	public VkPipelineStageFlags srcStageMask = 0U;
	public VkPipelineStageFlags dstStageMask = 0U;
	public VkBufferMemoryBarrier vkBarrier = .() { sType = .VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER };

	public List<ThsvsAccessType> prevAccesses = new .() ~ delete _;
	public List<ThsvsAccessType> nextAccesses = new .() ~ delete _;

	public ThsvsBufferBarrier barrier = .();
}