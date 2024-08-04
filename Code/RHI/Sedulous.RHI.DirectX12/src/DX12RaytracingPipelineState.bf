using System;
using Sedulous.RHI;
using Sedulous.RHI.Raytracing;
using Win32.Graphics.Direct3D12;
using System.Collections;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// DX12 Raytracing pipeline state.
/// </summary>
public class DX12RaytracingPipelineState : RaytracingPipelineState
{
	/// <summary>
	/// DX12 native pipeline as ID3D12StateObject.
	/// </summary>
	public ID3D12StateObject* nativePipeline;

	private D3D12_GLOBAL_ROOT_SIGNATURE globalRootSignature;

	/// <summary>
	/// Generated shader binding table.
	/// </summary>
	public DX12ShaderTable shaderBindingTable;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12RaytracingPipelineState" /> class.
	/// </summary>
	/// <param name="context">The graphics context.</param>
	/// <param name="description">The raytracing pipeline state description.</param>
	public this(DX12GraphicsContext context, in RaytracingPipelineDescription description)
		: base(description)
	{
		List<D3D12_STATE_SUBOBJECT> subobjects = scope .();
		List<D3D12_EXPORT_DESC> nativeExportDesc = scope .();
		Shader raygenShader = description.Shaders.RayGenerationShader;
		if (raygenShader != null)
		{
			nativeExportDesc.Add(.()
			{
				Name = raygenShader.Description.EntryPoint.ToScopedNativeWChar!::(),
				Flags = .D3D12_EXPORT_FLAG_NONE,
				ExportToRename = null
			});
		}
		Shader[] closesthitShaders = description.Shaders.ClosestHitShader;
		if (closesthitShaders != null)
		{
			for (int32 i = 0; i < closesthitShaders.Count; i++)
			{
				String entryPoint = closesthitShaders[i].Description.EntryPoint;
				nativeExportDesc.Add(.()
				{
					Name = entryPoint.ToScopedNativeWChar!::(),
					Flags = .D3D12_EXPORT_FLAG_NONE,
					ExportToRename = null
				});
			}
		}
		Shader[] missShaders = description.Shaders.MissShader;
		if (missShaders != null)
		{
			for (int32 i = 0; i < missShaders.Count; i++)
			{
				String entryPoint = missShaders[i].Description.EntryPoint;
				nativeExportDesc.Add(.()
				{
					Name = entryPoint.ToScopedNativeWChar!::(),
					Flags = .D3D12_EXPORT_FLAG_NONE,
					ExportToRename = null
				});
			}
		}
		Shader[] anyhitShaders = description.Shaders.AnyHitShader;
		if (anyhitShaders != null)
		{
			for (int32 i = 0; i < anyhitShaders.Count; i++)
			{
				String entryPoint = anyhitShaders[i].Description.EntryPoint;
				nativeExportDesc.Add(.()
				{
					Name = entryPoint.ToScopedNativeWChar!::(),
					Flags = .D3D12_EXPORT_FLAG_NONE,
					ExportToRename = null
				});
			}
		}
		Shader[] intersectionShaders = description.Shaders.IntersectionShader;
		if (intersectionShaders != null)
		{
			for (int32 i = 0; i < intersectionShaders.Count; i++)
			{
				String entryPoint = intersectionShaders[i].Description.EntryPoint;
				nativeExportDesc.Add(.()
				{
					Name = entryPoint.ToScopedNativeWChar!::(),
					Flags = .D3D12_EXPORT_FLAG_NONE,
					ExportToRename = null
				});
			}
		}
		D3D12_DXIL_LIBRARY_DESC dxilLibDesc = .()
				{
					DXILLibrary = ((DX12Shader)raygenShader).NativeShader,
					NumExports = (.)nativeExportDesc.Count,
					pExports = nativeExportDesc.Ptr
				};
		subobjects.Add(.(.D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY,&dxilLibDesc));
		for (int32 i = 0; i < description.HitGroups.Count; i++)
		{
			Sedulous.RHI.Raytracing.HitGroupDescription hitGroupDescription = description.HitGroups[i];
			D3D12_HIT_GROUP_DESC hitgroup = D3D12_HIT_GROUP_DESC()
			{
				Type = hitGroupDescription.Type.ToDirectX(),
				HitGroupExport = hitGroupDescription.Name.ToScopedNativeWChar!::(),
				ClosestHitShaderImport = hitGroupDescription.ClosestHitEntryPoint.ToScopedNativeWChar!::(),
				AnyHitShaderImport = hitGroupDescription.AnyHitEntryPoint.ToScopedNativeWChar!::(),
				IntersectionShaderImport = hitGroupDescription.IntersectionEntryPoint.ToScopedNativeWChar!::()
			};
			subobjects.Add(.(.D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP, &hitgroup));
		}
		D3D12_RAYTRACING_SHADER_CONFIG shaderConfig = D3D12_RAYTRACING_SHADER_CONFIG()
				{
					MaxPayloadSizeInBytes = (uint32)description.MaxPayloadSizeInBytes,
					MaxAttributeSizeInBytes = (uint32)description.MaxAttributeSizeInBytes
				};
		subobjects.Add(.(.D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG, &shaderConfig));
		globalRootSignature = .(){
					pGlobalRootSignature = context.DefaultRaytracingGlobalRootSignature
				};
		subobjects.Add(.(.D3D12_STATE_SUBOBJECT_TYPE_GLOBAL_ROOT_SIGNATURE, &globalRootSignature));

		D3D12_RAYTRACING_PIPELINE_CONFIG pipelineConfig = .()
				{
					MaxTraceRecursionDepth = (uint32)description.MaxTraceRecursionDepth
				};
		subobjects.Add(.(.D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG, &pipelineConfig));
		D3D12_STATE_OBJECT_DESC desc = .() {
			Type = .D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE,
			pSubobjects = subobjects.Ptr,
			NumSubobjects  = (uint32)subobjects.Count
		};

		((ID3D12Device5*)context.DXDevice).CreateStateObject(&desc, ID3D12StateObject.IID, (void**)& nativePipeline);
		CreateShaderBindingTable(context, description);
	}

	private void CreateShaderBindingTable(DX12GraphicsContext context, in RaytracingPipelineDescription description)
	{
		shaderBindingTable = new DX12ShaderTable(context);
		RaytracingShaderStateDescription shaders = description.Shaders;
		String rayGenIdentifier = shaders.GetEntryPointByStage(ShaderStages.RayGeneration, .. scope .())[0];
		shaderBindingTable.AddRayGenProgram(rayGenIdentifier, null);
		List<String> missIdentifiers = shaders.GetEntryPointByStage(ShaderStages.Miss, .. scope .());
		for (int32 i = 0; i < missIdentifiers.Count; i++)
		{
			shaderBindingTable.AddMissProgram(missIdentifiers[i], null);
		}
		Sedulous.RHI.Raytracing.HitGroupDescription[] hitgroups = description.HitGroups;
		for (int32 i = 0; i < hitgroups.Count; i++)
		{
			if (hitgroups[i].Type != 0)
			{
				String hitGroupIdentifier = hitgroups[i].Name;
				shaderBindingTable.AddHitGroupProgram(hitGroupIdentifier, null);
			}
		}
		shaderBindingTable.Generate(nativePipeline);
	}

	/// <summary>
	/// Apply only changes compare with the previous pipelineState.
	/// </summary>
	/// <param name="commandList">The commandList where to set this pipeline.</param>
	/// <param name="previousPipeline">The previous pipelineState.</param>
	public void Apply(ID3D12GraphicsCommandList* commandList, DX12RaytracingPipelineState previousPipeline)
	{
		commandList.SetComputeRootSignature(globalRootSignature.pGlobalRootSignature);
		((ID3D12GraphicsCommandList4*)commandList).SetPipelineState1(nativePipeline);
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
			}
			disposed = true;
		}
	}
}
