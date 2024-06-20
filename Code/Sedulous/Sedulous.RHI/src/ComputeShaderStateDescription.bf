using System;

namespace Sedulous.RHI;

/// <summary>
/// This struct contains all the shader stages.
/// </summary>
class ComputeShaderStateDescription : ShaderStateDescription, IEquatable<ComputeShaderStateDescription>, IHashable
{
	/// <summary>
	/// Gets or sets the compute shader program.
	/// </summary>
	public Shader ComputeShader;

	/// <inheritdoc />
	public override bool Equals(Object obj)
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
	public override int GetHashCode()
	{
		int hashCode = 0;
		if (ComputeShader != null)
		{
			hashCode = (hashCode * 397) ^ ComputeShader.GetHashCode();
		}
		return hashCode;
	}
}
