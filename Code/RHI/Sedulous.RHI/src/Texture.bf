using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// This class represents a Texture graphics resource.
/// </summary>
public abstract class Texture : GraphicsResource
{
	/// <summary>
	/// Gets or sets the <see cref="T:Sedulous.RHI.TextureDescription" /> struct.
	/// </summary>
	public readonly TextureDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debugger tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Gets a value indicating whether this texture can be attached to a framebuffer.
	/// </summary>
	public virtual bool CouldBeAttachedToFramebuffer => true;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Texture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The texture's description.</param>
	protected this(GraphicsContext context, in TextureDescription description)
		: base(context)
	{
		Description = description;
	}
}
