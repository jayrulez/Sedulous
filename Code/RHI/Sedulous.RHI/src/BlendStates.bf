namespace Sedulous.RHI;

/// <summary>
/// Default known values for <see cref="T:Sedulous.RHI.BlendStateDescription" />.
/// </summary>
public static class BlendStates
{
	/// <summary>
	/// Not blended.
	/// </summary>
	public static readonly BlendStateDescription Opaque;

	/// <summary>
	/// Pre-multiplied alpha blending.
	/// </summary>
	public static readonly BlendStateDescription AlphaBlend;

	/// <summary>
	/// Additive alpha blending.
	/// </summary>
	public static readonly BlendStateDescription Additive;

	/// <summary>
	/// Additive alpha blending effect.
	/// </summary>
	public static readonly BlendStateDescription Multiplicative;

	/// <summary>
	/// Non-premultiplied alpha blending.
	/// </summary>
	public static readonly BlendStateDescription NonPremultiplied;

	/// <summary>
	/// Initializes static members of the <see cref="T:Sedulous.RHI.BlendStates" /> class.
	/// </summary>
	static this()
	{
		Opaque = BlendStateDescription.Default;
		Opaque.RenderTarget0.BlendEnable = false;
		Opaque.RenderTarget0.SourceBlendColor = Blend.One;
		Opaque.RenderTarget0.DestinationBlendColor = Blend.Zero;
		AlphaBlend = BlendStateDescription.Default;
		AlphaBlend.RenderTarget0.BlendEnable = true;
		AlphaBlend.RenderTarget0.SourceBlendColor = Blend.One;
		AlphaBlend.RenderTarget0.DestinationBlendColor = Blend.InverseSourceAlpha;
		AlphaBlend.RenderTarget0.SourceBlendAlpha = Blend.One;
		AlphaBlend.RenderTarget0.DestinationBlendAlpha = Blend.InverseSourceAlpha;
		Additive = BlendStateDescription.Default;
		Additive.RenderTarget0.BlendEnable = true;
		Additive.RenderTarget0.BlendOperationColor = BlendOperation.Add;
		Additive.RenderTarget0.BlendOperationAlpha = BlendOperation.Add;
		Additive.RenderTarget0.SourceBlendColor = Blend.One;
		Additive.RenderTarget0.DestinationBlendColor = Blend.One;
		Additive.RenderTarget0.SourceBlendAlpha = Blend.One;
		Additive.RenderTarget0.DestinationBlendAlpha = Blend.One;
		Multiplicative = BlendStateDescription.Default;
		Multiplicative.RenderTarget0.BlendEnable = true;
		Multiplicative.RenderTarget0.BlendOperationColor = BlendOperation.Add;
		Multiplicative.RenderTarget0.BlendOperationAlpha = BlendOperation.Add;
		Multiplicative.RenderTarget0.SourceBlendColor = Blend.DestinationColor;
		Multiplicative.RenderTarget0.DestinationBlendColor = Blend.InverseSourceAlpha;
		Multiplicative.RenderTarget0.SourceBlendAlpha = Blend.One;
		Multiplicative.RenderTarget0.DestinationBlendAlpha = Blend.One;
		NonPremultiplied = BlendStateDescription.Default;
		NonPremultiplied.RenderTarget0.BlendEnable = true;
		NonPremultiplied.RenderTarget0.SourceBlendColor = Blend.SourceAlpha;
		NonPremultiplied.RenderTarget0.DestinationBlendColor = Blend.InverseSourceAlpha;
	}
}
