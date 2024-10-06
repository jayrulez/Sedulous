namespace Sedulous.RHI;

/// <summary>
/// The default values for the sampler state.
/// </summary>
public enum SamplerStateEnum
{
	/// <summary>
	/// SamplerState description using point filter (bilinear) and clamp address mode for UVW.
	/// </summary>
	PointClamp,
	/// <summary>
	/// SamplerState description using point filter (bilinear filtering) and wrap address mode for UVW.
	/// </summary>
	PointWrap,
	/// <summary>
	/// SamplerState description using point filter (bilinear) and mirror address mode for UVW.
	/// </summary>
	PointMirror,
	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and a clamp address mode for UVW.
	/// </summary>
	LinearClamp,
	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and a wrap address mode for UVW.
	/// </summary>
	LinearWrap,
	/// <summary>
	/// SamplerState description using a linear filter (trilinear) and mirror address mode for UVW.
	/// </summary>
	LinearMirror,
	/// <summary>
	/// Description of SamplerState using anisotropic filter and clamp address mode for UVW.
	/// </summary>
	AnisotropicClamp,
	/// <summary>
	/// SamplerState description using anisotropic filtering and wrap address mode for UVW.
	/// </summary>
	AnisotropicWrap,
	/// <summary>
	/// SamplerState description using an anisotropic filter and mirror address mode for UVW.
	/// </summary>
	AnisotropicMirror,
	/// <summary>
	/// Custom value.
	/// </summary>
	Custom
}
