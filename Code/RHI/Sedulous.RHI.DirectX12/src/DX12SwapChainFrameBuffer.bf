using Sedulous.RHI;
using System;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;

/// <summary>
/// This class represents the swapchain FrameBuffer in DirectX12.
/// </summary>
public class DX12SwapChainFrameBuffer : FrameBuffer
{
	/// <summary>
	/// The depth target view of this <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" />.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE DepthTargetview;

	/// <summary>
	/// The depth texture of this <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" />.
	/// </summary>
	public DX12Texture DepthTargetTexture;

	/// <summary>
	/// The render target view array of this <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" />.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE[] BackBuffers;

	/// <summary>
	/// The color texture array of this <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" />.
	/// </summary>
	public DX12Texture[] BackBufferTextures;

	/// <summary>
	/// The active back buffer index.
	/// </summary>
	public int32 CurrentBackBufferIndex;

	private DX12GraphicsContext graphicsContext;

	private String name = new .() ~ delete _;

	private readonly DX12SwapChain swapchain;

	/// <summary>
	/// Gets the render target view array of this <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" />.
	/// </summary>
	public ref D3D12_CPU_DESCRIPTOR_HANDLE ColorTargetViews => ref BackBuffers[CurrentBackBufferIndex];

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

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChainFrameBuffer" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="swapchain">The swap chain to create from.</param>
	public this(DX12GraphicsContext context, DX12SwapChain swapchain)
	{
		graphicsContext = context;
		this.swapchain = swapchain;
		SwapChainDescription description = swapchain.SwapChainDescription;
		base.IntermediateBufferAssociated = true;
		int swapChainBufferCount = 3;
		ColorTargets = .() { Count = swapChainBufferCount};
		for (int i = 0; i < swapChainBufferCount; i++)
		{
			ID3D12Resource* backBuffer = null;
			swapchain.nativeSwapChain.GetBuffer((uint32)i, ID3D12Resource.IID, (void**)&backBuffer);
			swapchain.swapChainBuffers[i] = DX12Texture.FromDirectXTexture(graphicsContext, backBuffer);
			ColorTargets[i] = FrameBufferAttachment(swapchain.swapChainBuffers[i], 0, 1);
		}
		TextureDescription depth = TextureDescription()
		{
			Format = description.DepthStencilTargetFormat,
			ArraySize = 1,
			Faces = 1,
			MipLevels = 1,
			Width = description.Width,
			Height = description.Height,
			Depth = 1,
			SampleCount = TextureSampleCount.None,
			Flags = TextureFlags.DepthStencil,
			Type = TextureType.Texture2D
		};
		Texture depthTexture = graphicsContext.Factory.CreateTexture(depth);
		DepthStencilTarget = FrameBufferAttachment(depthTexture, 0, 1);
		if (ColorTargets.Count != 0)
		{
			ref FrameBufferAttachment target = ref ColorTargets[0];
			base.Width = target.AttachmentTexture.Description.Width;
			base.Height = target.AttachmentTexture.Description.Height;
			base.ArraySize = target.AttachmentTexture.Description.ArraySize;
			base.SampleCount = target.AttachmentTexture.Description.SampleCount;
		}
		else if (DepthStencilTarget.HasValue)
		{
			TextureDescription? depthDescription = DepthStencilTarget?.AttachmentTexture.Description;
			if (depthDescription.HasValue)
			{
				base.Width = depthDescription.Value.Width;
				base.Height = depthDescription.Value.Height;
				base.ArraySize = depthDescription.Value.ArraySize;
				base.SampleCount = depthDescription.Value.SampleCount;
			}
		}
		DepthTargetTexture = depthTexture as DX12Texture;
		DepthTargetview = DepthTargetTexture.GetDepthStencilView(0, depthTexture.Description.ArraySize, 0);
		BackBuffers = new D3D12_CPU_DESCRIPTOR_HANDLE[swapChainBufferCount];
		BackBufferTextures = new DX12Texture[swapChainBufferCount];
		for (int32 i = 0; i < BackBuffers.Count; i++)
		{
			FrameBufferAttachment colorTarget = ColorTargets[i];
			DX12Texture colorTexture = colorTarget.AttachmentTexture as DX12Texture;
			BackBufferTextures[i] = colorTexture;
			BackBuffers[i] = colorTexture.GetRenderTargetView(colorTarget.FirstSlice, colorTarget.SliceCount, colorTarget.MipSlice);
		}
		base.OutputDescription = /*OutputDescription*/.CreateFromFrameBuffer(this);
	}

	public ~this()
	{
		for(int i = 0; i < BackBufferTextures.Count; i++)
		{
			BackBufferTextures[i].Dispose();
			delete BackBufferTextures[i];
		}
		delete BackBufferTextures;

		delete BackBuffers;

		DepthTargetTexture?.Dispose();
		delete DepthTargetTexture;
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	protected override void Dispose(bool disposing)
	{
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			for (int32 i = 0; i < BackBuffers.Count; i++)
			{
				graphicsContext.RenderTargetViewAllocator.Free(BackBuffers[i]);
			}
			graphicsContext.DepthStencilViewAllocator.Free(DepthTargetview);
		}
		disposed = true;
	}
}
