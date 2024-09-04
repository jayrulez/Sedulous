using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUCommandBuffer : CCVKGPUDeviceObject
{
	public VkCommandBuffer vkCommandBuffer = .Null;
	public VkCommandBufferLevel level = .VK_COMMAND_BUFFER_LEVEL_PRIMARY;
	public uint32 queueFamilyIndex = 0U;
	public bool began = false;
	public HashSet<VkBuffer> recordedBuffers = new .() ~ delete _;
}