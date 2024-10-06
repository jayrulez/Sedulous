namespace Sedulous.RHI;

/// <summary>
/// Filters options during texture sampling.
/// </summary>
public enum TextureFilter : uint8
{
	/// <summary>
	/// Uses point sampling for minification, magnification, and mip-level sampling.
	/// </summary>
	MinPoint_MagPoint_MipPoint,
	/// <summary>
	/// Uses point sampling for minification and magnification; uses linear interpolation for mip-level sampling.
	/// </summary>
	MinPoint_MagPoint_MipLinear,
	/// <summary>
	/// Uses point sampling for minification, linear interpolation for magnification, and point sampling for mip-level sampling.
	/// </summary>
	MinPoint_MagLinear_MipPoint,
	/// <summary>
	/// Uses point sampling for minification and linear interpolation for magnification and mip-level sampling.
	/// </summary>
	MinPoint_MagLinear_MipLinear,
	/// <summary>
	/// Uses linear interpolation for minification and point sampling for magnification and mip-level sampling.
	/// </summary>
	MinLinear_MagPoint_MipPoint,
	/// <summary>
	/// Uses linear interpolation for minification, point sampling for magnification, and linear interpolation for mip-level sampling.
	/// </summary>
	MinLinear_MagPoint_MipLinear,
	/// <summary>
	/// Uses linear interpolation for minification and magnification; uses point sampling for mip-level sampling.
	/// </summary>
	MinLinear_MagLinear_MipPoint,
	/// <summary>
	/// Uses linear interpolation for minification, magnification, and mip-level sampling.
	/// </summary>
	MinLinear_MagLinear_MipLinear,
	/// <summary>
	/// Uses anisotropic interpolation for minification, magnification, and mip-level sampling.
	/// </summary>
	Anisotropic
}
