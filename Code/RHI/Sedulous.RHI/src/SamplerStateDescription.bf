using System;

namespace Sedulous.RHI;

/// <summary>
/// Describes a sampler state.
/// </summary>
public struct SamplerStateDescription : IEquatable<SamplerStateDescription>
{
	/// <summary>
	/// Filtering method to use when sampling a texture.
	/// </summary>
	public TextureFilter Filter;

	/// <summary>
	/// Method to use for resolving a u texture coordinate that is outside the 0 to 1 range.
	/// </summary>
	public TextureAddressMode AddressU;

	/// <summary>
	/// Method to use for resolving a v texture coordinate that is outside the 0 to 1 range.
	/// </summary>
	public TextureAddressMode AddressV;

	/// <summary>
	/// Method to use for resolving a w texture coordinate that is outside the 0 to 1 range.
	/// </summary>
	public TextureAddressMode AddressW;

	/// <summary>
	/// Offset from the calculated mipmap level. For example, if Direct3D calculates that a
	/// texture should be sampled at mipmap level 3 and MipLODBias is 2, then the texture will be sampled at mipmap level 5.
	/// </summary>
	public float MipLODBias;

	/// <summary>
	/// Clamping value used if D3D11_FILTER_ANISOTROPIC or D3D11_FILTER_COMPARISON_ANISOTROPIC is
	/// specified in Filter. Valid values are between 1 and 16.
	/// </summary>
	public uint32 MaxAnisotropy;

	/// <summary>
	/// A function that compares sampled data against existing sampled data.
	/// </summary>
	public ComparisonFunction ComparisonFunc;

	/// <summary>
	/// Border color <see cref="T:Sedulous.RHI.SamplerBorderColor" />.
	/// </summary>
	public SamplerBorderColor BorderColor;

	/// <summary>
	/// Lower end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level
	/// and any level higher than that is less detailed.
	/// </summary>
	public float MinLOD;

	/// <summary>
	/// Upper end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level
	/// higher than that is less detailed. This value must be greater than or equal to MinLOD.
	/// </summary>
	public float MaxLOD;

	/// <summary>
	/// Gets default values for SamplerStateDescription.
	/// </summary>
	public static SamplerStateDescription Default
	{
		get
		{
			SamplerStateDescription defaultInstance = default(SamplerStateDescription);
			defaultInstance.SetDefault();
			return defaultInstance;
		}
	}

	/// <summary>
	/// Default SamplerStateDescription values.
	/// </summary>
	public void SetDefault() mut
	{
		Filter = TextureFilter.MinLinear_MagLinear_MipLinear;
		AddressU = TextureAddressMode.Clamp;
		AddressV = TextureAddressMode.Clamp;
		AddressW = TextureAddressMode.Clamp;
		MinLOD = -1000f;
		MaxLOD = 1000f;
		MipLODBias = 0f;
		MaxAnisotropy = 1;
		ComparisonFunc = ComparisonFunction.Never;
		BorderColor = SamplerBorderColor.OpaqueWhite;
	}

	/// <summary>
	/// Returns a hash code for this instance.
	/// </summary>
	/// <param name="other">Other used to compare.</param>
	/// <returns>
	/// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.
	/// </returns>
	public bool Equals(SamplerStateDescription other)
	{
		if (Filter == other.Filter && AddressU == other.AddressU && AddressV == other.AddressV && AddressW == other.AddressW && MinLOD.Equals(other.MinLOD) && MaxLOD.Equals(other.MaxLOD) && MipLODBias == other.MipLODBias && MaxAnisotropy == other.MaxAnisotropy && ComparisonFunc == other.ComparisonFunc)
		{
			return BorderColor == other.BorderColor;
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
		if (obj is SamplerStateDescription)
		{
			return Equals((SamplerStateDescription)obj);
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
		return (int32)(((((((((((((((((uint32)((int32)Filter * 397) ^ (uint32)AddressU) * 397) ^ (uint32)AddressV) * 397) ^ (uint32)AddressW) * 397) ^ (uint32)MinLOD.GetHashCode()) * 397) ^ (uint32)MaxLOD.GetHashCode()) * 397) ^ (uint32)MipLODBias.GetHashCode()) * 397) ^ MaxAnisotropy) * 397) ^ (uint32)ComparisonFunc) * 397) ^ ((int)BorderColor).GetHashCode();
	}

	/// <summary>
	/// Implements the operator ==.
	/// </summary>
	/// <param name="value1">The value1.</param>
	/// <param name="value2">The value2.</param>
	/// <returns>
	/// The result of the operator.
	/// </returns>
	public static bool operator ==(SamplerStateDescription value1, SamplerStateDescription value2)
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
	public static bool operator !=(SamplerStateDescription value1, SamplerStateDescription value2)
	{
		return !value1.Equals(value2);
	}
}
