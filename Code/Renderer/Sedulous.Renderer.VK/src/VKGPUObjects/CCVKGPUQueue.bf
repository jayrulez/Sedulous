using Bulkan;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUQueue
{
	public QueueType type = QueueType.GRAPHICS;
	public VkQueue vkQueue = .Null;
	public uint32 queueFamilyIndex = 0U;
	public List<uint32> possibleQueueFamilyIndices = new .() ~ delete _;
	public List<VkSemaphore> lastSignaledSemaphores = new .() ~ delete _;
	public List<VkPipelineStageFlags> submitStageMasks = new .() ~ delete _;
	public List<VkCommandBuffer> commandBuffers = new .() ~ delete _;
}