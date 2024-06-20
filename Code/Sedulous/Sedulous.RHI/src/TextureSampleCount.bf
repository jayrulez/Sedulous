namespace Sedulous.RHI;

/// <summary>
/// Describes the number of samples to use in a <see cref="T:Sedulous.RHI.Texture" />.
/// </summary>
enum TextureSampleCount : uint8
{
	/// <summary>
	/// No multisample.
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
	/// Multisample count of 8 pixels.
	/// </summary>
	Count8,
	/// <summary>
	/// Multisample count of 16 pixels.
	/// </summary>
	Count16,
	/// <summary>
	/// Multisample count of 32 pixels.
	/// </summary>
	Count32
}
