namespace Sedulous.Core.Abstractions;

/// <summary>
/// Represents an application component which participates in a context.
/// </summary>
interface IContextComponent
{
	/// <summary>
	/// Gets the context.
	/// </summary>
	Context Context { get; }
}