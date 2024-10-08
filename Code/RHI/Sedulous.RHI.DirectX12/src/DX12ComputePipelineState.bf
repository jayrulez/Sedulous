using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Foundation;
using Win32;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// The DirectX version of the PipelineState.
/// </summary>
public class DX12ComputePipelineState : ComputePipelineState
{
	private bool disposed;

	private ID3D12PipelineState* nativePipeline;

	private ID3D12RootSignature* rootSignature;

	private String name = new .() ~ delete _;

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
			SetDebugName(nativePipeline, name);
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ComputePipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The compute pipeline state description.</param>
	public this(DX12GraphicsContext context, in ComputePipelineDescription description)
		: base(description)
	{
		rootSignature = context.DefaultComputeSignature;
		D3D12_COMPUTE_PIPELINE_STATE_DESC nativePipelineStateDescription = D3D12_COMPUTE_PIPELINE_STATE_DESC()
		{
			CS = (description.shaderDescription.ComputeShader as DX12Shader).NativeShader,
			Flags = .D3D12_PIPELINE_STATE_FLAG_NONE,
			pRootSignature = rootSignature
		};
		HRESULT result = context.DXDevice.CreateComputePipelineState(&nativePipelineStateDescription, ID3D12PipelineState.IID, (void**)&nativePipeline);
		if (!SUCCEEDED(result))
		{
			context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
	}

	/// <summary>
	/// Apply only changes compared with the previous pipeline state.
	/// </summary>
	/// <param name="commandList">The command list where to set this pipeline.</param>
	/// <param name="previousPipeline">The previous pipeline state.</param>
	public void Apply(ID3D12GraphicsCommandList* commandList, DX12ComputePipelineState previousPipeline)
	{
		commandList.SetComputeRootSignature(rootSignature);
		commandList.SetPipelineState(nativePipeline);
	}

	/// <inheritdoc />
	public override void Dispose()
	{
		Dispose(disposing: true);
	}

	/// <summary>
	/// Releases unmanaged and - optionally - managed resources.
	/// </summary>
	/// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
	private void Dispose(bool disposing)
	{
		if (!disposed)
		{
			if (disposing)
			{
				nativePipeline?.Release();
				rootSignature?.Release();
			}
			disposed = true;
		}
	}
}
