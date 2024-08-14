using System;
using static Sedulous.MetalBindings.ObjectiveCRuntime;

namespace Sedulous.MetalBindings
{
	using internal Sedulous.MetalBindings;

    public struct MTLComputeCommandEncoder
    {
        public readonly void* NativePtr;
        public bool IsNull => NativePtr == null;

        private static readonly Selector sel_setComputePipelineState = "setComputePipelineState:";
        private static readonly Selector sel_setBuffer = "setBuffer:offset:atIndex:";
        private static readonly Selector sel_dispatchThreadgroups0 = "dispatchThreadgroups:threadsPerThreadgroup:";
        private static readonly Selector sel_dispatchThreadgroups1 = "dispatchThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerThreadgroup:";
        private static readonly Selector sel_endEncoding = "endEncoding";
        private static readonly Selector sel_setTexture = "setTexture:atIndex:";
        private static readonly Selector sel_setSamplerState = "setSamplerState:atIndex:";
        private static readonly Selector sel_setBytes = "setBytes:length:atIndex:";

        public void setComputePipelineState(MTLComputePipelineState state)
            => objc_msgSend(NativePtr, sel_setComputePipelineState, state.NativePtr);

        public void setBuffer(MTLBuffer buffer, uint offset, uint index)
            => objc_msgSend(NativePtr, sel_setBuffer,
                buffer.NativePtr,
                offset,
                index);

        public void setBytes(void* bytes, uint length, uint index)
            => objc_msgSend(NativePtr, sel_setBytes, bytes, length, index);

        public void dispatchThreadGroups(MTLSize threadgroupsPerGrid, MTLSize threadsPerThreadgroup)
            => objc_msgSend(NativePtr, sel_dispatchThreadgroups0, threadgroupsPerGrid, threadsPerThreadgroup);

        public void dispatchThreadgroupsWithIndirectBuffer(
            MTLBuffer indirectBuffer,
            uint indirectBufferOffset,
            MTLSize threadsPerThreadgroup)
            => objc_msgSend(NativePtr, sel_dispatchThreadgroups1,
                indirectBuffer.NativePtr,
                indirectBufferOffset,
                threadsPerThreadgroup);

        public void endEncoding() => objc_msgSend(NativePtr, sel_endEncoding);

        public void setTexture(MTLTexture texture, uint index)
            => objc_msgSend(NativePtr, sel_setTexture, texture.NativePtr, index);

        public void setSamplerState(MTLSamplerState sampler, uint index)
            => objc_msgSend(NativePtr, sel_setSamplerState, sampler.NativePtr, index);

        public void pushDebugGroup(NSString @string)
            => objc_msgSend(NativePtr, Selectors.pushDebugGroup, @string.NativePtr);

        public void popDebugGroup() => objc_msgSend(NativePtr, Selectors.popDebugGroup);

        public void insertDebugSignpost(NSString @string)
            => objc_msgSend(NativePtr, Selectors.insertDebugSignpost, @string.NativePtr);
    }
}
