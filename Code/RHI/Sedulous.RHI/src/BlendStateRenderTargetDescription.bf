using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes the blending state.
/// </summary>
public struct BlendStateRenderTargetDescription : IEquatable<BlendStateRenderTargetDescription>
{
	/// <summary>
	/// Enables (or disables) blending.
	/// </summary>
	public bool BlendEnable;

	/// <summary>
	/// This blend option specifies the operation to perform on the RGB values that the pixel shader outputs.
	/// The Blend option defines how to combine the SrcBlend and DestBlend operations.
	/// </summary>
	public Blend SourceBlendColor;

	/// <summary>
	/// This blend option specifies the operation to perform on the current RGB value in the render target.
	/// The Blend option defines how to combine the SrcBlend and DestBlend values.
	/// </summary>
	public Blend DestinationBlendColor;

	/// <summary>
	/// This blend operation defines how to combine the SrcBlend and DestBlend operands.
	/// </summary>
	public BlendOperation BlendOperationColor;

	/// <summary>
	/// This blend option specifies the operation to perform on the alpha value that the pixel shader outputs.
	/// Blend option that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha
	/// and DestBlendAlpha operations.
	/// </summary>
	public Blend SourceBlendAlpha;

	/// <summary>
	/// This blend option specifies the operation to perform on the current alpha value in the render target.
	/// Blend option that end in _COLOR are not allowed. The BlendOpAlpha member defines how to combine the SrcBlendAlpha
	/// and DestBlendAlpha operations.
	/// </summary>
	public Blend DestinationBlendAlpha;

	/// <summary>
	/// This blend operation defines how to combine the SrcBlendAlpha and DestBlendAlpha values.
	/// </summary>
	public BlendOperation BlendOperationAlpha;

	/// <summary>
	/// A writing mask.
	/// </summary>
	public ColorWriteChannels ColorWriteChannels;

	/// <summary>
	/// Gets the default values for <see cref="T:Sedulous.RHI.BlendStateDescription" />.
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
	/// <param name="other">The other object used for comparison.</param>
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
		return (int)(((((((((((((uint32)(BlendEnable.GetHashCode() * 397) ^ (uint32)SourceBlendColor) * 397) ^ (uint32)DestinationBlendColor) * 397) ^ (uint32)BlendOperationColor) * 397) ^ (uint32)SourceBlendAlpha) * 397) ^ (uint32)DestinationBlendAlpha) * 397) ^ (uint32)BlendOperationAlpha) * 397) ^ (int32)ColorWriteChannels;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The first value.</param>
	/// <param name="value2">The second value.</param>
	/// <returns>
	/// The result of the operation.
	/// </returns>
	public static bool operator ==(BlendStateRenderTargetDescription value1, BlendStateRenderTargetDescription value2)
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
	public static bool operator !=(BlendStateRenderTargetDescription value1, BlendStateRenderTargetDescription value2)
	{
		return !value1.Equals(value2);
	}
}
