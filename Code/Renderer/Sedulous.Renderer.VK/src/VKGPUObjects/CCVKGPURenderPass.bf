using System.Collections;
using Bulkan;
using System;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPURenderPass : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}

	public ColorAttachmentList colorAttachments;
	public DepthStencilAttachment depthStencilAttachment;
	public DepthStencilAttachment depthStencilResolveAttachment;
	public SubpassInfoList subpasses;
	public SubpassDependencyList dependencies;

	public VkRenderPass vkRenderPass;

	// helper storage
	public List<VkClearValue> clearValues;
	public List<VkSampleCountFlags> sampleCounts; // per subpass
	public List<bool> hasSelfDependency; // per subpass

	public CCVKGPUGeneralBarrier getBarrier(uint index, CCVKGPUDevice gpuDevice)
	{
		if (index < (uint)colorAttachments.Count)
		{
			return colorAttachments[(int)index].barrier != null ? ((CCVKGeneralBarrier)(colorAttachments[(int)index].barrier)).gpuBarrier() : gpuDevice.defaultColorBarrier;
		}
		return depthStencilAttachment.barrier != null ? ((CCVKGeneralBarrier)(depthStencilAttachment.barrier)).gpuBarrier() : gpuDevice.defaultDepthStencilBarrier;
	}
	public bool hasShadingAttachment(uint32 subPassId)
	{
		Runtime.Assert(subPassId < subpasses.Count);
		return subpasses[subPassId].shadingRate != INVALID_BINDING;
	}
}