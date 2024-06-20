namespace Sedulous.RHI;

/// <summary>
/// The blend state default values.
/// </summary>
enum BlendStateEnum
{
	/// <summary>
	/// Not blending.
	/// </summary>
	Opaque,
	/// <summary>
	/// Premultiplied alpha blending.
	/// </summary>
	AlphaBlend,
	/// <summary>
	/// Non premultiplied alpha blending.
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
	/// Custom value
	/// </summary>
	Custom
}
