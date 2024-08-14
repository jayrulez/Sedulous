using System;
using System.Diagnostics;
using Sedulous.MetalBindings;
using System.Collections;

namespace Sedulous.GAL.MTL
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.MTL;
    internal class MTLPipeline : Pipeline
    {
        private bool _disposed;
        private List<MTLFunction> _specializedFunctions;

        public MTLRenderPipelineState RenderPipelineState { get; }
        public MTLComputePipelineState ComputePipelineState { get; }
        public MTLPrimitiveType PrimitiveType { get; }
        public new MTLResourceLayout[] ResourceLayouts { get; }
        public ResourceBindingModel ResourceBindingModel { get; }
        public uint32 VertexBufferCount { get; }
        public uint32 NonVertexBufferCount { get; }
        public MTLCullMode CullMode { get; }
        public MTLWinding FrontFace { get; }
        public MTLTriangleFillMode FillMode { get; }
        public MTLDepthStencilState DepthStencilState { get; }
        public MTLDepthClipMode DepthClipMode { get; }
        public override bool IsComputePipeline { get; protected set; }
        public bool ScissorTestEnabled { get; }
        public MTLSize ThreadsPerThreadgroup { get; } = MTLSize(1, 1, 1);
        public bool HasStencil { get; }
        public override String Name { get; set; }
        public uint32 StencilReference { get; }
        public RgbaFloat BlendColor { get; }
        public override bool IsDisposed => _disposed;

        public this(in GraphicsPipelineDescription description, MTLGraphicsDevice gd)
            : base(description)
        {
            PrimitiveType = MTLFormats.VdToMTLPrimitiveTopology(description.PrimitiveTopology);
            ResourceLayouts = new MTLResourceLayout[description.ResourceLayouts.Count];
            NonVertexBufferCount = 0;
            for (int32 i = 0; i < ResourceLayouts.Count; i++)
            {
                ResourceLayouts[i] = Util.AssertSubtype<ResourceLayout, MTLResourceLayout>(description.ResourceLayouts[i]);
                NonVertexBufferCount += ResourceLayouts[i].BufferCount;
            }
            ResourceBindingModel = description.ResourceBindingModel ?? gd.ResourceBindingModel;

            CullMode = MTLFormats.VdToMTLCullMode(description.RasterizerState.CullMode);
            FrontFace = MTLFormats.VdVoMTLFrontFace(description.RasterizerState.FrontFace);
            FillMode = MTLFormats.VdToMTLFillMode(description.RasterizerState.FillMode);
            ScissorTestEnabled = description.RasterizerState.ScissorTestEnabled;

            MTLRenderPipelineDescriptor mtlDesc = MTLRenderPipelineDescriptor.New();
            for (Shader shader in description.ShaderSet.Shaders)
            {
                MTLShader mtlShader = Util.AssertSubtype<Shader, MTLShader>(shader);
                MTLFunction specializedFunction;

                if (mtlShader.HasFunctionConstants)
                {
                    // Need to create specialized MTLFunction.
                    MTLFunctionConstantValues constantValues = CreateConstantValues(description.ShaderSet.Specializations);
                    specializedFunction = mtlShader.Library.newFunctionWithNameConstantValues(mtlShader.EntryPoint, constantValues);
                    AddSpecializedFunction(specializedFunction);
                    ObjectiveCRuntime.release(constantValues.NativePtr);

                    Debug.Assert(specializedFunction.NativePtr != null, "Failed to create specialized MTLFunction");
                }
                else
                {
                    specializedFunction = mtlShader.Function;
                }

                if (shader.Stage == ShaderStages.Vertex)
                {
                    mtlDesc.vertexFunction = specializedFunction;
                }
                else if (shader.Stage == ShaderStages.Fragment)
                {
                    mtlDesc.fragmentFunction = specializedFunction;
                }
            }

            // Vertex layouts
            VertexLayoutDescription[] vdVertexLayouts = description.ShaderSet.VertexLayouts;
            MTLVertexDescriptor vertexDescriptor = mtlDesc.vertexDescriptor;

            for (uint32 i = 0; i < vdVertexLayouts.Count; i++)
            {
                uint32 layoutIndex = ResourceBindingModel == /*ResourceBindingModel*/.Improved
                    ? NonVertexBufferCount + i
                    : i;
                MTLVertexBufferLayoutDescriptor mtlLayout = vertexDescriptor.layouts[layoutIndex];
                mtlLayout.stride = (uint)vdVertexLayouts[i].Stride;
                uint32 stepRate = vdVertexLayouts[i].InstanceStepRate;
                mtlLayout.stepFunction = stepRate == 0 ? MTLVertexStepFunction.PerVertex : MTLVertexStepFunction.PerInstance;
                mtlLayout.stepRate = (uint)Math.Max(1, stepRate);
            }

            uint32 element = 0;
            for (uint32 i = 0; i < vdVertexLayouts.Count; i++)
            {
                uint32 offset = 0;
                VertexLayoutDescription vdDesc = vdVertexLayouts[i];
                for (uint32 j = 0; j < vdDesc.Elements.Count; j++)
                {
                    VertexElementDescription elementDesc = vdDesc.Elements[j];
                    MTLVertexAttributeDescriptor mtlAttribute = vertexDescriptor.attributes[element];
                    mtlAttribute.bufferIndex = (uint)(ResourceBindingModel == /*ResourceBindingModel*/.Improved
                        ? NonVertexBufferCount + i
                        : i);
                    mtlAttribute.format = MTLFormats.VdToMTLVertexFormat(elementDesc.Format);
                    mtlAttribute.offset = elementDesc.Offset != 0 ? (uint)elementDesc.Offset : (uint)offset;
                    offset += FormatSizeHelpers.GetSizeInBytes(elementDesc.Format);
                    element += 1;
                }
            }

            VertexBufferCount = (uint32)vdVertexLayouts.Count;

            // Outputs
            OutputDescription outputs = description.Outputs;
            BlendStateDescription blendStateDesc = description.BlendState;
            BlendColor = blendStateDesc.BlendFactor;

            if (outputs.SampleCount != TextureSampleCount.Count1)
            {
                mtlDesc.sampleCount = (uint)FormatHelpers.GetSampleCountUInt32(outputs.SampleCount);
            }

            if (outputs.DepthAttachment != null)
            {
                PixelFormat depthFormat = outputs.DepthAttachment.Value.Format;
                MTLPixelFormat mtlDepthFormat = MTLFormats.VdToMTLPixelFormat(depthFormat, true);
                mtlDesc.depthAttachmentPixelFormat = mtlDepthFormat;
                if ((FormatHelpers.IsStencilFormat(depthFormat)))
                {
                    HasStencil = true;
                    mtlDesc.stencilAttachmentPixelFormat = mtlDepthFormat;
                }
            }
            for (uint32 i = 0; i < outputs.ColorAttachments.Count; i++)
            {
                BlendAttachmentDescription attachmentBlendDesc = blendStateDesc.AttachmentStates[i];
                MTLRenderPipelineColorAttachmentDescriptor colorDesc = mtlDesc.colorAttachments[i];
                colorDesc.pixelFormat = MTLFormats.VdToMTLPixelFormat(outputs.ColorAttachments[i].Format, false);
                colorDesc.blendingEnabled = attachmentBlendDesc.BlendEnabled;
                colorDesc.writeMask = MTLFormats.VdToMTLColorWriteMask(attachmentBlendDesc.ColorWriteMask.GetValueOrDefault());
                colorDesc.alphaBlendOperation = MTLFormats.VdToMTLBlendOp(attachmentBlendDesc.AlphaFunction);
                colorDesc.sourceAlphaBlendFactor = MTLFormats.VdToMTLBlendFactor(attachmentBlendDesc.SourceAlphaFactor);
                colorDesc.destinationAlphaBlendFactor = MTLFormats.VdToMTLBlendFactor(attachmentBlendDesc.DestinationAlphaFactor);

                colorDesc.rgbBlendOperation = MTLFormats.VdToMTLBlendOp(attachmentBlendDesc.ColorFunction);
                colorDesc.sourceRGBBlendFactor = MTLFormats.VdToMTLBlendFactor(attachmentBlendDesc.SourceColorFactor);
                colorDesc.destinationRGBBlendFactor = MTLFormats.VdToMTLBlendFactor(attachmentBlendDesc.DestinationColorFactor);
            }

            mtlDesc.alphaToCoverageEnabled = blendStateDesc.AlphaToCoverageEnabled;

            RenderPipelineState = gd.Device.newRenderPipelineStateWithDescriptor(mtlDesc);
            ObjectiveCRuntime.release(mtlDesc.NativePtr);

            if (outputs.DepthAttachment != null)
            {
                MTLDepthStencilDescriptor depthDescriptor = MTLUtil.AllocInit<MTLDepthStencilDescriptor>(
                    nameof(MTLDepthStencilDescriptor));
                depthDescriptor.depthCompareFunction = MTLFormats.VdToMTLCompareFunction(
                    description.DepthStencilState.DepthComparison);
                depthDescriptor.depthWriteEnabled = description.DepthStencilState.DepthWriteEnabled;

                bool stencilEnabled = description.DepthStencilState.StencilTestEnabled;
                if (stencilEnabled)
                {
                    StencilReference = description.DepthStencilState.StencilReference;

                    StencilBehaviorDescription vdFrontDesc = description.DepthStencilState.StencilFront;
                    MTLStencilDescriptor front = MTLUtil.AllocInit<MTLStencilDescriptor>(nameof(MTLStencilDescriptor));
                    front.readMask = stencilEnabled ? description.DepthStencilState.StencilReadMask : 0u;
                    front.writeMask = stencilEnabled ? description.DepthStencilState.StencilWriteMask : 0u;
                    front.depthFailureOperation = MTLFormats.VdToMTLStencilOperation(vdFrontDesc.DepthFail);
                    front.stencilFailureOperation = MTLFormats.VdToMTLStencilOperation(vdFrontDesc.Fail);
                    front.depthStencilPassOperation = MTLFormats.VdToMTLStencilOperation(vdFrontDesc.Pass);
                    front.stencilCompareFunction = MTLFormats.VdToMTLCompareFunction(vdFrontDesc.Comparison);
                    depthDescriptor.frontFaceStencil = front;

                    StencilBehaviorDescription vdBackDesc = description.DepthStencilState.StencilBack;
                    MTLStencilDescriptor back = MTLUtil.AllocInit<MTLStencilDescriptor>(nameof(MTLStencilDescriptor));
                    back.readMask = stencilEnabled ? description.DepthStencilState.StencilReadMask : 0u;
                    back.writeMask = stencilEnabled ? description.DepthStencilState.StencilWriteMask : 0u;
                    back.depthFailureOperation = MTLFormats.VdToMTLStencilOperation(vdBackDesc.DepthFail);
                    back.stencilFailureOperation = MTLFormats.VdToMTLStencilOperation(vdBackDesc.Fail);
                    back.depthStencilPassOperation = MTLFormats.VdToMTLStencilOperation(vdBackDesc.Pass);
                    back.stencilCompareFunction = MTLFormats.VdToMTLCompareFunction(vdBackDesc.Comparison);
                    depthDescriptor.backFaceStencil = back;

                    ObjectiveCRuntime.release(front.NativePtr);
                    ObjectiveCRuntime.release(back.NativePtr);
                }

                DepthStencilState = gd.Device.newDepthStencilStateWithDescriptor(depthDescriptor);
                ObjectiveCRuntime.release(depthDescriptor.NativePtr);
            }

            DepthClipMode = description.DepthStencilState.DepthTestEnabled ? MTLDepthClipMode.Clip : MTLDepthClipMode.Clamp;
        }

        public this(in ComputePipelineDescription description, MTLGraphicsDevice gd)
            : base(description)
        {
            IsComputePipeline = true;
            ResourceLayouts = new MTLResourceLayout[description.ResourceLayouts.Count];
            for (int32 i = 0; i < ResourceLayouts.Count; i++)
            {
                ResourceLayouts[i] = Util.AssertSubtype<ResourceLayout, MTLResourceLayout>(description.ResourceLayouts[i]);
            }

            ThreadsPerThreadgroup = MTLSize(
                description.ThreadGroupSizeX,
                description.ThreadGroupSizeY,
                description.ThreadGroupSizeZ);

            MTLComputePipelineDescriptor mtlDesc = MTLUtil.AllocInit<MTLComputePipelineDescriptor>(
                nameof(MTLComputePipelineDescriptor));
            MTLShader mtlShader = Util.AssertSubtype<Shader, MTLShader>(description.ComputeShader);
            MTLFunction specializedFunction;
            if (mtlShader.HasFunctionConstants)
            {
                // Need to create specialized MTLFunction.
                MTLFunctionConstantValues constantValues = CreateConstantValues(description.Specializations);
                specializedFunction = mtlShader.Library.newFunctionWithNameConstantValues(mtlShader.EntryPoint, constantValues);
                AddSpecializedFunction(specializedFunction);
                ObjectiveCRuntime.release(constantValues.NativePtr);

                Debug.Assert(specializedFunction.NativePtr != null, "Failed to create specialized MTLFunction");
            }
            else
            {
                specializedFunction = mtlShader.Function;
            }

            mtlDesc.computeFunction = specializedFunction;
            MTLPipelineBufferDescriptorArray buffers = mtlDesc.buffers;
            uint32 bufferIndex = 0;
            for (MTLResourceLayout layout in ResourceLayouts)
            {
                for (ResourceLayoutElementDescription rle in layout.Description.Elements)
                {
                    ResourceKind kind = rle.Kind;
                    if (kind == ResourceKind.UniformBuffer
                        || kind == ResourceKind.StructuredBufferReadOnly)
                    {
                        MTLPipelineBufferDescriptor bufferDesc = buffers[bufferIndex];
                        bufferDesc.mutability = MTLMutability.Immutable;
                        bufferIndex += 1;
                    }
                    else if (kind == ResourceKind.StructuredBufferReadWrite)
                    {
                        MTLPipelineBufferDescriptor bufferDesc = buffers[bufferIndex];
                        bufferDesc.mutability = MTLMutability.Mutable;
                        bufferIndex += 1;
                    }
                }
            }

            ComputePipelineState = gd.Device.newComputePipelineStateWithDescriptor(mtlDesc);

            ObjectiveCRuntime.release(mtlDesc.NativePtr);
        }

        private MTLFunctionConstantValues CreateConstantValues(SpecializationConstant[] specializations)
        {
            MTLFunctionConstantValues ret = MTLFunctionConstantValues.New();
            if (specializations != null)
            {
                for (SpecializationConstant sc in specializations)
                {
                    MTLDataType mtlType = MTLFormats.VdVoMTLShaderConstantType(sc.Type);
                    ret.setConstantValuetypeatIndex(&sc.Data, mtlType, (uint)sc.ID);
                }
            }

            return ret;
        }

        private void AddSpecializedFunction(MTLFunction @function)
        {
            if (_specializedFunctions == null) { _specializedFunctions = new List<MTLFunction>(); }
            _specializedFunctions.Add(@function);
        }

        public override void Dispose()
        {
            if (!_disposed)
            {
                if (RenderPipelineState.NativePtr != null)
                {
                    ObjectiveCRuntime.release(RenderPipelineState.NativePtr);
                }
                else
                {
                    Debug.Assert(ComputePipelineState.NativePtr != null);
                    ObjectiveCRuntime.release(ComputePipelineState.NativePtr);
                }

                if (_specializedFunctions != null)
                {
                    for (MTLFunction @function in _specializedFunctions)
                    {
                        ObjectiveCRuntime.release(@function.NativePtr);
                    }
                    _specializedFunctions.Clear();
                }

                _disposed = true;
            }
        }
    }
}
