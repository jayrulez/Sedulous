using Bulkan;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUQueue
{
	public QueueType type = QueueType.GRAPHICS;
	public VkQueue vkQueue = .Null;
	public uint32 queueFamilyIndex = 0U;
	public List<uint32> possibleQueueFamilyIndices;
	public List<VkSemaphore> lastSignaledSemaphores;
	public List<VkPipelineStageFlags> submitStageMasks;
	public List<VkCommandBuffer> commandBuffers;
}