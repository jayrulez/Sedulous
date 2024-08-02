using System;

namespace Sedulous.RHI;

/// <summary>
/// This class represent a Texture graphics resource.
/// </summary>
abstract class Texture : GraphicsResource
{
	/// <summary>
	/// Gets or sets the <see cref="T:Sedulous.RHI.TextureDescription" /> struct.
	/// </summary>
	public readonly TextureDescription Description;

	/// <summary>
	/// Gets or sets a string identifying this instance. Can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Gets a value indicating whether this texture could be attached to a framebuffer.
	/// </summary>
	public virtual bool CouldBeAttachedToFramebuffer => true;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.Texture" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The texture description.</param>
	protected this(GraphicsContext context, ref TextureDescription description)
		: base(context)
	{
		Description = description;
	}

	public int GetHashCode()
	{
		return (int)Internal.UnsafeCastToPtr(this);
	}
}
