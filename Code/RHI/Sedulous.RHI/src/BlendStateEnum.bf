namespace Sedulous.RHI;

/// <summary>
/// The default values of the blend state.
/// </summary>
public enum BlendStateEnum
{
	/// <summary>
	/// Not blended.
	/// </summary>
	Opaque,
	/// <summary>
	/// Pre-multiplied alpha blending.
	/// </summary>
	AlphaBlend,
	/// <summary>
	/// Non-premultiplied alpha blending.
	/// </summary>
	AlphaNonPremultiplied,
	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	Additive,
	/// <summary>
	/// Multiplicative alpha blending.
	/// </summary>
	Multiplicative,
	/// <summary>
	/// Custom value.
	/// </summary>
	Custom
}
