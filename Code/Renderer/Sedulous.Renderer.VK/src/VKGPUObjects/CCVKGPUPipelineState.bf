using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUPipelineState : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}

	public PipelineBindPoint bindPoint = PipelineBindPoint.GRAPHICS;
	public PrimitiveMode primitive = PrimitiveMode.TRIANGLE_LIST;
	public CCVKGPUShader gpuShader;
	public CCVKGPUPipelineLayout gpuPipelineLayout;
	public InputState inputState;
	public RasterizerState rs;
	public DepthStencilState dss;
	public BlendState bs;
	public DynamicStateList dynamicStates;
	public CCVKGPURenderPass gpuRenderPass;
	public uint32 subpass = 0U;
	public VkPipeline vkPipeline = .Null;
}