using Win32.Graphics.Direct3D11;
using System;
using Win32.Graphics.Dxgi;
using System.Threading;
using System.Collections;
using Win32.Graphics.Direct3D;
using Win32.Graphics.Dxgi.Common;
using Win32.Foundation;
using Win32;
using Win32.System.Com;
using Win32.System.WinRT.Xaml;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    public class D3D11Swapchain : Swapchain
    {
        private readonly D3D11GraphicsDevice _gd;
        private readonly PixelFormat? _depthFormat;
        private readonly IDXGISwapChain* _dxgiSwapChain;
        private bool _vsync;
        private int32 _syncInterval;
        private D3D11Framebuffer _framebuffer;
        private D3D11Texture _depthTexture;
        private float _pixelScale = 1f;
        private bool _disposed;

        private readonly Monitor _referencedCLsLock = new .() ~ delete _;
        private HashSet<D3D11CommandList> _referencedCLs = new .();

        public override Framebuffer Framebuffer => _framebuffer;

		private String mName = new .() ~ delete _;

        public override String Name
        {
            get
            {
                char8[] pname = scope .[1024];
                uint32 size = 1024 - 1;
                _dxgiSwapChain.GetPrivateData(WKPDID_D3DDebugObjectName, &size, pname.Ptr);
                pname[size] = '\0';
                mName.Set(scope .(pname.Ptr));
				return mName;
            }
            set
            {
                if (String.IsNullOrEmpty(value))
                {
                    _dxgiSwapChain.SetPrivateData(WKPDID_D3DDebugObjectName, 0, null);
                }
                else
                {
                    _dxgiSwapChain.SetPrivateData(WKPDID_D3DDebugObjectName, (uint32)value.Length, value.Ptr);
                }
            }
        }

        public override bool SyncToVerticalBlank
        {
            get => _vsync; set
            {
                _vsync = value;
                _syncInterval = D3D11Util.GetSyncInterval(value);
            }
        }

        private readonly DXGI_FORMAT _colorFormat;

        public IDXGISwapChain* DxgiSwapChain => _dxgiSwapChain;

        public int32 SyncInterval => _syncInterval;

        public this(D3D11GraphicsDevice gd, in SwapchainDescription description)
        {
            _gd = gd;
            _depthFormat = description.DepthFormat;
            SyncToVerticalBlank = description.SyncToVerticalBlank;

            _colorFormat = description.ColorSrgb
                ? .DXGI_FORMAT_B8G8R8A8_UNORM_SRGB
				: .DXGI_FORMAT_B8G8R8A8_UNORM;

            if (let win32Source= description.Source as Win32SwapchainSource)
            {
                DXGI_SWAP_CHAIN_DESC dxgiSCDesc = DXGI_SWAP_CHAIN_DESC()
                {
				    BufferCount = 2,
				    Windowed = TRUE,
				    BufferDesc = .() {
				        Width = description.Width,
						Height = description.Height,
						Format = _colorFormat,
						RefreshRate = .(){
							Numerator = 60,
							Denominator = 1},
						ScanlineOrdering = .DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED,
						Scaling = .DXGI_MODE_SCALING_UNSPECIFIED,
					},
				    OutputWindow = (int)win32Source.Hwnd,
				    SampleDesc = .(1, 0),
				    SwapEffect = .DXGI_SWAP_EFFECT_DISCARD,
				    BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT
				};

                IDXGIFactory* dxgiFactory = null;
				HRESULT hr = _gd.Adapter.GetParent(IDXGIFactory.IID, (void**)&dxgiFactory);
				defer dxgiFactory.Release();
                {
                    hr = dxgiFactory.CreateSwapChain(_gd.Device, &dxgiSCDesc, &_dxgiSwapChain);
					dxgiFactory.MakeWindowAssociation((int)win32Source.Hwnd, DXGI_MWA_NO_ALT_ENTER);
                }
            }
            else if (let uwpSource = description.Source as UwpSwapchainSource)
            {
                _pixelScale = uwpSource.LogicalDpi / 96.0f;

                // Properties of the swap chain
                DXGI_SWAP_CHAIN_DESC1 swapChainDescription = DXGI_SWAP_CHAIN_DESC1()
                {
				    AlphaMode = .DXGI_ALPHA_MODE_IGNORE,
				    BufferCount = 2,
				    Format = _colorFormat,
				    Height = (uint32)(description.Height * _pixelScale),
				    Width = (uint32)(description.Width * _pixelScale),
				    SampleDesc = .(1, 0),
				    SwapEffect = .DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL,
				    BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT,
				};

                // Get the Vortice.DXGI factory automatically created when initializing the Direct3D device.
                IDXGIFactory2* dxgiFactory = null;
				HRESULT hr = _gd.Adapter.GetParent(IDXGIFactory2.IID, (void**)&dxgiFactory);
				defer dxgiFactory.Release();
                {
                    // Create the swap chain and get the highest version available.
                    IDXGISwapChain1* swapChain1 = null;
					hr = dxgiFactory.CreateSwapChainForComposition(_gd.Device, &swapChainDescription, null, &swapChain1);
					defer swapChain1.Release();
                    {
                        _dxgiSwapChain = swapChain1.QueryInterface<IDXGISwapChain2>();
                    }
                }

                IUnknown* co = (IUnknown*)uwpSource.SwapChainPanelNative;

                ISwapChainPanelNative* swapchainPanelNative = co.QueryInterface<ISwapChainPanelNative>();
                if (swapchainPanelNative != null)
                {
                    swapchainPanelNative.SetSwapChain(_dxgiSwapChain);
                }
                else
                {
                    ISwapChainBackgroundPanelNative* bgPanelNative = co.QueryInterface<ISwapChainBackgroundPanelNative>();
                    if (bgPanelNative != null)
                    {
                        bgPanelNative.SetSwapChain(_dxgiSwapChain);
                    }
                }
            }

            Resize(description.Width, description.Height);
        }

        public override void Resize(uint32 width, uint32 height)
        {
            using (_referencedCLsLock.Enter())
            {
                for (D3D11CommandList cl in _referencedCLs)
                {
                    cl.Reset();
                }

                _referencedCLs.Clear();
            }

            bool resizeBuffers = false;

            if (_framebuffer != null)
            {
                resizeBuffers = true;
                if (_depthTexture != null)
                {
                    _depthTexture.Dispose();
                }

                _framebuffer.Dispose();
            }

            uint32 actualWidth = (uint32)(width * _pixelScale);
            uint32 actualHeight = (uint32)(height * _pixelScale);
            if (resizeBuffers)
            {
                HRESULT hr = _dxgiSwapChain.ResizeBuffers(2, actualWidth, actualHeight, _colorFormat, 0);
				if(hr != S_OK){
					Runtime.FatalError("Buffer resize failed.");
				}
            }

            // Get the backbuffer from the swapchain
            ID3D11Texture2D* backBufferTexture = null;
			HRESULT hr = _dxgiSwapChain.GetBuffer(0, ID3D11Texture2D.IID, (void**)&backBufferTexture);
			defer backBufferTexture.Release();
            {
                if (_depthFormat != null)
                {
                    TextureDescription depthDesc = TextureDescription(
                        actualWidth, actualHeight, 1, 1, 1,
                        _depthFormat.Value,
                        TextureUsage.DepthStencil,
                        TextureType.Texture2D);
                    _depthTexture = new D3D11Texture(_gd.Device, depthDesc);
                }

                D3D11Texture backBufferVdTexture = new D3D11Texture(
                    backBufferTexture,
                    TextureType.Texture2D,
                    D3D11Formats.ToVdFormat(_colorFormat));

                FramebufferDescription desc = FramebufferDescription(_depthTexture, backBufferVdTexture);
                _framebuffer = new D3D11Framebuffer(_gd.Device, desc)
                {
                    Swapchain = this
                };
            }
        }

        public void AddCommandListReference(D3D11CommandList cl)
        {
            using (_referencedCLsLock.Enter())
            {
                _referencedCLs.Add(cl);
            }
        }

        public void RemoveCommandListReference(D3D11CommandList cl)
        {
            using (_referencedCLsLock.Enter())
            {
                _referencedCLs.Remove(cl);
            }
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            if (!_disposed)
            {
                _depthTexture?.Dispose();
                _framebuffer.Dispose();
                _dxgiSwapChain.Release();

                _disposed = true;
            }
        }
    }
}
