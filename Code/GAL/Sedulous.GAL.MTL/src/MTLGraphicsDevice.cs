using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;
using NativeLibrary = NativeLibraryLoader.NativeLibrary;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
    internal class MTLGraphicsDevice : GraphicsDevice
    {
        private static readonly Lazy<bool> s_isSupported = new Lazy<bool>(GetIsSupported);
        private static readonly Dictionary<IntPtr, MTLGraphicsDevice> s_aotRegisteredBlocks
            = new Dictionary<IntPtr, MTLGraphicsDevice>();

        private readonly MTLDevice _device;
        private readonly string _deviceName;
        private readonly GraphicsApiVersion _apiVersion;
        private readonly MTLCommandQueue _commandQueue;
        private readonly MTLSwapchain _mainSwapchain;
        private readonly bool[] _supportedSampleCounts;
        private BackendInfoMetal _metalInfo;

        private readonly object _submittedCommandsLock = new object();
        private readonly Dictionary<MTLCommandBuffer, MTLFence> _submittedCBs = new Dictionary<MTLCommandBuffer, MTLFence>();
        private MTLCommandBuffer _latestSubmittedCB;

        private readonly object _resetEventsLock = new object();
        private readonly List<ManualResetEvent[]> _resetEvents = new List<ManualResetEvent[]>();

        private const string UnalignedBufferCopyPipelineMacOSName = "MTL_UnalignedBufferCopy_macOS";
        private const string UnalignedBufferCopyPipelineiOSName = "MTL_UnalignedBufferCopy_iOS";
        private readonly object _unalignedBufferCopyPipelineLock = new object();
        private readonly NativeLibrary _libSystem;
        private readonly IntPtr _concreteGlobalBlock;
        private MTLShader _unalignedBufferCopyShader;
        private MTLComputePipelineState _unalignedBufferCopyPipeline;
        private MTLCommandBufferHandler _completionHandler;
        private readonly IntPtr _completionHandlerFuncPtr;
        private readonly IntPtr _completionBlockDescriptor;
        private readonly IntPtr _completionBlockLiteral;

        public MTLDevice Device => _device;
        public MTLCommandQueue CommandQueue => _commandQueue;
        public MTLFeatureSupport MetalFeatures { get; }
        public ResourceBindingModel ResourceBindingModel { get; }

        public MTLGraphicsDevice(
            GraphicsDeviceOptions options,
            SwapchainDescription? swapchainDesc)
        {
            _device = MTLDevice.MTLCreateSystemDefaultDevice();
            _deviceName = _device.name;
            MetalFeatures = new MTLFeatureSupport(_device);

            int32 major = (int32)MetalFeatures.MaxFeatureSet / 10000;
            int32 minor = (int32)MetalFeatures.MaxFeatureSet % 10000;
            _apiVersion = new GraphicsApiVersion(major, minor, 0, 0);

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
                _completionHandler = OnCommandBufferCompleted;
            }
            else
            {
                _completionHandler = OnCommandBufferCompleted_Static;
            }
            _completionHandlerFuncPtr = Marshal.GetFunctionPointerForDelegate<MTLCommandBufferHandler>(_completionHandler);
            _completionBlockDescriptor = Marshal.AllocHGlobal(Unsafe.SizeOf<BlockDescriptor>());
            BlockDescriptor* descriptorPtr = (BlockDescriptor*)_completionBlockDescriptor;
            descriptorPtr->reserved = 0;
            descriptorPtr->Block_size = (uint64)Unsafe.SizeOf<BlockDescriptor>();

            _completionBlockLiteral = Marshal.AllocHGlobal(Unsafe.SizeOf<BlockLiteral>());
            BlockLiteral* blockPtr = (BlockLiteral*)_completionBlockLiteral;
            blockPtr->isa = _concreteGlobalBlock;
            blockPtr->flags = 1 << 28 | 1 << 29;
            blockPtr->invoke = _completionHandlerFuncPtr;
            blockPtr->descriptor = descriptorPtr;

            if (!MetalFeatures.IsMacOS)
            {
                lock (s_aotRegisteredBlocks)
                {
                    s_aotRegisteredBlocks.Add(_completionBlockLiteral, this);
                }
            }

            ResourceFactory = new MTLResourceFactory(this);
            _commandQueue = _device.newCommandQueue();

            TextureSampleCount[] allSampleCounts = (TextureSampleCount[])Enum.GetValues(typeof(TextureSampleCount));
            _supportedSampleCounts = new bool[allSampleCounts.Length];
            for (int32 i = 0; i < allSampleCounts.Length; i++)
            {
                TextureSampleCount count = allSampleCounts[i];
                uint32 uintValue = FormatHelpers.GetSampleCountUInt32(count);
                if (_device.supportsTextureSampleCount((UIntPtr)uintValue))
                {
                    _supportedSampleCounts[i] = true;
                }
            }

            if (swapchainDesc != null)
            {
                SwapchainDescription desc = swapchainDesc.Value;
                _mainSwapchain = new MTLSwapchain(this, ref desc);
            }

            _metalInfo = new BackendInfoMetal(this);

            PostDeviceCreated();
        }

        public override string DeviceName => _deviceName;

        public override string VendorName => "Apple";

        public override GraphicsApiVersion ApiVersion => _apiVersion;

        public override GraphicsBackend BackendType => GraphicsBackend.Metal;

        public override bool IsUvOriginTopLeft => true;

        public override bool IsDepthRangeZeroToOne => true;

        public override bool IsClipSpaceYInverted => false;

        public override ResourceFactory ResourceFactory { get; }

        public override Swapchain MainSwapchain => _mainSwapchain;

        public override GraphicsDeviceFeatures Features { get; }

        private void OnCommandBufferCompleted(IntPtr block, MTLCommandBuffer cb)
        {
            lock (_submittedCommandsLock)
            {
                if (_submittedCBs.TryGetValue(cb, out MTLFence fence))
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
        [MonoPInvokeCallback(typeof(MTLCommandBufferHandler))]
        private static void OnCommandBufferCompleted_Static(IntPtr block, MTLCommandBuffer cb)
        {
            lock (s_aotRegisteredBlocks)
            {
                if (s_aotRegisteredBlocks.TryGetValue(block, out MTLGraphicsDevice gd))
                {
                    gd.OnCommandBufferCompleted(block, cb);
                }
            }
        }

        private protected override void SubmitCommandsCore(CommandList commandList, Fence fence)
        {
            MTLCommandList mtlCL = Util.AssertSubtype<CommandList, MTLCommandList>(commandList);

            mtlCL.CommandBuffer.addCompletedHandler(_completionBlockLiteral);
            lock (_submittedCommandsLock)
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
            for (int32 i = _supportedSampleCounts.Length - 1; i >= 0; i--)
            {
                if (_supportedSampleCounts[i])
                {
                    return (TextureSampleCount)i;
                }
            }

            return TextureSampleCount.Count1;
        }

        private protected override bool GetPixelFormatSupportCore(
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

            for (int32 i = 0; i < _supportedSampleCounts.Length; i++)
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
                throw Illegal.Value<TextureType>();
            }

            properties = new PixelFormatProperties(
                maxWidth,
                maxHeight,
                maxDepth,
                uint32.MaxValue,
                maxArrayLayer,
                sampleCounts);
            return true;
        }

        private protected override void SwapBuffersCore(Swapchain swapchain)
        {
            MTLSwapchain mtlSC = Util.AssertSubtype<Swapchain, MTLSwapchain>(swapchain);
            IntPtr currentDrawablePtr = mtlSC.CurrentDrawable.NativePtr;
            if (currentDrawablePtr != IntPtr.Zero)
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

        private protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr source, uint32 sizeInBytes)
        {
            var mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(buffer);
            void* destPtr = mtlBuffer.DeviceBuffer.contents();
            uint8* destOffsetPtr = (uint8*)destPtr + bufferOffsetInBytes;
            Unsafe.CopyBlock(destOffsetPtr, source.ToPointer(), sizeInBytes);
        }

        private protected override void UpdateTextureCore(
            Texture texture,
            IntPtr source,
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
            MTLTexture mtlTex = Util.AssertSubtype<Texture, MTLTexture>(texture);
            if (mtlTex.StagingBuffer.IsNull)
            {
                Texture stagingTex = ResourceFactory.CreateTexture(new TextureDescription(
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
                mtlTex.GetSubresourceLayout(mipLevel, arrayLayer, out uint32 dstRowPitch, out uint32 dstDepthPitch);
                uint64 dstOffset = Util.ComputeSubresourceOffset(mtlTex, mipLevel, arrayLayer);
                uint32 srcRowPitch = FormatHelpers.GetRowPitch(width, texture.Format);
                uint32 srcDepthPitch = FormatHelpers.GetDepthPitch(srcRowPitch, height, texture.Format);
                Util.CopyTextureRegion(
                    source.ToPointer(),
                    0, 0, 0,
                    srcRowPitch, srcDepthPitch,
                    (uint8*)mtlTex.StagingBuffer.contents() + dstOffset,
                    x, y, z,
                    dstRowPitch, dstDepthPitch,
                    width, height, depth,
                    texture.Format);
            }
        }

        private protected override void WaitForIdleCore()
        {
            MTLCommandBuffer lastCB = default(MTLCommandBuffer);
            lock (_submittedCommandsLock)
            {
                lastCB = _latestSubmittedCB;
                ObjectiveCRuntime.retain(lastCB.NativePtr);
            }

            if (lastCB.NativePtr != IntPtr.Zero && lastCB.status != MTLCommandBufferStatus.Completed)
            {
                lastCB.waitUntilCompleted();
            }

            ObjectiveCRuntime.release(lastCB.NativePtr);
        }

        protected override MappedResource MapCore(MappableResource resource, MapMode mode, uint32 subresource)
        {
            if (resource is MTLBuffer buffer)
            {
                return MapBuffer(buffer, mode);
            }
            else
            {
                MTLTexture texture = Util.AssertSubtype<MappableResource, MTLTexture>(resource);
                return MapTexture(texture, mode, subresource);
            }
        }

        private MappedResource MapBuffer(MTLBuffer buffer, MapMode mode)
        {
            void* data = buffer.DeviceBuffer.contents();
            return new MappedResource(
                buffer,
                mode,
                (IntPtr)data,
                buffer.SizeInBytes,
                0,
                buffer.SizeInBytes,
                buffer.SizeInBytes);
        }

        private MappedResource MapTexture(MTLTexture texture, MapMode mode, uint32 subresource)
        {
            Debug.Assert(!texture.StagingBuffer.IsNull);
            void* data = texture.StagingBuffer.contents();
            Util.GetMipLevelAndArrayLayer(texture, subresource, out uint32 mipLevel, out uint32 arrayLayer);
            Util.GetMipDimensions(texture, mipLevel, out uint32 width, out uint32 height, out uint32 depth);
            uint32 subresourceSize = texture.GetSubresourceSize(mipLevel, arrayLayer);
            texture.GetSubresourceLayout(mipLevel, arrayLayer, out uint32 rowPitch, out uint32 depthPitch);
            uint64 offset = Util.ComputeSubresourceOffset(texture, mipLevel, arrayLayer);
            uint8* offsetPtr = (uint8*)data + offset;
            return new MappedResource(texture, mode, (IntPtr)offsetPtr, subresourceSize, subresource, rowPitch, depthPitch);
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

            lock (s_aotRegisteredBlocks)
            {
                s_aotRegisteredBlocks.Remove(_completionBlockLiteral);
            }

            _libSystem.Dispose();
            Marshal.FreeHGlobal(_completionBlockDescriptor);
            Marshal.FreeHGlobal(_completionBlockLiteral);
        }

        public override bool GetMetalInfo(out BackendInfoMetal info)
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
                msTimeout = (int32)Math.Min(nanosecondTimeout / 1_000_000, int32.MaxValue);
            }

            ManualResetEvent[] events = GetResetEventArray(fences.Length);
            for (int32 i = 0; i < fences.Length; i++)
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

        private ManualResetEvent[] GetResetEventArray(int32 length)
        {
            lock (_resetEventsLock)
            {
                for (int32 i = _resetEvents.Count - 1; i > 0; i--)
                {
                    ManualResetEvent[] array = _resetEvents[i];
                    if (array.Length == length)
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
            lock (_resetEventsLock)
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
                        if (defaultDevice.NativePtr != IntPtr.Zero)
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
            lock (_unalignedBufferCopyPipelineLock)
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
                    string name = MetalFeatures.IsMacOS ? UnalignedBufferCopyPipelineMacOSName : UnalignedBufferCopyPipelineiOSName;
                    using (Stream resourceStream = typeof(MTLGraphicsDevice).Assembly.GetManifestResourceStream(name))
                    {
                        uint8[] data = new uint8[resourceStream.Length];
                        using (MemoryStream ms = new MemoryStream(data))
                        {
                            resourceStream.CopyTo(ms);
                            ShaderDescription shaderDesc = new ShaderDescription(ShaderStages.Compute, data, "copy_bytes");
                            _unalignedBufferCopyShader = new MTLShader(ref shaderDesc, this);
                        }
                    }

                    descriptor.computeFunction = _unalignedBufferCopyShader.Function;
                    _unalignedBufferCopyPipeline = _device.newComputePipelineStateWithDescriptor(descriptor);
                    ObjectiveCRuntime.release(descriptor.NativePtr);
                }

                return _unalignedBufferCopyPipeline;
            }
        }

        internal override uint32 GetUniformBufferMinOffsetAlignmentCore() => MetalFeatures.IsMacOS ? 16u : 256u;
        internal override uint32 GetStructuredBufferMinOffsetAlignmentCore() => 16u;
    }

    internal sealed class MonoPInvokeCallbackAttribute : Attribute
    {
        public MonoPInvokeCallbackAttribute(Type t) { }
    }
}
