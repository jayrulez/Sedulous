using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Sedulous.Foundation.Collections;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;

/// <summary>
/// FrameBuffer implementation on DirectX.
/// </summary>
public class DX12FrameBuffer : FrameBuffer
{
	/// <summary>
	/// The renderTargetView array of this <see cref="T:Sedulous.RHI.DirectX12.DX12FrameBuffer" />.
	/// </summary>
	public FixedList<D3D12_CPU_DESCRIPTOR_HANDLE, const Constants.MaxAttachments> ColorTargetViews;

	/// <summary>
	/// The colors texture array of this <see cref="T:Sedulous.RHI.DirectX12.DX12FrameBuffer" />.
	/// </summary>
	public DX12Texture[] ColorTargetTextures;

	/// <summary>
	/// The depthTargetView of this <see cref="T:Sedulous.RHI.DirectX12.DX12FrameBuffer" />.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE DepthTargetview;

	/// <summary>
	/// The depth texture of this <see cref="T:Sedulous.RHI.DirectX12.DX12FrameBuffer" />.
	/// </summary>
	public DX12Texture DepthTargetTexture;

	private DX12GraphicsContext graphicsContext;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
		}
	}

	/// <inheritdoc />
	public override bool RequireFlipProjection => false;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12FrameBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="depthTarget">The depth texture which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.DepthStencil" /> flag.</param>
	/// <param name="colorTargets">The array of color textures, all of which must have been created with <see cref="F:Sedulous.RHI.TextureFlags.RenderTarget" /> flags.</param>
	/// <param name="disposeAttachments">When this framebuffer is disposed, dispose the attachment textures too.</param>
	public this(DX12GraphicsContext context, FrameBufferAttachment? depthTarget, FrameBufferAttachmentList colorTargets, bool disposeAttachments = true)
		: base(depthTarget, colorTargets, disposeAttachments)
	{
		graphicsContext = context;
		if (depthTarget.HasValue)
		{
			DepthTargetview = (DepthTargetTexture = depthTarget.Value.AttachmentTexture as DX12Texture).GetDepthStencilView(depthTarget.Value.FirstSlice, depthTarget.Value.SliceCount, depthTarget.Value.MipSlice);
		}
		if (!colorTargets.IsEmpty && colorTargets.Count != 0)
		{
			ColorTargetViews = .() { Count = colorTargets.Count };
			ColorTargetTextures = new DX12Texture[colorTargets.Count];
			for (int32 i = 0; i < ColorTargetViews.Count; i++)
			{
				FrameBufferAttachment colorTarget = ColorTargets[i];
				DX12Texture colorTexture = colorTarget.AttachmentTexture as DX12Texture;
				ColorTargetTextures[i] = colorTexture;
				ColorTargetViews[i] = colorTexture.GetRenderTargetView(colorTarget.FirstSlice, colorTarget.SliceCount, colorTarget.MipSlice);
			}
		}
		else
		{
			ColorTargetViews = .();
		}
	}

	/// <inheritdoc />
	protected override void Dispose(bool disposing)
	{
		base.Dispose(disposing);
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			for (int32 i = 0; i < ColorTargetViews.Count; i++)
			{
				graphicsContext.RenderTargetViewAllocator.Free(ColorTargetViews[i]);
			}
			graphicsContext.DepthStencilViewAllocator.Free(DepthTargetview);
		}
		disposed = true;
	}
}
