using System.Collections;
using Bulkan.Utilities;
		namespace Sedulous.Renderer.VK.Internal;

struct CCVKGPUDescriptor
{
	public DescriptorType type = DescriptorType.UNKNOWN;
	public List<ThsvsAccessType> accessTypes = new .();
	public CCVKGPUBufferView gpuBufferView;
	public CCVKGPUTextureView gpuTextureView;
	public CCVKGPUSampler gpuSampler;
}