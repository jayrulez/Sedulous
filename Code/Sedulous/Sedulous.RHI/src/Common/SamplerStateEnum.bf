namespace Sedulous.RHI;

/// <summary>
/// The sampler state default values.
/// </summary>
enum SamplerStateEnum
{
	/// <summary>
	/// SamplerState description using point filter (bilinear) and clamp address mode for UVW.
	/// </summary>
	PointClamp,
	/// <summary>
	/// SamplerState description using point filter (bilinear) and wrap address mode for UVW.
	/// </summary>
	PointWrap,
	/// <summary>
	/// SamplerState description using point filter (bilinear) and mirror address mode for UVW.
	/// </summary>
	PointMirror,
	/// <summary>
	/// SamplerState description using linear filter (trilinear) and clamp address mode for UVW.
	/// </summary>
	LinearClamp,
	/// <summary>
	/// SamplerState description using linear filter (trilinear) and wrap address mode for UVW.
	/// </summary>
	LinearWrap,
	/// <summary>
	/// SamplerState description using linear filter (trilinear) and mirror address mode for UVW.
	/// </summary>
	LinearMirror,
	/// <summary>
	/// SamplerState description using anisotropic filter and clamp address mode for UVW.
	/// </summary>
	AnisotropicClamp,
	/// <summary>
	/// SamplerState description using anisotropic filter and wrap address mode for UVW.
	/// </summary>
	AnisotropicWrap,
	/// <summary>
	/// SamplerState description using anisotropic filter and mirror address mode for UVW.
	/// </summary>
	AnisotropicMirror,
	/// <summary>
	/// Custom value
	/// </summary>
	Custom
}
