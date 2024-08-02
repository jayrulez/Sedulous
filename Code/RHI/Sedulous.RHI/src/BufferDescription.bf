using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new buffer object.
/// </summary>
public struct BufferDescription : IEquatable<BufferDescription>
{
	/// <summary>
	/// Retrieves or sets the size of the new buffer.
	/// </summary>
	public uint32 SizeInBytes;

	/// <summary>
	/// Buffer flags describing buffer type.
	/// </summary>
	public BufferFlags Flags;

	/// <summary>
	/// Specifies the types of CPU access allowed for this buffer.
	/// </summary>
	public ResourceCpuAccess CpuAccess;

	/// <summary>
	/// Usage of this buffer.
	/// </summary>
	public ResourceUsage Usage;

	/// <summary>
	/// The structure byte stride.
	/// </summary>
	public int32 StructureByteStride;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.BufferDescription" /> struct.
	/// </summary>
	/// <param name="sizeInBytes">Size of the buffer in bytes.</param>
	/// <param name="flags">Buffer flags describing the buffer type.</param>
	/// <param name="cpuAccess">Describe the type of CPU access allowed for. </param>
	/// <param name="usage">Usage for this buffer.</param>
	/// <param name="structureByteStride">The structure byte stride.</param>
	public this(uint32 sizeInBytes, BufferFlags flags, ResourceUsage usage, ResourceCpuAccess cpuAccess = ResourceCpuAccess.None, int32 structureByteStride = 0)
	{
		SizeInBytes = sizeInBytes;
		Flags = flags;
		CpuAccess = cpuAccess;
		Usage = usage;
		StructureByteStride = structureByteStride;
	}

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(BufferDescription other)
	{
		if (SizeInBytes == other.SizeInBytes && Flags == other.Flags && CpuAccess == other.CpuAccess && Usage == other.Usage)
		{
			return StructureByteStride == other.StructureByteStride;
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
		if (obj is BufferDescription)
		{
			return Equals((BufferDescription)obj);
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
		return (int32)(((((((SizeInBytes * 397) ^ (uint32)Flags) * 397) ^ (uint32)CpuAccess) * 397) ^ (uint32)Usage) * 397) ^ StructureByteStride;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(BufferDescription value1, BufferDescription value2)
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
	public static bool operator !=(BufferDescription value1, BufferDescription value2)
	{
		return !value1.Equals(value2);
	}

	/// <summary>
	/// Gets the cpu access flags from resource usage.
	/// </summary>
	/// <param name="usage">The usage.</param>
	/// <returns>The cpu access flags.</returns>
	private static ResourceCpuAccess GetCpuAccessFromResourceUsage(ResourceUsage usage)
	{
		switch (usage)
		{
		case ResourceUsage.Dynamic:
			return ResourceCpuAccess.Write;
		case ResourceUsage.Staging:
			return ResourceCpuAccess.Write | ResourceCpuAccess.Read;
		default:
			return ResourceCpuAccess.None;
		}
	}
}
