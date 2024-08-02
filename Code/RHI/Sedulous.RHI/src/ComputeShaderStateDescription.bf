using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// This struct contains all the shader stages.
/// </summary>
public struct ComputeShaderStateDescription : IEquatable<ComputeShaderStateDescription>
{
	/// <summary>
	/// ConstantBuffers bindings.
	/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
	/// </summary>
	public List<(String name, uint32 slot)> constantBuffersBindings;

	/// <summary>
	/// Textures bindings.
	/// Used in OpenGL 410 or minor and OpenGLES 300 or minor.
	/// </summary>
	public List<(String name, uint32 slot)> texturesBindings;

	/// <summary>
	/// Uniform parameters bindings.
	/// Used in WebGL1 and OpenGL ES 2.0.
	/// </summary>
	public Dictionary<String, BufferParameterBinding> bufferParametersBinding;

	/// <summary>
	/// Gets or sets the compute shader program.
	/// </summary>
	public Shader ComputeShader;

	/// <inheritdoc />
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is ComputeShaderStateDescription)
		{
			return Equals((ComputeShaderStateDescription)obj);
		}
		return false;
	}

	/// <inheritdoc />
	public bool Equals(ComputeShaderStateDescription other)
	{
		if (ComputeShader != other.ComputeShader)
		{
			return false;
		}
		return true;
	}

	/// <inheritdoc />
	public int GetHashCode()
	{
		int hashCode = 0;
		if (ComputeShader != null)
		{
			hashCode = (hashCode * 397) ^ ComputeShader.GetHashCode();
		}
		return hashCode;
	}
}
