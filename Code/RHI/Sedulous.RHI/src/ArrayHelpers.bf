using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// Class containing useful methods for manipulating arrays.
/// </summary>
public static class ArrayHelpers
{
	/// <summary>
	/// Ensures that the array has the specified capacity. If it does not, resizes the array to the specified capacity.
	/// </summary>
	/// <typeparam name="T">The array type.</typeparam>
	/// <param name="array">The array.</param>
	/// <param name="capacity">The capacity.</param>
	[Inline]
	public static void EnsureCapacity<T>(ref T[] array, int32 capacity)
	{
		if (array == null)
		{
			array = new T[capacity];
		}
		else if (array.Count < capacity)
		{
			Array.Resize(ref array, capacity);
		}
	}

	/// <summary>
	/// Ensures that the array has the specified capacity. If it does not, resizes the capacity to the next power of two value that accommodates the specified capacity.
	/// </summary>
	/// <typeparam name="T">The array type.</typeparam>
	/// <param name="array">The array.</param>
	/// <param name="capacity">The capacity.</param>
	[Inline]
	public static void EnsureCapacityPo2<T>(ref T[] array, int capacity)
	{
		var capacity;

		if (array == null)
		{
			array = new T[capacity];
		}
		else if (array.Count < capacity)
		{
			capacity = MathUtil.NextPowerOfTwo((int32)capacity);
			Array.Resize(ref array, capacity);
		}
	}

	/// <summary>
	/// Ensure that the array length is equal to the specified size. If it is not, resize the array to the specified capacity.
	/// </summary>
	/// <typeparam name="T">The array type.</typeparam>
	/// <param name="array">The array.</param>
	/// <param name="size">The capacity.</param>
	[Inline]
	public static void EnsureArraySize<T>(ref T[] array, int size)
	{
		if (array == null)
		{
			array = new T[size];
		}
		else if (array.Count != size)
		{
			Array.Resize(ref array, size);
		}
	}

	/// <summary>
	/// Copies an array.
	/// </summary>
	/// <typeparam name="T">The type of the array.</typeparam>
	/// <param name="src">The source array.</param>
	/// <returns>The cloned array.</returns>
	public static T[] CopyArray<T>(this T[] src)
	{
		if (src == null)
		{
			return null;
		}
		T[] copy = new T[src.Count];
		Array.Copy(src, copy, src.Count);
		return copy;
	}
}
