using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes depth-stencil state.
/// </summary>
struct DepthStencilStateDescription : IEquatable<DepthStencilStateDescription>, IHashable
{
	/// <summary>
	/// Enable depth testing.
	/// </summary>
	public bool DepthEnable;

	/// <summary>
	/// Identify a portion of the depth-stencil buffer that can be modified by depth data.
	/// </summary>
	public bool DepthWriteMask;

	/// <summary>
	/// A function that compares depth data against existing depth data.
	/// </summary>
	public ComparisonFunction DepthFunction;

	/// <summary>
	/// Enable stencil testing.
	/// </summary>
	public bool StencilEnable;

	/// <summary>
	/// Identify a portion of the depth-stencil buffer for reading stencil data.
	/// </summary>
	public uint8 StencilReadMask;

	/// <summary>
	/// Identify a portion of the depth-stencil buffer for writing stencil data.
	/// </summary>
	public uint8 StencilWriteMask;

	/// <summary>
	/// Identify how to use the results of the depth test and the stencil test for pixels whose surface normal is facing towards the camera.
	/// </summary>
	public DepthStencilOperationDescription FrontFace;

	/// <summary>
	/// Identify how to use the results of the depth test and the stencil test for pixels whose surface normal is facing away from the camera.
	/// </summary>
	public DepthStencilOperationDescription BackFace;

	/// <summary>
	/// Gets default values for DephtStencilStateDescription.
	/// </summary>
	public static DepthStencilStateDescription Default
	{
		get
		{
			DepthStencilStateDescription defaultInstance = default(DepthStencilStateDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default DephtStencilStateDescription values.
	/// </summary>
	public void SetDefault() mut
	{
		DepthEnable = true;
		DepthWriteMask = true;
		DepthFunction = ComparisonFunction.LessEqual;
		StencilEnable = false;
		StencilReadMask = uint8.MaxValue;
		StencilWriteMask = uint8.MaxValue;

		FrontFace.StencilFunction = ComparisonFunction.Always;
		FrontFace.StencilPassOperation = StencilOperation.Keep;
		FrontFace.StencilFailOperation = StencilOperation.Keep;
		FrontFace.StencilDepthFailOperation = StencilOperation.Keep;

		BackFace.StencilFunction = ComparisonFunction.Always;
		BackFace.StencilPassOperation = StencilOperation.Keep;
		BackFace.StencilFailOperation = StencilOperation.Keep;
		BackFace.StencilDepthFailOperation = StencilOperation.Keep;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(DepthStencilStateDescription other)
	{
		if (DepthEnable == other.DepthEnable
			&& DepthWriteMask == other.DepthWriteMask
			&& DepthFunction == other.DepthFunction
			&& StencilEnable == other.StencilEnable
			&& StencilReadMask == other.StencilReadMask
			&& StencilWriteMask == other.StencilWriteMask
			&& FrontFace == other.FrontFace)
		{
			return BackFace == other.BackFace;
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
		if (obj is DepthStencilStateDescription)
		{
			return Equals((DepthStencilStateDescription)obj);
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
		return (int)(((((((((((uint32)(((DepthEnable.GetHashCode() * 397)
			^ DepthWriteMask.GetHashCode()) * 397)
			^ (uint32)DepthFunction) * 397)
			^ (uint32)StencilEnable.GetHashCode()) * 397)
			^ (uint32)StencilReadMask.GetHashCode()) * 397)
			^ (uint32)StencilWriteMask.GetHashCode()) * 397)
			^ (uint32)FrontFace.GetHashCode()) * 397)
			^ BackFace.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(DepthStencilStateDescription value1, DepthStencilStateDescription value2)
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
	public static bool operator !=(DepthStencilStateDescription value1, DepthStencilStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
