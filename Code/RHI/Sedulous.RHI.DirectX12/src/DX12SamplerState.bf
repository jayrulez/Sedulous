using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// The DirectX sampler state.
/// </summary>
public class DX12SamplerState : SamplerState
{
	/// <summary>
	/// The native sampler state.
	/// </summary>
	public readonly D3D12_CPU_DESCRIPTOR_HANDLE NativeSampler;

	private DX12GraphicsContext nativeGraphicsContext;

	private String name = new .() ~ delete _;

	/// <inheritdoc />
	public override void* NativePointer => (void*)((int)NativeSampler.ptr);

	/// <inheritdoc />
	public override String Name
	{
		get
		{
			return name;
		}
		set
		{
			name.Set(value);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12SamplerState" /> class.
	/// </summary>
	/// <param name="context">The graphics context. <see cref="T:Sedulous.RHI.GraphicsContext" />.</param>
	/// <param name="description">The sampler state description. <see cref="T:Sedulous.RHI.SamplerStateDescription" />.</param>
	public this(GraphicsContext context, in SamplerStateDescription description)
		: base(context, description)
	{
		D3D12_SAMPLER_DESC nativeDescription = default(D3D12_SAMPLER_DESC);
		nativeDescription.Filter = description.Filter.ToDirectX(description.ComparisonFunc != Sedulous.RHI.ComparisonFunction.Never);
		nativeDescription.AddressU = description.AddressU.ToDirectX();
		nativeDescription.AddressV = description.AddressV.ToDirectX();
		nativeDescription.AddressW = description.AddressW.ToDirectX();
		nativeDescription.MipLODBias = description.MipLODBias;
		nativeDescription.MaxAnisotropy = description.MaxAnisotropy;
		nativeDescription.ComparisonFunc = description.ComparisonFunc.ToDirectX();
		nativeDescription.BorderColor = description.BorderColor.ToDirectX();
		nativeDescription.MinLOD = description.MinLOD;
		nativeDescription.MaxLOD = description.MaxLOD;
		nativeGraphicsContext = context as DX12GraphicsContext;
		NativeSampler = nativeGraphicsContext.SamplerAllocator.Allocate();
		nativeGraphicsContext.DXDevice.CreateSampler(&nativeDescription, NativeSampler);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		nativeGraphicsContext.SamplerAllocator?.Free(NativeSampler);
	}
}
