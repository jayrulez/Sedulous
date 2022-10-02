namespace Sedulous.Core.Abstractions;

/// <summary>
/// Represents an object which injects factory methods into the context.
/// </summary>
public interface IContextFactoryInitializer
{
    /// <summary>
    /// Initializes the specified factory.
    /// </summary>
    /// <param name="owner">The context that owns the initializer.</param>
    /// <param name="factory">The <see cref="ContextFactory"/> to initialize.</param>
    void Initialize(Context owner, ContextFactory factory);
}