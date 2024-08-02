using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes the blend state.
/// </summary>
struct BlendStateRenderTargetDescription : IEquatable<BlendStateRenderTargetDescription>, IHashable
{
	/// <summary>
	/// Enable (or disable) blending.
	/// </summary>
	public bool BlendEnable;

	/// <summary>
	/// This blend option specifies the operation to perform on the RGB value that the pixel shader outputs.
	/// The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
	/// </summary>
	public Blend SourceBlendColor;

	/// <summary>
	/// This blend option specifies the operation to perform on the current RGB value in the render target.
	/// The BlendOp member defines how to combine the SrcBlend and DestBlend operations.
	/// </summary>
	public Blend DestinationBlendColor;

	/// <summary>
	/// This blend operation defines how to combine the SrcBlend and DestBlend operations.
	/// </summary>
	public BlendOperation BlendOperationColor;

	/// <summary>
	/// This blend option specifies the operation to perform on the alpha value that the pixel shader outputs.
	/// Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha
	/// and DestBlendAlpha operations.
	/// </summary>
	public Blend SourceBlendAlpha;

	/// <summary>
	/// This blend option specifies the operation to perform on the current alpha value in the render target.
	/// Blend options that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha
	/// and DestBlendAlpha operations.
	/// </summary>
	public Blend DestinationBlendAlpha;

	/// <summary>
	/// This blend operation defines how to combine the SrcBlendAlpha and DestBlendAlpha operations.
	/// </summary>
	public BlendOperation BlendOperationAlpha;

	/// <summary>
	/// A write mask.
	/// </summary>
	public ColorWriteChannels ColorWriteChannels;

	/// <summary>
	/// Gets default values for BlendStateDescription.
	/// </summary>
	public static BlendStateRenderTargetDescription Default
	{
		get
		{
			BlendStateRenderTargetDescription defaultInstance = default(BlendStateRenderTargetDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default BlendStateDescription values.
	/// </summary>
	public void SetDefault() mut
	{
		BlendEnable = false;
		SourceBlendColor = Blend.One;
		DestinationBlendColor = Blend.Zero;
		BlendOperationColor = BlendOperation.Add;
		SourceBlendAlpha = Blend.One;
		DestinationBlendAlpha = Blend.Zero;
		BlendOperationAlpha = BlendOperation.Add;
		ColorWriteChannels = /*ColorWriteChannels*/.All;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(BlendStateRenderTargetDescription other)
	{
		if (BlendEnable == other.BlendEnable
			&& SourceBlendColor == other.SourceBlendColor
			&& DestinationBlendColor == other.DestinationBlendColor
			&& BlendOperationColor == other.BlendOperationColor
			&& SourceBlendAlpha == other.SourceBlendAlpha
			&& DestinationBlendAlpha == other.DestinationBlendAlpha
			&& BlendOperationAlpha == other.BlendOperationAlpha)
		{
			return ColorWriteChannels == other.ColorWriteChannels;
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
		if (obj is BlendStateRenderTargetDescription)
		{
			return Equals((BlendStateRenderTargetDescription)obj);
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
		return (int)(((((((((((((uint32)(BlendEnable.GetHashCode() * 397)
			^ (uint32)SourceBlendColor) * 397)
			^ (uint32)DestinationBlendColor) * 397)
			^ (uint32)BlendOperationColor) * 397)
			^ (uint32)SourceBlendAlpha) * 397)
			^ (uint32)DestinationBlendAlpha) * 397)
			^ (uint32)BlendOperationAlpha) * 397)
			^ (int)ColorWriteChannels;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(BlendStateRenderTargetDescription value1, BlendStateRenderTargetDescription value2)
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
	public static bool operator !=(BlendStateRenderTargetDescription value1, BlendStateRenderTargetDescription value2)
	{
		return !value1.Equals(value2);
	}
}
