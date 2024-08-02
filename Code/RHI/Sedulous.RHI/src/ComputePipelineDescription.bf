using System;

namespace Sedulous.RHI;

/// <summary>
/// Contains properties that describe the characteristics of a new pipeline state object.
/// </summary>
public struct ComputePipelineDescription : IEquatable<ComputePipelineDescription>
{
	/// <summary>
	/// Describes the resources layout input.
	/// </summary>
	public ResourceLayout[] ResourceLayouts;

	/// <summary>
	/// Gets or sets the compute shader program.
	/// </summary>
	public ComputeShaderStateDescription shaderDescription;

	/// <summary>
	/// The X dimension of the thread group size.
	/// </summary>
	public uint32 ThreadGroupSizeX;

	/// <summary>
	/// The Y dimension of the thread group size.
	/// </summary>
	public uint32 ThreadGroupSizeY;

	/// <summary>
	/// The Z dimension of the thread group size.
	/// </summary>
	public uint32 ThreadGroupSizeZ;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.ComputePipelineDescription" /> struct.
	/// </summary>
	/// <param name="resourceLayouts">The resources layout description.</param>
	/// <param name="shaderDescription">The compute shader.</param>
	/// <param name="threadGroupSizeX">The X dimension of the thread group size.</param>
	/// <param name="threadGroupSizeY">The Y dimension of the thread group size.</param>
	/// <param name="threadGroupSizeZ">The Z dimension of the thread group size.</param>
	public this(ResourceLayout[] resourceLayouts, ComputeShaderStateDescription shaderDescription, uint32 threadGroupSizeX = 1, uint32 threadGroupSizeY = 1, uint32 threadGroupSizeZ = 1)
	{
		ResourceLayouts = resourceLayouts;
		this.shaderDescription = shaderDescription;
		ThreadGroupSizeX = threadGroupSizeX;
		ThreadGroupSizeY = threadGroupSizeY;
		ThreadGroupSizeZ = threadGroupSizeZ;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(ComputePipelineDescription other)
	{
		if (shaderDescription != other.shaderDescription || !ResourceLayouts.SequenceEqual(other.ResourceLayouts) || ThreadGroupSizeX != other.ThreadGroupSizeX || ThreadGroupSizeY != other.ThreadGroupSizeY || ThreadGroupSizeZ != other.ThreadGroupSizeZ)
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
		if (obj is ComputePipelineDescription)
		{
			return Equals((ComputePipelineDescription)obj);
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
		return (int)((((((uint32)(((shaderDescription.GetHashCode() * 397) ^ HashCode.Generate(ResourceLayouts)) * 397) ^ ThreadGroupSizeX) * 397) ^ ThreadGroupSizeY) * 397) ^ ThreadGroupSizeZ);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(ComputePipelineDescription value1, ComputePipelineDescription value2)
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
	public static bool operator !=(ComputePipelineDescription value1, ComputePipelineDescription value2)
	{
		return !value1.Equals(value2);
	}
}
