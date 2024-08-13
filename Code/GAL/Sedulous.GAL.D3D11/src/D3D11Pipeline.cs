using Win32.Graphics.Direct3D11;
using System.Diagnostics;
using System;
using Win32.Graphics.Direct3D;
using System.Collections;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL;
	using internal Sedulous.GAL.D3D11;

    public class D3D11Pipeline : Pipeline
    {
        private String _name;
        private bool _disposed;

        public ID3D11BlendState* BlendState { get; }
        public float[4] BlendFactor { get; }
        public ID3D11DepthStencilState* DepthStencilState { get; }
        public uint32 StencilReference { get; }
        public ID3D11RasterizerState* RasterizerState { get; }
        public D3D_PRIMITIVE_TOPOLOGY PrimitiveTopology { get; }
        public ID3D11InputLayout* InputLayout { get; }
        public ID3D11VertexShader* VertexShader { get; }
        public ID3D11GeometryShader* GeometryShader { get; } // May be null.
        public ID3D11HullShader* HullShader { get; } // May be null.
        public ID3D11DomainShader* DomainShader { get; } // May be null.
        public ID3D11PixelShader* PixelShader { get; }
        public ID3D11ComputeShader* ComputeShader { get; }
        public new D3D11ResourceLayout[] ResourceLayouts { get; }
        public int32[] VertexStrides { get; }

        public override bool IsComputePipeline { get; protected set; }

        public this(D3D11ResourceCache cache, in GraphicsPipelineDescription description)
            : base(description)
        {
            List<uint8> vsBytecode = null;
            Shader[] stages = description.ShaderSet.Shaders;
            for (int i = 0; i < description.ShaderSet.Shaders.Count; i++)
            {
                if (stages[i].Stage == ShaderStages.Vertex)
                {
                    D3D11Shader d3d11VertexShader = ((D3D11Shader)stages[i]);
                    VertexShader = (ID3D11VertexShader*)d3d11VertexShader.DeviceShader;
                    vsBytecode = d3d11VertexShader.Bytecode;
                }
                if (stages[i].Stage == ShaderStages.Geometry)
                {
                    GeometryShader = (ID3D11GeometryShader*)((D3D11Shader)stages[i]).DeviceShader;
                }
                if (stages[i].Stage == ShaderStages.TessellationControl)
                {
                    HullShader = (ID3D11HullShader*)((D3D11Shader)stages[i]).DeviceShader;
                }
                if (stages[i].Stage == ShaderStages.TessellationEvaluation)
                {
                    DomainShader = (ID3D11DomainShader*)((D3D11Shader)stages[i]).DeviceShader;
                }
                if (stages[i].Stage == ShaderStages.Fragment)
                {
                    PixelShader = (ID3D11PixelShader*)((D3D11Shader)stages[i]).DeviceShader;
                }
                if (stages[i].Stage == ShaderStages.Compute)
                {
                    ComputeShader = (ID3D11ComputeShader*)((D3D11Shader)stages[i]).DeviceShader;
                }
            }

            cache.GetPipelineResources(
                description.BlendState,
                description.DepthStencilState,
                description.RasterizerState,
                description.Outputs.SampleCount != TextureSampleCount.Count1,
                description.ShaderSet.VertexLayouts,
                vsBytecode,
                var blendState,
                var depthStencilState,
                var rasterizerState,
                var inputLayout);

            BlendState = blendState;
            BlendFactor = description.BlendState.BlendFactor.ToFloat4();
            DepthStencilState = depthStencilState;
            StencilReference = description.DepthStencilState.StencilReference;
            RasterizerState = rasterizerState;
            PrimitiveTopology = D3D11Formats.VdToD3D11PrimitiveTopology(description.PrimitiveTopology);

            ResourceLayout[] genericLayouts = description.ResourceLayouts;
            ResourceLayouts = new D3D11ResourceLayout[genericLayouts.Count];
            for (int i = 0; i < ResourceLayouts.Count; i++)
            {
                ResourceLayouts[i] = Util.AssertSubtype<ResourceLayout, D3D11ResourceLayout>(genericLayouts[i]);
            }

            Debug.Assert(vsBytecode != null || ComputeShader != null);
            if (vsBytecode != null && description.ShaderSet.VertexLayouts.Count > 0)
            {
                InputLayout = inputLayout;
                int numVertexBuffers = description.ShaderSet.VertexLayouts.Count;
                VertexStrides = new int32[numVertexBuffers];
                for (int i = 0; i < numVertexBuffers; i++)
                {
                    VertexStrides[i] = (int32)description.ShaderSet.VertexLayouts[i].Stride;
                }
            }
            else
            {
                VertexStrides = new .[0];
            }
        }

        public this(D3D11ResourceCache cache, in ComputePipelineDescription description)
            : base(description)
        {
            IsComputePipeline = true;
            ComputeShader = (ID3D11ComputeShader*)((D3D11Shader)description.ComputeShader).DeviceShader;
            ResourceLayout[] genericLayouts = description.ResourceLayouts;
            ResourceLayouts = new D3D11ResourceLayout[genericLayouts.Count];
            for (int i = 0; i < ResourceLayouts.Count; i++)
            {
                ResourceLayouts[i] = Util.AssertSubtype<ResourceLayout, D3D11ResourceLayout>(genericLayouts[i]);
            }
        }

        public override String Name
        {
            get => _name;
            set => _name = value;
        }

        public override bool IsDisposed => _disposed;

        public override void Dispose()
        {
            _disposed = true;
        }
    }
}
