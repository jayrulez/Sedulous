using System;
using Win32.Graphics.Direct3D11;
using Win32.Foundation;
using Sedulous.Foundation.Collections;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    public class D3D11Framebuffer : Framebuffer
    {
        private String _name;
        private bool _disposed;

        public ref FixedList<ID3D11RenderTargetView*, const 8> RenderTargetViews { get; }
        public ref ID3D11DepthStencilView* DepthStencilView { get; }

        // Only non-null if this is the Framebuffer for a Swapchain.
        internal D3D11Swapchain Swapchain { get; set; }

        public override bool IsDisposed => _disposed;

        public this(ID3D11Device* device, in FramebufferDescription description)
            : base(description.DepthTarget, description.ColorTargets)
        {
            if (description.DepthTarget != null)
            {
                D3D11Texture d3dDepthTarget = Util.AssertSubtype<Texture, D3D11Texture>(description.DepthTarget.Value.Target);
                D3D11_DEPTH_STENCIL_VIEW_DESC dsvDesc = D3D11_DEPTH_STENCIL_VIEW_DESC()
                {
                    Format = D3D11Formats.GetDepthFormat(d3dDepthTarget.Format),
                };
                if (d3dDepthTarget.ArrayLayers == 1)
                {
                    if (d3dDepthTarget.SampleCount == TextureSampleCount.Count1)
                    {
                        dsvDesc.ViewDimension = .D3D11_DSV_DIMENSION_TEXTURE2D;
                        dsvDesc.Texture2D.MipSlice = description.DepthTarget.Value.MipLevel;
                    }
                    else
                    {
                        dsvDesc.ViewDimension = .D3D11_DSV_DIMENSION_TEXTURE2DMS;
                    }
                }
                else
                {
                    if (d3dDepthTarget.SampleCount == TextureSampleCount.Count1)
                    {
                        dsvDesc.ViewDimension = .D3D11_DSV_DIMENSION_TEXTURE2DARRAY;
                        dsvDesc.Texture2DArray.FirstArraySlice = description.DepthTarget.Value.ArrayLayer;
                        dsvDesc.Texture2DArray.ArraySize = 1;
                        dsvDesc.Texture2DArray.MipSlice = description.DepthTarget.Value.MipLevel;
                    }
                    else
                    {
                        dsvDesc.ViewDimension = .D3D11_DSV_DIMENSION_TEXTURE2DMSARRAY;
                        dsvDesc.Texture2DMSArray.FirstArraySlice = description.DepthTarget.Value.ArrayLayer;
                        dsvDesc.Texture2DMSArray.ArraySize = 1;
                    }
                }

                HRESULT hr = device.CreateDepthStencilView(d3dDepthTarget.DeviceTexture, &dsvDesc, &DepthStencilView);
            }

            if (/*description.ColorTargets != null &&*/ description.ColorTargets.Count > 0)
            {
                RenderTargetViews = .() {Count = description.ColorTargets.Count};
                for (int32 i = 0; i < RenderTargetViews.Count; i++)
                {
                    D3D11Texture d3dColorTarget = Util.AssertSubtype<Texture, D3D11Texture>(description.ColorTargets[i].Target);
                    D3D11_RENDER_TARGET_VIEW_DESC rtvDesc = D3D11_RENDER_TARGET_VIEW_DESC()
                    {
                        Format = D3D11Formats.ToDxgiFormat(d3dColorTarget.Format, false),
                    };
                    if (d3dColorTarget.ArrayLayers > 1 || (d3dColorTarget.Usage & TextureUsage.Cubemap) != 0)
                    {
                        if (d3dColorTarget.SampleCount == TextureSampleCount.Count1)
                        {
                            rtvDesc.ViewDimension = .D3D11_RTV_DIMENSION_TEXTURE2DARRAY;
                            rtvDesc.Texture2DArray = .()
                            {
                                ArraySize = 1,
                                FirstArraySlice = description.ColorTargets[i].ArrayLayer,
                                MipSlice = description.ColorTargets[i].MipLevel
                            };
                        }
                        else
                        {
                            rtvDesc.ViewDimension = .D3D11_RTV_DIMENSION_TEXTURE2DMSARRAY;
                            rtvDesc.Texture2DMSArray = .()
                            {
                                ArraySize = 1,
                                FirstArraySlice = description.ColorTargets[i].ArrayLayer
                            };
                        }
                    }
                    else
                    {
                        if (d3dColorTarget.SampleCount == TextureSampleCount.Count1)
                        {
                            rtvDesc.ViewDimension = .D3D11_RTV_DIMENSION_TEXTURE2D;
                            rtvDesc.Texture2D.MipSlice = description.ColorTargets[i].MipLevel;
                        }
                        else
                        {
                            rtvDesc.ViewDimension = .D3D11_RTV_DIMENSION_TEXTURE2DMS;
                        }
                    }
                    HRESULT hr = device.CreateRenderTargetView(d3dColorTarget.DeviceTexture, &rtvDesc, &RenderTargetViews[i]);
                }
            }
            else
            {
                RenderTargetViews = .();
            }
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                for (int32 i = 0; i < RenderTargetViews.Count; i++)
                {
                    D3D11Util.SetDebugName(RenderTargetViews[i], scope $"{value}_RTV{i}");
                }
                if (DepthStencilView != null)
                {
                    D3D11Util.SetDebugName(DepthStencilView, scope $"{value}_DSV");
                }
            }
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                DepthStencilView?.Release();
                for (ID3D11RenderTargetView* rtv in RenderTargetViews)
                {
                    rtv.Release();
                }

                _disposed = true;
            }
        }
    }
}
