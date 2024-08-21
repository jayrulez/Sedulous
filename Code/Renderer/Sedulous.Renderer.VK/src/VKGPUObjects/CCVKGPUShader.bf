using System;
using System.Collections;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUShader : CCVKGPUDeviceObject
{
	public override void shutdown()
	{
		cmdFuncCCVKDestroyShader(CCVKDevice.getInstance().gpuDevice(), this);
	}

	public String name;
	public VertexAttributeList attributes;
	public List<CCVKGPUShaderStage> gpuStages;
	public bool initialized = false;
}