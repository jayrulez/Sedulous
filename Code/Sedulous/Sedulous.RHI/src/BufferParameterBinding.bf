using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// This class represents a parameter property of a constant buffer. Used in WebGL1 and OpenGL ES 2.0.
/// </summary>
class BufferParameterBinding
{
	/// <summary>
	/// The buffer parameter type.
	/// </summary>
	public enum BufferParameterType
	{
		Float,
		Float2,
		Float3,
		Float4,
		Int,
		Int2,
		Int3,
		Int4,
		UInt,
		UInt2,
		UInt3,
		UInt4,
		Matrix2x2,
		Matrix3x3,
		Matrix4x4
	}

	/// <summary>
	/// The parameter name.
	/// </summary>
	public String Name;

	/// <summary>
	/// The constant slot.
	/// </summary>
	public int32 CBufferSlot;

	/// <summary>
	/// The buffer parameter type.
	/// </summary>
	public BufferParameterType ParameterType;

	/// <summary>
	/// Offset of this parameter in the buffer.
	/// </summary>
	public int32 Offset;

	/// <summary>
	/// In case of array, specify the parameter array size.
	/// </summary>
	public int32 ArrayCount;

	/// <summary>
	/// Gets the buffer parameter type from a string type.
	/// </summary>
	/// <param name="type">The type.</param>
	/// <returns>float.</returns>
	public static BufferParameterType FromType(Type type)
	{
		if (type == typeof(float))
		{
			return BufferParameterType.Float;
		}
		if (type == typeof(Vector2))
		{
			return BufferParameterType.Float2;
		}
		if (type == typeof(Vector3))
		{
			return BufferParameterType.Float3;
		}
		if (type == typeof(Vector4))
		{
			return BufferParameterType.Float4;
		}
		if (type == typeof(int32))
		{
			return BufferParameterType.Int;
		}
		if (type == typeof(uint32))
		{
			return BufferParameterType.UInt;
		}
		if (type == typeof(uint32[2]))//if (type == typeof(UInt2))
		{
			return BufferParameterType.UInt2;
		}
		if (type == typeof(uint32[3]))//if (type == typeof(UInt3))
		{
			return BufferParameterType.UInt3;
		}
		if (type == typeof(float[3][3]))//if (type == typeof(Matrix3x3))
		{
			return BufferParameterType.Matrix3x3;
		}
		if (type == typeof(Matrix))
		{
			return BufferParameterType.Matrix4x4;
		}
		return BufferParameterType.Float;
	}
}
