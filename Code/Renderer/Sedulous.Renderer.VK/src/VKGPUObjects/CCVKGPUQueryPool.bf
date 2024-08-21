using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUQueryPool : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		CCVKDevice.getInstance().gpuRecycleBin().collect(this);
	}

	public QueryType type = QueryType.OCCLUSION;
	public uint32 maxQueryObjects = 0;
	public bool forceWait = true;
	public VkQueryPool vkPool = .Null;
}