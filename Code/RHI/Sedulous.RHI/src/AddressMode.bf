namespace Sedulous.RHI;

/// <summary>
/// Specifies texture addressing mode.
/// </summary>
public enum AddressMode : uint8
{
	/// <summary>
	/// Point/nearest neighbor filtering, clamped texture coordinates.
	/// </summary>
	PointClamp,
	/// <summary>
	/// Point/nearest neighbor filtering, wrapped texture coordinates.
	/// </summary>
	PointWrap,
	/// <summary>
	/// Bilinear filtering, clamped texture coordinates.
	/// </summary>
	LinearClamp,
	/// <summary>
	/// Bilinear filtering, wrapped texture coordinates.
	/// </summary>
	LinearWrap,
	/// <summary>
	/// Anisotropic filtering, clamped texture coordinates.
	/// </summary>
	AnisotropicClamp,
	/// <summary>
	/// Anisotropic filtering, wrapped texture coordinates.
	/// </summary>
	AnisotropicWrap
}
