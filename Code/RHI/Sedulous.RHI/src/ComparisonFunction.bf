namespace Sedulous.RHI;

/// <summary>
/// Comparison options.
/// </summary>
public enum ComparisonFunction : uint8
{
	/// <summary>
	/// Never pass the comparison test.
	/// </summary>
	Never,
	/// <summary>
	/// If the source data is less than the destination data, the comparison succeeds.
	/// </summary>
	Less,
	/// <summary>
	/// If the source data is equal to the destination data, the comparison passes.
	/// </summary>
	Equal,
	/// <summary>
	/// If the source data is less than or equal to the destination data, the comparison passes.
	/// </summary>
	LessEqual,
	/// <summary>
	/// If the source data is greater than the destination data, the comparison succeeds.
	/// </summary>
	Greater,
	/// <summary>
	/// The comparison passes if the source data is not equal to the destination data.
	/// </summary>
	NotEqual,
	/// <summary>
	/// If the source data is greater than or equal to the destination data, the comparison passes.
	/// </summary>
	GreaterEqual,
	/// <summary>
	/// Always passes the comparison.
	/// </summary>
	Always
}
