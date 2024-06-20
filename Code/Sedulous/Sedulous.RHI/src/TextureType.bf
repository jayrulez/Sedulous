namespace Sedulous.RHI;

/// <summary>
/// Texture type.
/// </summary>
enum TextureType : uint8
{
	/// <summary>
	/// Represent a 2D texture.
	/// </summary>
	Texture2D,
	/// <summary>
	/// Represent a 2D texture array
	/// </summary>
	Texture2DArray,
	/// <summary>
	/// Represent a 1D texture.
	/// </summary>
	Texture1D,
	/// <summary>
	/// Represent a 1D texture array.
	/// </summary>
	Texture1DArray,
	/// <summary>
	/// Represent a Cubemap texture.
	/// </summary>
	TextureCube,
	/// <summary>
	/// Represent a TextureCube array
	/// </summary>
	TextureCubeArray,
	/// <summary>
	/// Represent a 3D texture.
	/// </summary>
	Texture3D
}
