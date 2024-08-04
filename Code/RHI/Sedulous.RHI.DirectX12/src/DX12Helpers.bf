using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// A set of helper functions for DX12.
/// </summary>
public static class DX12Helpers
{
	/// <summary>
	/// Ensure the array size.
	/// </summary>
	/// <typeparam name="T">The array type.</typeparam>
	/// <param name="array">The array object.</param>
	/// <param name="size">The array size to check.</param>
	public static void EnsureArraySize<T>(ref T[] array, int size)
	{
		if (array == null)
		{
			array = new T[size];
		}
		else
		{
			Array.Resize(ref array, size);
		}
	}

	/// <summary>
	/// Convert from Matrix to Matrix3x4.
	/// </summary>
	/// <param name="m">Sedulous Matrix.</param>
	/// <returns>DX12 matrix3x4.</returns>
	public static float[12] ToMatrix3x4(this Matrix m)
	{
		return .(m.M11, m.M12, m.M13, m.M14, m.M21, m.M22, m.M23, m.M24, m.M31, m.M32, m.M33, m.M34);
	}
}
