using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new queryheap object.
/// </summary>
public struct QueryHeapDescription : IEquatable<QueryHeapDescription>
{
	/// <summary>
	/// Specifies the queryheap type, <see cref="T:Sedulous.RHI.QueryType" /> structure.
	/// </summary>
	public QueryType Type;

	/// <summary>
	/// Specifies the queryheap capacity.
	/// </summary>
	public uint32 QueryCount;

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(QueryHeapDescription other)
	{
		if (Type == other.Type)
		{
			return QueryCount == other.QueryCount;
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
		if (obj is QueryHeapDescription)
		{
			return Equals((QueryHeapDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return ((int32)Type * 397) ^ (int32)QueryCount;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(QueryHeapDescription value1, QueryHeapDescription value2)
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
	public static bool operator !=(QueryHeapDescription value1, QueryHeapDescription value2)
	{
		return !value1.Equals(value2);
	}
}
