namespace Sedulous.RHI;

/// <summary>
///  Defines the type of depth in the clip space depth.
/// </summary>
public enum ClipDepth : uint8
{
	/// <summary>
	/// The depth in clip space is in the [0, 1] range.
	/// </summary>
	ZeroToOne,
	/// <summary>
	/// The depth in clip space is in the [-1, 1] range.
	/// </summary>
	NegativeOneToOne
}
