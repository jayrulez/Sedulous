namespace Sedulous.RHI;

/// <summary>
/// The texture type.
/// </summary>
public enum TextureType : uint8
{
	/// <summary>
	/// Represents a 2D texture.
	/// </summary>
	Texture2D,
	/// <summary>
	/// Represents a 2D texture array
	/// </summary>
	Texture2DArray,
	/// <summary>
	/// Represents a 1D texture.
	/// </summary>
	Texture1D,
	/// <summary>
	/// Represents a 1D texture array.
	/// </summary>
	Texture1DArray,
	/// <summary>
	/// Represents a Cubemap texture.
	/// </summary>
	TextureCube,
	/// <summary>
	/// Represents a TextureCube array
	/// </summary>
	TextureCubeArray,
	/// <summary>
	/// Represents a 3D texture.
	/// </summary>
	Texture3D
}
