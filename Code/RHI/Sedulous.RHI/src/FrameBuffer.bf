using System;
using System.Collections;

namespace Sedulous.RHI;

/// <summary>
/// This class represents which color texture and depth texture are rendered to present.
/// </summary>
public abstract class FrameBuffer : IDisposable
{
	/// <summary>
	/// Indicates if the instance has been disposed.
	/// </summary>
	protected bool disposed;

	/// <summary>
	/// Indicates if this FrameBuffer requires the projection matrix to be flipped.
	/// </summary>
	protected bool requireFlipProjection;

	/// <summary>
	/// A value indicating whether attachment textures need to be disposed of when this framebuffer is disposed.
	/// </summary>
	protected bool disposeAttachments;


	/// <summary>
	/// Gets or sets a string identifying this instance. It can be used in graphics debuggers tools.
	/// </summary>
	public abstract String Name { get; set; }

	/// <summary>
	/// Gets or sets the width, in pixels, of the <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public uint32 Width { get; protected set; }

	/// <summary>
	/// Gets or sets the height, in pixels, of the <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public uint32 Height { get; protected set; }

	/// <summary>
	/// Gets or sets the array size of the <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public uint32 ArraySize { get; protected set; } = 1;


	/// <summary>
	/// Gets or sets the sample count of the <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public TextureSampleCount SampleCount { get; protected set; }

	/// <summary>
	/// Gets or sets a value indicating whether this FrameBuffer requires the projection matrix to be flipped.
	/// By default, it will indicate the default flip behavior, but the user can change it.
	/// </summary>
	public virtual bool RequireFlipProjection
	{
		get
		{
			return requireFlipProjection;
		}
		set
		{
			requireFlipProjection = value;
		}
	}

	/// <summary>
	/// Gets or sets the collection of color target textures associated with this <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public virtual ref FrameBufferAttachmentList ColorTargets { get; protected set; }

	/// <summary>
	/// Gets or sets the depth target texture associated with this <see cref="T:Sedulous.RHI.FrameBuffer" />.
	/// </summary>
	public virtual FrameBufferAttachment? DepthStencilTarget { get; protected set; }

	/// <summary>
	/// Gets or sets an <see cref="P:Sedulous.RHI.FrameBuffer.OutputDescription" /> that describes the number and formats of the depth and color targets.
	/// </summary>
	public OutputDescription OutputDescription { get; protected set; }

	/// <summary>
	/// Gets or sets a value indicating whether the framebuffer is associated with a swapchain.
	/// </summary>
	public bool IntermediateBufferAssociated { get; set; }

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBuffer" /> class.
	/// </summary>
	/// <param name="depthTarget">The depth texture, which must be created with the <see cref="F:Sedulous.RHI.TextureFlags.DepthStencil" /> flag.</param>
	/// <param name="colorTargets">The array of color textures, all of which must be created with the <see cref="F:Sedulous.RHI.TextureFlags.RenderTarget" /> flags.</param>
	/// <param name="disposeAttachments">When this framebuffer is disposed, dispose of the attachment textures too.</param>
	public this(FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments)
	{
		DepthStencilTarget = depthTarget;
		ColorTargets = colorTargets;
		this.disposeAttachments = disposeAttachments;
		FrameBufferAttachmentList colorTargets2 = ColorTargets;
		if (!colorTargets2.IsEmpty && colorTargets2.Count != 0)
		{
			FrameBufferAttachment target = ColorTargets[0];
			Width = target.AttachmentTexture.Description.Width;
			Height = target.AttachmentTexture.Description.Height;
			ArraySize = target.AttachmentTexture.Description.ArraySize;
			SampleCount = target.AttachmentTexture.Description.SampleCount;
		}
		else if (DepthStencilTarget.HasValue)
		{
			TextureDescription? depthDescription = DepthStencilTarget?.AttachmentTexture.Description;
			if (depthDescription.HasValue)
			{
				Width = depthDescription.Value.Width;
				Height = depthDescription.Value.Height;
				ArraySize = depthDescription.Value.ArraySize;
				SampleCount = depthDescription.Value.SampleCount;
			}
		}
		OutputDescription = /*OutputDescription*/.CreateFromFrameBuffer(this);
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.FrameBuffer" /> class.
	/// </summary>
	public this()
	{
	}

	/// <inheritdoc />
	public void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and optionally managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	protected virtual void Dispose(bool disposing)
	{
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			if (disposeAttachments)
			{
				if (!ColorTargets.IsEmpty)
				{
					FrameBufferAttachmentList colorTargets = ColorTargets;
					for (int i = 0; i < colorTargets.Count; i++)
					{
						FrameBufferAttachment frameBufferAttachment = colorTargets[i];
						frameBufferAttachment.AttachmentTexture.Dispose();
						frameBufferAttachment.ResolvedTexture?.Dispose();
					}
				}
				DepthStencilTarget?.AttachmentTexture?.Dispose();
				DepthStencilTarget?.ResolvedTexture?.Dispose();
			}
		}
		disposed = true;
	}
}
