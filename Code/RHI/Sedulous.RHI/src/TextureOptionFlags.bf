namespace Sedulous.RHI;

/// <summary>
/// Identifies the expected texture usage during rendering.
/// </summary>
public enum TextureOptionFlags : uint8
{
	/// <summary>
	/// The default value.
	/// </summary>
	None,
	/// <summary>
	/// Specifies a texture cube access.
	/// </summary>
	TextureCube
}
