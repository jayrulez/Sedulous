using Win32.Graphics.Direct3D11;
using System;
using System.Diagnostics;
using System.Threading;
using Win32.Graphics.Dxgi;
using System.Collections;
using Win32.Foundation;
using Win32.Graphics.Direct3D;
using Win32;
using Win32.Graphics.Dxgi.Common;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;

    public class D3D11GraphicsDevice : GraphicsDevice
    {
        private readonly IDXGIAdapter* _dxgiAdapter;
        private readonly ID3D11Device* _device;
        private readonly String _deviceName;
        private readonly String _vendorName;
        private readonly GraphicsApiVersion _apiVersion;
        private readonly int32 _deviceId;
        private readonly ID3D11DeviceContext* _immediateContext;
        private readonly D3D11ResourceFactory _d3d11ResourceFactory;
        private readonly D3D11Swapchain _mainSwapchain;
        private readonly bool _supportsConcurrentResources;
        private readonly bool _supportsCommandLists;
        private readonly Monitor _immediateContextLock = new .() ~ delete _;
        private readonly BackendInfoD3D11 _d3d11Info;

        private readonly Monitor _mappedResourceLock = new .() ~ delete _;
        private readonly Dictionary<MappedResourceCacheKey, MappedResourceInfo> _mappedResources = new .() ~ delete _;

        private readonly Monitor _stagingResourcesLock = new .() ~ delete _;
        private readonly List<D3D11Buffer> _availableStagingBuffers = new List<D3D11Buffer>();

        public override String DeviceName => _deviceName;

        public override String VendorName => _vendorName;

        public override GraphicsApiVersion ApiVersion => _apiVersion;

        public override GraphicsBackend BackendType => GraphicsBackend.Direct3D11;

        public override bool IsUvOriginTopLeft => true;

        public override bool IsDepthRangeZeroToOne => true;

        public override bool IsClipSpaceYInverted => false;

        public override ResourceFactory ResourceFactory { get => _d3d11ResourceFactory; protected set {}}

        public ID3D11Device* Device => _device;

        public IDXGIAdapter* Adapter => _dxgiAdapter;

        public bool IsDebugEnabled { get; }

        public bool SupportsConcurrentResources => _supportsConcurrentResources;

        public bool SupportsCommandLists => _supportsCommandLists;

        public int32 DeviceId => _deviceId;

        public override Swapchain MainSwapchain => _mainSwapchain;

        public override GraphicsDeviceFeatures Features { get; protected set; }

        public this(GraphicsDeviceOptions options, D3D11DeviceOptions d3D11DeviceOptions, SwapchainDescription? swapchainDesc)
            : this(MergeOptions(d3D11DeviceOptions, options), swapchainDesc)
        {
        }

        public this(D3D11DeviceOptions options, SwapchainDescription? swapchainDesc)
        {
            var flags = (D3D11_CREATE_DEVICE_FLAG)options.DeviceCreationFlags;
#if DEBUG
            flags |= D3D11_CREATE_DEVICE_FLAG.D3D11_CREATE_DEVICE_DEBUG;
#endif
			bool sdkLayersAvailable = D3D11CreateDevice(null, .D3D_DRIVER_TYPE_NULL, 0, .D3D11_CREATE_DEVICE_DEBUG, null, 0, D3D11_SDK_VERSION, null, null, null) == S_OK;
            // If debug flag set but SDK layers aren't available we can't enable debug.
            if (0 != (flags & D3D11_CREATE_DEVICE_FLAG.D3D11_CREATE_DEVICE_DEBUG) && !sdkLayersAvailable)
            {
                flags &= ~D3D11_CREATE_DEVICE_FLAG.D3D11_CREATE_DEVICE_DEBUG;
            }

			HRESULT hr = S_OK;
            {
                if (options.AdapterPtr != null)
				{
				    hr = D3D11CreateDevice(options.AdapterPtr,
				        .D3D_DRIVER_TYPE_HARDWARE,
						0,
				        flags,
				        scope D3D_FEATURE_LEVEL[]*
				        (
				            .D3D_FEATURE_LEVEL_11_1,
				            .D3D_FEATURE_LEVEL_11_0,
				        ),
						2,
						0,
				        &_device,
						null,
						null);
				}
				else
				{
				    hr = D3D11CreateDevice(null,
				        .D3D_DRIVER_TYPE_HARDWARE,
						0,
				        flags,
				        scope D3D_FEATURE_LEVEL[]*
				        (
				            .D3D_FEATURE_LEVEL_11_1,
				            .D3D_FEATURE_LEVEL_11_0,
				        ),
						2,
						0,
				        &_device,
						null,
						null);
				}
            }
            if(hr != S_OK)
            {
                hr = D3D11CreateDevice(null,
				    .D3D_DRIVER_TYPE_HARDWARE,
					0,
				flags,
				null,
				0,
				0,
				&_device,
				null,
				null);
            }

            IDXGIDevice* dxgiDevice = _device.QueryInterface<IDXGIDevice>();
			defer dxgiDevice.Release();
            {
                // Store a pointer to the DXGI adapter.
                // This is for the case of no preferred DXGI adapter, or fallback to WARP.
                if(dxgiDevice.GetAdapter(&_dxgiAdapter) != S_OK){
					// todo: error?
				}

                DXGI_ADAPTER_DESC desc = .();
				_dxgiAdapter.GetDesc(&desc);
				_deviceName = new .(&desc.Description);
				_vendorName = new .(scope $"id:{desc.VendorId:x8}");
				_deviceId = (.)desc.DeviceId;
            }

            switch (_device.GetFeatureLevel())
			{
			    case .D3D_FEATURE_LEVEL_10_0:
			        _apiVersion = GraphicsApiVersion(10, 0, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_10_1:
			        _apiVersion = GraphicsApiVersion(10, 1, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_11_0:
			        _apiVersion = GraphicsApiVersion(11, 0, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_11_1:
			        _apiVersion = GraphicsApiVersion(11, 1, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_12_0:
			        _apiVersion = GraphicsApiVersion(12, 0, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_12_1:
			        _apiVersion = GraphicsApiVersion(12, 1, 0, 0);
			        break;

			    case .D3D_FEATURE_LEVEL_12_2:
			        _apiVersion = GraphicsApiVersion(12, 2, 0, 0);
			        break;
			default: break;
			}

            if (swapchainDesc != null)
            {
                SwapchainDescription desc = swapchainDesc.Value;
                _mainSwapchain = new D3D11Swapchain(this, desc);
            }
            _device.GetImmediateContext(&_immediateContext);
            (int32 DriverConcurrentCreates, int32 DriverCommandLists) threadingSupport = (0, 0);
			hr = _device.CheckFeatureSupport(.D3D11_FEATURE_THREADING, &threadingSupport, sizeof(decltype(threadingSupport)));
			if (hr < S_OK)
			{
				_supportsCommandLists = false;
				_supportsConcurrentResources = false;
			} else
			{
				_supportsCommandLists = threadingSupport.DriverCommandLists == TRUE;
				_supportsConcurrentResources = threadingSupport.DriverConcurrentCreates == TRUE;
			}

			IsDebugEnabled = (flags & (.)D3D11_CREATE_DEVICE_FLAG.D3D11_CREATE_DEVICE_DEBUG) != 0;

			D3D11_FEATURE_DATA_DOUBLES featureDouble = ?;
			hr = _device.CheckFeatureSupport(.D3D11_FEATURE_DOUBLES, &featureDouble, sizeof(D3D11_FEATURE_DATA_DOUBLES));

            Features = new GraphicsDeviceFeatures(
                computeShader: true,
                geometryShader: true,
                tessellationShaders: true,
                multipleViewports: true,
                samplerLodBias: true,
                drawBaseVertex: true,
                drawBaseInstance: true,
                drawIndirect: true,
                drawIndirectBaseInstance: true,
                fillModeWireframe: true,
                samplerAnisotropy: true,
                depthClipDisable: true,
                texture1D: true,
                independentBlend: true,
                structuredBuffer: true,
                subsetTextureView: true,
                commandListDebugMarkers: _device.GetFeatureLevel() >= .D3D_FEATURE_LEVEL_11_1,
                bufferRangeBinding: _device.GetFeatureLevel() >= .D3D_FEATURE_LEVEL_11_1,
                shaderFloat64: featureDouble.DoublePrecisionFloatShaderOps == TRUE);

            _d3d11ResourceFactory = new D3D11ResourceFactory(this);
            _d3d11Info = new BackendInfoD3D11(this);

            PostDeviceCreated();
        }

        private static D3D11DeviceOptions MergeOptions(D3D11DeviceOptions d3D11DeviceOptions, GraphicsDeviceOptions options)
        {
			var d3D11DeviceOptions;
            if (options.Debug)
            {
                d3D11DeviceOptions.DeviceCreationFlags |= (uint32)D3D11_CREATE_DEVICE_FLAG.D3D11_CREATE_DEVICE_DEBUG;
            }

            return d3D11DeviceOptions;
        }

        protected override void SubmitCommandsCore(CommandList cl, Fence fence)
        {
            D3D11CommandList d3d11CL = Util.AssertSubtype<CommandList, D3D11CommandList>(cl);
            using (_immediateContextLock.Enter())
            {
                if (d3d11CL.DeviceCommandList != null) // CommandList may have been reset in the meantime (resized swapchain).
                {
                    _immediateContext.ExecuteCommandList(d3d11CL.DeviceCommandList, FALSE);
                    d3d11CL.OnCompleted();
                }
            }

            if (let d3d11Fence = fence as D3D11Fence)
            {
                d3d11Fence.Set();
            }
        }

        protected override void SwapBuffersCore(Swapchain swapchain)
        {
            using (_immediateContextLock.Enter())
            {
                D3D11Swapchain d3d11SC = Util.AssertSubtype<Swapchain, D3D11Swapchain>(swapchain);
                d3d11SC.DxgiSwapChain.Present((uint32)d3d11SC.SyncInterval, /*DXGI_PRESENT_NONE*/0);
            }
        }

        public override TextureSampleCount GetSampleCountLimit(PixelFormat format, bool depthFormat)
        {
            DXGI_FORMAT dxgiFormat = D3D11Formats.ToDxgiFormat(format, depthFormat);
            if (CheckFormatMultisample(dxgiFormat, 32))
            {
                return TextureSampleCount.Count32;
            }
            else if (CheckFormatMultisample(dxgiFormat, 16))
            {
                return TextureSampleCount.Count16;
            }
            else if (CheckFormatMultisample(dxgiFormat, 8))
            {
                return TextureSampleCount.Count8;
            }
            else if (CheckFormatMultisample(dxgiFormat, 4))
            {
                return TextureSampleCount.Count4;
            }
            else if (CheckFormatMultisample(dxgiFormat, 2))
            {
                return TextureSampleCount.Count2;
            }

            return TextureSampleCount.Count1;
        }

        private bool CheckFormatMultisample(DXGI_FORMAT format, int32 sampleCount)
        {
            return _device.CheckMultisampleQualityLevels(format, (uint32)sampleCount, null) != 0;
        }

        protected override bool GetPixelFormatSupportCore(
            PixelFormat format,
            TextureType type,
            TextureUsage usage,
            out PixelFormatProperties properties)
        {
            if (D3D11Formats.IsUnsupportedFormat(format))
            {
                properties = default(PixelFormatProperties);
                return false;
            }

            DXGI_FORMAT dxgiFormat = D3D11Formats.ToDxgiFormat(format, (usage & TextureUsage.DepthStencil) != 0);
            D3D11_FORMAT_SUPPORT fs = 0;
			HRESULT hr = _device.CheckFormatSupport(dxgiFormat, (.)&fs);

            if ((usage & TextureUsage.RenderTarget) != 0 && (fs & .D3D11_FORMAT_SUPPORT_RENDER_TARGET) == 0
				|| (usage & TextureUsage.DepthStencil) != 0 && (fs & .D3D11_FORMAT_SUPPORT_DEPTH_STENCIL) == 0
				|| (usage & TextureUsage.Sampled) != 0 && (fs & .D3D11_FORMAT_SUPPORT_SHADER_SAMPLE) == 0
				|| (usage & TextureUsage.Cubemap) != 0 && (fs & .D3D11_FORMAT_SUPPORT_TEXTURECUBE) == 0
				|| (usage & TextureUsage.Storage) != 0 && (fs & .D3D11_FORMAT_SUPPORT_TYPED_UNORDERED_ACCESS_VIEW) == 0)
            {
                properties = default(PixelFormatProperties);
                return false;
            }

            const uint32 MaxTextureDimension = 16384;
            const uint32 MaxVolumeExtent = 2048;

            uint32 sampleCounts = 0;
            if (CheckFormatMultisample(dxgiFormat, 1)) { sampleCounts |= (1 << 0); }
            if (CheckFormatMultisample(dxgiFormat, 2)) { sampleCounts |= (1 << 1); }
            if (CheckFormatMultisample(dxgiFormat, 4)) { sampleCounts |= (1 << 2); }
            if (CheckFormatMultisample(dxgiFormat, 8)) { sampleCounts |= (1 << 3); }
            if (CheckFormatMultisample(dxgiFormat, 16)) { sampleCounts |= (1 << 4); }
            if (CheckFormatMultisample(dxgiFormat, 32)) { sampleCounts |= (1 << 5); }

            properties = PixelFormatProperties(
                MaxTextureDimension,
                type == TextureType.Texture1D ? 1 : MaxTextureDimension,
                type != TextureType.Texture3D ? 1 : MaxVolumeExtent,
                uint32.MaxValue,
                type == TextureType.Texture3D ? 1 : MaxVolumeExtent,
                sampleCounts);
            return true;
        }

        protected override MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource)
        {
            MappedResourceCacheKey key = MappedResourceCacheKey(resource, subresource);
            using (_mappedResourceLock.Enter())
            {
                if (_mappedResources.TryGetValue(key, var info))
                {
                    if (info.Mode != mode)
                    {
                        Runtime.GALError("The given resource was already mapped with a different MapMode.");
                    }

                    info.RefCount += 1;
                    _mappedResources[key] = info;
                }
                else
                {
                    // No current mapping exists -- create one.

                    if (let buffer = resource as D3D11Buffer)
                    {
                        using (_immediateContextLock.Enter())
                        {
							D3D11_MAPPED_SUBRESOURCE msr = .();
                            HRESULT hr = _immediateContext.Map(
								buffer.Buffer,
								0,
								D3D11Formats.VdToD3D11MapMode((buffer.Usage & BufferUsage.Dynamic) == BufferUsage.Dynamic, mode),
								(int32)(D3D11_MAP_FLAG)0, &msr);

                            info.MappedResource = MappedResource(resource, mode, msr.pData, buffer.SizeInBytes);
                            info.RefCount = 1;
                            info.Mode = mode;
                            _mappedResources.Add(key, info);
                        }
                    }
                    else
                    {
                        D3D11Texture texture = Util.AssertSubtype<MappableResource, D3D11Texture>(resource);
                        using (_immediateContextLock.Enter())
                        {
                            Util.GetMipLevelAndArrayLayer(texture, subresource, var mipLevel, var arrayLayer);
							uint32 subresourceIndex = texture.CalculateSubresourceIndex(mipLevel, arrayLayer);
							D3D11_MAPPED_SUBRESOURCE msr = .();
                            _immediateContext.Map(
								texture.DeviceTexture,
								subresourceIndex,
								D3D11Formats.VdToD3D11MapMode(false, mode),
								(int32)(D3D11_MAP_FLAG)0,
								&msr);

                            info.MappedResource = MappedResource(
                                resource,
                                mode,
                                msr.pData,
                                texture.Height * (uint32)msr.RowPitch,
                                subresource,
                                (uint32)msr.RowPitch,
                                (uint32)msr.DepthPitch);
                            info.RefCount = 1;
                            info.Mode = mode;
                            _mappedResources.Add(key, info);
                        }
                    }
                }

                return info.MappedResource;
            }
        }

        protected override void UnmapCore(MappableResource resource, uint32 subresource)
        {
            MappedResourceCacheKey key = MappedResourceCacheKey(resource, subresource);
            bool commitUnmap;

            using (_mappedResourceLock.Enter())
            {
                if (!_mappedResources.TryGetValue(key, var info))
                {
                    Runtime.GALError(scope $"The given resource ({resource}) is not mapped.");
                }

                info.RefCount -= 1;
                commitUnmap = info.RefCount == 0;
                if (commitUnmap)
                {
                    using (_immediateContextLock.Enter())
                    {
                        if (let buffer = resource as D3D11Buffer)
                        {
                            _immediateContext.Unmap(buffer.Buffer, 0);
                        }
                        else
                        {
                            D3D11Texture texture = Util.AssertSubtype<MappableResource, D3D11Texture>(resource);
                            _immediateContext.Unmap(texture.DeviceTexture, subresource);
                        }

                        bool result = _mappedResources.Remove(key);
                        Debug.Assert(result);
                    }
                }
                else
                {
                    _mappedResources[key] = info;
                }
            }
        }

        protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
        {
            D3D11Buffer d3dBuffer = Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(buffer);
            if (sizeInBytes == 0)
            {
                return;
            }

            bool isDynamic = (buffer.Usage & BufferUsage.Dynamic) == BufferUsage.Dynamic;
            bool isStaging = (buffer.Usage & BufferUsage.Staging) == BufferUsage.Staging;
            bool isUniformBuffer = (buffer.Usage & BufferUsage.UniformBuffer) == BufferUsage.UniformBuffer;
            bool updateFullBuffer = bufferOffsetInBytes == 0 && sizeInBytes == buffer.SizeInBytes;
            bool useUpdateSubresource = (!isDynamic && !isStaging) && (!isUniformBuffer || updateFullBuffer);
            bool useMap = (isDynamic && updateFullBuffer) || isStaging;

            if (useUpdateSubresource)
            {
                D3D11_BOX* subregion = scope :: .(bufferOffsetInBytes, 0, 0, (sizeInBytes + bufferOffsetInBytes), 1, 1);

                if (isUniformBuffer)
                {
                    subregion = null;
                }

                using (_immediateContextLock.Enter())
                {
                    _immediateContext.UpdateSubresource(d3dBuffer.Buffer, 0, subregion, source, 0, 0);
                }
            }
            else if (useMap)
            {
                MappedResource mr = MapCore(buffer, MapMode.Write, 0);
                if (sizeInBytes < 1024)
                {
                    Internal.MemCpy((uint8*)mr.Data + bufferOffsetInBytes, source, sizeInBytes);
                }
                else
                {
                    Internal.MemCpy(
                        (uint8*)mr.Data + bufferOffsetInBytes,
                        source,
                        sizeInBytes);
                }
                UnmapCore(buffer, 0);
            }
            else
            {
                D3D11Buffer staging = GetFreeStagingBuffer(sizeInBytes);
                UpdateBuffer(staging, 0, source, sizeInBytes);
                D3D11_BOX sourceRegion = .(0, 0, 0, sizeInBytes, 1, 1);
                using (_immediateContextLock.Enter())
                {
                    _immediateContext.CopySubresourceRegion(
                        d3dBuffer.Buffer, 0, bufferOffsetInBytes, 0, 0,
                        staging.Buffer, 0,
                        &sourceRegion);
                }

                using (_stagingResourcesLock.Enter())
                {
                    _availableStagingBuffers.Add(staging);
                }
            }
        }

        private D3D11Buffer GetFreeStagingBuffer(uint32 sizeInBytes)
        {
            using (_stagingResourcesLock.Enter())
            {
                for (D3D11Buffer buffer in _availableStagingBuffers)
                {
                    if (buffer.SizeInBytes >= sizeInBytes)
                    {
                        _availableStagingBuffers.Remove(buffer);
                        return buffer;
                    }
                }
            }

            DeviceBuffer staging = ResourceFactory.CreateBuffer(
                BufferDescription(sizeInBytes, BufferUsage.Staging));

            return Util.AssertSubtype<DeviceBuffer, D3D11Buffer>(staging);
        }

        protected override void UpdateTextureCore(
            Texture texture,
            void* source,
            uint32 sizeInBytes,
            uint32 x,
            uint32 y,
            uint32 z,
            uint32 width,
            uint32 height,
            uint32 depth,
            uint32 mipLevel,
            uint32 arrayLayer)
        {
            D3D11Texture d3dTex = Util.AssertSubtype<Texture, D3D11Texture>(texture);
            bool useMap = (texture.Usage & TextureUsage.Staging) == TextureUsage.Staging;
            if (useMap)
            {
                uint32 subresource = texture.CalculateSubresource(mipLevel, arrayLayer);
                MappedResourceCacheKey key = MappedResourceCacheKey(texture, subresource);
                MappedResource map = MapCore(texture, MapMode.Write, subresource);

                uint32 denseRowSize = FormatHelpers.GetRowPitch(width, texture.Format);
                uint32 denseSliceSize = FormatHelpers.GetDepthPitch(denseRowSize, height, texture.Format);

                Util.CopyTextureRegion(
                    source,
                    0, 0, 0,
                    denseRowSize, denseSliceSize,
                    map.Data,
                    x, y, z,
                    map.RowPitch, map.DepthPitch,
                    width, height, depth,
                    texture.Format);

                UnmapCore(texture, subresource);
            }
            else
            {
                int32 subresource = D3D11Util.ComputeSubresource(mipLevel, texture.MipLevels, arrayLayer);
                D3D11_BOX resourceRegion = .(
                    left: x,
                    right: (x + width),
                    top: y,
                    front: z,
                    bottom: (y + height),
                    back: (z + depth));

                uint32 srcRowPitch = FormatHelpers.GetRowPitch(width, texture.Format);
                uint32 srcDepthPitch = FormatHelpers.GetDepthPitch(srcRowPitch, height, texture.Format);
                using (_immediateContextLock.Enter())
                {
                    _immediateContext.UpdateSubresource(
                        d3dTex.DeviceTexture,
                        (uint32)subresource,
                        &resourceRegion,
                        source,
                        srcRowPitch,
                        srcDepthPitch);
                }
            }
        }

        public override bool WaitForFence(Fence fence, uint64 nanosecondTimeout)
        {
            return Util.AssertSubtype<Fence, D3D11Fence>(fence).Wait(nanosecondTimeout);
        }

        public override bool WaitForFences(Fence[] fences, bool waitAll, uint64 nanosecondTimeout)
        {
            int32 msTimeout;
            if (nanosecondTimeout == uint64.MaxValue)
            {
                msTimeout = -1;
            }
            else
            {
                msTimeout = (int32)Math.Min<uint64>(nanosecondTimeout / 1000000, int32.MaxValue);
            }

            ManualResetEvent[] events = GetResetEventArray(fences.Count);
            for (int i = 0; i < fences.Count; i++)
            {
                events[i] = Util.AssertSubtype<Fence, D3D11Fence>(fences[i]).ResetEvent;
            }
            bool result;
            if (waitAll)
            {
                result = WaitAll(events, (uint32)msTimeout);
            }
            else
            {
                uint32 index = WaitAny(events, (uint32)msTimeout);
                result = index != (uint32)WIN32_ERROR.WAIT_TIMEOUT;
            }

            ReturnResetEventArray(events);

            return result;
        }

		private bool WaitAll(Span<ManualResetEvent> events, uint32 msTimeout)
		{
			List<HANDLE> eventHandles = scope .();

			for(var event in events)
			{
				eventHandles.Add(event.Handle);
			}
			
			int32 index = (.)Win32.System.Threading.WaitForMultipleObjects((uint32)eventHandles.Count, eventHandles.Ptr, TRUE, msTimeout);
		    return (index >= (.)WIN32_ERROR.WAIT_OBJECT_0) && (index < (.)WIN32_ERROR.WAIT_ABANDONED);
		}

		private uint32 WaitAny(Span<ManualResetEvent> events, uint32 msTimeout)
		{
			List<HANDLE> eventHandles = scope .();

			for(var event in events)
			{
				eventHandles.Add(event.Handle);
			}
			
			uint32 index = (.)Win32.System.Threading.WaitForMultipleObjects((uint32)eventHandles.Count, eventHandles.Ptr, FALSE, msTimeout);
			return index;
		}

        private readonly Monitor _resetEventsLock = new .() ~ delete _;
        private readonly List<ManualResetEvent[]> _resetEvents = new .();

        private ManualResetEvent[] GetResetEventArray(int length)
        {
            using (_resetEventsLock.Enter())
            {
                for (int i = _resetEvents.Count - 1; i > 0; i--)
                {
                    ManualResetEvent[] array = _resetEvents[i];
                    if (array.Count == length)
                    {
                        _resetEvents.RemoveAt(i);
                        return array;
                    }
                }
            }

            ManualResetEvent[] newArray = new ManualResetEvent[length];
            return newArray;
        }

        private void ReturnResetEventArray(ManualResetEvent[] array)
        {
            using (_resetEventsLock.Enter())
            {
                _resetEvents.Add(array);
            }
        }

        public override void ResetFence(Fence fence)
        {
            Util.AssertSubtype<Fence, D3D11Fence>(fence).Reset();
        }

        protected override uint32 GetUniformBufferMinOffsetAlignmentCore() => 256u;

        protected override uint32 GetStructuredBufferMinOffsetAlignmentCore() => 16;

        protected override void PlatformDispose()
        {
            // Dispose staging buffers
            for (DeviceBuffer buffer in _availableStagingBuffers)
            {
                buffer.Dispose();
            }
            _availableStagingBuffers.Clear();

            _d3d11ResourceFactory.Dispose();
            _mainSwapchain?.Dispose();
            _immediateContext.Release();

            if (IsDebugEnabled)
            {
                uint32 refCount = _device.Release();
                if (refCount > 0)
                {
                    ID3D11Debug* deviceDebug = _device.QueryInterface<ID3D11Debug>();
                    if (deviceDebug != null)
                    {
                        deviceDebug.ReportLiveDeviceObjects(.D3D11_RLDO_SUMMARY | .D3D11_RLDO_DETAIL | .D3D11_RLDO_IGNORE_INTERNAL);
                        deviceDebug.Release();
                    }
                }

                _dxgiAdapter.Release();

                // Report live objects using DXGI if available (DXGIGetDebugInterface1 will fail on pre Windows 8 OS).
				IDXGIDebug1* dxgiDebug = null;
                if (DXGIGetDebugInterface1(0, IDXGIDebug1.IID, (void**)&dxgiDebug) == S_OK)
                {
                    dxgiDebug.ReportLiveObjects(DXGI_DEBUG_ALL, .DXGI_DEBUG_RLO_SUMMARY | .DXGI_DEBUG_RLO_IGNORE_INTERNAL);
                    dxgiDebug.Release();
                }
            }
            else
            {
                _device.Release();
                _dxgiAdapter.Release();
            }
        }

        protected override void WaitForIdleCore()
        {
        }

        public bool GetD3D11Info(out BackendInfoD3D11 info)
        {
            info = _d3d11Info;
            return true;
        }
    }
}
