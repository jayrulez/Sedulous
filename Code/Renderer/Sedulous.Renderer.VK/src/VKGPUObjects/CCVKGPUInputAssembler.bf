using System.Collections;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUInputAssembler : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		var hub = CCVKDevice.getInstance().gpuIAHub();
		for (var vb in gpuVertexBuffers)
		{
			hub.disengage(this, vb);
		}
		if (gpuIndexBuffer != null)
		{
			hub.disengage(this, gpuIndexBuffer);
		}
		if (gpuIndirectBuffer != null)
		{
			hub.disengage(this, gpuIndirectBuffer);
		}
	}
	public void update(CCVKGPUBufferView oldBuffer, CCVKGPUBufferView newBuffer)
	{
		for (uint32 i = 0; i < gpuVertexBuffers.Count; ++i)
		{
			if (gpuVertexBuffers[i] == oldBuffer)
			{
				gpuVertexBuffers[i] = newBuffer;
				vertexBuffers[i] = newBuffer.gpuBuffer.vkBuffer;
			}
		}
		if (gpuIndexBuffer == oldBuffer)
		{
			gpuIndexBuffer = newBuffer;
		}
		if (gpuIndirectBuffer == oldBuffer)
		{
			gpuIndirectBuffer = newBuffer;
		}
	}

	public VertexAttributeList attributes;
	public List<CCVKGPUBufferView> gpuVertexBuffers;
	public CCVKGPUBufferView gpuIndexBuffer;
	public CCVKGPUBufferView gpuIndirectBuffer;
	public List<VkBuffer> vertexBuffers;
	public List<VkDeviceSize> vertexBufferOffsets;
}