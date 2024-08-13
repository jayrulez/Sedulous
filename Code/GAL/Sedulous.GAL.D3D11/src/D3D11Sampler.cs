using System;
using Win32.Graphics.Direct3D11;
using Win32.Foundation;

namespace Sedulous.GAL.D3D11
{
	using internal Sedulous.GAL.D3D11;

	internal class D3D11Sampler : Sampler
	{
		private String _name;

		public ref ID3D11SamplerState* DeviceSampler { get; }

		public this(ID3D11Device* device, in SamplerDescription description)
		{
			D3D11_COMPARISON_FUNC comparision = description.ComparisonKind == null ? .D3D11_COMPARISON_NEVER : D3D11Formats.VdToD3D11ComparisonFunc(description.ComparisonKind.Value);
			D3D11_SAMPLER_DESC samplerStateDesc = .()
				{
					AddressU = D3D11Formats.VdToD3D11AddressMode(description.AddressModeU),
					AddressV = D3D11Formats.VdToD3D11AddressMode(description.AddressModeV),
					AddressW = D3D11Formats.VdToD3D11AddressMode(description.AddressModeW),
					Filter = D3D11Formats.ToD3D11Filter(description.Filter, description.ComparisonKind.HasValue),
					MinLOD = description.MinimumLod,
					MaxLOD = description.MaximumLod,
					MaxAnisotropy = (uint32)description.MaximumAnisotropy,
					ComparisonFunc = comparision,
					MipLODBias = description.LodBias,
					BorderColor = ToRawColor4(description.BorderColor)
				};

			HRESULT hr = device.CreateSamplerState(&samplerStateDesc, &DeviceSampler);
		}

		private static float[4] ToRawColor4(SamplerBorderColor borderColor)
		{
			switch (borderColor)
			{
			case SamplerBorderColor.TransparentBlack:
				return .(0, 0, 0, 0);
			case SamplerBorderColor.OpaqueBlack:
				return .(0, 0, 0, 1);
			case SamplerBorderColor.OpaqueWhite:
				return .(1, 1, 1, 1);
			default:
				Runtime.IllegalValue<SamplerBorderColor>();
			}
		}

		public override String Name
		{
			get => _name;
			set
			{
				_name = value;
				D3D11Util.SetDebugName(DeviceSampler, value);
			}
		}

		public override bool IsDisposed => DeviceSampler == null;

		public override void Dispose()
		{
			DeviceSampler.Release();
		}
	}
}
