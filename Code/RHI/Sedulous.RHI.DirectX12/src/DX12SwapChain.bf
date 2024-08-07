using System;
using Sedulous.RHI;
using Win32.Graphics.Dxgi;
using Win32;
using Win32.Foundation;
using Sedulous.Platform;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// This class represents a native swapchain object on DirectX12.
/// </summary>
public class DX12SwapChain : SwapChain
{
	/// <summary>
	/// A default number of buffer in the swapchain.
	/// </summary>
	public const int32 SwapChainBufferCount = 3;

	/// <summary>
	/// The DirectX SwapChain instance.
	/// </summary>
	internal IDXGISwapChain3* nativeSwapChain;

	internal uint32 swapInterval;

	internal DX12Texture[] swapChainBuffers ~ delete _;

	private int32 currentBackBufferIndex;

	private String name = new .() ~ delete _;

	/// <summary>
	/// Gets or sets the active backbuffer index.
	/// </summary>
	public int32 CurrentBackBufferIndex
	{
		get
		{
			return currentBackBufferIndex;
		}
		set
		{
			currentBackBufferIndex = value;
			(base.FrameBuffer as DX12SwapChainFrameBuffer).CurrentBackBufferIndex = value;
		}
	}

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
	public override void* NativeSwapChainPointer => nativeSwapChain;

	/// <inheritdoc />
	public override Texture GetCurrentFramebufferTexture()
	{
		return swapChainBuffers[CurrentBackBufferIndex];
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12SwapChain" /> class.
	/// </summary>
	/// <param name="context">Graphics Context.</param>
	/// <param name="description">SwapChain description.</param>
	public this(GraphicsContext context, Sedulous.RHI.SwapChainDescription description)
	{
		GraphicsContext = context;
		swapChainBuffers = new DX12Texture[3];
		nativeSwapChain?.Release();
		base.SwapChainDescription = description;
		if (description.SurfaceInfo.Type == .WinUI)
		{
			DXGI_SWAP_CHAIN_DESC1 swapChainDescription = .()
			{
				Width = description.Width,
				Height = description.Height,
				Format = description.ColorTargetFormat.ToDirectX(),
				Scaling = .DXGI_SCALING_STRETCH,
				Flags = (.)DXGI_SWAP_CHAIN_FLAG.DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH,
				SampleDesc = description.SampleCount.ToDirectX(),
				BufferUsage = (DXGI_USAGE_RENDER_TARGET_OUTPUT | DXGI_USAGE_BACK_BUFFER),
				BufferCount = 3,
				SwapEffect = .DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL,
				Stereo = FALSE
			};
			IDXGISwapChain1* swapChain1 = null;
			((DX12GraphicsContext)context).DXFactory.CreateSwapChainForComposition(((DX12GraphicsContext)context).DefaultGraphicsQueue.CommandQueue, &swapChainDescription, null, &swapChain1);
			nativeSwapChain = swapChain1.QueryInterface<IDXGISwapChain3>();
		}
		else
		{
			DXGI_SWAP_CHAIN_DESC1 swapChainDescription = .()
			{
				Width = description.Width,
				Height = description.Height,
				Format = description.ColorTargetFormat.ToDirectX(),
				Scaling = .DXGI_SCALING_NONE,
				Flags = (.)DXGI_SWAP_CHAIN_FLAG.DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH,
				SampleDesc = description.SampleCount.ToDirectX(),
				BufferUsage = (DXGI_USAGE_RENDER_TARGET_OUTPUT | DXGI_USAGE_BACK_BUFFER),
				BufferCount = 3,
				SwapEffect = .DXGI_SWAP_EFFECT_FLIP_DISCARD,
				Stereo = FALSE
			};
			DXGI_SWAP_CHAIN_FULLSCREEN_DESC fullScreenDescription = .()
			{
				RefreshRate = .(description.RefreshRate, 1),
				Windowed = description.IsWindowed ? TRUE : FALSE,
				Scaling = .DXGI_MODE_SCALING_UNSPECIFIED,
				ScanlineOrdering = .DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED
			};
			IDXGISwapChain1* swapChain1 = null;
			((DX12GraphicsContext)context).DXFactory.CreateSwapChainForHwnd(((DX12GraphicsContext)context).DefaultGraphicsQueue.CommandQueue, (int)description.SurfaceInfo.Win32.Hwnd, &swapChainDescription, &fullScreenDescription, null, &swapChain1);
			nativeSwapChain = swapChain1.QueryInterface<IDXGISwapChain3>();
		}
		DX12SwapChainFrameBuffer frameBuffer = new DX12SwapChainFrameBuffer(GraphicsContext as DX12GraphicsContext, this);
		if (base.FrameBuffer != null)
		{
			frameBuffer.IntermediateBufferAssociated = base.FrameBuffer.IntermediateBufferAssociated;
		}
		base.FrameBuffer = frameBuffer;
		CurrentBackBufferIndex = (int32)nativeSwapChain.GetCurrentBackBufferIndex();
	}

	/// <inheritdoc />
	public override void ResizeSwapChain(uint32 width, uint32 height)
	{
		(GraphicsContext as DX12GraphicsContext).DefaultGraphicsQueue.WaitIdle();
		base.FrameBuffer.Dispose();
		for (int32 i = 0; i < swapChainBuffers.Count; i++)
		{
			swapChainBuffers[i].NativeTexture.Release();
		}
		HRESULT result = nativeSwapChain.ResizeBuffers(3, width, height, nativeSwapChain.GetDesc(.. scope .()).BufferDesc.Format, /*SwapChainFlags.None*/0);
		if (SUCCEEDED(result))
		{
			Sedulous.RHI.SwapChainDescription copyDescription = base.SwapChainDescription;
			copyDescription.Width = width;
			copyDescription.Height = height;
			base.SwapChainDescription = copyDescription;
			base.FrameBuffer = new DX12SwapChainFrameBuffer(GraphicsContext as DX12GraphicsContext, this);
			CurrentBackBufferIndex = (int32)nativeSwapChain.GetCurrentBackBufferIndex();
		}
		else
		{
			GraphicsContext.ValidationLayer?.Notify("DX12", result.ToString(.. scope .()));
		}
	}

	/// <inheritdoc />
	public override void RefreshSurfaceInfo(SurfaceInfo surfaceInfo)
	{
	}

	/// <inheritdoc />
	public override void Present()
	{
		swapInterval = (VerticalSync ? 1 : 0);
		nativeSwapChain.Present(swapInterval, /*PresentFlags.None*/0);
		CurrentBackBufferIndex = (int32)nativeSwapChain.GetCurrentBackBufferIndex();
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				base.FrameBuffer?.Dispose();
				if(base.FrameBuffer != null)
				{
					delete base.FrameBuffer;
					base.FrameBuffer = null;
				}
				nativeSwapChain?.Release();
			}
			disposed = true;
		}
	}
}
