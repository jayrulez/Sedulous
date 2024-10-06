using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new query heap object.
/// </summary>
public struct QueryHeapDescription : IEquatable<QueryHeapDescription>
{
	/// <summary>
	/// Specifies the QueryHeap type, see <see cref="T:Sedulous.RHI.QueryType" /> structure.
	/// </summary>
	public QueryType Type;

	/// <summary>
	/// Specifies the query heap capacity.
	/// </summary>
	public uint32 QueryCount;

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">The object used for comparison.</param>
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
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like hash tables.
	/// </returns>
	public int GetHashCode()
	{
		return ((int32)Type * 397) ^ (int32)QueryCount;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator ==(QueryHeapDescription value1, QueryHeapDescription value2)
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
	public static bool operator !=(QueryHeapDescription value1, QueryHeapDescription value2)
	{
		return !value1.Equals(value2);
	}
}
