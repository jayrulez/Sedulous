namespace Sedulous.RHI;

/// <summary>
/// Default known values for <see cref="T:Sedulous.RHI.BlendStateDescription" />.
/// </summary>
public static class BlendStates
{
	/// <summary>
	/// Not blending.
	/// </summary>
	public static readonly BlendStateDescription Opaque;

	/// <summary>
	/// Premultiplied alpha blending.
	/// </summary>
	public static readonly BlendStateDescription AlphaBlend;

	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	public static readonly BlendStateDescription Additive;

	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	public static readonly BlendStateDescription Multiplicative;

	/// <summary>
	/// Non premultiplied alpha blending.
	/// </summary>
	public static readonly BlendStateDescription NonPremultiplied;

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.BlendStates" /> class.
	/// </summary>
	static this()
	{
		Opaque = BlendStateDescription.Default;
		Opaque.RenderTargets[0].BlendEnable = false;
		Opaque.RenderTargets[0].SourceBlendColor = Blend.One;
		Opaque.RenderTargets[0].DestinationBlendColor = Blend.Zero;

		AlphaBlend = BlendStateDescription.Default;
		AlphaBlend.RenderTargets[0].BlendEnable = true;
		AlphaBlend.RenderTargets[0].SourceBlendColor = Blend.One;
		AlphaBlend.RenderTargets[0].DestinationBlendColor = Blend.InverseSourceAlpha;
		AlphaBlend.RenderTargets[0].SourceBlendAlpha = Blend.One;
		AlphaBlend.RenderTargets[0].DestinationBlendAlpha = Blend.InverseSourceAlpha;

		Additive = BlendStateDescription.Default;
		Additive.RenderTargets[0].BlendEnable = true;
		Additive.RenderTargets[0].BlendOperationColor = BlendOperation.Add;
		Additive.RenderTargets[0].BlendOperationAlpha = BlendOperation.Add;
		Additive.RenderTargets[0].SourceBlendColor = Blend.One;
		Additive.RenderTargets[0].DestinationBlendColor = Blend.One;
		Additive.RenderTargets[0].SourceBlendAlpha = Blend.One;
		Additive.RenderTargets[0].DestinationBlendAlpha = Blend.One;

		Multiplicative = BlendStateDescription.Default;
		Multiplicative.RenderTargets[0].BlendEnable = true;
		Multiplicative.RenderTargets[0].BlendOperationColor = BlendOperation.Add;
		Multiplicative.RenderTargets[0].BlendOperationAlpha = BlendOperation.Add;
		Multiplicative.RenderTargets[0].SourceBlendColor = Blend.DestinationColor;
		Multiplicative.RenderTargets[0].DestinationBlendColor = Blend.InverseSourceAlpha;
		Multiplicative.RenderTargets[0].SourceBlendAlpha = Blend.One;
		Multiplicative.RenderTargets[0].DestinationBlendAlpha = Blend.One;

		NonPremultiplied = BlendStateDescription.Default;
		NonPremultiplied.RenderTargets[0].BlendEnable = true;
		NonPremultiplied.RenderTargets[0].SourceBlendColor = Blend.SourceAlpha;
		NonPremultiplied.RenderTargets[0].DestinationBlendColor = Blend.InverseSourceAlpha;
	}
}
