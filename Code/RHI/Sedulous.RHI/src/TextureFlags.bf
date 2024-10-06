using System;

namespace Sedulous.RHI;

/// <summary>
/// Identifies how to bind a texture.
/// </summary>
public enum TextureFlags : uint8
{
	/// <summary>
	/// No options.
	/// </summary>
	None = 0,
	/// <summary>
	/// A texture that can be used as shader parameter.
	/// </summary>
	ShaderResource = 1,
	/// <summary>
	/// A texture that can be used as a render target.
	/// </summary>
	RenderTarget = 2,
	/// <summary>
	/// A texture that can be used as an unordered access buffer.
	/// </summary>
	UnorderedAccess = 4,
	/// <summary>
	/// A texture that can be used as a depth stencil buffer.
	/// </summary>
	DepthStencil = 8,
	/// <summary>
	/// Enables GPU mipmap generation
	/// </summary>
	GenerateMipmaps = 0x10
}
