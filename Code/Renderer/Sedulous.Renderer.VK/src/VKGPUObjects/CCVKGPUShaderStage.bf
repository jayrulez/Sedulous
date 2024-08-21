using System;
using Bulkan;
namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUShaderStage
{
	public this(ShaderStageFlagBit t, String s)
	{
		type = t;
		source = s;
	}
	public ShaderStageFlagBit type = ShaderStageFlagBit.NONE;
	public String source;
	public VkShaderModule vkShader = .Null;
}