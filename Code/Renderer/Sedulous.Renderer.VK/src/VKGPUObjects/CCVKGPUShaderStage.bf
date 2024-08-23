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
	public String source = new .() ~ delete _;
	public VkShaderModule vkShader = .Null;
}