using System;
using Sedulous.Foundation.Mathematics;

namespace Sedulous.RHI;

/// <summary>
/// This struct represent all the parameters in the render states.
/// </summary>
public struct RenderStateDescription : IEquatable<RenderStateDescription>
{
	/// <summary>
	/// Gets or sets the Rasterizer State.
	/// </summary>
	public RasterizerStateDescription RasterizerState;

	/// <summary>
	/// Gets or sets the DepthStencil state.
	/// </summary>
	public DepthStencilStateDescription DepthStencilState;

	/// <summary>
	/// Gets or sets the BlendState state.
	/// </summary>
	public BlendStateDescription BlendState;

	/// <summary>
	/// The reference value to use when doing a stencil test.
	/// </summary>
	public int32 StencilReference;

	/// <summary>
	/// Array of blend factors, one for each RGBA component. The blend factors modulate values for the pixel shader, render target, or both.
	/// If you created the blend-state object with D3D11_BLEND_BLEND_FACTOR or D3D11_BLEND_INV_BLEND_FACTOR, the blending stage uses the non-NULL array of blend factors.
	/// If you didn't create the blend-state object with D3D11_BLEND_BLEND_FACTOR or D3D11_BLEND_INV_BLEND_FACTOR, the blending stage does not
	/// use the non-NULL array of blend factors; the runtime stores the blend factors, and you can later call ID3D11DeviceContext::OMGetBlendState to retrieve the blend factors.
	/// If you pass NULL, the runtime uses or stores a blend factor equal to { 1, 1, 1, 1 }.
	/// </summary>
	public Vector4? BlendFactor;

	/// <summary>
	/// 32-bit sample coverage. The default value is 0xFFFFFF. See remarks.
	/// </summary>
	public int32? SampleMask;

	/// <summary>
	/// Gets default values for RenderStateDescription.
	/// </summary>
	public static RenderStateDescription Default
	{
		get
		{
			RenderStateDescription defaultInstance = default(RenderStateDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default RenderStateDescription values.
	/// </summary>
	public void SetDefault() mut
	{
		RasterizerState = RasterizerStateDescription.Default;
		DepthStencilState = DepthStencilStateDescription.Default;
		BlendState = BlendStateDescription.Default;
		StencilReference = 0;
		BlendFactor = null;
		SampleMask = 16777215;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(RenderStateDescription other)
	{
		if (RasterizerState == other.RasterizerState
			&& DepthStencilState == other.DepthStencilState
			&& BlendState == other.BlendState
			&& StencilReference == other.StencilReference
			&& BlendFactor == other.BlendFactor)
		{
			return SampleMask == other.SampleMask;
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
		if (obj is RenderStateDescription)
		{
			return Equals((RenderStateDescription)obj);
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
		int hashCode = RasterizerState.GetHashCode();
		hashCode = (hashCode * 397) ^ BlendState.GetHashCode();
		hashCode = (hashCode * 397) ^ DepthStencilState.GetHashCode();
		hashCode = (hashCode * 397) ^ StencilReference;
		hashCode = (hashCode * 397) ^ BlendFactor.GetHashCode();
		if (BlendFactor.HasValue)
		{
			hashCode = (hashCode * 397) ^ BlendFactor.GetHashCode();
		}
		if (SampleMask.HasValue)
		{
			hashCode = (hashCode * 397) ^ SampleMask.Value;
		}
		return hashCode;
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(RenderStateDescription value1, RenderStateDescription value2)
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
	public static bool operator !=(RenderStateDescription value1, RenderStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
