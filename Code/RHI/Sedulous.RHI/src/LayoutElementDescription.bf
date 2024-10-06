using System;

namespace Sedulous.RHI;

/// <summary>
/// This class represents a shader resource binding.
/// </summary>
public struct LayoutElementDescription : IEquatable<LayoutElementDescription>
{
	/// <summary>
	/// Gets the resource slot.
	/// </summary>
	public readonly uint32 Slot;

	/// <summary>
	/// Gets the shader resource type.
	/// </summary>
	public readonly ResourceType Type;

	/// <summary>
	/// Gets the resource's shader stage.
	/// </summary>
	public readonly ShaderStages Stages;

	/// <summary>
	/// Gets a value indicating whether this resource allows dynamic offset. It's used in some graphics backends to allow specifying dynamic offset.
	/// </summary>
	public readonly bool AllowDynamicOffset;

	/// <summary>
	/// If it is greater than 0, it overrides the size of this resource (in bytes). Valid only for Constant Buffers.
	/// </summary>
	public readonly uint32 Range;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.LayoutElementDescription" /> struct.
	/// </summary>
	/// <param name="slot">The resource slot.</param>
	/// <param name="type">The resource type.</param>
	/// <param name="stages">The stages where this resource will be available.</param>
	/// <param name="allowDynamicOffset">Specifies whether to allow a dynamic offset. Only valid for Constant Buffers.</param>
	/// <param name="size">If greater than 0, it overrides the size of this resource (in bytes). Only valid for Constant Buffers.</param>
	public this(uint32 slot, ResourceType type, ShaderStages stages, bool allowDynamicOffset = false, uint32 size = 0)
	{
		Slot = slot;
		Type = type;
		Stages = stages;
		AllowDynamicOffset = allowDynamicOffset;
		Range = size;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">The other object used for comparison.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(LayoutElementDescription other)
	{
		if (Slot == other.Slot && Type == other.Type)
		{
			return Stages == other.Stages;
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
		if (obj is LayoutElementDescription)
		{
			return Equals((LayoutElementDescription)obj);
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
		return (int32)(((Slot * 397) ^ (uint32)((int)Type).GetHashCode()) * 397) ^ ((int)Stages).GetHashCode();
	}

	/// <summary>
	/// Implements the == operator.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(LayoutElementDescription value1, LayoutElementDescription value2)
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
	public static bool operator !=(LayoutElementDescription value1, LayoutElementDescription value2)
	{
		return !value1.Equals(value2);
	}
}
