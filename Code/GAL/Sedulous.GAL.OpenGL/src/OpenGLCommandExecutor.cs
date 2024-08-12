using System;
using static Sedulous.OpenGLBindings.OpenGLNative;
using static Sedulous.GAL.OpenGL.OpenGLUtil;
using Sedulous.OpenGLBindings;
using System.Text;

namespace Sedulous.GAL.OpenGL
{
    internal class OpenGLCommandExecutor
    {
        private readonly OpenGLGraphicsDevice _gd;
        private readonly GraphicsBackend _backend;
        private readonly OpenGLTextureSamplerManager _textureSamplerManager;
        private readonly StagingMemoryPool _stagingMemoryPool;
        private readonly OpenGLExtensions _extensions;
        private readonly OpenGLPlatformInfo _platformInfo;
        private readonly GraphicsDeviceFeatures _features;

        private Framebuffer _fb;
        private bool _isSwapchainFB;
        private OpenGLPipeline _graphicsPipeline;
        private BoundResourceSetInfo[] _graphicsResourceSets = Array.Empty<BoundResourceSetInfo>();
        private bool[] _newGraphicsResourceSets = Array.Empty<bool>();
        private OpenGLBuffer[] _vertexBuffers = Array.Empty<OpenGLBuffer>();
        private uint32[] _vbOffsets = Array.Empty<uint32>();
        private uint32[] _vertexAttribDivisors = Array.Empty<uint32>();
        private uint32 _vertexAttributesBound;
        private readonly Viewport[] _viewports = new Viewport[20];
        private DrawElementsType _drawElementsType;
        private uint32 _ibOffset;
        private PrimitiveType _primitiveType;

        private OpenGLPipeline _computePipeline;
        private BoundResourceSetInfo[] _computeResourceSets = Array.Empty<BoundResourceSetInfo>();
        private bool[] _newComputeResourceSets = Array.Empty<bool>();

        private bool _graphicsPipelineActive;
        private bool _vertexLayoutFlushed;

        public OpenGLCommandExecutor(OpenGLGraphicsDevice gd, OpenGLPlatformInfo platformInfo)
        {
            _gd = gd;
            _backend = gd.BackendType;
            _extensions = gd.Extensions;
            _textureSamplerManager = gd.TextureSamplerManager;
            _stagingMemoryPool = gd.StagingMemoryPool;
            _platformInfo = platformInfo;
            _features = gd.Features;
        }

        public void Begin()
        {
        }

        public void ClearColorTarget(uint32 index, RgbaFloat clearColor)
        {
            if (!_isSwapchainFB)
            {
                DrawBuffersEnum bufs = (DrawBuffersEnum)((uint32)DrawBuffersEnum.ColorAttachment0 + index);
                glDrawBuffers(1, &bufs);
                CheckLastError();
            }

            RgbaFloat color = clearColor;
            glClearColor(color.R, color.G, color.B, color.A);
            CheckLastError();

            if (_graphicsPipeline != null && _graphicsPipeline.RasterizerState.ScissorTestEnabled)
            {
                glDisable(EnableCap.ScissorTest);
                CheckLastError();
            }

            glClear(ClearBufferMask.ColorBufferBit);
            CheckLastError();

            if (_graphicsPipeline != null && _graphicsPipeline.RasterizerState.ScissorTestEnabled)
            {
                glEnable(EnableCap.ScissorTest);
            }

            if (!_isSwapchainFB)
            {
                int32 colorCount = _fb.ColorTargets.Count;
                DrawBuffersEnum* bufs = stackalloc DrawBuffersEnum[colorCount];
                for (int32 i = 0; i < colorCount; i++)
                {
                    bufs[i] = DrawBuffersEnum.ColorAttachment0 + i;
                }
                glDrawBuffers((uint32)colorCount, bufs);
                CheckLastError();
            }
        }

        public void ClearDepthStencil(float depth, uint8 stencil)
        {
            glClearDepth_Compat(depth);
            CheckLastError();

            glStencilMask(~0u);
            CheckLastError();

            glClearStencil(stencil);
            CheckLastError();

            if (_graphicsPipeline != null && _graphicsPipeline.RasterizerState.ScissorTestEnabled)
            {
                glDisable(EnableCap.ScissorTest);
                CheckLastError();
            }

            glDepthMask(true);
            glClear(ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit);
            CheckLastError();

            if (_graphicsPipeline != null && _graphicsPipeline.RasterizerState.ScissorTestEnabled)
            {
                glEnable(EnableCap.ScissorTest);
            }
        }

        public void Draw(uint32 vertexCount, uint32 instanceCount, uint32 vertexStart, uint32 instanceStart)
        {
            PreDrawCommand();

            if (instanceCount == 1 && instanceStart == 0)
            {
                glDrawArrays(_primitiveType, (int32)vertexStart, vertexCount);
                CheckLastError();
            }
            else
            {
                if (instanceStart == 0)
                {
                    glDrawArraysInstanced(_primitiveType, (int32)vertexStart, vertexCount, instanceCount);
                    CheckLastError();
                }
                else
                {
                    glDrawArraysInstancedBaseInstance(_primitiveType, (int32)vertexStart, vertexCount, instanceCount, instanceStart);
                    CheckLastError();
                }
            }
        }

        public void DrawIndexed(uint32 indexCount, uint32 instanceCount, uint32 indexStart, int32 vertexOffset, uint32 instanceStart)
        {
            PreDrawCommand();

            uint32 indexSize = _drawElementsType == DrawElementsType.UnsignedShort ? 2u : 4u;
            void* indices = (void*)((indexStart * indexSize) + _ibOffset);

            if (instanceCount == 1 && instanceStart == 0)
            {
                if (vertexOffset == 0)
                {
                    glDrawElements(_primitiveType, indexCount, _drawElementsType, indices);
                    CheckLastError();
                }
                else
                {
                    glDrawElementsBaseVertex(_primitiveType, indexCount, _drawElementsType, indices, vertexOffset);
                    CheckLastError();
                }
            }
            else
            {
                if (instanceStart > 0)
                {
                    glDrawElementsInstancedBaseVertexBaseInstance(
                        _primitiveType,
                        indexCount,
                        _drawElementsType,
                        indices,
                        instanceCount,
                        vertexOffset,
                        instanceStart);
                    CheckLastError();
                }
                else if (vertexOffset == 0)
                {
                    glDrawElementsInstanced(_primitiveType, indexCount, _drawElementsType, indices, instanceCount);
                    CheckLastError();
                }
                else
                {
                    glDrawElementsInstancedBaseVertex(
                        _primitiveType,
                        indexCount,
                        _drawElementsType,
                        indices,
                        instanceCount,
                        vertexOffset);
                    CheckLastError();
                }
            }
        }

        public void DrawIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();

            OpenGLBuffer glBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(indirectBuffer);
            glBindBuffer(BufferTarget.DrawIndirectBuffer, glBuffer.Buffer);
            CheckLastError();

            if (_extensions.MultiDrawIndirect)
            {
                glMultiDrawArraysIndirect(_primitiveType, (IntPtr)offset, drawCount, stride);
                CheckLastError();
            }
            else
            {
                uint32 indirect = offset;
                for (uint32 i = 0; i < drawCount; i++)
                {
                    glDrawArraysIndirect(_primitiveType, (IntPtr)indirect);
                    CheckLastError();

                    indirect += stride;
                }
            }
        }

        public void DrawIndexedIndirect(DeviceBuffer indirectBuffer, uint32 offset, uint32 drawCount, uint32 stride)
        {
            PreDrawCommand();

            OpenGLBuffer glBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(indirectBuffer);
            glBindBuffer(BufferTarget.DrawIndirectBuffer, glBuffer.Buffer);
            CheckLastError();

            if (_extensions.MultiDrawIndirect)
            {
                glMultiDrawElementsIndirect(_primitiveType, _drawElementsType, (IntPtr)offset, drawCount, stride);
                CheckLastError();
            }
            else
            {
                uint32 indirect = offset;
                for (uint32 i = 0; i < drawCount; i++)
                {
                    glDrawElementsIndirect(_primitiveType, _drawElementsType, (IntPtr)indirect);
                    CheckLastError();

                    indirect += stride;
                }
            }
        }

        private void PreDrawCommand()
        {
            if (!_graphicsPipelineActive)
            {
                ActivateGraphicsPipeline();
            }

            FlushResourceSets(graphics: true);
            if (!_vertexLayoutFlushed)
            {
                FlushVertexLayouts();
                _vertexLayoutFlushed = true;
            }
        }

        private void FlushResourceSets(bool graphics)
        {
            uint32 sets = graphics
                ? (uint32)_graphicsPipeline.ResourceLayouts.Length
                : (uint32)_computePipeline.ResourceLayouts.Length;
            for (uint32 slot = 0; slot < sets; slot++)
            {
                BoundResourceSetInfo brsi = graphics ? _graphicsResourceSets[slot] : _computeResourceSets[slot];
                OpenGLResourceSet glSet = Util.AssertSubtype<ResourceSet, OpenGLResourceSet>(brsi.Set);
                ResourceLayoutElementDescription[] layoutElements = glSet.Layout.Elements;
                bool isNew = graphics ? _newGraphicsResourceSets[slot] : _newComputeResourceSets[slot];

                ActivateResourceSet(slot, graphics, brsi, layoutElements, isNew);
            }

            Util.ClearArray(graphics ? _newGraphicsResourceSets : _newComputeResourceSets);
        }

        private void FlushVertexLayouts()
        {
            uint32 totalSlotsBound = 0;
            VertexLayoutDescription[] layouts = _graphicsPipeline.VertexLayouts;
            for (int32 i = 0; i < layouts.Length; i++)
            {
                VertexLayoutDescription input = layouts[i];
                OpenGLBuffer vb = _vertexBuffers[i];
                glBindBuffer(BufferTarget.ArrayBuffer, vb.Buffer);
                uint32 offset = 0;
                uint32 vbOffset = _vbOffsets[i];
                for (uint32 slot = 0; slot < input.Elements.Length; slot++)
                {
                    ref VertexElementDescription element = ref input.Elements[slot]; // Large structure -- use by reference.
                    uint32 actualSlot = totalSlotsBound + slot;
                    if (actualSlot >= _vertexAttributesBound)
                    {
                        glEnableVertexAttribArray(actualSlot);
                    }
                    VertexAttribPointerType type = OpenGLFormats.VdToGLVertexAttribPointerType(
                        element.Format,
                        out bool normalized,
                        out bool isInteger);

                    uint32 actualOffset = element.Offset != 0 ? element.Offset : offset;
                    actualOffset += vbOffset;

                    if (isInteger && !normalized)
                    {
                        glVertexAttribIPointer(
                            actualSlot,
                            FormatHelpers.GetElementCount(element.Format),
                            type,
                            (uint32)_graphicsPipeline.VertexStrides[i],
                            (void*)actualOffset);
                        CheckLastError();
                    }
                    else
                    {
                        glVertexAttribPointer(
                            actualSlot,
                            FormatHelpers.GetElementCount(element.Format),
                            type,
                            normalized,
                            (uint32)_graphicsPipeline.VertexStrides[i],
                            (void*)actualOffset);
                        CheckLastError();
                    }

                    uint32 stepRate = input.InstanceStepRate;
                    if (_vertexAttribDivisors[actualSlot] != stepRate)
                    {
                        glVertexAttribDivisor(actualSlot, stepRate);
                        _vertexAttribDivisors[actualSlot] = stepRate;
                    }

                    offset += FormatSizeHelpers.GetSizeInBytes(element.Format);
                }

                totalSlotsBound += (uint32)input.Elements.Length;
            }

            for (uint32 extraSlot = totalSlotsBound; extraSlot < _vertexAttributesBound; extraSlot++)
            {
                glDisableVertexAttribArray(extraSlot);
            }

            _vertexAttributesBound = totalSlotsBound;
        }

        internal void Dispatch(uint32 groupCountX, uint32 groupCountY, uint32 groupCountZ)
        {
            PreDispatchCommand();

            glDispatchCompute(groupCountX, groupCountY, groupCountZ);
            CheckLastError();

            PostDispatchCommand();
        }

        public void DispatchIndirect(DeviceBuffer indirectBuffer, uint32 offset)
        {
            PreDispatchCommand();

            OpenGLBuffer glBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(indirectBuffer);
            glBindBuffer(BufferTarget.DrawIndirectBuffer, glBuffer.Buffer);
            CheckLastError();

            glDispatchComputeIndirect((IntPtr)offset);
            CheckLastError();

            PostDispatchCommand();
        }

        private void PreDispatchCommand()
        {
            if (_graphicsPipelineActive)
            {
                ActivateComputePipeline();
            }

            FlushResourceSets(false);
        }

        private static void PostDispatchCommand()
        {
            // TODO: Smart barriers?
            glMemoryBarrier(MemoryBarrierFlags.AllBarrierBits);
            CheckLastError();
        }

        public void End()
        {
        }

        public void SetFramebuffer(Framebuffer fb)
        {
            if (fb is OpenGLFramebuffer glFB)
            {
                if (_backend == GraphicsBackend.OpenGL || _extensions.EXT_sRGBWriteControl)
                {
                    glEnable(EnableCap.FramebufferSrgb);
                    CheckLastError();
                }

                glFB.EnsureResourcesCreated();
                glBindFramebuffer(FramebufferTarget.Framebuffer, glFB.Framebuffer);
                CheckLastError();
                _isSwapchainFB = false;
            }
            else if (fb is OpenGLSwapchainFramebuffer swapchainFB)
            {
                if ((_backend == GraphicsBackend.OpenGL || _extensions.EXT_sRGBWriteControl))
                {
                    if (swapchainFB.DisableSrgbConversion)
                    {
                        glDisable(EnableCap.FramebufferSrgb);
                        CheckLastError();
                    }
                    else
                    {
                        glEnable(EnableCap.FramebufferSrgb);
                        CheckLastError();
                    }
                }

                if (_platformInfo.SetSwapchainFramebuffer != null)
                {
                    _platformInfo.SetSwapchainFramebuffer();
                }
                else
                {
                    glBindFramebuffer(FramebufferTarget.Framebuffer, 0);
                    CheckLastError();
                }

                _isSwapchainFB = true;
            }
            else
            {
                Runtime.GALError("Invalid Framebuffer type: " + fb.GetType().Name);
            }

            _fb = fb;
        }

        public void SetIndexBuffer(DeviceBuffer ib, IndexFormat format, uint32 offset)
        {
            OpenGLBuffer glIB = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(ib);
            glIB.EnsureResourcesCreated();

            glBindBuffer(BufferTarget.ElementArrayBuffer, glIB.Buffer);
            CheckLastError();

            _drawElementsType = OpenGLFormats.VdToGLDrawElementsType(format);
            _ibOffset = offset;
        }

        public void SetPipeline(Pipeline pipeline)
        {
            if (!pipeline.IsComputePipeline && _graphicsPipeline != pipeline)
            {
                _graphicsPipeline = Util.AssertSubtype<Pipeline, OpenGLPipeline>(pipeline);
                ActivateGraphicsPipeline();
                _vertexLayoutFlushed = false;
            }
            else if (pipeline.IsComputePipeline && _computePipeline != pipeline)
            {
                _computePipeline = Util.AssertSubtype<Pipeline, OpenGLPipeline>(pipeline);
                ActivateComputePipeline();
                _vertexLayoutFlushed = false;
            }
        }

        private void ActivateGraphicsPipeline()
        {
            _graphicsPipelineActive = true;
            _graphicsPipeline.EnsureResourcesCreated();

            Util.EnsureArrayMinimumSize(ref _graphicsResourceSets, (uint32)_graphicsPipeline.ResourceLayouts.Length);
            Util.EnsureArrayMinimumSize(ref _newGraphicsResourceSets, (uint32)_graphicsPipeline.ResourceLayouts.Length);

            // Force ResourceSets to be re-bound.
            for (int32 i = 0; i < _graphicsPipeline.ResourceLayouts.Length; i++)
            {
                _newGraphicsResourceSets[i] = true;
            }

            // Blend State

            BlendStateDescription blendState = _graphicsPipeline.BlendState;
            glBlendColor(blendState.BlendFactor.R, blendState.BlendFactor.G, blendState.BlendFactor.B, blendState.BlendFactor.A);
            CheckLastError();

            if (blendState.AlphaToCoverageEnabled)
            {
                glEnable(EnableCap.SampleAlphaToCoverage);
                CheckLastError();
            }
            else
            {
                glDisable(EnableCap.SampleAlphaToCoverage);
                CheckLastError();
            }

            if (_features.IndependentBlend)
            {
                for (uint32 i = 0; i < blendState.AttachmentStates.Length; i++)
                {
                    BlendAttachmentDescription attachment = blendState.AttachmentStates[i];
                    ColorWriteMask colorMask = attachment.ColorWriteMask.GetOrDefault();

                    glColorMaski(
                        i,
                        (colorMask & ColorWriteMask.Red) == ColorWriteMask.Red,
                        (colorMask & ColorWriteMask.Green) == ColorWriteMask.Green,
                        (colorMask & ColorWriteMask.Blue) == ColorWriteMask.Blue,
                        (colorMask & ColorWriteMask.Alpha) == ColorWriteMask.Alpha);
                    CheckLastError();

                    if (!attachment.BlendEnabled)
                    {
                        glDisablei(EnableCap.Blend, i);
                        CheckLastError();
                    }
                    else
                    {
                        glEnablei(EnableCap.Blend, i);
                        CheckLastError();

                        glBlendFuncSeparatei(
                            i,
                            OpenGLFormats.VdToGLBlendFactorSrc(attachment.SourceColorFactor),
                            OpenGLFormats.VdToGLBlendFactorDest(attachment.DestinationColorFactor),
                            OpenGLFormats.VdToGLBlendFactorSrc(attachment.SourceAlphaFactor),
                            OpenGLFormats.VdToGLBlendFactorDest(attachment.DestinationAlphaFactor));
                        CheckLastError();

                        glBlendEquationSeparatei(
                            i,
                            OpenGLFormats.VdToGLBlendEquationMode(attachment.ColorFunction),
                            OpenGLFormats.VdToGLBlendEquationMode(attachment.AlphaFunction));
                        CheckLastError();
                    }
                }
            }
            else if (blendState.AttachmentStates.Length > 0)
            {
                BlendAttachmentDescription attachment = blendState.AttachmentStates[0];
                ColorWriteMask colorMask = attachment.ColorWriteMask.GetOrDefault();

                glColorMask(
                    (colorMask & ColorWriteMask.Red) == ColorWriteMask.Red,
                    (colorMask & ColorWriteMask.Green) == ColorWriteMask.Green,
                    (colorMask & ColorWriteMask.Blue) == ColorWriteMask.Blue,
                    (colorMask & ColorWriteMask.Alpha) == ColorWriteMask.Alpha);
                CheckLastError();

                if (!attachment.BlendEnabled)
                {
                    glDisable(EnableCap.Blend);
                    CheckLastError();
                }
                else
                {
                    glEnable(EnableCap.Blend);
                    CheckLastError();

                    glBlendFuncSeparate(
                        OpenGLFormats.VdToGLBlendFactorSrc(attachment.SourceColorFactor),
                        OpenGLFormats.VdToGLBlendFactorDest(attachment.DestinationColorFactor),
                        OpenGLFormats.VdToGLBlendFactorSrc(attachment.SourceAlphaFactor),
                        OpenGLFormats.VdToGLBlendFactorDest(attachment.DestinationAlphaFactor));
                    CheckLastError();

                    glBlendEquationSeparate(
                        OpenGLFormats.VdToGLBlendEquationMode(attachment.ColorFunction),
                        OpenGLFormats.VdToGLBlendEquationMode(attachment.AlphaFunction));
                    CheckLastError();
                }
            }

            // Depth Stencil State

            DepthStencilStateDescription dss = _graphicsPipeline.DepthStencilState;
            if (!dss.DepthTestEnabled)
            {
                glDisable(EnableCap.DepthTest);
                CheckLastError();
            }
            else
            {
                glEnable(EnableCap.DepthTest);
                CheckLastError();

                glDepthFunc(OpenGLFormats.VdToGLDepthFunction(dss.DepthComparison));
                CheckLastError();
            }

            glDepthMask(dss.DepthWriteEnabled);
            CheckLastError();

            if (dss.StencilTestEnabled)
            {
                glEnable(EnableCap.StencilTest);
                CheckLastError();

                glStencilFuncSeparate(
                    CullFaceMode.Front,
                    OpenGLFormats.VdToGLStencilFunction(dss.StencilFront.Comparison),
                    (int32)dss.StencilReference,
                    dss.StencilReadMask);
                CheckLastError();

                glStencilOpSeparate(
                    CullFaceMode.Front,
                    OpenGLFormats.VdToGLStencilOp(dss.StencilFront.Fail),
                    OpenGLFormats.VdToGLStencilOp(dss.StencilFront.DepthFail),
                    OpenGLFormats.VdToGLStencilOp(dss.StencilFront.Pass));
                CheckLastError();

                glStencilFuncSeparate(
                    CullFaceMode.Back,
                    OpenGLFormats.VdToGLStencilFunction(dss.StencilBack.Comparison),
                    (int32)dss.StencilReference,
                    dss.StencilReadMask);
                CheckLastError();

                glStencilOpSeparate(
                    CullFaceMode.Back,
                    OpenGLFormats.VdToGLStencilOp(dss.StencilBack.Fail),
                    OpenGLFormats.VdToGLStencilOp(dss.StencilBack.DepthFail),
                    OpenGLFormats.VdToGLStencilOp(dss.StencilBack.Pass));
                CheckLastError();

                glStencilMask(dss.StencilWriteMask);
                CheckLastError();
            }
            else
            {
                glDisable(EnableCap.StencilTest);
                CheckLastError();
            }

            // Rasterizer State

            RasterizerStateDescription rs = _graphicsPipeline.RasterizerState;
            if (rs.CullMode == FaceCullMode.None)
            {
                glDisable(EnableCap.CullFace);
                CheckLastError();
            }
            else
            {
                glEnable(EnableCap.CullFace);
                CheckLastError();

                glCullFace(OpenGLFormats.VdToGLCullFaceMode(rs.CullMode));
                CheckLastError();
            }

            if (_backend == GraphicsBackend.OpenGL)
            {
                glPolygonMode(MaterialFace.FrontAndBack, OpenGLFormats.VdToGLPolygonMode(rs.FillMode));
                CheckLastError();
            }

            if (!rs.ScissorTestEnabled)
            {
                glDisable(EnableCap.ScissorTest);
                CheckLastError();
            }
            else
            {
                glEnable(EnableCap.ScissorTest);
                CheckLastError();
            }

            if (_backend == GraphicsBackend.OpenGL)
            {
                if (!rs.DepthClipEnabled)
                {
                    glEnable(EnableCap.DepthClamp);
                    CheckLastError();
                }
                else
                {
                    glDisable(EnableCap.DepthClamp);
                    CheckLastError();
                }
            }

            glFrontFace(OpenGLFormats.VdToGLFrontFaceDirection(rs.FrontFace));
            CheckLastError();

            // Primitive Topology
            _primitiveType = OpenGLFormats.VdToGLPrimitiveType(_graphicsPipeline.PrimitiveTopology);

            // Shader Set
            glUseProgram(_graphicsPipeline.Program);
            CheckLastError();

            int32 vertexStridesCount = _graphicsPipeline.VertexStrides.Length;
            Util.EnsureArrayMinimumSize(ref _vertexBuffers, (uint32)vertexStridesCount);
            Util.EnsureArrayMinimumSize(ref _vbOffsets, (uint32)vertexStridesCount);

            uint32 totalVertexElements = 0;
            for (int32 i = 0; i < _graphicsPipeline.VertexLayouts.Length; i++)
            {
                totalVertexElements += (uint32)_graphicsPipeline.VertexLayouts[i].Elements.Length;
            }
            Util.EnsureArrayMinimumSize(ref _vertexAttribDivisors, totalVertexElements);
        }

        public void GenerateMipmaps(Texture texture)
        {
            OpenGLTexture glTex = Util.AssertSubtype<Texture, OpenGLTexture>(texture);
            glTex.EnsureResourcesCreated();
            if (_extensions.ARB_DirectStateAccess)
            {
                glGenerateTextureMipmap(glTex.Texture);
                CheckLastError();
            }
            else
            {
                TextureTarget target = glTex.TextureTarget;
                _textureSamplerManager.SetTextureTransient(target, glTex.Texture);
                glGenerateMipmap(target);
                CheckLastError();
            }
        }

        public void PushDebugGroup(string name)
        {
            if (_extensions.KHR_Debug)
            {
                int32 byteCount = Encoding.UTF8.GetByteCount(name);
                uint8* utf8Ptr = stackalloc uint8[byteCount];
                fixed (char* namePtr = name)
                {
                    Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
                }
                glPushDebugGroup(DebugSource.DebugSourceApplication, 0, (uint32)byteCount, utf8Ptr);
                CheckLastError();
            }
            else if (_extensions.EXT_DebugMarker)
            {
                int32 byteCount = Encoding.UTF8.GetByteCount(name);
                uint8* utf8Ptr = stackalloc uint8[byteCount];
                fixed (char* namePtr = name)
                {
                    Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
                }
                glPushGroupMarker((uint32)byteCount, utf8Ptr);
                CheckLastError();
            }
        }

        public void PopDebugGroup()
        {
            if (_extensions.KHR_Debug)
            {
                glPopDebugGroup();
                CheckLastError();
            }
            else if (_extensions.EXT_DebugMarker)
            {
                glPopGroupMarker();
                CheckLastError();
            }
        }

        public void InsertDebugMarker(string name)
        {
            if (_extensions.KHR_Debug)
            {
                int32 byteCount = Encoding.UTF8.GetByteCount(name);
                uint8* utf8Ptr = stackalloc uint8[byteCount];
                fixed (char* namePtr = name)
                {
                    Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
                }

                glDebugMessageInsert(
                    DebugSource.DebugSourceApplication,
                    DebugType.DebugTypeMarker,
                    0,
                    DebugSeverity.DebugSeverityNotification,
                    (uint32)byteCount,
                    utf8Ptr);
                CheckLastError();
            }
            else if (_extensions.EXT_DebugMarker)
            {
                int32 byteCount = Encoding.UTF8.GetByteCount(name);
                uint8* utf8Ptr = stackalloc uint8[byteCount];
                fixed (char* namePtr = name)
                {
                    Encoding.UTF8.GetBytes(namePtr, name.Length, utf8Ptr, byteCount);
                }

                glInsertEventMarker((uint32)byteCount, utf8Ptr);
                CheckLastError();
            }
        }

        private void ActivateComputePipeline()
        {
            _graphicsPipelineActive = false;
            _computePipeline.EnsureResourcesCreated();
            Util.EnsureArrayMinimumSize(ref _computeResourceSets, (uint32)_computePipeline.ResourceLayouts.Length);
            Util.EnsureArrayMinimumSize(ref _newComputeResourceSets, (uint32)_computePipeline.ResourceLayouts.Length);

            // Force ResourceSets to be re-bound.
            for (int32 i = 0; i < _computePipeline.ResourceLayouts.Length; i++)
            {
                _newComputeResourceSets[i] = true;
            }

            // Shader Set
            glUseProgram(_computePipeline.Program);
            CheckLastError();
        }

        public void SetGraphicsResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            if (!_graphicsResourceSets[slot].Equals(rs, dynamicOffsetCount, ref dynamicOffsets))
            {
                _graphicsResourceSets[slot].Offsets.Dispose();
                _graphicsResourceSets[slot] = new BoundResourceSetInfo(rs, dynamicOffsetCount, ref dynamicOffsets);
                _newGraphicsResourceSets[slot] = true;
            }
        }

        public void SetComputeResourceSet(uint32 slot, ResourceSet rs, uint32 dynamicOffsetCount, ref uint32 dynamicOffsets)
        {
            if (!_computeResourceSets[slot].Equals(rs, dynamicOffsetCount, ref dynamicOffsets))
            {
                _computeResourceSets[slot].Offsets.Dispose();
                _computeResourceSets[slot] = new BoundResourceSetInfo(rs, dynamicOffsetCount, ref dynamicOffsets);
                _newComputeResourceSets[slot] = true;
            }
        }

        private void ActivateResourceSet(
            uint32 slot,
            bool graphics,
            BoundResourceSetInfo brsi,
            ResourceLayoutElementDescription[] layoutElements,
            bool isNew)
        {
            OpenGLResourceSet glResourceSet = Util.AssertSubtype<ResourceSet, OpenGLResourceSet>(brsi.Set);
            OpenGLPipeline pipeline = graphics ? _graphicsPipeline : _computePipeline;
            uint32 ubBaseIndex = GetUniformBaseIndex(slot, graphics);
            uint32 ssboBaseIndex = GetShaderStorageBaseIndex(slot, graphics);

            uint32 ubOffset = 0;
            uint32 ssboOffset = 0;
            uint32 dynamicOffsetIndex = 0;
            for (uint32 element = 0; element < glResourceSet.Resources.Length; element++)
            {
                ResourceKind kind = layoutElements[element].Kind;
                BindableResource resource = glResourceSet.Resources[(int32)element];

                uint32 bufferOffset = 0;
                if (glResourceSet.Layout.IsDynamicBuffer(element))
                {
                    bufferOffset = brsi.Offsets.Get(dynamicOffsetIndex);
                    dynamicOffsetIndex += 1;
                }

                switch (kind)
                {
                    case ResourceKind.UniformBuffer:
                    {
                        if (!isNew) { continue; }

                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        OpenGLBuffer glUB = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(range.Buffer);

                        glUB.EnsureResourcesCreated();
                        if (pipeline.GetUniformBindingForSlot(slot, element, out OpenGLUniformBinding uniformBindingInfo))
                        {
                            if (range.SizeInBytes < uniformBindingInfo.BlockSize)
                            {
                                string name = glResourceSet.Layout.Elements[element].Name;
                                Runtime.GALError(
                                    $"Not enough data in uniform buffer \"{name}\" (slot {slot}, element {element}). Shader expects at least {uniformBindingInfo.BlockSize} bytes, but buffer only contains {range.SizeInBytes} bytes");
                            }
                            glUniformBlockBinding(pipeline.Program, uniformBindingInfo.BlockLocation, ubBaseIndex + ubOffset);
                            CheckLastError();

                            glBindBufferRange(
                                BufferRangeTarget.UniformBuffer,
                                ubBaseIndex + ubOffset,
                                glUB.Buffer,
                                (IntPtr)range.Offset,
                                (UIntPtr)range.SizeInBytes);
                            CheckLastError();

                            ubOffset += 1;
                        }
                        break;
                    }
                    case ResourceKind.StructuredBufferReadWrite:
                    case ResourceKind.StructuredBufferReadOnly:
                    {
                        if (!isNew) { continue; }

                        DeviceBufferRange range = Util.GetBufferRange(resource, bufferOffset);
                        OpenGLBuffer glBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(range.Buffer);

                        glBuffer.EnsureResourcesCreated();
                        if (pipeline.GetStorageBufferBindingForSlot(slot, element, out OpenGLShaderStorageBinding shaderStorageBinding))
                        {
                            if (_backend == GraphicsBackend.OpenGL)
                            {
                                glShaderStorageBlockBinding(
                                    pipeline.Program,
                                    shaderStorageBinding.StorageBlockBinding,
                                    ssboBaseIndex + ssboOffset);
                                CheckLastError();

                                glBindBufferRange(
                                    BufferRangeTarget.ShaderStorageBuffer,
                                    ssboBaseIndex + ssboOffset,
                                    glBuffer.Buffer,
                                    (IntPtr)range.Offset,
                                    (UIntPtr)range.SizeInBytes);
                                CheckLastError();
                            }
                            else
                            {
                                glBindBufferRange(
                                    BufferRangeTarget.ShaderStorageBuffer,
                                    shaderStorageBinding.StorageBlockBinding,
                                    glBuffer.Buffer,
                                    (IntPtr)range.Offset,
                                    (UIntPtr)range.SizeInBytes);
                                CheckLastError();
                            }
                            ssboOffset += 1;
                        }
                        break;
                    }
                    case ResourceKind.TextureReadOnly:
                        TextureView texView = Util.GetTextureView(_gd, resource);
                        OpenGLTextureView glTexView = Util.AssertSubtype<TextureView, OpenGLTextureView>(texView);
                        glTexView.EnsureResourcesCreated();
                        if (pipeline.GetTextureBindingInfo(slot, element, out OpenGLTextureBindingSlotInfo textureBindingInfo))
                        {
                            _textureSamplerManager.SetTexture((uint32)textureBindingInfo.RelativeIndex, glTexView);
                            glUniform1i(textureBindingInfo.UniformLocation, textureBindingInfo.RelativeIndex);
                            CheckLastError();
                        }
                        break;
                    case ResourceKind.TextureReadWrite:
                        TextureView texViewRW = Util.GetTextureView(_gd, resource);
                        OpenGLTextureView glTexViewRW = Util.AssertSubtype<TextureView, OpenGLTextureView>(texViewRW);
                        glTexViewRW.EnsureResourcesCreated();
                        if (pipeline.GetTextureBindingInfo(slot, element, out OpenGLTextureBindingSlotInfo imageBindingInfo))
                        {
                            var layered = texViewRW.Target.Usage.HasFlag(TextureUsage.Cubemap) || texViewRW.ArrayLayers > 1;

                            if (layered && (texViewRW.BaseArrayLayer > 0
                                || (texViewRW.ArrayLayers > 1 && texViewRW.ArrayLayers < texViewRW.Target.ArrayLayers)))
                            {
                                Runtime.GALError(
                                    "Cannot bind texture with BaseArrayLayer > 0 and ArrayLayers > 1, or with an incomplete set of array layers (cubemaps have ArrayLayers == 6 implicitly).");
                            }

                            if (_backend == GraphicsBackend.OpenGL)
                            {
                                glBindImageTexture(
                                    (uint32)imageBindingInfo.RelativeIndex,
                                    glTexViewRW.Target.Texture,
                                    (int32)texViewRW.BaseMipLevel,
                                    layered,
                                    (int32)texViewRW.BaseArrayLayer,
                                    TextureAccess.ReadWrite,
                                    glTexViewRW.GetReadWriteSizedInternalFormat());
                                CheckLastError();
                                glUniform1i(imageBindingInfo.UniformLocation, imageBindingInfo.RelativeIndex);
                                CheckLastError();
                            }
                            else
                            {
                                glBindImageTexture(
                                    (uint32)imageBindingInfo.RelativeIndex,
                                    glTexViewRW.Target.Texture,
                                    (int32)texViewRW.BaseMipLevel,
                                    layered,
                                    (int32)texViewRW.BaseArrayLayer,
                                    TextureAccess.ReadWrite,
                                    glTexViewRW.GetReadWriteSizedInternalFormat());
                                CheckLastError();
                            }
                        }
                        break;
                    case ResourceKind.Sampler:
                        OpenGLSampler glSampler = Util.AssertSubtype<BindableResource, OpenGLSampler>(resource);
                        glSampler.EnsureResourcesCreated();
                        if (pipeline.GetSamplerBindingInfo(slot, element, out OpenGLSamplerBindingSlotInfo samplerBindingInfo))
                        {
                            for (int32 index in samplerBindingInfo.RelativeIndices)
                            {
                                _textureSamplerManager.SetSampler((uint32)index, glSampler);
                            }
                        }
                        break;
                    default: Runtime.IllegalValue<ResourceKind>();
                }
            }
        }

        public void ResolveTexture(Texture source, Texture destination)
        {
            OpenGLTexture glSourceTex = Util.AssertSubtype<Texture, OpenGLTexture>(source);
            OpenGLTexture glDestinationTex = Util.AssertSubtype<Texture, OpenGLTexture>(destination);
            glSourceTex.EnsureResourcesCreated();
            glDestinationTex.EnsureResourcesCreated();

            uint32 sourceFramebuffer = glSourceTex.GetFramebuffer(0, 0);
            uint32 destinationFramebuffer = glDestinationTex.GetFramebuffer(0, 0);

            glBindFramebuffer(FramebufferTarget.ReadFramebuffer, sourceFramebuffer);
            CheckLastError();

            glBindFramebuffer(FramebufferTarget.DrawFramebuffer, destinationFramebuffer);
            CheckLastError();

            glDisable(EnableCap.ScissorTest);
            CheckLastError();

            glBlitFramebuffer(
                0,
                0,
                (int32)source.Width,
                (int32)source.Height,
                0,
                0,
                (int32)destination.Width,
                (int32)destination.Height,
                ClearBufferMask.ColorBufferBit,
                BlitFramebufferFilter.Nearest);
            CheckLastError();
        }

        private uint32 GetUniformBaseIndex(uint32 slot, bool graphics)
        {
            OpenGLPipeline pipeline = graphics ? _graphicsPipeline : _computePipeline;
            uint32 ret = 0;
            for (uint32 i = 0; i < slot; i++)
            {
                ret += pipeline.GetUniformBufferCount(i);
            }

            return ret;
        }

        private uint32 GetShaderStorageBaseIndex(uint32 slot, bool graphics)
        {
            OpenGLPipeline pipeline = graphics ? _graphicsPipeline : _computePipeline;
            uint32 ret = 0;
            for (uint32 i = 0; i < slot; i++)
            {
                ret += pipeline.GetShaderStorageBufferCount(i);
            }

            return ret;
        }

        public void SetScissorRect(uint32 index, uint32 x, uint32 y, uint32 width, uint32 height)
        {
            if (_backend == GraphicsBackend.OpenGL)
            {
                glScissorIndexed(
                    index,
                    (int32)x,
                    (int32)(_fb.Height - (int32)height - y),
                    width,
                    height);
                CheckLastError();
            }
            else
            {
                if (index == 0)
                {
                    glScissor(
                        (int32)x,
                        (int32)(_fb.Height - (int32)height - y),
                        width,
                        height);
                    CheckLastError();
                }
            }
        }

        public void SetVertexBuffer(uint32 index, DeviceBuffer vb, uint32 offset)
        {
            OpenGLBuffer glVB = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(vb);
            glVB.EnsureResourcesCreated();

            Util.EnsureArrayMinimumSize(ref _vertexBuffers, index + 1);
            Util.EnsureArrayMinimumSize(ref _vbOffsets, index + 1);
            _vertexLayoutFlushed = false;
            _vertexBuffers[index] = glVB;
            _vbOffsets[index] = offset;
        }

        public void SetViewport(uint32 index, ref Viewport viewport)
        {
            _viewports[(int32)index] = viewport;

            if (_backend == GraphicsBackend.OpenGL)
            {
                float left = viewport.X;
                float bottom = _fb.Height - (viewport.Y + viewport.Height);

                glViewportIndexed(index, left, bottom, viewport.Width, viewport.Height);
                CheckLastError();

                glDepthRangeIndexed(index, viewport.MinDepth, viewport.MaxDepth);
                CheckLastError();
            }
            else
            {
                if (index == 0)
                {
                    glViewport((int32)viewport.X, (int32)viewport.Y, (uint32)viewport.Width, (uint32)viewport.Height);
                    CheckLastError();

                    glDepthRangef(viewport.MinDepth, viewport.MaxDepth);
                    CheckLastError();
                }
            }
        }

        public void UpdateBuffer(DeviceBuffer buffer, uint32 bufferOffsetInBytes, IntPtr dataPtr, uint32 sizeInBytes)
        {
            OpenGLBuffer glBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(buffer);
            glBuffer.EnsureResourcesCreated();

            if (_extensions.ARB_DirectStateAccess)
            {
                glNamedBufferSubData(
                    glBuffer.Buffer,
                    (IntPtr)bufferOffsetInBytes,
                    sizeInBytes,
                    dataPtr.ToPointer());
                CheckLastError();
            }
            else
            {
                BufferTarget bufferTarget = BufferTarget.CopyWriteBuffer;
                glBindBuffer(bufferTarget, glBuffer.Buffer);
                CheckLastError();
                glBufferSubData(
                    bufferTarget,
                    (IntPtr)bufferOffsetInBytes,
                    (UIntPtr)sizeInBytes,
                    dataPtr.ToPointer());
                CheckLastError();
            }
        }

        public void UpdateTexture(
            Texture texture,
            IntPtr dataPtr,
            uint32 x,
            uint32 y,
            uint32 z,
            uint32 width,
            uint32 height,
            uint32 depth,
            uint32 mipLevel,
            uint32 arrayLayer)
        {
            if (width == 0 || height == 0 || depth == 0) { return; }

            OpenGLTexture glTex = Util.AssertSubtype<Texture, OpenGLTexture>(texture);
            glTex.EnsureResourcesCreated();

            TextureTarget texTarget = glTex.TextureTarget;

            _textureSamplerManager.SetTextureTransient(texTarget, glTex.Texture);
            CheckLastError();

            bool isCompressed = FormatHelpers.IsCompressedFormat(texture.Format);
            uint32 blockSize = isCompressed ? 4u : 1u;

            uint32 blockAlignedWidth = Math.Max(width, blockSize);
            uint32 blockAlignedHeight = Math.Max(height, blockSize);

            uint32 rowPitch = FormatHelpers.GetRowPitch(blockAlignedWidth, texture.Format);
            uint32 depthPitch = FormatHelpers.GetDepthPitch(rowPitch, blockAlignedHeight, texture.Format);

            // Compressed textures can specify regions that are larger than the dimensions.
            // We should only pass up to the dimensions to OpenGL, though.
            Util.GetMipDimensions(glTex, mipLevel, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);
            width = Math.Min(width, mipWidth);
            height = Math.Min(height, mipHeight);

            uint32 unpackAlignment = 4;
            if (!isCompressed)
            {
                unpackAlignment = FormatSizeHelpers.GetSizeInBytes(glTex.Format);
            }
            if (unpackAlignment < 4)
            {
                glPixelStorei(PixelStoreParameter.UnpackAlignment, (int32)unpackAlignment);
                CheckLastError();
            }

            if (texTarget == TextureTarget.Texture1D)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage1D(
                        TextureTarget.Texture1D,
                        (int32)mipLevel,
                        (int32)x,
                        width,
                        glTex.GLInternalFormat,
                        rowPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage1D(
                        TextureTarget.Texture1D,
                        (int32)mipLevel,
                        (int32)x,
                        width,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.Texture1DArray)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage2D(
                        TextureTarget.Texture1DArray,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)arrayLayer,
                        width,
                        1,
                        glTex.GLInternalFormat,
                        rowPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage2D(
                    TextureTarget.Texture1DArray,
                    (int32)mipLevel,
                    (int32)x,
                    (int32)arrayLayer,
                    width,
                    1,
                    glTex.GLPixelFormat,
                    glTex.GLPixelType,
                    dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.Texture2D)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage2D(
                        TextureTarget.Texture2D,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        width,
                        height,
                        glTex.GLInternalFormat,
                        depthPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage2D(
                        TextureTarget.Texture2D,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        width,
                        height,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.Texture2DArray)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage3D(
                        TextureTarget.Texture2DArray,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)arrayLayer,
                        width,
                        height,
                        1,
                        glTex.GLInternalFormat,
                        depthPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage3D(
                        TextureTarget.Texture2DArray,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)arrayLayer,
                        width,
                        height,
                        1,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.Texture3D)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage3D(
                        TextureTarget.Texture3D,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)z,
                        width,
                        height,
                        depth,
                        glTex.GLInternalFormat,
                        depthPitch * depth,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage3D(
                        TextureTarget.Texture3D,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)z,
                        width,
                        height,
                        depth,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.TextureCubeMap)
            {
                TextureTarget cubeTarget = GetCubeTarget(arrayLayer);
                if (isCompressed)
                {
                    glCompressedTexSubImage2D(
                        cubeTarget,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        width,
                        height,
                        glTex.GLInternalFormat,
                        depthPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage2D(
                        cubeTarget,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        width,
                        height,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else if (texTarget == TextureTarget.TextureCubeMapArray)
            {
                if (isCompressed)
                {
                    glCompressedTexSubImage3D(
                        TextureTarget.TextureCubeMapArray,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)arrayLayer,
                        width,
                        height,
                        1,
                        glTex.GLInternalFormat,
                        depthPitch,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
                else
                {
                    glTexSubImage3D(
                        TextureTarget.TextureCubeMapArray,
                        (int32)mipLevel,
                        (int32)x,
                        (int32)y,
                        (int32)arrayLayer,
                        width,
                        height,
                        1,
                        glTex.GLPixelFormat,
                        glTex.GLPixelType,
                        dataPtr.ToPointer());
                    CheckLastError();
                }
            }
            else
            {
                Runtime.GALError($"Invalid OpenGL TextureTarget encountered: {glTex.TextureTarget}.");
            }

            if (unpackAlignment < 4)
            {
                glPixelStorei(PixelStoreParameter.UnpackAlignment, 4);
                CheckLastError();
            }
        }

        private TextureTarget GetCubeTarget(uint32 arrayLayer)
        {
            switch (arrayLayer)
            {
                case 0:
                    return TextureTarget.TextureCubeMapPositiveX;
                case 1:
                    return TextureTarget.TextureCubeMapNegativeX;
                case 2:
                    return TextureTarget.TextureCubeMapPositiveY;
                case 3:
                    return TextureTarget.TextureCubeMapNegativeY;
                case 4:
                    return TextureTarget.TextureCubeMapPositiveZ;
                case 5:
                    return TextureTarget.TextureCubeMapNegativeZ;
                default:
                    Runtime.GALError("Unexpected array layer in UpdateTexture called on a cubemap texture.");
            }
        }

        public void CopyBuffer(DeviceBuffer source, uint32 sourceOffset, DeviceBuffer destination, uint32 destinationOffset, uint32 sizeInBytes)
        {
            OpenGLBuffer srcGLBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(source);
            OpenGLBuffer dstGLBuffer = Util.AssertSubtype<DeviceBuffer, OpenGLBuffer>(destination);

            srcGLBuffer.EnsureResourcesCreated();
            dstGLBuffer.EnsureResourcesCreated();

            if (_extensions.ARB_DirectStateAccess)
            {
                glCopyNamedBufferSubData(
                    srcGLBuffer.Buffer,
                    dstGLBuffer.Buffer,
                    (IntPtr)sourceOffset,
                    (IntPtr)destinationOffset,
                    sizeInBytes);
            }
            else
            {
                glBindBuffer(BufferTarget.CopyReadBuffer, srcGLBuffer.Buffer);
                CheckLastError();

                glBindBuffer(BufferTarget.CopyWriteBuffer, dstGLBuffer.Buffer);
                CheckLastError();

                glCopyBufferSubData(
                    BufferTarget.CopyReadBuffer,
                    BufferTarget.CopyWriteBuffer,
                    (IntPtr)sourceOffset,
                    (IntPtr)destinationOffset,
                    (IntPtr)sizeInBytes);
                CheckLastError();
            }
        }

        public void CopyTexture(
            Texture source,
            uint32 srcX, uint32 srcY, uint32 srcZ,
            uint32 srcMipLevel,
            uint32 srcBaseArrayLayer,
            Texture destination,
            uint32 dstX, uint32 dstY, uint32 dstZ,
            uint32 dstMipLevel,
            uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth,
            uint32 layerCount)
        {
            OpenGLTexture srcGLTexture = Util.AssertSubtype<Texture, OpenGLTexture>(source);
            OpenGLTexture dstGLTexture = Util.AssertSubtype<Texture, OpenGLTexture>(destination);

            srcGLTexture.EnsureResourcesCreated();
            dstGLTexture.EnsureResourcesCreated();

            if (_extensions.CopyImage && depth == 1)
            {
                // glCopyImageSubData does not work properly when depth > 1, so use the awful roundabout copy.
                uint32 srcZOrLayer = Math.Max(srcBaseArrayLayer, srcZ);
                uint32 dstZOrLayer = Math.Max(dstBaseArrayLayer, dstZ);
                uint32 depthOrLayerCount = Math.Max(depth, layerCount);
                // Copy width and height are allowed to be a full compressed block size, even if the mip level only contains a
                // region smaller than the block size.
                Util.GetMipDimensions(source, srcMipLevel, out uint32 mipWidth, out uint32 mipHeight, out _);
                width = Math.Min(width, mipWidth);
                height = Math.Min(height, mipHeight);
                glCopyImageSubData(
                    srcGLTexture.Texture, srcGLTexture.TextureTarget, (int32)srcMipLevel, (int32)srcX, (int32)srcY, (int32)srcZOrLayer,
                    dstGLTexture.Texture, dstGLTexture.TextureTarget, (int32)dstMipLevel, (int32)dstX, (int32)dstY, (int32)dstZOrLayer,
                    width, height, depthOrLayerCount);
                CheckLastError();
            }
            else
            {
                for (uint32 layer = 0; layer < layerCount; layer++)
                {
                    uint32 srcLayer = layer + srcBaseArrayLayer;
                    uint32 dstLayer = layer + dstBaseArrayLayer;
                    CopyRoundabout(
                        srcGLTexture, dstGLTexture,
                        srcX, srcY, srcZ, srcMipLevel, srcLayer,
                        dstX, dstY, dstZ, dstMipLevel, dstLayer,
                        width, height, depth);
                }
            }
        }

        private void CopyRoundabout(
            OpenGLTexture srcGLTexture, OpenGLTexture dstGLTexture,
            uint32 srcX, uint32 srcY, uint32 srcZ, uint32 srcMipLevel, uint32 srcLayer,
            uint32 dstX, uint32 dstY, uint32 dstZ, uint32 dstMipLevel, uint32 dstLayer,
            uint32 width, uint32 height, uint32 depth)
        {
            bool isCompressed = FormatHelpers.IsCompressedFormat(srcGLTexture.Format);
            if (srcGLTexture.Format != dstGLTexture.Format)
            {
                Runtime.GALError("Copying to/from Textures with different formats is not supported.");
            }

            uint32 packAlignment = 4;
            uint32 depthSliceSize = 0;
            uint32 sizeInBytes;
            TextureTarget srcTarget = srcGLTexture.TextureTarget;
            if (isCompressed)
            {
                _textureSamplerManager.SetTextureTransient(srcTarget, srcGLTexture.Texture);
                CheckLastError();

                int32 compressedSize;
                glGetTexLevelParameteriv(
                    srcTarget,
                    (int32)srcMipLevel,
                    GetTextureParameter.TextureCompressedImageSize,
                    &compressedSize);
                CheckLastError();
                sizeInBytes = (uint32)compressedSize;
            }
            else
            {
                uint32 pixelSize = FormatSizeHelpers.GetSizeInBytes(srcGLTexture.Format);
                packAlignment = pixelSize;
                depthSliceSize = width * height * pixelSize;
                sizeInBytes = depthSliceSize * depth;
            }

            StagingBlock block = _stagingMemoryPool.GetStagingBlock(sizeInBytes);

            if (packAlignment < 4)
            {
                glPixelStorei(PixelStoreParameter.PackAlignment, (int32)packAlignment);
                CheckLastError();
            }

            if (isCompressed)
            {
                if (_extensions.ARB_DirectStateAccess)
                {
                    glGetCompressedTextureImage(
                        srcGLTexture.Texture,
                        (int32)srcMipLevel,
                        block.SizeInBytes,
                        block.Data);
                    CheckLastError();
                }
                else
                {
                    _textureSamplerManager.SetTextureTransient(srcTarget, srcGLTexture.Texture);
                    CheckLastError();

                    glGetCompressedTexImage(srcTarget, (int32)srcMipLevel, block.Data);
                    CheckLastError();
                }

                TextureTarget dstTarget = dstGLTexture.TextureTarget;
                _textureSamplerManager.SetTextureTransient(dstTarget, dstGLTexture.Texture);
                CheckLastError();

                Util.GetMipDimensions(srcGLTexture, srcMipLevel, out uint32 mipWidth, out uint32 mipHeight, out uint32 mipDepth);
                uint32 fullRowPitch = FormatHelpers.GetRowPitch(mipWidth, srcGLTexture.Format);
                uint32 fullDepthPitch = FormatHelpers.GetDepthPitch(
                    fullRowPitch,
                    mipHeight,
                    srcGLTexture.Format);

                uint32 denseRowPitch = FormatHelpers.GetRowPitch(width, srcGLTexture.Format);
                uint32 denseDepthPitch = FormatHelpers.GetDepthPitch(denseRowPitch, height, srcGLTexture.Format);
                uint32 numRows = FormatHelpers.GetNumRows(height, srcGLTexture.Format);
                uint32 trueCopySize = denseRowPitch * numRows;
                StagingBlock trueCopySrc = _stagingMemoryPool.GetStagingBlock(trueCopySize);

                uint32 layerStartOffset = denseDepthPitch * srcLayer;

                Util.CopyTextureRegion(
                    (uint8*)block.Data + layerStartOffset,
                    srcX, srcY, srcZ,
                    fullRowPitch, fullDepthPitch,
                    trueCopySrc.Data,
                    0, 0, 0,
                    denseRowPitch,
                    denseDepthPitch,
                    width, height, depth,
                    srcGLTexture.Format);

                UpdateTexture(
                    dstGLTexture,
                    (IntPtr)trueCopySrc.Data,
                    dstX, dstY, dstZ,
                    width, height, 1,
                    dstMipLevel, dstLayer);

                _stagingMemoryPool.Free(trueCopySrc);
            }
            else // !isCompressed
            {
                if (_extensions.ARB_DirectStateAccess)
                {
                    glGetTextureSubImage(
                        srcGLTexture.Texture, (int32)srcMipLevel, (int32)srcX, (int32)srcY, (int32)srcZ,
                        width, height, depth,
                        srcGLTexture.GLPixelFormat, srcGLTexture.GLPixelType, block.SizeInBytes, block.Data);
                    CheckLastError();
                }
                else
                {
                    for (uint32 layer = 0; layer < depth; layer++)
                    {
                        uint32 curLayer = srcZ + srcLayer + layer;
                        uint32 curOffset = depthSliceSize * layer;
                        glGenFramebuffers(1, out uint32 readFB);
                        CheckLastError();
                        glBindFramebuffer(FramebufferTarget.ReadFramebuffer, readFB);
                        CheckLastError();

                        if (srcGLTexture.ArrayLayers > 1 || srcGLTexture.Type == TextureType.Texture3D
                            || (srcGLTexture.Usage & TextureUsage.Cubemap) != 0)
                        {
                            glFramebufferTextureLayer(
                                FramebufferTarget.ReadFramebuffer,
                                GLFramebufferAttachment.ColorAttachment0,
                                srcGLTexture.Texture,
                                (int32)srcMipLevel,
                                (int32)curLayer);
                            CheckLastError();
                        }
                        else if (srcGLTexture.Type == TextureType.Texture1D)
                        {
                            glFramebufferTexture1D(
                                FramebufferTarget.ReadFramebuffer,
                                GLFramebufferAttachment.ColorAttachment0,
                                TextureTarget.Texture1D,
                                srcGLTexture.Texture,
                                (int32)srcMipLevel);
                            CheckLastError();
                        }
                        else
                        {
                            glFramebufferTexture2D(
                                FramebufferTarget.ReadFramebuffer,
                                GLFramebufferAttachment.ColorAttachment0,
                                TextureTarget.Texture2D,
                                srcGLTexture.Texture,
                                (int32)srcMipLevel);
                            CheckLastError();
                        }

                        CheckLastError();
                        glReadPixels(
                            (int32)srcX, (int32)srcY,
                            width, height,
                            srcGLTexture.GLPixelFormat,
                            srcGLTexture.GLPixelType,
                            (uint8*)block.Data + curOffset);
                        CheckLastError();
                        glDeleteFramebuffers(1, ref readFB);
                        CheckLastError();
                    }
                }

                UpdateTexture(
                    dstGLTexture,
                    (IntPtr)block.Data,
                    dstX, dstY, dstZ,
                    width, height, depth, dstMipLevel, dstLayer);
            }

            if (packAlignment < 4)
            {
                glPixelStorei(PixelStoreParameter.PackAlignment, 4);
                CheckLastError();
            }

            _stagingMemoryPool.Free(block);
        }

        private static void CopyWithFBO(
            OpenGLTextureSamplerManager textureSamplerManager,
            OpenGLTexture srcGLTexture, OpenGLTexture dstGLTexture,
            uint32 srcX, uint32 srcY, uint32 srcZ, uint32 srcMipLevel, uint32 srcBaseArrayLayer,
            uint32 dstX, uint32 dstY, uint32 dstZ, uint32 dstMipLevel, uint32 dstBaseArrayLayer,
            uint32 width, uint32 height, uint32 depth, uint32 layerCount, uint32 layer)
        {
            TextureTarget dstTarget = dstGLTexture.TextureTarget;
            if (dstTarget == TextureTarget.Texture2D)
            {
                glBindFramebuffer(
                    FramebufferTarget.ReadFramebuffer,
                    srcGLTexture.GetFramebuffer(srcMipLevel, srcBaseArrayLayer + layer));
                CheckLastError();

                textureSamplerManager.SetTextureTransient(TextureTarget.Texture2D, dstGLTexture.Texture);
                CheckLastError();

                glCopyTexSubImage2D(
                    TextureTarget.Texture2D,
                    (int32)dstMipLevel,
                    (int32)dstX, (int32)dstY,
                    (int32)srcX, (int32)srcY,
                    width, height);
                CheckLastError();
            }
            else if (dstTarget == TextureTarget.Texture2DArray)
            {
                glBindFramebuffer(
                    FramebufferTarget.ReadFramebuffer,
                    srcGLTexture.GetFramebuffer(srcMipLevel, srcBaseArrayLayer + layerCount));

                textureSamplerManager.SetTextureTransient(TextureTarget.Texture2DArray, dstGLTexture.Texture);
                CheckLastError();

                glCopyTexSubImage3D(
                    TextureTarget.Texture2DArray,
                    (int32)dstMipLevel,
                    (int32)dstX,
                    (int32)dstY,
                    (int32)(dstBaseArrayLayer + layer),
                    (int32)srcX,
                    (int32)srcY,
                    width,
                    height);
                CheckLastError();
            }
            else if (dstTarget == TextureTarget.Texture3D)
            {
                textureSamplerManager.SetTextureTransient(TextureTarget.Texture3D, dstGLTexture.Texture);
                CheckLastError();

                for (uint32 i = srcZ; i < srcZ + depth; i++)
                {
                    glCopyTexSubImage3D(
                        TextureTarget.Texture3D,
                        (int32)dstMipLevel,
                        (int32)dstX,
                        (int32)dstY,
                        (int32)dstZ,
                        (int32)srcX,
                        (int32)srcY,
                        width,
                        height);
                }
                CheckLastError();
            }
        }
    }
}
