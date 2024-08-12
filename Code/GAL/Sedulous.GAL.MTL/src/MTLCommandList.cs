using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using Sedulous.MetalBindings;

namespace Sedulous.GAL.MTL
{
    internal class MTLCommandList : CommandList
    {
        private readonly MTLGraphicsDevice _gd;
        private MTLCommandBuffer _cb;
        private MTLFramebufferBase _mtlFramebuffer;
        private uint32 _viewportCount;
        private bool _currentFramebufferEverActive;
        private MTLRenderCommandEncoder _rce;
        private MTLBlitCommandEncoder _bce;
        private MTLComputeCommandEncoder _cce;
        private RgbaFloat?[] _clearColors = Array.Empty<RgbaFloat?>();
        private (float depth, uint8 stencil)? _clearDepth;
        private MTLBuffer _indexBuffer;
        private uint32 _ibOffset;
        private MTLIndexType _indexType;
        private new MTLPipeline _graphicsPipeline;
        private bool _graphicsPipelineChanged;
        private new MTLPipeline _computePipeline;
        private bool _computePipelineChanged;
        private MTLViewport[] _viewports = Array.Empty<MTLViewport>();
        private bool _viewportsChanged;
        private MTLScissorRect[] _scissorRects = Array.Empty<MTLScissorRect>();
        private bool _scissorRectsChanged;
        private uint32 _graphicsResourceSetCount;
        private BoundResourceSetInfo[] _graphicsResourceSets;
        private bool[] _graphicsResourceSetsActive;
        private uint32 _computeResourceSetCount;
        private BoundResourceSetInfo[] _computeResourceSets;
        private bool[] _computeResourceSetsActive;
        private uint32 _vertexBufferCount;
        private uint32 _nonVertexBufferCount;
        private MTLBuffer[] _vertexBuffers;
        private uint32[] _vbOffsets;
        private bool[] _vertexBuffersActive;
        private bool _disposed;

        public MTLCommandBuffer CommandBuffer => _cb;

        public MTLCommandList(ref CommandListDescription description, MTLGraphicsDevice gd)
            : base(ref description, gd.Features, gd.UniformBufferMinOffsetAlignment, gd.StructuredBufferMinOffsetAlignment)
        {
            _gd = gd;
        }

        public override string Name { get; set; }

        public override bool IsDisposed => _disposed;

        public MTLCommandBuffer Commit()
        {
            _cb.commit();
            MTLCommandBuffer ret = _cb;
            _cb = default(MTLCommandBuffer);
            return ret;
        }

        public override void Begin()
        {
            if (_cb.NativePtr != IntPtr.Zero)
            {
                ObjectiveCRuntime.release(_cb.NativePtr);
            }

            using (NSAutoreleasePool.Begin())
            {
                _cb = _gd.CommandQueue.commandBuffer();
                ObjectiveCRuntime.retain(_cb.NativePtr);
            }

            ClearCachedState();
        }

        private protected override void ClearColorTargetCore(uint32 index, RgbaFloat clearColor)
        {
            EnsureNoRenderPass();
            _clearColors[index] = clearColor;
        }

        private protected override void ClearDepthStencilCore(float depth, uint8 stencil)
        {
            EnsureNoRenderPass();
            _clearDepth = (depth, stencil);
        }

        public override void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            PreComputeCommand();
            _cce.dispatchThreadGroups(
                new MTLSize(groupCountX, groupCountY, groupCountZ),
                _computePipeline.ThreadsPerThreadgroup);
        }

        private protected override void DrawCore(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            if (PreDrawCommand())
            {
                if (instanceStart == 0)
                {
                    _rce.drawPrimitives(
                        _graphicsPipeline.PrimitiveType,
                        (UIntPtr)vertexStart,
                        (UIntPtr)vertexCount,
                        (UIntPtr)instanceCount);
                }
                else
                {
                    _rce.drawPrimitives(
                        _graphicsPipeline.PrimitiveType,
                        (UIntPtr)vertexStart,
                        (UIntPtr)vertexCount,
                        (UIntPtr)instanceCount,
                        (UIntPtr)instanceStart);

                }
            }
        }

        private protected override void DrawIndexedCore(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            if (PreDrawCommand())
            {
                uint32 indexSize = _indexType == MTLIndexType.UInt16 ? 2u : 4u;
                uint32 indexBufferOffset = (indexSize * indexStart) + _ibOffset;

                if (vertexOffset == 0 && instanceStart == 0)
                {
                    _rce.drawIndexedPrimitives(
                        _graphicsPipeline.PrimitiveType,
                        (UIntPtr)indexCount,
                        _indexType,
                        _indexBuffer.DeviceBuffer,
                        (UIntPtr)indexBufferOffset,
                        (UIntPtr)instanceCount);
                }
                else
                {
                    _rce.drawIndexedPrimitives(
                        _graphicsPipeline.PrimitiveType,
                        (UIntPtr)indexCount,
                        _indexType,
                        _indexBuffer.DeviceBuffer,
                        (UIntPtr)indexBufferOffset,
                        (UIntPtr)instanceCount,
                        (IntPtr)vertexOffset,
                        (UIntPtr)instanceStart);
                }
            }
        }
        private bool PreDrawCommand()
        {
            if (EnsureRenderPass())
            {
                if (_viewportsChanged)
                {
                    FlushViewports();
                    _viewportsChanged = false;
                }
                if (_scissorRectsChanged && _graphicsPipeline.ScissorTestEnabled)
                {
                    FlushScissorRects();
                    _scissorRectsChanged = false;
                }
                if (_graphicsPipelineChanged)
                {
                    Debug.Assert(_graphicsPipeline != null);
                    _rce.setRenderPipelineState(_graphicsPipeline.RenderPipelineState);
                    _rce.setCullMode(_graphicsPipeline.CullMode);
                    _rce.setFrontFacing(_graphicsPipeline.FrontFace);
                    _rce.setTriangleFillMode(_graphicsPipeline.FillMode);
                    RgbaFloat blendColor = _graphicsPipeline.BlendColor;
                    _rce.setBlendColor(blendColor.R, blendColor.G, blendColor.B, blendColor.A);
                    if (_framebuffer.DepthTarget != null)
                    {
                        _rce.setDepthStencilState(_graphicsPipeline.DepthStencilState);
                        _rce.setDepthClipMode(_graphicsPipeline.DepthClipMode);
                        _rce.setStencilReferenceValue(_graphicsPipeline.StencilReference);
                    }
                }

                for (uint32 i = 0; i < _graphicsResourceSetCount; i++)
                {
                    if (!_graphicsResourceSetsActive[i])
                    {
                        ActivateGraphicsResourceSet(i, _graphicsResourceSets[i]);
                        _graphicsResourceSetsActive[i] = true;
                    }
                }

                for (uint32 i = 0; i < _vertexBufferCount; i++)
                {
                    if (!_vertexBuffersActive[i])
                    {
                        UIntPtr index = (UIntPtr)(_graphicsPipeline.ResourceBindingModel == ResourceBindingModel.Improved
                            ? _nonVertexBufferCount + i
                            : i);
                        _rce.setVertexBuffer(
                            _vertexBuffers[i].DeviceBuffer,
                            (UIntPtr)_vbOffsets[i],
                            index);
                    }
                }
                return true;
            }
            return false;
        }


        private void FlushViewports()
        {
            if (_gd.MetalFeatures.IsSupported(MTLFeatureSet.macOS_GPUFamily1_v3))
            {
                fixed (MTLViewport* viewportsPtr = &_viewports[0])
                {
                    _rce.setViewports(viewportsPtr, (UIntPtr)_viewportCount);
                }
            }
            else
            {
                _rce.setViewport(_viewports[0]);
            }
        }

        private void FlushScissorRects()
        {
            if (_gd.MetalFeatures.IsSupported(MTLFeatureSet.macOS_GPUFamily1_v3))
            {
                fixed (MTLScissorRect* scissorRectsPtr = &_scissorRects[0])
                {
                    _rce.setScissorRects(scissorRectsPtr, (UIntPtr)_viewportCount);
                }
            }
            else
            {
                _rce.setScissorRect(_scissorRects[0]);
            }
        }

        private void PreComputeCommand()
        {
            EnsureComputeEncoder();
            if (_computePipelineChanged)
            {
                _cce.setComputePipelineState(_computePipeline.ComputePipelineState);
            }

            for (uint32 i = 0; i < _computeResourceSetCount; i++)
            {
                if (!_computeResourceSetsActive[i])
                {
                    ActivateComputeResourceSet(i, _computeResourceSets[i]);
                    _computeResourceSetsActive[i] = true;
                }
            }
        }

        public override void End()
        {
            EnsureNoBlitEncoder();
            EnsureNoComputeEncoder();

            if (!_currentFramebufferEverActive && _mtlFramebuffer != null)
            {
                BeginCurrentRenderPass();
            }
            EnsureNoRenderPass();
        }

        private protected override void SetPipelineCore(Pipeline pipeline)
        {
            if (pipeline.IsComputePipeline)
            {
                _computePipeline = Util.AssertSubtype<Pipeline, MTLPipeline>(pipeline);
                _computeResourceSetCount = (uint32)_computePipeline.ResourceLayouts.Length;
                Util.EnsureArrayMinimumSize(ref _computeResourceSets, _computeResourceSetCount);
                Util.EnsureArrayMinimumSize(ref _computeResourceSetsActive, _computeResourceSetCount);
                Util.ClearArray(_computeResourceSetsActive);
                _computePipelineChanged = true;
            }
            else
            {
                _graphicsPipeline = Util.AssertSubtype<Pipeline, MTLPipeline>(pipeline);
                _graphicsResourceSetCount = (uint32)_graphicsPipeline.ResourceLayouts.Length;
                Util.EnsureArrayMinimumSize(ref _graphicsResourceSets, _graphicsResourceSetCount);
                Util.EnsureArrayMinimumSize(ref _graphicsResourceSetsActive, _graphicsResourceSetCount);
                Util.ClearArray(_graphicsResourceSetsActive);

                _nonVertexBufferCount = _graphicsPipeline.NonVertexBufferCount;

                _vertexBufferCount = _graphicsPipeline.VertexBufferCount;
                Util.EnsureArrayMinimumSize(ref _vertexBuffers, _vertexBufferCount);
                Util.EnsureArrayMinimumSize(ref _vbOffsets, _vertexBufferCount);
                Util.EnsureArrayMinimumSize(ref _vertexBuffersActive, _vertexBufferCount);
                Util.ClearArray(_vertexBuffersActive);

                _graphicsPipelineChanged = true;
            }
        }

        public override void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            _scissorRectsChanged = true;
            _scissorRects[index] = new MTLScissorRect(x, y, width, height);
        }

        public override void SetViewport(uint32 index, ref Viewport viewport)
        {
            _viewportsChanged = true;
            _viewports[index] = new MTLViewport(
                viewport.X,
                viewport.Y,
                viewport.Width,
                viewport.Height,
                viewport.MinDepth,
                viewport.MaxDepth);
        }

        private protected override void UpdateBufferCore(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr source, uint32 sizeInBytes)
        {
            bool useComputeCopy = (bufferOffsetInBytes % 4 != 0)
                || (sizeInBytes % 4 != 0 && bufferOffsetInBytes != 0 && sizeInBytes != buffer.SizeInBytes);

            MTLBuffer dstMTLBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(buffer);
            // TODO: Cache these, and rely on the command buffer's completion callback to add them back to a shared pool.
            MTLBuffer copySrc = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(
                _gd.ResourceFactory.CreateBuffer(new BufferDescription(sizeInBytes, BufferUsage.Staging)));
            _gd.UpdateBuffer(copySrc, 0, source, sizeInBytes);

            if (useComputeCopy)
            {
                CopyBufferCore(copySrc, 0, buffer, bufferOffsetInBytes, sizeInBytes);
            }
            else
            {
                Debug.Assert(bufferOffsetInBytes % 4 == 0);
                uint32 sizeRoundFactor = (4 - (sizeInBytes % 4)) % 4;
                EnsureBlitEncoder();
                _bce.copy(
                    copySrc.DeviceBuffer, UIntPtr.Zero,
                    dstMTLBuffer.DeviceBuffer, (UIntPtr)bufferOffsetInBytes,
                    (UIntPtr)(sizeInBytes + sizeRoundFactor));
            }

            copySrc.Dispose();
        }

        protected override void CopyBufferCore(
            DeviceBuffer source,
            uint32 sourceOffset,
            DeviceBuffer destination,
            uint32 destinationOffset,
            uint32 sizeInBytes)
        {
            MTLBuffer mtlSrc = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(source);
            MTLBuffer mtlDst = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(destination);

            if (sourceOffset % 4 != 0 || destinationOffset % 4 != 0 || sizeInBytes % 4 != 0)
            {
                // Unaligned copy -- use special compute shader.
                EnsureComputeEncoder();
                _cce.setComputePipelineState(_gd.GetUnalignedBufferCopyPipeline());
                _cce.setBuffer(mtlSrc.DeviceBuffer, UIntPtr.Zero, (UIntPtr)0);
                _cce.setBuffer(mtlDst.DeviceBuffer, UIntPtr.Zero, (UIntPtr)1);

                MTLUnalignedBufferCopyInfo copyInfo;
                copyInfo.SourceOffset = sourceOffset;
                copyInfo.DestinationOffset = destinationOffset;
                copyInfo.CopySize = sizeInBytes;

                _cce.setBytes(&copyInfo, (UIntPtr)sizeof(MTLUnalignedBufferCopyInfo), (UIntPtr)2);
                _cce.dispatchThreadGroups(new MTLSize(1, 1, 1), new MTLSize(1, 1, 1));
            }
            else
            {
                EnsureBlitEncoder();
                _bce.copy(
                    mtlSrc.DeviceBuffer, (UIntPtr)sourceOffset,
                    mtlDst.DeviceBuffer, (UIntPtr)destinationOffset,
                    (UIntPtr)sizeInBytes);
            }
        }

        protected override void CopyTextureCore(
            Texture source, uint32 srcX, uint32 srcY, uint32 srcZ, uint32 srcMipLevel, uint32 srcBaseArrayLayer,
            Texture destination, uint32 dstX, uint32 dstY, uint32 dstZ, uint32 dstMipLevel, uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth, uint32 layerCount)
        {
            EnsureBlitEncoder();
            MTLTexture srcMTLTexture = Util.AssertSubtype<Texture, MTLTexture>(source);
            MTLTexture dstMTLTexture = Util.AssertSubtype<Texture, MTLTexture>(destination);

            bool srcIsStaging = (source.Usage & TextureUsage.Staging) != 0;
            bool dstIsStaging = (destination.Usage & TextureUsage.Staging) != 0;
            if (srcIsStaging && !dstIsStaging)
            {
                // Staging -> Normal
                MetalBindings.MTLBuffer srcBuffer = srcMTLTexture.StagingBuffer;
                MetalBindings.MTLTexture dstTexture = dstMTLTexture.DeviceTexture;

                Util.GetMipDimensions(srcMTLTexture, srcMipLevel, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    uint32 blockSize = FormatHelpers.IsCompressedFormat(srcMTLTexture.Format) ? 4u : 1u;
                    uint32 compressedSrcX = srcX / blockSize;
                    uint32 compressedSrcY = srcY / blockSize;
                    uint32 blockSizeInBytes = blockSize == 1
                        ? FormatSizeHelpers.GetSizeInBytes(srcMTLTexture.Format)
                        : FormatHelpers.GetBlockSizeInBytes(srcMTLTexture.Format);

                    uint64 srcSubresourceBase = Util.ComputeSubresourceOffset(
                        srcMTLTexture,
                        srcMipLevel,
                        layer + srcBaseArrayLayer);
                    srcMTLTexture.GetSubresourceLayout(
                        srcMipLevel,
                        srcBaseArrayLayer + layer,
                        out uint32 srcRowPitch,
                        out uint32 srcDepthPitch);
                    uint64 sourceOffset = srcSubresourceBase
                        + srcDepthPitch * srcZ
                        + srcRowPitch * compressedSrcY
                        + blockSizeInBytes * compressedSrcX;

                    uint32 copyWidth = width > mipWidth && width <= blockSize
                        ? mipWidth
                        : width;

                    uint32 copyHeight = height > mipHeight && height <= blockSize
                        ? mipHeight
                        : height;

                    MTLSize sourceSize = new MTLSize(copyWidth, copyHeight, depth);
                    if (dstMTLTexture.Type != TextureType.Texture3D)
                    {
                        srcDepthPitch = 0;
                    }
                    _bce.copyFromBuffer(
                        srcBuffer,
                        (UIntPtr)sourceOffset,
                        (UIntPtr)srcRowPitch,
                        (UIntPtr)srcDepthPitch,
                        sourceSize,
                        dstTexture,
                        (UIntPtr)(dstBaseArrayLayer + layer),
                        (UIntPtr)dstMipLevel,
                        new MTLOrigin(dstX, dstY, dstZ));
                }
            }
            else if (srcIsStaging && dstIsStaging)
            {
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    // Staging -> Staging
                    uint64 srcSubresourceBase = Util.ComputeSubresourceOffset(
                        srcMTLTexture,
                        srcMipLevel,
                        layer + srcBaseArrayLayer);
                    srcMTLTexture.GetSubresourceLayout(
                        srcMipLevel,
                        srcBaseArrayLayer + layer,
                        out uint32 srcRowPitch,
                        out uint32 srcDepthPitch);

                    uint64 dstSubresourceBase = Util.ComputeSubresourceOffset(
                        dstMTLTexture,
                        dstMipLevel,
                        layer + dstBaseArrayLayer);
                    dstMTLTexture.GetSubresourceLayout(
                        dstMipLevel,
                        dstBaseArrayLayer + layer,
                        out uint32 dstRowPitch,
                        out uint32 dstDepthPitch);

                    uint32 blockSize = FormatHelpers.IsCompressedFormat(dstMTLTexture.Format) ? 4u : 1u;
                    if (blockSize == 1)
                    {
                        uint32 pixelSize = FormatSizeHelpers.GetSizeInBytes(dstMTLTexture.Format);
                        uint32 copySize = width * pixelSize;
                        for (uint32 zz = 0; zz < depth; zz++)
                            for (uint32 yy = 0; yy < height; yy++)
                            {
                                uint64 srcRowOffset = srcSubresourceBase
                                    + srcDepthPitch * (zz + srcZ)
                                    + srcRowPitch * (yy + srcY)
                                    + pixelSize * srcX;
                                uint64 dstRowOffset = dstSubresourceBase
                                    + dstDepthPitch * (zz + dstZ)
                                    + dstRowPitch * (yy + dstY)
                                    + pixelSize * dstX;
                                _bce.copy(
                                    srcMTLTexture.StagingBuffer,
                                    (UIntPtr)srcRowOffset,
                                    dstMTLTexture.StagingBuffer,
                                    (UIntPtr)dstRowOffset,
                                    (UIntPtr)copySize);
                            }
                    }
                    else // blockSize != 1
                    {
                        uint32 paddedWidth = Math.Max(blockSize, width);
                        uint32 paddedHeight = Math.Max(blockSize, height);
                        uint32 numRows = FormatHelpers.GetNumRows(paddedHeight, srcMTLTexture.Format);
                        uint32 rowPitch = FormatHelpers.GetRowPitch(paddedWidth, srcMTLTexture.Format);

                        uint32 compressedSrcX = srcX / 4;
                        uint32 compressedSrcY = srcY / 4;
                        uint32 compressedDstX = dstX / 4;
                        uint32 compressedDstY = dstY / 4;
                        uint32 blockSizeInBytes = FormatHelpers.GetBlockSizeInBytes(srcMTLTexture.Format);

                        for (uint32 zz = 0; zz < depth; zz++)
                            for (uint32 row = 0; row < numRows; row++)
                            {
                                uint64 srcRowOffset = srcSubresourceBase
                                    + srcDepthPitch * (zz + srcZ)
                                    + srcRowPitch * (row + compressedSrcY)
                                    + blockSizeInBytes * compressedSrcX;
                                uint64 dstRowOffset = dstSubresourceBase
                                    + dstDepthPitch * (zz + dstZ)
                                    + dstRowPitch * (row + compressedDstY)
                                    + blockSizeInBytes * compressedDstX;
                                _bce.copy(
                                    srcMTLTexture.StagingBuffer,
                                    (UIntPtr)srcRowOffset,
                                    dstMTLTexture.StagingBuffer,
                                    (UIntPtr)dstRowOffset,
                                    (UIntPtr)rowPitch);
                            }
                    }
                }
            }
            else if (!srcIsStaging && dstIsStaging)
            {
                // Normal -> Staging
                MTLOrigin srcOrigin = new MTLOrigin(srcX, srcY, srcZ);
                MTLSize srcSize = new MTLSize(width, height, depth);
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    dstMTLTexture.GetSubresourceLayout(
                        dstMipLevel,
                        dstBaseArrayLayer + layer,
                        out uint32 dstBytesPerRow,
                        out uint32 dstBytesPerImage);

                    Util.GetMipDimensions(srcMTLTexture, dstMipLevel, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);
                    uint32 blockSize = FormatHelpers.IsCompressedFormat(srcMTLTexture.Format) ? 4u : 1u;
                    uint32 bufferRowLength = Math.Max(mipWidth, blockSize);
                    uint32 bufferImageHeight = Math.Max(mipHeight, blockSize);
                    uint32 compressedDstX = dstX / blockSize;
                    uint32 compressedDstY = dstY / blockSize;
                    uint32 blockSizeInBytes = blockSize == 1
                        ? FormatSizeHelpers.GetSizeInBytes(srcMTLTexture.Format)
                        : FormatHelpers.GetBlockSizeInBytes(srcMTLTexture.Format);
                    uint32 rowPitch = FormatHelpers.GetRowPitch(bufferRowLength, srcMTLTexture.Format);
                    uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, bufferImageHeight, srcMTLTexture.Format);

                    uint64 dstOffset = Util.ComputeSubresourceOffset(dstMTLTexture, dstMipLevel, dstBaseArrayLayer + layer)
                        + (dstZ * depthPitch)
                        + (compressedDstY * rowPitch)
                        + (compressedDstX * blockSizeInBytes);

                    _bce.copyTextureToBuffer(
                        srcMTLTexture.DeviceTexture,
                        (UIntPtr)(srcBaseArrayLayer + layer),
                        (UIntPtr)srcMipLevel,
                        srcOrigin,
                        srcSize,
                        dstMTLTexture.StagingBuffer,
                        (UIntPtr)dstOffset,
                        (UIntPtr)dstBytesPerRow,
                        (UIntPtr)dstBytesPerImage);
                }
            }
            else
            {
                // Normal -> Normal
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    _bce.copyFromTexture(
                        srcMTLTexture.DeviceTexture,
                        (UIntPtr)(srcBaseArrayLayer + layer),
                        (UIntPtr)srcMipLevel,
                        new MTLOrigin(srcX, srcY, srcZ),
                        new MTLSize(width, height, depth),
                        dstMTLTexture.DeviceTexture,
                        (UIntPtr)(dstBaseArrayLayer + layer),
                        (UIntPtr)dstMipLevel,
                        new MTLOrigin(dstX, dstY, dstZ));
                }
            }
        }

        private protected override void GenerateMipmapsCore(Texture texture)
        {
            Debug.Assert(texture.MipLevels > 1);
            EnsureBlitEncoder();
            MTLTexture mtlTex = Util.AssertSubtype<Texture, MTLTexture>(texture);
            _bce.generateMipmapsForTexture(mtlTex.DeviceTexture);
        }

        protected override void DispatchIndirectCore(DeviceBuffer indirectBuffer, uint32 offset)
        {
            MTLBuffer mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(indirectBuffer);
            PreComputeCommand();
            _cce.dispatchThreadgroupsWithIndirectBuffer(
                mtlBuffer.DeviceBuffer,
                (UIntPtr)offset,
                _computePipeline.ThreadsPerThreadgroup);
        }

        protected override void DrawIndexedIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            if (PreDrawCommand())
            {
                MTLBuffer mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(indirectBuffer);
                for (uint32 i = 0; i < drawCount; i++)
                {
                    uint32 currentOffset = i * stride + offset;
                    _rce.drawIndexedPrimitives(
                        _graphicsPipeline.PrimitiveType,
                        _indexType,
                        _indexBuffer.DeviceBuffer,
                        (UIntPtr)_ibOffset,
                        mtlBuffer.DeviceBuffer,
                        (UIntPtr)currentOffset);
                }
            }
        }

        protected override void DrawIndirectCore(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            if (PreDrawCommand())
            {
                MTLBuffer mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(indirectBuffer);
                for (uint32 i = 0; i < drawCount; i++)
                {
                    uint32 currentOffset = i * stride + offset;
                    _rce.drawPrimitives(_graphicsPipeline.PrimitiveType, mtlBuffer.DeviceBuffer, (UIntPtr)currentOffset);
                }
            }
        }

        protected override void ResolveTextureCore(Texture source, Texture destination)
        {
            // TODO: This approach destroys the contents of the source Texture (according to the docs).
            EnsureNoBlitEncoder();
            EnsureNoRenderPass();

            MTLTexture mtlSrc = Util.AssertSubtype<Texture, MTLTexture>(source);
            MTLTexture mtlDst = Util.AssertSubtype<Texture, MTLTexture>(destination);

            MTLRenderPassDescriptor rpDesc = MTLRenderPassDescriptor.New();
            var colorAttachment = rpDesc.colorAttachments[0];
            colorAttachment.texture = mtlSrc.DeviceTexture;
            colorAttachment.loadAction = MTLLoadAction.Load;
            colorAttachment.storeAction = MTLStoreAction.MultisampleResolve;
            colorAttachment.resolveTexture = mtlDst.DeviceTexture;

            using (NSAutoreleasePool.Begin())
            {
                MTLRenderCommandEncoder encoder = _cb.renderCommandEncoderWithDescriptor(rpDesc);
                encoder.endEncoding();
            }

            ObjectiveCRuntime.release(rpDesc.NativePtr);
        }

        protected override void SetComputeResourceSetCore(uint32 slot, ResourceSet set, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            if (!_computeResourceSets[slot].Equals(set, dynamicOffsetCount, ref dynamicOffsets))
            {
                _computeResourceSets[slot].Offsets.Dispose();
                _computeResourceSets[slot] = new BoundResourceSetInfo(set, dynamicOffsetCount, ref dynamicOffsets);
                _computeResourceSetsActive[slot] = false;
            }
        }

        protected override void SetFramebufferCore(Framebuffer fb)
        {
            if (!_currentFramebufferEverActive && _mtlFramebuffer != null)
            {
                // This ensures that any submitted clear values will be used even if nothing has been drawn.
                if (EnsureRenderPass())
                {
                    EndCurrentRenderPass();
                }
            }

            EnsureNoRenderPass();
            _mtlFramebuffer = Util.AssertSubtype<Framebuffer, MTLFramebufferBase>(fb);
            _viewportCount = Math.Max(1u, (uint32)fb.ColorTargets.Count);
            Util.EnsureArrayMinimumSize(ref _viewports, _viewportCount);
            Util.ClearArray(_viewports);
            Util.EnsureArrayMinimumSize(ref _scissorRects, _viewportCount);
            Util.ClearArray(_scissorRects);
            Util.EnsureArrayMinimumSize(ref _clearColors, (uint32)fb.ColorTargets.Count);
            Util.ClearArray(_clearColors);
            _currentFramebufferEverActive = false;
        }

        protected override void SetGraphicsResourceSetCore(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            if (!_graphicsResourceSets[slot].Equals(rs, dynamicOffsetCount, ref dynamicOffsets))
            {
                _graphicsResourceSets[slot].Offsets.Dispose();
                _graphicsResourceSets[slot] = new BoundResourceSetInfo(rs, dynamicOffsetCount, ref dynamicOffsets);
                _graphicsResourceSetsActive[slot] = false;
            }
        }

        private void ActivateGraphicsResourceSet(uint32 slot, BoundResourceSetInfo brsi)
        {
            Debug.Assert(RenderEncoderActive);
            MTLResourceSet mtlRS = Util.AssertSubtype<ResourceSet, MTLResourceSet>(brsi.Set);
            MTLResourceLayout layout = mtlRS.Layout;
            uint32 dynamicOffsetIndex = 0;

            for (int32 i = 0; i < mtlRS.Resources.Length; i++)
            {
                MTLResourceLayout.ResourceBindingInfo bindingInfo = layout.GetBindingInfo(i);
                BindableResource resource = mtlRS.Resources[i];
                uint32 bufferOffset = 0;
                if (bindingInfo.DynamicBuffer)
                {
                    bufferOffset = brsi.Offsets.Get(dynamicOffsetIndex);
                    dynamicOffsetIndex += 1;
                }
                switch (bindingInfo.Kind)
                {
                    case ResourceKind.UniformBuffer:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    case ResourceKind.TextureReadOnly:
                        TextureView texView = Util.GetTextureView(_gd, resource);
                        MTLTextureView mtlTexView = Util.AssertSubtype<TextureView, MTLTextureView>(texView);
                        BindTexture(mtlTexView, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.TextureReadWrite:
                        TextureView texViewRW = Util.GetTextureView(_gd, resource);
                        MTLTextureView mtlTexViewRW = Util.AssertSubtype<TextureView, MTLTextureView>(texViewRW);
                        BindTexture(mtlTexViewRW, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.Sampler:
                        MTLSampler mtlSampler = Util.AssertSubtype<BindableResource, MTLSampler>(resource);
                        BindSampler(mtlSampler, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.StructuredBufferReadOnly:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    case ResourceKind.StructuredBufferReadWrite:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    default:
                        Runtime.IllegalValue<ResourceKind>();
                }
            }
        }

        private void ActivateComputeResourceSet(uint32 slot, BoundResourceSetInfo brsi)
        {
            Debug.Assert(ComputeEncoderActive);
            MTLResourceSet mtlRS = Util.AssertSubtype<ResourceSet, MTLResourceSet>(brsi.Set);
            MTLResourceLayout layout = mtlRS.Layout;
            uint32 dynamicOffsetIndex = 0;

            for (int32 i = 0; i < mtlRS.Resources.Length; i++)
            {
                MTLResourceLayout.ResourceBindingInfo bindingInfo = layout.GetBindingInfo(i);
                BindableResource resource = mtlRS.Resources[i];
                uint32 bufferOffset = 0;
                if (bindingInfo.DynamicBuffer)
                {
                    bufferOffset = brsi.Offsets.Get(dynamicOffsetIndex);
                    dynamicOffsetIndex += 1;
                }

                switch (bindingInfo.Kind)
                {
                    case ResourceKind.UniformBuffer:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    case ResourceKind.TextureReadOnly:
                        TextureView texView = Util.GetTextureView(_gd, resource);
                        MTLTextureView mtlTexView = Util.AssertSubtype<TextureView, MTLTextureView>(texView);
                        BindTexture(mtlTexView, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.TextureReadWrite:
                        TextureView texViewRW = Util.GetTextureView(_gd, resource);
                        MTLTextureView mtlTexViewRW = Util.AssertSubtype<TextureView, MTLTextureView>(texViewRW);
                        BindTexture(mtlTexViewRW, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.Sampler:
                        MTLSampler mtlSampler = Util.AssertSubtype<BindableResource, MTLSampler>(resource);
                        BindSampler(mtlSampler, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    case ResourceKind.StructuredBufferReadOnly:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    case ResourceKind.StructuredBufferReadWrite:
                    {
                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        BindBuffer(range, slot, bindingInfo.Slot, bindingInfo.Stages);
                        break;
                    }
                    default:
                        Runtime.IllegalValue<ResourceKind>();
                }
            }
        }

        private void BindBuffer(DeviceBufferRange range, uint32 set, uint32 slot, ShaderStages stages)
        {
            MTLBuffer mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(range.Buffer);
            uint32 baseBuffer = GetBufferBase(set, stages != ShaderStages.Compute);
            if (stages == ShaderStages.Compute)
            {
                _cce.setBuffer(mtlBuffer.DeviceBuffer, (UIntPtr)range.Offset, (UIntPtr)(slot + baseBuffer));
            }
            else
            {
                if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
                {
                    UIntPtr index = (UIntPtr)(_graphicsPipeline.ResourceBindingModel == ResourceBindingModel.Improved
                        ? slot + baseBuffer
                        : slot + _vertexBufferCount + baseBuffer);
                    _rce.setVertexBuffer(mtlBuffer.DeviceBuffer, (UIntPtr)range.Offset, index);
                }
                if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
                {
                    _rce.setFragmentBuffer(mtlBuffer.DeviceBuffer, (UIntPtr)range.Offset, (UIntPtr)(slot + baseBuffer));
                }
            }
        }

        private void BindTexture(MTLTextureView mtlTexView, uint32 set, uint32 slot, ShaderStages stages)
        {
            uint32 baseTexture = GetTextureBase(set, stages != ShaderStages.Compute);
            if (stages == ShaderStages.Compute)
            {
                _cce.setTexture(mtlTexView.TargetDeviceTexture, (UIntPtr)(slot + baseTexture));
            }
            if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
            {
                _rce.setVertexTexture(mtlTexView.TargetDeviceTexture, (UIntPtr)(slot + baseTexture));
            }
            if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
            {
                _rce.setFragmentTexture(mtlTexView.TargetDeviceTexture, (UIntPtr)(slot + baseTexture));
            }
        }

        private void BindSampler(MTLSampler mtlSampler, uint32 set, uint32 slot, ShaderStages stages)
        {
            uint32 baseSampler = GetSamplerBase(set, stages != ShaderStages.Compute);
            if (stages == ShaderStages.Compute)
            {
                _cce.setSamplerState(mtlSampler.DeviceSampler, (UIntPtr)(slot + baseSampler));
            }
            if ((stages & ShaderStages.Vertex) == ShaderStages.Vertex)
            {
                _rce.setVertexSamplerState(mtlSampler.DeviceSampler, (UIntPtr)(slot + baseSampler));
            }
            if ((stages & ShaderStages.Fragment) == ShaderStages.Fragment)
            {
                _rce.setFragmentSamplerState(mtlSampler.DeviceSampler, (UIntPtr)(slot + baseSampler));
            }
        }

        private uint32 GetBufferBase(uint32 set, bool graphics)
        {
            MTLResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            uint32 ret = 0;
            for (int32 i = 0; i < set; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].BufferCount;
            }

            return ret;
        }

        private uint32 GetTextureBase(uint32 set, bool graphics)
        {
            MTLResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            uint32 ret = 0;
            for (int32 i = 0; i < set; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].TextureCount;
            }

            return ret;
        }

        private uint32 GetSamplerBase(uint32 set, bool graphics)
        {
            MTLResourceLayout[] layouts = graphics ? _graphicsPipeline.ResourceLayouts : _computePipeline.ResourceLayouts;
            uint32 ret = 0;
            for (int32 i = 0; i < set; i++)
            {
                Debug.Assert(layouts[i] != null);
                ret += layouts[i].SamplerCount;
            }

            return ret;
        }

        private bool EnsureRenderPass()
        {
            Debug.Assert(_mtlFramebuffer != null);
            EnsureNoBlitEncoder();
            EnsureNoComputeEncoder();
            return RenderEncoderActive || BeginCurrentRenderPass();
        }

        private bool RenderEncoderActive => !_rce.IsNull;
        private bool BlitEncoderActive => !_bce.IsNull;
        private bool ComputeEncoderActive => !_cce.IsNull;

        private bool BeginCurrentRenderPass()
        {
            if (!_mtlFramebuffer.IsRenderable)
            {
                return false;
            }

            MTLRenderPassDescriptor rpDesc = _mtlFramebuffer.CreateRenderPassDescriptor();
            for (uint32 i = 0; i < _clearColors.Length; i++)
            {
                if (_clearColors[i] != null)
                {
                    var attachment = rpDesc.colorAttachments[0];
                    attachment.loadAction = MTLLoadAction.Clear;
                    RgbaFloat c = _clearColors[i].Value;
                    attachment.clearColor = new MTLClearColor(c.R, c.G, c.B, c.A);
                    _clearColors[i] = null;
                }
            }

            if (_clearDepth != null)
            {
                MTLRenderPassDepthAttachmentDescriptor depthAttachment = rpDesc.depthAttachment;
                depthAttachment.loadAction = MTLLoadAction.Clear;
                depthAttachment.clearDepth = _clearDepth.Value.depth;

                if (FormatHelpers.IsStencilFormat(_mtlFramebuffer.DepthTarget.Value.Target.Format))
                {
                    MTLRenderPassStencilAttachmentDescriptor stencilAttachment = rpDesc.stencilAttachment;
                    stencilAttachment.loadAction = MTLLoadAction.Clear;
                    stencilAttachment.clearStencil = _clearDepth.Value.stencil;
                }

                _clearDepth = null;
            }

            using (NSAutoreleasePool.Begin())
            {
                _rce = _cb.renderCommandEncoderWithDescriptor(rpDesc);
                ObjectiveCRuntime.retain(_rce.NativePtr);
            }

            ObjectiveCRuntime.release(rpDesc.NativePtr);
            _currentFramebufferEverActive = true;

            return true;
        }

        private void EnsureNoRenderPass()
        {
            if (RenderEncoderActive)
            {
                EndCurrentRenderPass();
            }

            Debug.Assert(!RenderEncoderActive);
        }

        private void EndCurrentRenderPass()
        {
            _rce.endEncoding();
            ObjectiveCRuntime.release(_rce.NativePtr);
            _rce = default(MTLRenderCommandEncoder);
            _graphicsPipelineChanged = true;
            Util.ClearArray(_graphicsResourceSetsActive);
            _viewportsChanged = true;
            _scissorRectsChanged = true;
        }

        private void EnsureBlitEncoder()
        {
            if (!BlitEncoderActive)
            {
                EnsureNoRenderPass();
                EnsureNoComputeEncoder();
                using (NSAutoreleasePool.Begin())
                {
                    _bce = _cb.blitCommandEncoder();
                    ObjectiveCRuntime.retain(_bce.NativePtr);
                }
            }

            Debug.Assert(BlitEncoderActive);
            Debug.Assert(!RenderEncoderActive);
            Debug.Assert(!ComputeEncoderActive);
        }

        private void EnsureNoBlitEncoder()
        {
            if (BlitEncoderActive)
            {
                _bce.endEncoding();
                ObjectiveCRuntime.release(_bce.NativePtr);
                _bce = default(MTLBlitCommandEncoder);
            }

            Debug.Assert(!BlitEncoderActive);
        }

        private void EnsureComputeEncoder()
        {
            if (!ComputeEncoderActive)
            {
                EnsureNoBlitEncoder();
                EnsureNoRenderPass();

                using (NSAutoreleasePool.Begin())
                {
                    _cce = _cb.computeCommandEncoder();
                    ObjectiveCRuntime.retain(_cce.NativePtr);
                }
            }

            Debug.Assert(ComputeEncoderActive);
            Debug.Assert(!RenderEncoderActive);
            Debug.Assert(!BlitEncoderActive);
        }

        private void EnsureNoComputeEncoder()
        {
            if (ComputeEncoderActive)
            {
                _cce.endEncoding();
                ObjectiveCRuntime.release(_cce.NativePtr);
                _cce = default(MTLComputeCommandEncoder);
                _computePipelineChanged = true;
                Util.ClearArray(_computeResourceSetsActive);
            }

            Debug.Assert(!ComputeEncoderActive);
        }

        private protected override void SetIndexBufferCore(DeviceBuffer buffer, IndexFormat format, uint32 offset)
        {
            _indexBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(buffer);
            _ibOffset = offset;
            _indexType = MTLFormats.VdToMTLIndexFormat(format);
        }

        private protected override void SetVertexBufferCore(uint32 index, DeviceBuffer buffer, uint32 offset)
        {
            Util.EnsureArrayMinimumSize(ref _vertexBuffers, index + 1);
            Util.EnsureArrayMinimumSize(ref _vbOffsets, index + 1);
            Util.EnsureArrayMinimumSize(ref _vertexBuffersActive, index + 1);
            if (_vertexBuffers[index] != buffer || _vbOffsets[index] != offset)
            {
                MTLBuffer mtlBuffer = Util.AssertSubtype<DeviceBuffer, MTLBuffer>(buffer);
                _vertexBuffers[index] = mtlBuffer;
                _vbOffsets[index] = offset;
                _vertexBuffersActive[index] = false;
            }
        }

        private protected override void PushDebugGroupCore(string name)
        {
            NSString nsName = NSString.New(name);
            if (!_bce.IsNull)
            {
                _bce.pushDebugGroup(nsName);
            }
            else if (!_cce.IsNull)
            {
                _cce.pushDebugGroup(nsName);
            }
            else if (!_rce.IsNull)
            {
                _rce.pushDebugGroup(nsName);
            }

            ObjectiveCRuntime.release(nsName);
        }

        private protected override void PopDebugGroupCore()
        {
            if (!_bce.IsNull)
            {
                _bce.popDebugGroup();
            }
            else if (!_cce.IsNull)
            {
                _cce.popDebugGroup();
            }
            else if (!_rce.IsNull)
            {
                _rce.popDebugGroup();
            }
        }

        private protected override void InsertDebugMarkerCore(string name)
        {
            NSString nsName = NSString.New(name);
            if (!_bce.IsNull)
            {
                _bce.insertDebugSignpost(nsName);
            }
            else if (!_cce.IsNull)
            {
                _cce.insertDebugSignpost(nsName);
            }
            else if (!_rce.IsNull)
            {
                _rce.insertDebugSignpost(nsName);
            }

            ObjectiveCRuntime.release(nsName);
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                _disposed = true;
                EnsureNoRenderPass();
                if (_cb.NativePtr != IntPtr.Zero)
                {
                    ObjectiveCRuntime.release(_cb.NativePtr);
                }
            }
        }
    }
}
