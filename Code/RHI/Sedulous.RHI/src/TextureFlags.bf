using System;

namespace Sedulous.RHI;

/// <summary>
/// Identifies how to bing a texture.
/// </summary>
public enum TextureFlags : uint8
{
	/// <summary>
	/// No option.
	/// </summary>
	None = 0,
	/// <summary>
	/// A texture usable as a ShaderResourceView.
	/// </summary>
	ShaderResource = 1,
	/// <summary>
	/// A texture usable as render target.
	/// </summary>
	RenderTarget = 2,
	/// <summary>
	/// A texture usable as an unordered access buffer.
	/// </summary>
	UnorderedAccess = 4,
	/// <summary>
	/// A texture usable as a depth stencil buffer.
	/// </summary>
	DepthStencil = 8,
	/// <summary>
	/// Enables MIP map generation by GPU
	/// </summary>
	GenerateMipmaps = 0x10
}
