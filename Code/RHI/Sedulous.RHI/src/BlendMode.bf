namespace Sedulous.RHI;

/// <summary>
/// Specifies alpha blending mode.
/// </summary>
public enum BlendMode : uint8
{
	/// <summary>
	/// No blending.
	/// </summary>
	Opaque,
	/// <summary>
	/// Premultiplied alpha blending.
	/// </summary>
	AlphaBlend,
	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	Additive,
	/// <summary>
	/// Non premultiplied alpha blending.
	/// </summary>
	NonPremultiplied
}
