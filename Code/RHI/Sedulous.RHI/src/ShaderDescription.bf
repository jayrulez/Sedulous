using System;

namespace Sedulous.RHI;

/// <summary>
/// This struct represents all parameters required to create a new shader.
/// </summary>
public struct ShaderDescription : IEquatable<ShaderDescription>
{
	/// <summary>
	/// Gets the name of the entry point function.
	/// </summary>
	public readonly String EntryPoint;

	/// <summary>
	/// Gets the raw shader code.
	/// </summary>
	public readonly uint8[] ShaderBytes;

	/// <summary>
	/// Gets the shader stage.
	/// </summary>
	public readonly ShaderStages Stage;

	/// <summary>
	/// Byte array hash code cached.
	/// </summary>
	private int32 shaderArrayHashCode;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ShaderDescription" /> struct.
	/// </summary>
	/// <param name="stage">The shader stage.</param>
	/// <param name="entryPoint">The entry point function.</param>
	/// <param name="shaderBytes">The shader code in bytes.</param>
	public this(ShaderStages stage, String entryPoint, uint8[] shaderBytes)
	{
		Stage = stage;
		EntryPoint = entryPoint;
		ShaderBytes = shaderBytes;
		shaderArrayHashCode = 17;
		for (int32 i = 0; i < ShaderBytes.Count; i++)
		{
			shaderArrayHashCode = (shaderArrayHashCode * 397) ^ ShaderBytes[i];
		}
	}

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">The object to compare with.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(ShaderDescription other)
	{
		if (EntryPoint == other.EntryPoint && ShaderBytes == other.ShaderBytes)
		{
			return Stage == other.Stage;
		}
		return false;
	}

	/// <summary>
	/// Determines whether the specified <see cref="T:System.Object" /> is equal to this instance.
	/// </summary>
	/// <param name="obj">The <see cref="T:System.Object" /> to compare with this instance.</param>
	/// <returns>
	///   <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(Object obj)
	{
		if (obj == null)
		{
			return false;
		}
		if (obj is ShaderDescription)
		{
			return Equals((ShaderDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures such as a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return (((EntryPoint.GetHashCode() * 397) ^ shaderArrayHashCode) * 397) ^ (int32)Stage;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator ==(ShaderDescription value1, ShaderDescription value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator !=(ShaderDescription value1, ShaderDescription value2)
	{
		return !value1.Equals(value2);
	}
}
