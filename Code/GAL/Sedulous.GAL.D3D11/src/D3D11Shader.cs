using System;
using System.Text;
using Win32.Graphics.Direct3D11;
using System.Collections;
using Sedulous.GAL.D3D11.ShaderCompiler;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL.D3D11;

    public class D3D11Shader : Shader
    {
        private String _name;

        public ref ID3D11DeviceChild* DeviceShader { get; }
        public ref List<uint8> Bytecode { get; internal set; }

        public this(ID3D11Device* device, ShaderDescription description)
            : base(description.Stage, description.EntryPoint)
        {
            if (description.ShaderBytes.Count > 4
                && description.ShaderBytes[0] == 0x44
                && description.ShaderBytes[1] == 0x58
                && description.ShaderBytes[2] == 0x42
                && description.ShaderBytes[3] == 0x43)
            {
                Bytecode = new .(description.ShaderBytes);
            }
            else
            {
                Bytecode = CompileCode(description, .. new .());
            }

            switch (description.Stage)
            {
                case ShaderStages.Vertex:
                    device.CreateVertexShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11VertexShader**)&DeviceShader);
                    break;
                case ShaderStages.Geometry:
                    device.CreateGeometryShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11GeometryShader**)&DeviceShader);
                    break;
                case ShaderStages.TessellationControl:
                    device.CreateHullShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11HullShader**)&DeviceShader);
                    break;
                case ShaderStages.TessellationEvaluation:
                    device.CreateDomainShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11DomainShader**)&DeviceShader);
                    break;
                case ShaderStages.Fragment:
                    device.CreatePixelShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11PixelShader**)&DeviceShader);
                    break;
                case ShaderStages.Compute:
                    device.CreateComputeShader(Bytecode.Ptr, (.)Bytecode.Count, null, .. (ID3D11ComputeShader**)&DeviceShader);
                    break;
                default:
                    Runtime.IllegalValue<ShaderStages>();
            }
        }

        private void CompileCode(ShaderDescription description, List<uint8> byteCode)
        {
            String profile;
            switch (description.Stage)
            {
                case ShaderStages.Vertex:
                    profile = "vs_5_0";
                    break;
                case ShaderStages.Geometry:
                    profile = "gs_5_0";
                    break;
                case ShaderStages.TessellationControl:
                    profile = "hs_5_0";
                    break;
                case ShaderStages.TessellationEvaluation:
                    profile = "ds_5_0";
                    break;
                case ShaderStages.Fragment:
                    profile = "ps_5_0";
                    break;
                case ShaderStages.Compute:
                    profile = "cs_5_0";
                    break;
                default:
                    Runtime.IllegalValue<ShaderStages>();
            }

            ShaderFlags flags = description.Debug ? ShaderFlags.Debug : ShaderFlags.OptimizationLevel3;
            FxcCompiler.Compile(scope .((char8*)description.ShaderBytes.Ptr, description.ShaderBytes.Count), null, null,
				scope .(description.EntryPoint), null,
				profile, flags, .None, var result, var error);

            if (result == null)
            {
                Runtime.GALError(scope $"Failed to compile HLSL code: {scope String((char8*)error.GetBufferPointer(), (.)error.GetBufferSize())}");
            }

            byteCode.AddRange(Span<uint8>((uint8*)result.GetBufferPointer(), (.)result.GetBufferSize()));
        }

        public override String Name
        {
            get => _name;
            set
            {
                _name = value;
                D3D11Util.SetDebugName(DeviceShader, value);
            }
        }

        public override bool IsDisposed => DeviceShader == null;

        public override void Dispose()
        {
            DeviceShader.Release();
        }
    }
}
