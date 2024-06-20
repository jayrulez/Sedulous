using System;

namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Contains properties that describe the characteristics of a new pipeline state object.
/// </summary>
struct RaytracingPipelineDescription : IEquatable<RaytracingPipelineDescription>
{
	/// <summary>
	/// Describes the resources layout input.
	/// </summary>
	public ResourceLayout[] ResourceLayouts;

	/// <summary>
	/// Gets or sets the raytracing shader program.
	/// </summary>
	public RaytracingShaderStateDescription Shaders;

	/// <summary>
	/// Gets or sets the raytracing hit groups.
	/// </summary>
	public HitGroupDescription[] HitGroups;

	/// <summary>
	/// Limit on ray recursion for the raytracing pipeline. It must be in the range of 0 to 31. Below the maximum
	/// recursion depth, shader invocations such as closest hit or miss shaders can call TraceRay any number of times.
	/// At the maximum recursion depth, TraceRay calls result in the device going into removed state.
	/// </summary>
	public uint32 MaxTraceRecursionDepth;

	/// <summary>
	/// The maximum storage for scalars (counted as 4 bytes each) in ray payloads in raytracing pipelines that
	/// contain this program. Callable shader payloads are not part of this limit. This field is ignored for
	/// payloads that use payload access qualifiers.
	/// </summary>
	public uint32 MaxPayloadSizeInBytes;

	/// <summary>
	/// The maximum number of scalars (counted as 4 bytes each) that can be used for attributes in pipelines
	/// that contain this shader. The value cannot exceed D3D12_RAYTRACING_MAX_ATTRIBUTE_SIZE_IN_BYTES constant
	/// (https://microsoft.github.io/DirectX-Specs/d3d/Raytracing.html#constants).
	/// </summary>
	public uint32 MaxAttributeSizeInBytes;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Raytracing.RaytracingPipelineDescription" /> struct.
	/// </summary>
	/// <param name="resourceLayouts">The resources layout description.</param>
	/// <param name="shaderDescription">The raytracing shader.</param>
	/// <param name="hitGroupDescriptions">The hit group descriptions.</param>
	/// <param name="maxRecursionDepth">Max Recursion Depth.</param>
	/// <param name="maxPayloadSize">Max Payload Size.</param>
	/// <param name="maxAttributeSize">Max Attribute Size.</param>
	public this(ResourceLayout[] resourceLayouts, RaytracingShaderStateDescription shaderDescription, HitGroupDescription[] hitGroupDescriptions, uint32 maxRecursionDepth, uint32 maxPayloadSize, uint32 maxAttributeSize)
	{
		ResourceLayouts = resourceLayouts;
		Shaders = shaderDescription;
		HitGroups = hitGroupDescriptions;
		MaxTraceRecursionDepth = maxRecursionDepth;
		MaxPayloadSizeInBytes = maxPayloadSize;
		MaxAttributeSizeInBytes = maxAttributeSize;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(RaytracingPipelineDescription other)
	{
		if (Shaders != other.Shaders
			|| !ResourceLayouts.SequenceEqual(other.ResourceLayouts)
			|| !HitGroups.SequenceEqual(other.HitGroups)
			|| MaxTraceRecursionDepth != other.MaxTraceRecursionDepth
			|| MaxPayloadSizeInBytes != other.MaxPayloadSizeInBytes
			|| MaxAttributeSizeInBytes != other.MaxAttributeSizeInBytes)
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
		if (obj is RaytracingPipelineDescription)
		{
			return Equals((RaytracingPipelineDescription)obj);
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
		return (int)((((((uint32)(((((Shaders.GetHashCode() * 397)
			^ ResourceLayouts.GetHashCode()) * 397)
			^ HitGroups.GetHashCode()) * 397)
			^ MaxTraceRecursionDepth) * 397)
			^ MaxPayloadSizeInBytes) * 397)
			^ MaxAttributeSizeInBytes);
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(RaytracingPipelineDescription value1, RaytracingPipelineDescription value2)
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
	public static bool operator !=(RaytracingPipelineDescription value1, RaytracingPipelineDescription value2)
	{
		return !value1.Equals(value2);
	}
}
