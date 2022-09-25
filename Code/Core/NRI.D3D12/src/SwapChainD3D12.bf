using NRI.D3DCommon;
using Win32.Graphics.Direct3D12;
using System.Collections;
using Win32.Graphics.Dxgi;
using Win32.Graphics.Dxgi.Common;
using Win32.Foundation;
using System;
using Win32;
namespace NRI.D3D12;

public static
{
	public const DXGI_FORMAT[5] g_SwapChainFormat =
		.(
		.DXGI_FORMAT_R8G8B8A8_UNORM, // BT709_G10_8BIT,
		.DXGI_FORMAT_R16G16B16A16_FLOAT, // BT709_G10_16BIT,
		.DXGI_FORMAT_R8G8B8A8_UNORM, // BT709_G22_8BIT,
		.DXGI_FORMAT_R10G10B10A2_UNORM, // BT709_G22_10BIT,
		.DXGI_FORMAT_R10G10B10A2_UNORM // BT2020_G2084_10BIT
		);

	public const DXGI_COLOR_SPACE_TYPE[5] g_ColorSpace =
		.(
		.DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709, // BT709_G10_8BIT,
		.DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709, // BT709_G10_16BIT,
		.DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709, // BT709_G22_8BIT,
		.DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709, // BT709_G22_10BIT,
		.DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020 // BT2020_G2084_10BIT
		);

	public const Format[5] g_SwapChainTextureFormat =
		.(
		Format.RGBA8_SRGB, // BT709_G10_8BIT,
		Format.RGBA16_SFLOAT, // BT709_G10_16BIT,
		Format.RGBA8_UNORM, // BT709_G22_8BIT,
		Format.R10_G10_B10_A2_UNORM, // BT709_G22_10BIT,
		Format.R10_G10_B10_A2_UNORM // BT2020_G2084_10BIT
		);
}

class SwapChainD3D12 : SwapChain
{
	private DeviceD3D12 m_Device;
	private ComPtr<IDXGISwapChain4> m_SwapChain;
	private ComPtr<ID3D12CommandQueue> m_CommandQueue;
	private List<TextureD3D12> m_Textures;
	private List<Texture> m_TexturePointer;
	private Format m_Format = Format.UNKNOWN;
	private bool m_IsTearingAllowed = false;
	private bool m_IsFullscreenEnabled = false;

	private SwapChainDesc m_SwapChainDesc = .();


	public this(DeviceD3D12 device)
	{
		m_Device = device;

		m_Textures = Allocate!<List<TextureD3D12>>(m_Device.GetAllocator());
		m_TexturePointer = Allocate!<List<Texture>>(m_Device.GetAllocator());
	}

	public ~this()
	{
		if (m_IsFullscreenEnabled)
		{
			BOOL fullscreen = FALSE;
			m_SwapChain->GetFullscreenState(&fullscreen, null);
			if (fullscreen != 0)
				m_SwapChain->SetFullscreenState( FALSE, null);
		}

		Deallocate!(m_Device.GetAllocator(), m_TexturePointer);

		for (var texture in m_Textures)
		{
			delete texture;
		}

		Deallocate!(m_Device.GetAllocator(), m_Textures);

		m_CommandQueue.Dispose();
		m_SwapChain.Dispose();
	}

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(SwapChainDesc swapChainDesc)
	{
		var swapChainDesc;
		ID3D12Device* device = m_Device;

		ComPtr<IDXGIFactory4> factory = default;
		defer factory.Dispose();

		HRESULT hr = CreateDXGIFactory2(0, IDXGIFactory4.IID, (void**)(&factory));
		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "CreateDXGIFactory2(), error code: 0x{0:X}.", hr);

		ComPtr<IDXGIAdapter> adapter = default;
		defer adapter.Dispose();

		hr = factory->EnumAdapterByLuid(device.GetAdapterLuid(), IDXGIAdapter.IID, (void**)(&adapter));
		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "IDXGIFactory4.EnumAdapterByLuid(), error code: 0x{0:X}.", hr);

		m_IsTearingAllowed = false;

		ComPtr<IDXGIFactory5> dxgiFactory5 = default;
		defer dxgiFactory5.Dispose();

		hr = factory->QueryInterface(IDXGIFactory5.IID, (void**)(&dxgiFactory5));
		if (SUCCEEDED(hr))
		{
			uint32 tearingSupport = 0;
			hr = dxgiFactory5->CheckFeatureSupport(.DXGI_FEATURE_PRESENT_ALLOW_TEARING, &tearingSupport, sizeof(decltype(tearingSupport)));
			m_IsTearingAllowed = (SUCCEEDED(hr) && tearingSupport > 0) ? true : false;
		}

		CommandQueue commandQueue = null;
		if (m_Device.GetCommandQueue(CommandQueueType.GRAPHICS, out commandQueue) != Result.SUCCESS)
			return Result.FAILURE;

		CommandQueueD3D12 commandQueueD3D12 = (CommandQueueD3D12)commandQueue;

		DXGI_FORMAT format = g_SwapChainFormat[(uint32)swapChainDesc.format];
		DXGI_COLOR_SPACE_TYPE colorSpace = g_ColorSpace[(uint32)swapChainDesc.format];

		readonly HWND window = (HWND)swapChainDesc.window.windows.hwnd;

		if (window == 0)
			return Result.INVALID_ARGUMENT;

		DXGI_SWAP_CHAIN_DESC1 swapChainDesc1 = .();
		swapChainDesc1.BufferCount = swapChainDesc.textureNum;
		swapChainDesc1.Width = swapChainDesc.width;
		swapChainDesc1.Height = swapChainDesc.height;
		swapChainDesc1.Format = format;
		swapChainDesc1.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
		swapChainDesc1.SwapEffect = .DXGI_SWAP_EFFECT_FLIP_DISCARD;
		swapChainDesc1.SampleDesc.Count = 1;
		swapChainDesc1.Flags = m_IsTearingAllowed ? (.)DXGI_SWAP_CHAIN_FLAG.DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING : 0;
		swapChainDesc1.Scaling = .DXGI_SCALING_NONE;

		ComPtr<IDXGISwapChain1> swapChain = default;
		defer swapChain.Dispose();
		hr = factory->CreateSwapChainForHwnd((ID3D12CommandQueue*)commandQueueD3D12, window, &swapChainDesc1, null, null, swapChain.GetAddressOf());
		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "IDXGIFactory2.CreateSwapChainForHwnd() failed, error code: 0x{0:X}.", hr);

		hr = factory->MakeWindowAssociation(window, DXGI_MWA_NO_ALT_ENTER);
		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "CreateSwapChainForHwnd.MakeWindowAssociation() failed, error code: 0x{0:X}.", hr);

		hr = swapChain->QueryInterface(__uuidof(m_SwapChain), (void**)m_SwapChain.GetAddressOf());
		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "IDXGISwapChain1.QueryInterface() failed, error code: 0x{0:X}.", hr);

		uint32 colorSpaceSupport = 0;
		hr = m_SwapChain->CheckColorSpaceSupport(colorSpace, &colorSpaceSupport);

		if (!(colorSpaceSupport & (.)DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG.DXGI_SWAP_CHAIN_COLOR_SPACE_SUPPORT_FLAG_PRESENT != 0))
			hr = E_FAIL;

		if (SUCCEEDED(hr))
			hr = m_SwapChain->SetColorSpace1(colorSpace);

		if (FAILED(hr))
			REPORT_ERROR(m_Device.GetLogger(), "IDXGISwapChain3.SetColorSpace1() failed, error code: 0x{0:X}.", hr);

		if (swapChainDesc.display != null)
		{
			using (ComPtr<IDXGIOutput> output = default)
			{
				if (!m_Device.GetOutput(ref swapChainDesc.display, ref output))
				{
					REPORT_ERROR(m_Device.GetLogger(), "Failed to get IDXGIOutput for the specified display.");
					return Result.UNSUPPORTED;
				}
			}

			hr = m_SwapChain->SetFullscreenState(TRUE, null);
			RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "IDXGISwapChain1.SetFullscreenState() failed, error code: 0x{0:X}.", hr);

			hr = m_SwapChain->ResizeBuffers(swapChainDesc1.BufferCount, swapChainDesc1.Width, swapChainDesc1.Height, swapChainDesc1.Format, swapChainDesc1.Flags);
			RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), hr, "IDXGISwapChain1.ResizeBuffers() failed, error code: 0x{0:X}.", hr);

			m_IsTearingAllowed = false;
			m_IsFullscreenEnabled = true;
		}

		m_SwapChainDesc = swapChainDesc;

		m_Format = g_SwapChainTextureFormat[(uint32)swapChainDesc.format];
		for (uint32 i = 0; i < swapChainDesc.textureNum; i++)
		{
			using (ComPtr<ID3D12Resource> resource = default)
			{
				hr = m_SwapChain->GetBuffer(i, ID3D12Resource.IID, (void**)(&resource));
				if (FAILED(hr))
				{
					REPORT_ERROR(m_Device.GetLogger(), "IDXGISwapChain4.GetBuffer() failed, error code: 0x{0:X}.", hr);
					return Result.FAILURE;
				}

				m_Textures.Add(new .(m_Device));
				m_Textures[i].Initialize(resource);
			}
		}

		m_TexturePointer.Resize(swapChainDesc.textureNum);
		for (uint32 i = 0; i < swapChainDesc.textureNum; i++)
			m_TexturePointer[i] = (Texture)m_Textures[i];

		m_CommandQueue = (ID3D12CommandQueue*)commandQueueD3D12;

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_SwapChain, scope String(name));
	}

	public Texture* GetTextures(ref uint32 textureNum, ref Format format)
	{
		textureNum = (uint32)m_TexturePointer.Count;
		format = m_Format;

		return m_TexturePointer.Ptr;
	}

	public uint32 AcquireNextTexture(ref QueueSemaphore textureReadyForRender)
	{
		((QueueSemaphoreD3D12)textureReadyForRender).Signal(m_CommandQueue);

		return m_SwapChain->GetCurrentBackBufferIndex();
	}

	public Result Present(QueueSemaphore textureReadyForPresent)
	{
		((QueueSemaphoreD3D12)textureReadyForPresent).Wait(m_CommandQueue);

		BOOL fullscreen = FALSE;
		m_SwapChain->GetFullscreenState(&fullscreen, null);
		if (fullscreen != BOOL(m_IsFullscreenEnabled ? 1 : 0))
			return Result.SWAPCHAIN_RESIZE;

		uint32 flags = (m_SwapChainDesc.verticalSyncInterval == 0 && m_IsTearingAllowed) ? DXGI_PRESENT_ALLOW_TEARING : 0;

		readonly HRESULT result = m_SwapChain->Present(m_SwapChainDesc.verticalSyncInterval, flags);

		RETURN_ON_BAD_HRESULT!(m_Device.GetLogger(), result, "Can't present the swapchain: IDXGISwapChain.Present() returned {0}.", (int32)result);

		return Result.SUCCESS;
	}

	public Result SetHdrMetadata(HdrMetadata hdrMetadata)
	{
		DXGI_HDR_METADATA_HDR10 data = .();
		data.RedPrimary[0] = uint16(hdrMetadata.displayPrimaryRed[0] * 50000.0f);
		data.RedPrimary[1] = uint16(hdrMetadata.displayPrimaryRed[1] * 50000.0f);
		data.GreenPrimary[0] = uint16(hdrMetadata.displayPrimaryGreen[0] * 50000.0f);
		data.GreenPrimary[1] = uint16(hdrMetadata.displayPrimaryGreen[1] * 50000.0f);
		data.BluePrimary[0] = uint16(hdrMetadata.displayPrimaryBlue[0] * 50000.0f);
		data.BluePrimary[1] = uint16(hdrMetadata.displayPrimaryBlue[1] * 50000.0f);
		data.WhitePoint[0] = uint16(hdrMetadata.whitePoint[0] * 50000.0f);
		data.WhitePoint[1] = uint16(hdrMetadata.whitePoint[1] * 50000.0f);
		data.MaxMasteringLuminance = uint32(hdrMetadata.luminanceMax);
		data.MinMasteringLuminance = uint32(hdrMetadata.luminanceMin);
		data.MaxContentLightLevel = uint16(hdrMetadata.contentLightLevelMax);
		data.MaxFrameAverageLightLevel = uint16(hdrMetadata.frameAverageLightLevelMax);

		HRESULT hr = m_SwapChain->SetHDRMetaData(.DXGI_HDR_METADATA_TYPE_HDR10, sizeof(DXGI_HDR_METADATA_HDR10), &data);
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "IDXGISwapChain4.SetHDRMetaData() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}
}