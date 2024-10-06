using System;
using System.IO;

namespace Sedulous.RHI;

/// <summary>
/// Describes an individual component of a vertex.
/// </summary>
public struct ElementDescription : IEquatable<ElementDescription>
{
	/// <summary>
	/// Use sequential offset.
	/// </summary>
	public const int32 AppendAligned = -1;

	/// <summary>
	/// Gets the type of the element.
	/// </summary>
	public ElementSemanticType Semantic;

	/// <summary>
	/// Gets the semantic index of this element.
	/// </summary>
	public uint32 SemanticIndex;

	/// <summary>
	/// Gets the format of the element.
	/// </summary>
	public ElementFormat Format;

	/// <summary>
	/// Gets the offset of the element.
	/// </summary>
	public int32 Offset;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ElementDescription" /> struct.
	/// </summary>
	/// <param name="format">The element format, <see cref="T:Sedulous.RHI.ElementFormat" />.</param>
	/// <param name="semanticType">The element semantic type, <see cref="T:Sedulous.RHI.ElementSemanticType" />.</param>
	/// <param name="semanticIndex">The semantic index for this element.</param>
	/// <param name="offset">The element offset.</param>
	public this(ElementFormat format, ElementSemanticType semanticType, uint32 semanticIndex = 0, int32 offset = -1)
	{
		Semantic = semanticType;
		SemanticIndex = semanticIndex;
		Format = format;
		Offset = offset;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">The object to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(ElementDescription other)
	{
		if (Semantic != other.Semantic || Format != other.Format)
		{
			return false;
		}
		return true;
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
		if (obj is ElementDescription)
		{
			return Equals((ElementDescription)obj);
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
		return (int)(((uint32)((int32)Semantic * 397) ^ SemanticIndex) * 397) ^ (int32)Format;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(ElementDescription value1, ElementDescription value2)
	{
		return value1.Equals(value2);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator !=(ElementDescription value1, ElementDescription value2)
	{
		return !value1.Equals(value2);
	}
}
