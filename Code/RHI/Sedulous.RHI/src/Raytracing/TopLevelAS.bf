namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Top-Level Acceleration Structure.
/// </summary>
public abstract class TopLevelAS : GraphicsResource
{
	/// <summary>
	/// Gets the Acceleration Structure description.
	/// </summary>
	public TopLevelASDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Raytracing.TopLevelAS" /> class.
	/// </summary>
	/// <param name="context">The device context.</param>
	/// <param name="description">The top-level acceleration structure description.</param>
	protected this(GraphicsContext context, in TopLevelASDescription description)
		: base(context)
	{
		Description = description;
	}
}
