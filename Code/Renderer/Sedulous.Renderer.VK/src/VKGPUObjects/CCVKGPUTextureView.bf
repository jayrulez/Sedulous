using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUTextureView : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuDescriptorHub().disengage(this);
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}
	public void init()
	{
		cmdFuncCCVKCreateTextureView(CCVKDevice.getInstance(), this);
	}

	public CCVKGPUTexture gpuTexture;
	public TextureType type = TextureType.TEX2D;
	public Format format = Format.UNKNOWN;
	public uint32 baseLevel = 0U;
	public uint32 levelCount = 1U;
	public uint32 baseLayer = 0U;
	public uint32 layerCount = 1U;
	public uint32 basePlane = 0U;
	public uint32 planeCount = 1U;

	public List<VkImageView> swapchainVkImageViews;

	// descriptor infos
	public VkImageView vkImageView = .Null;
}