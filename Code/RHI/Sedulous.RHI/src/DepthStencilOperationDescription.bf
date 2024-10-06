using System;

namespace Sedulous.RHI;

/// <summary>
/// Stencil operations that can be performed based on the results of the stencil test.
/// </summary>
public struct DepthStencilOperationDescription : IEquatable<DepthStencilOperationDescription>
{
	/// <summary>
	/// The stencil operation performed when stencil testing fails.
	/// </summary>
	public StencilOperation StencilFailOperation;

	/// <summary>
	/// The stencil operation to perform when stencil testing passes and depth testing fails.
	/// </summary>
	public StencilOperation StencilDepthFailOperation;

	/// <summary>
	/// The stencil operation to perform when both stencil testing and depth testing pass.
	/// </summary>
	public StencilOperation StencilPassOperation;

	/// <summary>
	/// A function that compares stencil data with existing stencil data.
	/// </summary>
	public ComparisonFunction StencilFunction;

	/// <summary>
	/// Determines whether the specified parameter is equal to this instance.
	/// </summary>
	/// <param name="other">The object to compare with this instance.</param>
	/// <returns>
	/// <c>true</c> if the specified <see cref="T:System.Object" /> is equal to this instance; otherwise, <c>false</c>.
	/// </returns>
	public bool Equals(DepthStencilOperationDescription other)
	{
		if (StencilFailOperation == other.StencilFailOperation && StencilDepthFailOperation == other.StencilDepthFailOperation && StencilPassOperation == other.StencilPassOperation)
		{
			return StencilFunction == other.StencilFunction;
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
		if (obj is DepthStencilOperationDescription)
		{
			return Equals((DepthStencilOperationDescription)obj);
		}
		return false;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures, such as a hash table.
	/// </returns>
	public int GetHashCode()
	{
		return (int)(((((uint32)(((int)StencilFailOperation).GetHashCode() * 397) ^ (uint32)StencilDepthFailOperation) * 397) ^ (uint32)StencilPassOperation) * 397) ^ (int)StencilFunction;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value to compare.</param>
	/// <param name="value2">The second value to compare.</param>
	/// <returns>
	/// The result of the comparison.
	/// </returns>
	public static bool operator ==(DepthStencilOperationDescription value1, DepthStencilOperationDescription value2)
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
	public static bool operator !=(DepthStencilOperationDescription value1, DepthStencilOperationDescription value2)
	{
		return !value1.Equals(value2);
	}
}
