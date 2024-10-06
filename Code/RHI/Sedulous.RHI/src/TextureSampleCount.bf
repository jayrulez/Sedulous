namespace Sedulous.RHI;

/// <summary>
/// Describes the number of samples used in a <see cref="T:Sedulous.RHI.Texture" />.
/// </summary>
public enum TextureSampleCount : uint8
{
	/// <summary>
	/// No multi-sampling.
	/// </summary>
	None,
	/// <summary>
	/// Multisample count of 2 pixels.
	/// </summary>
	Count2,
	/// <summary>
	/// Multisample count of 4 pixels.
	/// </summary>
	Count4,
	/// <summary>
	/// Multisample count of 8 samples.
	/// </summary>
	Count8,
	/// <summary>
	/// Multisample count of 16 pixels.
	/// </summary>
	Count16,
	/// <summary>
	/// Multisample count of 32.
	/// </summary>
	Count32
}
