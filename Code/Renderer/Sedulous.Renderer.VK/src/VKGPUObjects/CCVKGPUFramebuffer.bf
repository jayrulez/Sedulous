using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUFramebuffer : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}

	public CCVKGPURenderPass gpuRenderPass;
	public List<CCVKGPUTextureView> gpuColorViews;
	public CCVKGPUTextureView gpuDepthStencilView;
	public CCVKGPUTextureView gpuDepthStencilResolveView;
	public VkFramebuffer vkFramebuffer = .Null;
	public List<VkFramebuffer> vkFrameBuffers;
	public CCVKGPUSwapchain swapchain = null;
	public bool isOffscreen = true;
	public uint32 width = 0U;
	public uint32 height = 0U;
}