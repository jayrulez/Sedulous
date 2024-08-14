using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
    public struct MTLDevice
    {
        private const String MetalFramework = "/System/Library/Frameworks/Metal.framework/Metal";

        public readonly void* NativePtr;
        public static implicit operator void*(MTLDevice device) => device.NativePtr;
        public this(void* nativePtr) => NativePtr = nativePtr;

		//public String name => string_objc_msgSend(NativePtr, sel_name);
        public void name(String str) => string_objc_msgSend(NativePtr, sel_name, str);
        public MTLSize maxThreadsPerThreadgroup
        {
            get
            {
                if (UseStret<MTLSize>())
                {
                    return objc_msgSend_stret<MTLSize>(this, sel_maxThreadsPerThreadgroup);
                }
                else
                {
                    return MTLSize_objc_msgSend(this, sel_maxThreadsPerThreadgroup);
                }
            }
        }

        public MTLLibrary newLibraryWithSource(String source, MTLCompileOptions options)
        {
            NSString sourceNSS = NSString.New(source);

            void* library = IntPtr_objc_msgSend(NativePtr, sel_newLibraryWithSource,
                sourceNSS,
                options,
                var error);

            release(sourceNSS.NativePtr);

            if (library == null)
            {
                Runtime.FatalError(scope $"Shader compilation failed: {error.localizedDescription(.. scope .())}");
            }

            return MTLLibrary(library);
        }

        public MTLLibrary newLibraryWithData(DispatchData data)
        {
            void* library = IntPtr_objc_msgSend(NativePtr, sel_newLibraryWithData, data.NativePtr, var error);

            if (library == null)
            {
                Runtime.FatalError(scope $"Unable to load Metal library: {error.localizedDescription(.. scope .())}");
            }

            return MTLLibrary(library);
        }

        public MTLRenderPipelineState newRenderPipelineStateWithDescriptor(MTLRenderPipelineDescriptor desc)
        {
            void* ret = IntPtr_objc_msgSend(NativePtr, sel_newRenderPipelineStateWithDescriptor,
                desc.NativePtr,
                var error);

            if (error.NativePtr != null)
            {
                Runtime.FatalError(scope $"Failed to create new MTLRenderPipelineState: {error.localizedDescription(.. scope .())}");
            }

            return MTLRenderPipelineState(ret);
        }

        public MTLComputePipelineState newComputePipelineStateWithDescriptor(
            MTLComputePipelineDescriptor descriptor)
        {
            void* ret = IntPtr_objc_msgSend(NativePtr, sel_newComputePipelineStateWithDescriptor,
                descriptor,
                0,
                null,
                var error);

            if (error.NativePtr != null)
            {
                Runtime.FatalError(scope $"Failed to create new MTLRenderPipelineState: {error.localizedDescription(.. scope .())}");
            }

            return MTLComputePipelineState(ret);
        }

        public MTLCommandQueue newCommandQueue() => objc_msgSend<MTLCommandQueue>(NativePtr, sel_newCommandQueue);

        public MTLBuffer newBuffer(void* pointer, uint length, MTLResourceOptions options)
        {
            void* buffer = IntPtr_objc_msgSend(NativePtr, sel_newBufferWithBytes,
                pointer,
                length,
                options);
            return MTLBuffer(buffer);
        }

        public MTLBuffer newBufferWithLengthOptions(uint length, MTLResourceOptions options)
        {
            void* buffer = IntPtr_objc_msgSend(NativePtr, sel_newBufferWithLength, length, options);
            return MTLBuffer(buffer);
        }

        public MTLTexture newTextureWithDescriptor(MTLTextureDescriptor descriptor)
            => objc_msgSend<MTLTexture>(NativePtr, sel_newTextureWithDescriptor, descriptor.NativePtr);

        public MTLSamplerState newSamplerStateWithDescriptor(MTLSamplerDescriptor descriptor)
            => objc_msgSend<MTLSamplerState>(NativePtr, sel_newSamplerStateWithDescriptor, descriptor.NativePtr);

        public MTLDepthStencilState newDepthStencilStateWithDescriptor(MTLDepthStencilDescriptor descriptor)
            => objc_msgSend<MTLDepthStencilState>(NativePtr, sel_newDepthStencilStateWithDescriptor, descriptor.NativePtr);

        public Bool8 supportsTextureSampleCount(uint sampleCount)
            => bool8_objc_msgSend(NativePtr, sel_supportsTextureSampleCount, sampleCount);

        public Bool8 supportsFeatureSet(MTLFeatureSet featureSet)
            => bool8_objc_msgSend(NativePtr, sel_supportsFeatureSet, (uint32)featureSet);

        public Bool8 isDepth24Stencil8PixelFormatSupported
            => bool8_objc_msgSend(NativePtr, sel_isDepth24Stencil8PixelFormatSupported);

        [Import(MetalFramework)]
        public static extern MTLDevice MTLCreateSystemDefaultDevice();

        [Import(MetalFramework)]
        public static extern NSArray MTLCopyAllDevices();

        private static readonly Selector sel_name = "name";
        private static readonly Selector sel_maxThreadsPerThreadgroup = "maxThreadsPerThreadgroup";
        private static readonly Selector sel_newLibraryWithSource = "newLibraryWithSource:options:error:";
        private static readonly Selector sel_newLibraryWithData = "newLibraryWithData:error:";
        private static readonly Selector sel_newRenderPipelineStateWithDescriptor = "newRenderPipelineStateWithDescriptor:error:";
        private static readonly Selector sel_newComputePipelineStateWithDescriptor = "newComputePipelineStateWithDescriptor:options:reflection:error:";
        private static readonly Selector sel_newCommandQueue = "newCommandQueue";
        private static readonly Selector sel_newBufferWithBytes = "newBufferWithBytes:length:options:";
        private static readonly Selector sel_newBufferWithLength = "newBufferWithLength:options:";
        private static readonly Selector sel_newTextureWithDescriptor = "newTextureWithDescriptor:";
        private static readonly Selector sel_newSamplerStateWithDescriptor = "newSamplerStateWithDescriptor:";
        private static readonly Selector sel_newDepthStencilStateWithDescriptor = "newDepthStencilStateWithDescriptor:";
        private static readonly Selector sel_supportsTextureSampleCount = "supportsTextureSampleCount:";
        private static readonly Selector sel_supportsFeatureSet = "supportsFeatureSet:";
        private static readonly Selector sel_isDepth24Stencil8PixelFormatSupported = "isDepth24Stencil8PixelFormatSupported";
    }
}