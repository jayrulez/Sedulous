namespace Sedulous.RHI;

/// <summary>
/// Blend factors, which modulate values for the pixel shader and the render target.
/// </summary>
public enum Blend : uint8
{
	/// <summary>
	/// The data source is the color black (0, 0, 0, 0). No pre-blend operation is performed.
	/// </summary>
	Zero = 1,
	/// <summary>
	/// The data source is the color white (1, 1, 1, 1). No pre-blending operation.
	/// </summary>
	One = 2,
	/// <summary>
	/// The data source is color data (RGB) from a pixel shader with no pre-blend operation.
	/// </summary>
	SourceColor = 3,
	/// <summary>
	/// The data source is color data (RGB) from a pixel shader. The pre-blend operation inverts the data, generating 1 - RGB.
	/// </summary>
	InverseSourceColor = 4,
	/// <summary>
	/// The data source is alpha data (A) from a pixel shader. No pre-blend operation.
	/// </summary>
	SourceAlpha = 5,
	/// <summary>
	/// The data source is alpha data (A) from a pixel shader. The pre-blend operation inverts the data, generating 1 - A.
	/// </summary>
	InverseSourceAlpha = 6,
	/// <summary>
	/// The data source is alpha data from a render target. No pre-blend operation.
	/// </summary>
	DestinationAlpha = 7,
	/// <summary>
	/// The data source is alpha data from a render target. The pre-blend operation inverts the data, generating 1 - A.
	/// </summary>
	InverseDestinationAlpha = 8,
	/// <summary>
	/// The data source is color data from a render target. No pre-blend operation.
	/// </summary>
	DestinationColor = 9,
	/// <summary>
	/// The data source is color data from a render target. The pre-blend operation inverts the data, generating 1 - RGB.
	/// </summary>
	InverseDestinationColor = 10,
	/// <summary>
	/// The data source is the alpha data from a pixel shader. The pre-blend operation clamps the data to 1 or less.
	/// </summary>
	SourceAlphaSaturate = 11,
	/// <summary>
	/// The data source is the blend factor set with BlendStates. No pre-blend operation is performed.
	/// </summary>
	BlendFactor = 14,
	/// <summary>
	/// The data source is the blend factor set with SetBlendState. The pre-blend operation inverts the blend factor, generating 1 - blendFactor.
	/// </summary>
	InverseBlendFactor = 15,
	/// <summary>
	/// The data sources are both color data output by a pixel shader. There is no pre-blend operation. This option supports dual-source color blending.
	/// </summary>
	SecondarySourceColor = 16,
	/// <summary>
	/// The data sources are both color data output by a pixel shader. The pre-blend operation inverts the data, generating 1 - RGB. This option supports dual-source color blending.
	/// </summary>
	InverseSecondarySourceColor = 17,
	/// <summary>
	/// The data sources are alpha data output by a pixel shader. There is no pre-blend operation. This option supports dual-source color blending.
	/// </summary>
	SecondarySourceAlpha = 18,
	/// <summary>
	/// The data sources are alpha data output by a pixel shader. The pre-blend operation inverts the data, generating 1 - A. This option supports dual-source color blending.
	/// </summary>
	InverseSecondarySourceAlpha = 19
}
