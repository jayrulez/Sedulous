namespace Sedulous.RHI;

/// <summary>
///  Define the type of depth in the clip space depth.
/// </summary>
enum ClipDepth : uint8
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
