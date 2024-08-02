using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes the blend state.
/// </summary>
struct BlendStateDescription : IEquatable<BlendStateDescription>, IHashable
{
	/// <summary>
	/// Specifies whether to use alpha-to-coverage as a multisampling technique when setting a pixel to a render target.
	/// </summary>
	public bool AlphaToCoverageEnable;

	/// <summary>
	/// Specifies whether to enable independent blending in simultaneous render targets. Set to TRUE to enable independent blending.
	/// If set to FALSE, only the RenderTarget[0] members are used; RenderTarget[1..7] are ignored.
	/// </summary>
	public bool IndependentBlendEnable;

	/// <summary>
	/// RenderTarget blend descriptions.
	/// </summary>
	public BlendStateRenderTargetDescription[8] RenderTargets;

	/// <summary>
	/// Gets default values for BlendStateDescription.
	/// </summary>
	public static BlendStateDescription Default
	{
		get
		{
			BlendStateDescription defaultInstance = default(BlendStateDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default BlendStateDescription values.
	/// </summary>
	public void SetDefault() mut
	{
		AlphaToCoverageEnable = false;
		IndependentBlendEnable = false;
		RenderTargets[0] = BlendStateRenderTargetDescription.Default;
		RenderTargets[1] = BlendStateRenderTargetDescription.Default;
		RenderTargets[2] = BlendStateRenderTargetDescription.Default;
		RenderTargets[3] = BlendStateRenderTargetDescription.Default;
		RenderTargets[4] = BlendStateRenderTargetDescription.Default;
		RenderTargets[5] = BlendStateRenderTargetDescription.Default;
		RenderTargets[6] = BlendStateRenderTargetDescription.Default;
		RenderTargets[7] = BlendStateRenderTargetDescription.Default;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(BlendStateDescription other)
	{
		if (AlphaToCoverageEnable != other.AlphaToCoverageEnable
			|| IndependentBlendEnable != other.IndependentBlendEnable
			|| RenderTargets[0] != other.RenderTargets[0]
			|| RenderTargets[1] != other.RenderTargets[1]
			|| RenderTargets[2] != other.RenderTargets[2]
			|| RenderTargets[3] != other.RenderTargets[3]
			|| RenderTargets[4] != other.RenderTargets[4]
			|| RenderTargets[5] != other.RenderTargets[5]
			|| RenderTargets[6] != other.RenderTargets[6]
			|| RenderTargets[7] != other.RenderTargets[7])
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
		if (obj is BlendStateDescription)
		{
			return Equals((BlendStateDescription)obj);
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
		return (((((((((((((((((AlphaToCoverageEnable.GetHashCode() * 397)
			^ IndependentBlendEnable.GetHashCode()) * 397)
			^ RenderTargets[0].GetHashCode()) * 397)
			^ RenderTargets[1].GetHashCode()) * 397)
			^ RenderTargets[2].GetHashCode()) * 397)
			^ RenderTargets[3].GetHashCode()) * 397)
			^ RenderTargets[4].GetHashCode()) * 397)
			^ RenderTargets[5].GetHashCode()) * 397)
			^ RenderTargets[6].GetHashCode()) * 397)
			^ RenderTargets[7].GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(BlendStateDescription value1, BlendStateDescription value2)
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
	public static bool operator !=(BlendStateDescription value1, BlendStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
