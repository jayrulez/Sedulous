using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes the depth-stencil state.
/// </summary>
public struct DepthStencilStateDescription : IEquatable<DepthStencilStateDescription>
{
	/// <summary>
	/// Enables depth testing.
	/// </summary>
	public bool DepthEnable;

	/// <summary>
	/// Identifies a portion of the depth-stencil buffer that can be modified by depth data.
	/// </summary>
	public bool DepthWriteMask;

	/// <summary>
	/// Compares depth data against existing depth data.
	/// </summary>
	public ComparisonFunction DepthFunction;

	/// <summary>
	/// Enables stencil testing.
	/// </summary>
	public bool StencilEnable;

	/// <summary>
	/// Identifies a portion of the depth-stencil buffer for reading stencil data.
	/// </summary>
	public uint8 StencilReadMask;

	/// <summary>
	/// Identifies a portion of the depth-stencil buffer for writing stencil data.
	/// </summary>
	public uint8 StencilWriteMask;

	/// <summary>
	/// Identifies how to use the results of the depth test and the stencil test for pixels whose surface normals are facing towards the camera.
	/// </summary>
	public DepthStencilOperationDescription FrontFace;

	/// <summary>
	/// Identifies how to use the results of the depth test and the stencil test for pixels whose surface normal is facing away from the camera.
	/// </summary>
	public DepthStencilOperationDescription BackFace;

	/// <summary>
	/// Gets default values for DepthStencilStateDescription.
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
	/// Default DepthStencilStateDescription values.
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
	/// <param name="other">Used to compare.</param>
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
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures such as a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return (int)(((((((((((uint32)(((DepthEnable.GetHashCode() * 397) ^ DepthWriteMask.GetHashCode()) * 397) ^ (uint32)DepthFunction) * 397) ^ (uint32)StencilEnable.GetHashCode()) * 397) ^ (uint32)StencilReadMask.GetHashCode()) * 397) ^ (uint32)StencilWriteMask.GetHashCode()) * 397) ^ (uint32)FrontFace.GetHashCode()) * 397) ^ BackFace.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
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
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator !=(DepthStencilStateDescription value1, DepthStencilStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
