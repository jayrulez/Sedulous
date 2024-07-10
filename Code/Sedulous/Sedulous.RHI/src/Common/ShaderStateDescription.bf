using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// Shader State Description.
/// </summary>
abstract class ShaderStateDescription : IEquatable<ShaderStateDescription>, IHashable
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

	/// <inheritdoc />
	public bool Equals(ShaderStateDescription other)
	{
		return false;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="obj">The <see cref="T:System.Object" /> to compare with this instance.</param>
	/// <returns>
	///   <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public virtual bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is ShaderStateDescription)
		{
			return Equals((ShaderStateDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(ShaderStateDescription value1, ShaderStateDescription value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(ShaderStateDescription value1, ShaderStateDescription value2)
	{
		return !value1.Equals(value2);
	}

	/// <inheritdoc />
	public virtual int GetHashCode()
	{
		return GetHashCode();
	}
}
