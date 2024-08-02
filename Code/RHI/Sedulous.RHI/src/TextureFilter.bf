namespace Sedulous.RHI;

/// <summary>
/// Filtering options during texture sampling.
/// </summary>
public enum TextureFilter : uint8
{
	/// <summary>
	/// Use point sampling for minification, magnification, and mip-level sampling.
	/// </summary>
	MinPoint_MagPoint_MipPoint,
	/// <summary>
	/// Use point sampling for minification and magnification; use linear interpolation for mip-level sampling.
	/// </summary>
	MinPoint_MagPoint_MipLinear,
	/// <summary>
	/// Use point sampling for minification; use linear interpolation for magnification; use point sampling for mip-level sampling.
	/// </summary>
	MinPoint_MagLinear_MipPoint,
	/// <summary>
	/// Use point sampling for minification; use linear interpolation for magnification and mip-level sampling.
	/// </summary>
	MinPoint_MagLinear_MipLinear,
	/// <summary>
	/// Use linear interpolation for minification; use point sampling for magnification and mip-level sampling.
	/// </summary>
	MinLinear_MagPoint_MipPoint,
	/// <summary>
	/// Use linear interpolation for minification; use point sampling for magnification; use linear interpolation for mip-level sampling.
	/// </summary>
	MinLinear_MagPoint_MipLinear,
	/// <summary>
	/// Use linear interpolation for minification and magnification; use point sampling for mip-level sampling.
	/// </summary>
	MinLinear_MagLinear_MipPoint,
	/// <summary>
	/// Use linear interpolation for minification, magnification, and mip-level sampling.
	/// </summary>
	MinLinear_MagLinear_MipLinear,
	/// <summary>
	/// Use anisotropic interpolation for minification, magnification, and mip-level sampling.
	/// </summary>
	Anisotropic
}
