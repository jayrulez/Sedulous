using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes the blend state.
/// </summary>
public struct BlendStateDescription : IEquatable<BlendStateDescription>
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
	/// RenderTarget blend description 0 of 7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget0;

	/// <summary>
	/// Render Target blend description 1 of 7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget1;

	/// <summary>
	/// RenderTarget blend description 2 of 7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget2;

	/// <summary>
	/// Render Target blend description 3/7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget3;

	/// <summary>
	/// Render target blend description 4/7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget4;

	/// <summary>
	/// Render target blend description 5/7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget5;

	/// <summary>
	/// RenderTarget blend description 6 of 7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget6;

	/// <summary>
	/// RenderTarget blend description 7 out of 7.
	/// </summary>
	public BlendStateRenderTargetDescription RenderTarget7;

	/// <summary>
	/// Gets the default values for BlendStateDescription.
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
		RenderTarget0 = BlendStateRenderTargetDescription.Default;
		RenderTarget1 = BlendStateRenderTargetDescription.Default;
		RenderTarget2 = BlendStateRenderTargetDescription.Default;
		RenderTarget3 = BlendStateRenderTargetDescription.Default;
		RenderTarget4 = BlendStateRenderTargetDescription.Default;
		RenderTarget5 = BlendStateRenderTargetDescription.Default;
		RenderTarget6 = BlendStateRenderTargetDescription.Default;
		RenderTarget7 = BlendStateRenderTargetDescription.Default;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">The object to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(BlendStateDescription other)
	{
		if (AlphaToCoverageEnable != other.AlphaToCoverageEnable || IndependentBlendEnable != other.IndependentBlendEnable || RenderTarget0 != other.RenderTarget0 || RenderTarget1 != other.RenderTarget1 || RenderTarget2 != other.RenderTarget2 || RenderTarget3 != other.RenderTarget3 || RenderTarget4 != other.RenderTarget4 || RenderTarget5 != other.RenderTarget5 || RenderTarget6 != other.RenderTarget6 || RenderTarget7 != other.RenderTarget7)
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
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like hash tables.
	/// </returns>
	public int GetHashCode()
	{
		return (((((((((((((((((AlphaToCoverageEnable.GetHashCode() * 397) ^ IndependentBlendEnable.GetHashCode()) * 397) ^ RenderTarget0.GetHashCode()) * 397) ^ RenderTarget1.GetHashCode()) * 397) ^ RenderTarget2.GetHashCode()) * 397) ^ RenderTarget3.GetHashCode()) * 397) ^ RenderTarget4.GetHashCode()) * 397) ^ RenderTarget5.GetHashCode()) * 397) ^ RenderTarget6.GetHashCode()) * 397) ^ RenderTarget7.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
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
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator !=(BlendStateDescription value1, BlendStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
