namespace Sedulous.RHI;

/// <summary>
/// Describes a sample state.
/// </summary>
public static class SamplerStates
{
	/// <summary>
	/// SamplerState description using point filter (bilinear) and clamp address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription PointClamp;

	/// <summary>
	/// SamplerState description using a point filter (bilinear) and a wrap address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription PointWrap;

	/// <summary>
	/// SamplerState description using point filter (bilinear) and mirror address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription PointMirror;

	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and clamp address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription LinearClamp;

	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and wrap address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription LinearWrap;

	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and a mirror address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription LinearMirror;

	/// <summary>
	/// SamplerState description using an anisotropic filter and clamp address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription AnisotropicClamp;

	/// <summary>
	/// SamplerState description using an anisotropic filter and wrap address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription AnisotropicWrap;

	/// <summary>
	/// Describes the SamplerState using anisotropic filtering and mirror address mode for UVW.
	/// </summary>
	public static readonly SamplerStateDescription AnisotropicMirror;

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.SamplerStates" /> class.
	/// </summary>
	static this()
	{
		PointClamp = SamplerStateDescription.Default;
		PointClamp.Filter = TextureFilter.MinPoint_MagPoint_MipPoint;
		PointWrap = SamplerStateDescription.Default;
		PointClamp.Filter = TextureFilter.MinPoint_MagPoint_MipPoint;
		PointWrap.AddressU = TextureAddressMode.Wrap;
		PointWrap.AddressV = TextureAddressMode.Wrap;
		PointWrap.AddressW = TextureAddressMode.Wrap;
		PointMirror = SamplerStateDescription.Default;
		PointClamp.Filter = TextureFilter.MinPoint_MagPoint_MipPoint;
		PointMirror.AddressU = TextureAddressMode.Mirror;
		PointMirror.AddressV = TextureAddressMode.Mirror;
		PointMirror.AddressW = TextureAddressMode.Mirror;
		LinearClamp = SamplerStateDescription.Default;
		LinearWrap = SamplerStateDescription.Default;
		LinearWrap.AddressU = TextureAddressMode.Wrap;
		LinearWrap.AddressV = TextureAddressMode.Wrap;
		LinearWrap.AddressW = TextureAddressMode.Wrap;
		LinearMirror = SamplerStateDescription.Default;
		LinearMirror.AddressU = TextureAddressMode.Mirror;
		LinearMirror.AddressV = TextureAddressMode.Mirror;
		LinearMirror.AddressW = TextureAddressMode.Mirror;
		AnisotropicClamp = SamplerStateDescription.Default;
		AnisotropicClamp.Filter = TextureFilter.Anisotropic;
		AnisotropicWrap = SamplerStateDescription.Default;
		AnisotropicWrap.Filter = TextureFilter.Anisotropic;
		AnisotropicWrap.AddressU = TextureAddressMode.Wrap;
		AnisotropicWrap.AddressV = TextureAddressMode.Wrap;
		AnisotropicWrap.AddressW = TextureAddressMode.Wrap;
		AnisotropicMirror = SamplerStateDescription.Default;
		AnisotropicMirror.Filter = TextureFilter.Anisotropic;
		AnisotropicMirror.AddressU = TextureAddressMode.Mirror;
		AnisotropicMirror.AddressV = TextureAddressMode.Mirror;
		AnisotropicMirror.AddressW = TextureAddressMode.Mirror;
	}
}
