using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Threading;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;

    public class MTLGraphicsDevice : GraphicsDevice
    {
        private static readonly Lazy<bool> s_isSupported = new Lazy<bool>(GetIsSupported);
		private static readonly Monitor s_aotRegisteredBlocksLock = new .() ~ delete _;
        private static readonly Dictionary<void*, MTLGraphicsDevice> s_aotRegisteredBlocks = new .();

        private readonly MTLDevice _device;
        private readonly String _deviceName;
        private readonly GraphicsApiVersion _apiVersion;
        private readonly MTLCommandQueue _commandQueue;
        private readonly MTLSwapchain _mainSwapchain;
        private readonly bool[] _supportedSampleCounts;
        private BackendInfoMetal _metalInfo;

        private readonly Monitor _submittedCommandsLock = new .() ~ delete _;
        private readonly Dictionary<MTLCommandBuffer, MTLFence> _submittedCBs = new .() ~ delete _;
        private MTLCommandBuffer _latestSubmittedCB;

        private readonly Monitor _resetEventsLock = new .() ~ delete _;
        private readonly List<ManualResetEvent[]> _resetEvents = new List<ManualResetEvent[]>();

        private const String UnalignedBufferCopyPipelineMacOSName = "MTL_UnalignedBufferCopy_macOS";
        private const String UnalignedBufferCopyPipelineiOSName = "MTL_UnalignedBufferCopy_iOS";
        private readonly Monitor _unalignedBufferCopyPipelineLock = new .() ~ delete _;
        private readonly NativeLibrary _libSystem;
        private readonly void* _concreteGlobalBlock;
        private MTLShader _unalignedBufferCopyShader;
        private MTLComputePipelineState _unalignedBufferCopyPipeline;
        private MTLCommandBufferHandler _completionHandler;
        private readonly void* _completionHandlerFuncPtr;
        private readonly void* _completionBlockDescriptor;
        private readonly void* _completionBlockLiteral;

        public MTLDevice Device => _device;
        public MTLCommandQueue CommandQueue => _commandQueue;
        internal MTLFeatureSupport MetalFeatures { get; }
        public ResourceBindingModel ResourceBindingModel { get; }

        public this(
            GraphicsDeviceOptions options,
            SwapchainDescription? swapchainDesc)
        {
            _device = MTLDevice.MTLCreateSystemDefaultDevice();
            _deviceName = _device.name(.. new .());
            MetalFeatures = new MTLFeatureSupport(_device);

            int32 major = (int32)MetalFeatures.MaxFeatureSet / 10000;
            int32 minor = (int32)MetalFeatures.MaxFeatureSet % 10000;
            _apiVersion = GraphicsApiVersion(major, minor, 0, 0);

            Features = new GraphicsDeviceFeatures(
                computeShader: true,
                geometryShader: false,
                tessellationShaders: false,
                multipleViewports: MetalFeatures.IsSupported(MTLFeatureSet.macOS_GPUFamily1_v3),
                samplerLodBias: false,
                drawBaseVertex: MetalFeatures.IsDrawBaseVertexInstanceSupported(),
                drawBaseInstance: MetalFeatures.IsDrawBaseVertexInstanceSupported(),
                drawIndirect: true,
                drawIndirectBaseInstance: true,
                fillModeWireframe: true,
                samplerAnisotropy: true,
                depthClipDisable: true,
                texture1D: true, // TODO: Should be macOS 10.11+ and iOS 11.0+.
                independentBlend: true,
                structuredBuffer: true,
                subsetTextureView: true,
                commandListDebugMarkers: true,
                bufferRangeBinding: true,
                shaderFloat64: false);
            ResourceBindingModel = options.ResourceBindingModel;

            _libSystem = new NativeLibrary("libSystem.dylib");
            _concreteGlobalBlock = _libSystem.LoadFunction("_NSConcreteGlobalBlock");
            if (MetalFeatures.IsMacOS)
            {
				static void completionHandler(void* block, MTLCommandBuffer buffer)
				{
					OnCommandBufferCompleted(block, buffer);
				}
                _completionHandler = => completionHandler;
            }
            else
            {
                _completionHandler = => OnCommandBufferCompleted_Static;
            }
            _completionHandlerFuncPtr = (MTLCommandBufferHandler)_completionHandler;
            _completionBlockDescriptor = new uint8[sizeof(BlockDescriptor)]*;
            BlockDescriptor* descriptorPtr = (BlockDescriptor*)_completionBlockDescriptor;
            descriptorPtr.reserved = 0;
            descriptorPtr.Block_size = (uint64)sizeof(BlockDescriptor);

            _completionBlockLiteral = new uint8[sizeof(BlockLiteral)]*;
            BlockLiteral* blockPtr = (BlockLiteral*)_completionBlockLiteral;
            blockPtr.isa = _concreteGlobalBlock;
            blockPtr.flags = 1 << 28 | 1 << 29;
            blockPtr.invoke = _completionHandlerFuncPtr;
            blockPtr.descriptor = descriptorPtr;

            if (!MetalFeatures.IsMacOS)
            {
                using (s_aotRegisteredBlocksLock.Enter())
                {
                    s_aotRegisteredBlocks.Add(_completionBlockLiteral, this);
                }
            }

            ResourceFactory = new MTLResourceFactory(this);
            _commandQueue = _device.newCommandQueue();

            List<TextureSampleCount> allSampleCounts = scope .(Enum.GetValues<TextureSampleCount>());
            _supportedSampleCounts = new bool[allSampleCounts.Count];
            for (int i = 0; i < allSampleCounts.Count; i++)
            {
                TextureSampleCount count = allSampleCounts[i];
                uint32 uintValue = FormatHelpers.GetSampleCountUInt32(count);
                if (_device.supportsTextureSampleCount((uint)uintValue))
                {
                    _supportedSampleCounts[i] = true;
                }
            }

            if (swapchainDesc != null)
            {
                SwapchainDescription desc = swapchainDesc.Value;
                _mainSwapchain = new MTLSwapchain(this, desc);
            }

            _metalInfo = new BackendInfoMetal(this);

            PostDeviceCreated();
        }

        public override String DeviceName => _deviceName;

        public override String VendorName => "Apple";

        public override GraphicsApiVersion ApiVersion => _apiVersion;

        public override GraphicsBackend BackendType => GraphicsBackend.Metal;

        public override bool IsUvOriginTopLeft => true;

        public override bool IsDepthRangeZeroToOne => true;

        public override bool IsClipSpaceYInverted => false;

        public override ResourceFactory ResourceFactory { get; }

        public override Swapchain MainSwapchain => _mainSwapchain;

        public override GraphicsDeviceFeatures Features { get; }

        private void OnCommandBufferCompleted(void* block, MTLCommandBuffer cb)
        {
            using (_submittedCommandsLock.Enter())
            {
                if (_submittedCBs.TryGetValue(cb, var fence))
                {
                    fence.Set();
                    _submittedCBs.Remove(cb);
                }

                if (_latestSubmittedCB.NativePtr == cb.NativePtr)
                {
                    _latestSubmittedCB = default(MTLCommandBuffer);
                }
            }

            ObjectiveCRuntime.release(cb.NativePtr);
        }

        // Xamarin AOT requires native callbacks be static.
        //[MonoPInvokeCallback(typeof(MTLCommandBufferHandler))]
        private static void OnCommandBufferCompleted_Static(void* block, MTLCommandBuffer cb)
        {
            using (s_aotRegisteredBlocksLock.Enter())
            {
                if (s_aotRegisteredBlocks.TryGetValue(block, var gd))
                {
                    gd.OnCommandBufferCompleted(block, cb);
                }
            }
        }

        protected override void SubmitCommandsCore(CommandList commandList, Fence fence)
        {
            MTLCommandList mtlCL = Util.AssertSubtype<CommandList, MTLCommandList>(commandList);

            mtlCL.CommandBuffer.addCompletedHandler(_completionBlockLiteral);
            using (_submittedCommandsLock.Enter())
            {
                if (fence != null)
                {
                    MTLFence mtlFence = Util.AssertSubtype<Fence, MTLFence>(fence);
                    _submittedCBs.Add(mtlCL.CommandBuffer, mtlFence);
                }

                _latestSubmittedCB = mtlCL.Commit();
            }
        }

        public override TextureSampleCount GetSampleCountLimit(PixelFormat format, bool depthFormat)
        {
            for (int i = _supportedSampleCounts.Count - 1; i >= 0; i--)
            {
                if (_supportedSampleCounts[i])
                {
                    return (TextureSampleCount)i;
                }
            }

            return TextureSampleCount.Count1;
        }

        protected override bool GetPixelFormatSupportCore(
            PixelFormat format,
            TextureType type,
            TextureUsage usage,
            out PixelFormatProperties properties)
        {
            if (!MTLFormats.IsFormatSupported(format, usage, MetalFeatures))
            {
                properties = default(PixelFormatProperties);
                return false;
            }

            uint32 sampleCounts = 0;

            for (int32 i = 0; i < _supportedSampleCounts.Count; i++)
            {
                if (_supportedSampleCounts[i])
                {
                    sampleCounts |= (uint32)(1 << i);
                }
            }

            MTLFeatureSet maxFeatureSet = MetalFeatures.MaxFeatureSet;
            uint32 maxArrayLayer = MTLFormats.GetMaxTextureVolume(maxFeatureSet);
            uint32 maxWidth;
            uint32 maxHeight;
            uint32 maxDepth;
            if (type == TextureType.Texture1D)
            {
                maxWidth = MTLFormats.GetMaxTexture1DWidth(maxFeatureSet);
                maxHeight = 1;
                maxDepth = 1;
            }
            else if (type == TextureType.Texture2D)
            {
                uint32 maxDimensions;
                if ((usage & TextureUsage.Cubemap) != 0)
                {
                    maxDimensions = MTLFormats.GetMaxTextureCubeDimensions(maxFeatureSet);
                }
                else
                {
                    maxDimensions = MTLFormats.GetMaxTexture2DDimensions(maxFeatureSet);
                }

                maxWidth = maxDimensions;
                maxHeight = maxDimensions;
                maxDepth = 1;
            }
            else if (type == TextureType.Texture3D)
            {
                maxWidth = maxArrayLayer;
                maxHeight = maxArrayLayer;
                maxDepth = maxArrayLayer;
                maxArrayLayer = 1;
            }
            else
            {
                Runtime.IllegalValue<TextureType>();
            }

            properties = PixelFormatProperties(
                maxWidth,
                maxHeight,
                maxDepth,
                uint32.MaxValue,
                maxArrayLayer,
                sampleCounts);
            return true;
        }

        protected override void SwapBuffersCore(Swapchain swapchain)
        {
            MTLSwapchain mtlSC = Util.AssertSubtype<Swapchain, MTLSwapchain>(swapchain);
            void* currentDrawablePtr = mtlSC.CurrentDrawable.NativePtr;
            if (currentDrawablePtr != null)
            {
                using (NSAutoreleasePool.Begin())
                {
                    MTLCommandBuffer submitCB = _commandQueue.commandBuffer();
                    submitCB.presentDrawable(currentDrawablePtr);
                    submitCB.commit();
                }
            }

            mtlSC.GetNextDrawable();
        }

        protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, void* source, uint32 sizeInBytes)
        {
            var mtlBuffer = Util.AssertSubtype<DeviceBuffer, Sedulous.GAL.MTL.MTLBuffer>(buffer);
            void* destPtr = mtlBuffer.DeviceBuffer.contents();
            uint8* destOffsetPtr = (uint8*)destPtr + bufferOffsetInBytes;
            Internal.MemCpy(destOffsetPtr, source, sizeInBytes);
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
            Sedulous.GAL.MTL.MTLTexture mtlTex = Util.AssertSubtype<Texture, Sedulous.GAL.MTL.MTLTexture>(texture);
            if (mtlTex.StagingBuffer.IsNull)
            {
                Texture stagingTex = ResourceFactory.CreateTexture(TextureDescription(
                    width, height, depth, 1, 1, texture.Format, TextureUsage.Staging, texture.Type));
                UpdateTexture(stagingTex, source, sizeInBytes, 0, 0, 0, width, height, depth, 0, 0);
                CommandList cl = ResourceFactory.CreateCommandList();
                cl.Begin();
                cl.CopyTexture(
                    stagingTex, 0, 0, 0, 0, 0,
                    texture, x, y, z, mipLevel, arrayLayer,
                    width, height, depth, 1);
                cl.End();
                SubmitCommands(cl);

                cl.Dispose();
                stagingTex.Dispose();
            }
            else
            {
                mtlTex.GetSubresourceLayout(mipLevel, arrayLayer, var dstRowPitch, var dstDepthPitch);
                uint64 dstOffset = Util.ComputeSubresourceOffset(mtlTex, mipLevel, arrayLayer);
                uint32 srcRowPitch = FormatHelpers.GetRowPitch(width, texture.Format);
                uint32 srcDepthPitch = FormatHelpers.GetDepthPitch(srcRowPitch, height, texture.Format);
                Util.CopyTextureRegion(
                    source,
                    0, 0, 0,
                    srcRowPitch, srcDepthPitch,
                    (uint8*)mtlTex.StagingBuffer.contents() + dstOffset,
                    x, y, z,
                    dstRowPitch, dstDepthPitch,
                    width, height, depth,
                    texture.Format);
            }
        }

        protected override void WaitForIdleCore()
        {
            MTLCommandBuffer lastCB = default(MTLCommandBuffer);
            using (_submittedCommandsLock.Enter())
            {
                lastCB = _latestSubmittedCB;
                ObjectiveCRuntime.retain(lastCB.NativePtr);
            }

            if (lastCB.NativePtr != null && lastCB.status != MTLCommandBufferStatus.Completed)
            {
                lastCB.waitUntilCompleted();
            }

            ObjectiveCRuntime.release(lastCB.NativePtr);
        }

        protected override MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource)
        {
            if (let buffer = resource as Sedulous.GAL.MTL.MTLBuffer)
            {
                return MapBuffer(buffer, mode);
            }
            else
            {
                Sedulous.GAL.MTL.MTLTexture texture = Util.AssertSubtype<MappableResource, Sedulous.GAL.MTL.MTLTexture>(resource);
                return MapTexture(texture, mode, subresource);
            }
        }

        private MappedResource MapBuffer(Sedulous.GAL.MTL.MTLBuffer buffer, MapMode mode)
        {
            void* data = buffer.DeviceBuffer.contents();
            return MappedResource(
                buffer,
                mode,
                data,
                buffer.SizeInBytes,
                0,
                buffer.SizeInBytes,
                buffer.SizeInBytes);
        }

        private MappedResource MapTexture(Sedulous.GAL.MTL.MTLTexture texture, MapMode mode, uint32 subresource)
        {
            Debug.Assert(!texture.StagingBuffer.IsNull);
            void* data = texture.StagingBuffer.contents();
            Util.GetMipLevelAndArrayLayer(texture, subresource, var mipLevel, var arrayLayer);
            Util.GetMipDimensions(texture, mipLevel, var width, var height, var depth);
            uint32 subresourceSize = texture.GetSubresourceSize(mipLevel, arrayLayer);
            texture.GetSubresourceLayout(mipLevel, arrayLayer, var rowPitch, var depthPitch);
            uint64 offset = Util.ComputeSubresourceOffset(texture, mipLevel, arrayLayer);
            uint8* offsetPtr = (uint8*)data + offset;
            return MappedResource(texture, mode, offsetPtr, subresourceSize, subresource, rowPitch, depthPitch);
        }

        protected override void PlatformDispose()
        {
            WaitForIdle();
            if (!_unalignedBufferCopyPipeline.IsNull)
            {
                _unalignedBufferCopyShader.Dispose();
                ObjectiveCRuntime.release(_unalignedBufferCopyPipeline.NativePtr);
            }
            _mainSwapchain?.Dispose();
            ObjectiveCRuntime.release(_commandQueue.NativePtr);
            ObjectiveCRuntime.release(_device.NativePtr);

            using (s_aotRegisteredBlocksLock.Enter())
            {
                s_aotRegisteredBlocks.Remove(_completionBlockLiteral);
            }

            _libSystem.Dispose();
            delete _completionBlockDescriptor;
            delete _completionBlockLiteral;
        }

        public bool GetMetalInfo(out BackendInfoMetal info)
        {
            info = _metalInfo;
            return true;
        }

        protected override void UnmapCore(MappableResource resource, uint32 subresource)
        {
        }

        public override bool WaitForFence(Fence fence, uint64 nanosecondTimeout)
        {
            return Util.AssertSubtype<Fence, MTLFence>(fence).Wait(nanosecondTimeout);
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
                msTimeout = (int32)Math.Min(nanosecondTimeout / 1000000, uint32.MaxValue);
            }

            ManualResetEvent[] events = GetResetEventArray(fences.Count);
            for (int i = 0; i < fences.Count; i++)
            {
                events[i] = Util.AssertSubtype<Fence, MTLFence>(fences[i]).ResetEvent;
            }
            bool result;
            if (waitAll)
            {
                result = WaitHandle.WaitAll(events, msTimeout);
            }
            else
            {
                int32 index = WaitHandle.WaitAny(events, msTimeout);
                result = index != WaitHandle.WaitTimeout;
            }

            ReturnResetEventArray(events);

            return result;
        }

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
            Util.AssertSubtype<Fence, MTLFence>(fence).Reset();
        }

        internal static bool IsSupported() => s_isSupported.Value;

        private static bool GetIsSupported()
        {
            bool result = false;
            try
            {
                if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
                {
                    if (RuntimeInformation.OSDescription.Contains("Darwin"))
                    {
                        NSArray allDevices = MTLDevice.MTLCopyAllDevices();
                        result |= (uint64)allDevices.count > 0;
                        ObjectiveCRuntime.release(allDevices.NativePtr);
                    }
                    else
                    {
                        MTLDevice defaultDevice = MTLDevice.MTLCreateSystemDefaultDevice();
                        if (defaultDevice.NativePtr != null)
                        {
                            result = true;
                            ObjectiveCRuntime.release(defaultDevice.NativePtr);
                        }
                    }
                }
            }
            catch
            {
                result = false;
            }

            return result;
        }

        internal MTLComputePipelineState GetUnalignedBufferCopyPipeline()
        {
            using (_unalignedBufferCopyPipelineLock.Enter())
            {
                if (_unalignedBufferCopyPipeline.IsNull)
                {
                    MTLComputePipelineDescriptor descriptor = MTLUtil.AllocInit<MTLComputePipelineDescriptor>(
                       nameof(MTLComputePipelineDescriptor));
                    MTLPipelineBufferDescriptor buffer0 = descriptor.buffers[0];
                    buffer0.mutability = MTLMutability.Mutable;
                    MTLPipelineBufferDescriptor buffer1 = descriptor.buffers[1];
                    buffer0.mutability = MTLMutability.Mutable;

                    Debug.Assert(_unalignedBufferCopyShader == null);
                    String name = MetalFeatures.IsMacOS ? UnalignedBufferCopyPipelineMacOSName : UnalignedBufferCopyPipelineiOSName;
                    using (Stream resourceStream = typeof(MTLGraphicsDevice).Assembly.GetManifestResourceStream(name))
                    {
                        uint8[] data = new uint8[resourceStream.Length];
                        using (MemoryStream ms = new MemoryStream(data))
                        {
                            resourceStream.CopyTo(ms);
                            ShaderDescription shaderDesc = ShaderDescription(ShaderStages.Compute, data, "copy_bytes");
                            _unalignedBufferCopyShader = new MTLShader(shaderDesc, this);
                        }
                    }

                    descriptor.computeFunction = _unalignedBufferCopyShader.Function;
                    _unalignedBufferCopyPipeline = _device.newComputePipelineStateWithDescriptor(descriptor);
                    ObjectiveCRuntime.release(descriptor.NativePtr);
                }

                return _unalignedBufferCopyPipeline;
            }
        }

        protected override uint32 GetUniformBufferMinOffsetAlignmentCore() => MetalFeatures.IsMacOS ? 16 : 256;
        protected override uint32 GetStructuredBufferMinOffsetAlignmentCore() => 16;
    }
}
