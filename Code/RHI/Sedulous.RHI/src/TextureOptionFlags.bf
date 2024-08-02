namespace Sedulous.RHI;

/// <summary>
/// Identifies expected texture use during rendering.
/// </summary>
enum TextureOptionFlags : uint8
{
	/// <summary>
	/// The default value.
	/// </summary>
	None,
	/// <summary>
	/// Specifies a textureCube access.
	/// </summary>
	TextureCube
}