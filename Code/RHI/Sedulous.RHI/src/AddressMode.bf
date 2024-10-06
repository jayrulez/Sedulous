namespace Sedulous.RHI;

/// <summary>
/// Specifies the texture addressing mode.
/// </summary>
public enum AddressMode : uint8
{
	/// <summary>
	/// Point/nearest neighbor filtering with clamped texture coordinates.
	/// </summary>
	PointClamp,
	/// <summary>
	/// Point/nearest neighbor filtering, wrapped texture coordinates.
	/// </summary>
	PointWrap,
	/// <summary>
	/// Bilinear filtering with clamped texture coordinates.
	/// </summary>
	LinearClamp,
	/// <summary>
	/// Bilinear filtering with wrapped texture coordinates.
	/// </summary>
	LinearWrap,
	/// <summary>
	/// Anisotropic filtering with clamped texture coordinates.
	/// </summary>
	AnisotropicClamp,
	/// <summary>
	/// Anisotropic filtering with wrapped texture coordinates.
	/// </summary>
	AnisotropicWrap
}
