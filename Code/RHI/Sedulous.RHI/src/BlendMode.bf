namespace Sedulous.RHI;

/// <summary>
/// Specifies the alpha blending mode.
/// </summary>
public enum BlendMode : uint8
{
	/// <summary>
	/// No blending.
	/// </summary>
	Opaque,
	/// <summary>
	/// Pre-multiplied alpha blending.
	/// </summary>
	AlphaBlend,
	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	Additive,
	/// <summary>
	/// Non-premultiplied alpha blending.
	/// </summary>
	NonPremultiplied
}
