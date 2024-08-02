namespace Sedulous.RHI.Raytracing;

/// <summary>
/// Bottom Level Acceleration Structure.
/// </summary>
public abstract class BottomLevelAS : GraphicsResource
{
	/// <summary>
	/// Get the Acceleration Structure description.
	/// </summary>
	public BottomLevelASDescription Description;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Raytracing.BottomLevelAS" /> class.
	/// </summary>
	/// <param name="context">The device context.</param>
	/// <param name="description">The Bottom Level Acceleration Structure description.</param>
	protected this(GraphicsContext context, in BottomLevelASDescription description)
		: base(context)
	{
		Description = description;
	}
}
