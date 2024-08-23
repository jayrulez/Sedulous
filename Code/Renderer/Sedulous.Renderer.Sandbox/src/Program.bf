using System;
using Sedulous.Renderer.SPIRV;
using Bulkan;
namespace Sedulous.Renderer.Sandbox;

class Program
{
	public static void Main()
	{
		String source = """
			#version 450
			precision highp float;
			layout(location = 0) in vec2 a_position;
			layout(set = 0, binding = 1) uniform MVP { mat4 u_MVP; };

			void main() {
			    gl_Position = u_MVP * vec4(a_position, 0.0, 1.0);
			}
			""";

		SPIRVUtils spvUtils = scope .();
		spvUtils.initialize((int32)VulkanNative.VK_API_VERSION_MINOR(0));

		spvUtils.compileGLSL(.VERTEX, source);
		VertexAttributeList attributes = scope .();
		spvUtils.compressInputLocations(ref attributes);

		Console.WriteLine("Hello");
	}
}