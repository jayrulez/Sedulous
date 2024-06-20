using System;

namespace Sedulous.RHI;

/// <summary>
/// Represents the requiered information to create a new swapchain depending of the platform.
/// </summary>
struct SwapChainDescription : IEquatable<SwapChainDescription>, IHashable
{
	/// <summary>
	/// Surface information.
	/// </summary>
	public SurfaceInfo SurfaceInfo;

	/// <summary>
	/// The swapchain buffers width.
	/// </summary>
	public uint32 Width;

	/// <summary>
	/// The swapchain buffers height.
	/// </summary>
	public uint32 Height;

	/// <summary>
	/// The refresh rate.
	/// </summary>
	public uint32 RefreshRate;

	/// <summary>
	/// The pixel format of the color target.
	/// </summary>
	public PixelFormat ColorTargetFormat;

	/// <summary>
	/// The color texture flags for binding to pipeline stages. The flags ca be combined by a logical OR.
	/// </summary>
	public TextureFlags ColorTargetFlags;

	/// <summary>
	/// The pixel format of the depthstencil target.
	/// </summary>
	public PixelFormat DepthStencilTargetFormat;

	/// <summary>
	/// The depth texture flags for binding to pipeline stages. The flags ca be combined by a logical OR.
	/// </summary>
	public TextureFlags DepthStencilTargetFlags;

	/// <summary>
	/// The sampler count of this swapchain.
	/// </summary>
	public TextureSampleCount SampleCount;

	/// <summary>
	/// Whether the output is in windowed mode.
	/// </summary>
	public bool IsWindowed;

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(SwapChainDescription other)
	{
		if (SurfaceInfo.Equals(other.SurfaceInfo)
			&& Width == other.Width
			&& Height == other.Height
			&& RefreshRate == other.RefreshRate
			&& ColorTargetFormat == other.ColorTargetFormat
			&& ColorTargetFlags == other.ColorTargetFlags
			&& DepthStencilTargetFormat == other.DepthStencilTargetFormat
			&& DepthStencilTargetFlags == other.DepthStencilTargetFlags
			&& SampleCount == other.SampleCount)
		{
			return IsWindowed == other.IsWindowed;
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
		if (obj is SwapChainDescription)
		{
			return Equals((SwapChainDescription)obj);
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
		return (int)(((((((((((((((((uint32)(SurfaceInfo.GetHashCode() * 397)
			^ Width) * 397)
			^ Height) * 397)
			^ RefreshRate) * 397)
			^ (uint32)ColorTargetFormat) * 397)
			^ (uint32)ColorTargetFlags) * 397)
			^ (uint32)DepthStencilTargetFormat) * 397)
			^ (uint32)DepthStencilTargetFlags) * 397)
			^ (uint32)SampleCount) * 397)
			^ IsWindowed.GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(SwapChainDescription value1, SwapChainDescription value2)
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
	public static bool operator !=(SwapChainDescription value1, SwapChainDescription value2)
	{
		return !value1.Equals(value2);
	}
}
