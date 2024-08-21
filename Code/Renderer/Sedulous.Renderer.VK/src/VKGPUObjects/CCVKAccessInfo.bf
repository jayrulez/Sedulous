using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

struct CCVKAccessInfo
{
	public VkPipelineStageFlags stageMask = 0;
	public VkAccessFlags accessMask = 0;
	public VkImageLayout imageLayout = .VK_IMAGE_LAYOUT_UNDEFINED;
	public bool hasWriteAccess = false;
}