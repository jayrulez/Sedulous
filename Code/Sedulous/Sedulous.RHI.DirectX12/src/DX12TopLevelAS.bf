using System;
using Sedulous.RHI.Raytracing;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;
using static Sedulous.RHI.DirectX12.DX12Helpers;

/// <summary>
/// DX12 Top Level Acceleration Structure implementation.
/// </summary>
public class DX12TopLevelAS : TopLevelAS
{
	struct SEDULOUS_D3D12_RAYTRACING_INSTANCE_DESC
	{
		public float[12] Transform;
		[Bitfield(.Public, .Bits(24), "InstanceID")]
		[Bitfield(.Public, .Bits(8), "InstanceMask")]
		public uint32 _bitfield1;

		[Bitfield(.Public, .Bits(24), "InstanceContributionToHitGroupIndex")]
		[Bitfield<D3D12_RAYTRACING_INSTANCE_FLAGS>(.Public, .Bits(8), "Flags")]
		public uint32 _bitfield2;
		public uint64 AccelerationStructure;

		public static implicit  operator D3D12_RAYTRACING_INSTANCE_DESC(Self self)
		{
			return .()
				{
					Transform = self.Transform,
					_bitfield1 = self._bitfield1,
					_bitfield2 = self._bitfield2,
					AccelerationStructure = self.AccelerationStructure
				};
		}
	}

	internal D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC  AccelerationStructureDescription;

	private D3D12_CPU_DESCRIPTOR_HANDLE? accerationStructureView;

	private ID3D12Resource* scratchBuffer;

	private ID3D12Resource* instancesBuffer;

	/// <summary>
	/// DX12 Acceleration Structure Result buffer.
	/// </summary>
	public ID3D12Resource* ResultBuffer;

	/// <inheritdoc />
	public override void* NativePointer => ResultBuffer;

	/// <summary>
	/// Gets the shader resource view.
	/// </summary>
	public D3D12_CPU_DESCRIPTOR_HANDLE AccelerationStructureView
	{
		get
		{
			if (!accerationStructureView.HasValue)
			{
				accerationStructureView = GetAccelerationStructureView();
			}
			return accerationStructureView.Value;
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12TopLevelAS" /> class.
	/// </summary>
	/// <param name="context">DirectX12 Context.</param>
	/// <param name="description">Top Level Description.</param>
	public this(DX12GraphicsContext context, ref TopLevelASDescription description)
		: base(context, ref description)
	{
		//IL_0119: Unknown result type (might be due to invalid IL or missing references)
		D3D12_RAYTRACING_INSTANCE_DESC[] raytracingInstanceDescriptions = new D3D12_RAYTRACING_INSTANCE_DESC[description.Instances.Count];
		for (int32 i = 0; i < raytracingInstanceDescriptions.Count; i++)
		{
			AccelerationStructureInstance instance = description.Instances[i];
			SEDULOUS_D3D12_RAYTRACING_INSTANCE_DESC instanceDesc = SEDULOUS_D3D12_RAYTRACING_INSTANCE_DESC()
			{
				InstanceID = instance.InstanceID,
				InstanceContributionToHitGroupIndex = instance.InstanceContributionToHitGroupIndex,
				Flags = (D3D12_RAYTRACING_INSTANCE_FLAGS)instance.Flags,
				InstanceMask = instance.InstanceMask,
				Transform = instance.Transform4x4.ToMatrix3x4(),
				AccelerationStructure = ((DX12BottomLevelAS)instance.BottonLevel).ResultBuffer.GetGPUVirtualAddress()
			};
			raytracingInstanceDescriptions[i] = instanceDesc;
		}
		ID3D12Device5* device = (ID3D12Device5*)context.DXDevice;
		instancesBuffer = DX12RaytracingHelpers.CreateBuffer(device, (uint32)(sizeof(D3D12_RAYTRACING_INSTANCE_DESC) * description.Instances.Count), .D3D12_RESOURCE_FLAG_NONE, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ, DX12RaytracingHelpers.kUploadHeapProps);
		void* bufferPointer = null;
		instancesBuffer.Map(0, null, &bufferPointer);
		Internal.MemCpy((void*)bufferPointer, (void*)raytracingInstanceDescriptions.Ptr, (uint32)(sizeof(D3D12_RAYTRACING_INSTANCE_DESC) * raytracingInstanceDescriptions.Count));
		instancesBuffer.Unmap(0, null);
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS inputs = D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS()
		{
			Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL,
			DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY,
			Flags = (D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS)description.Flags,
			NumDescs = (uint32)description.Instances.Count,
			InstanceDescs = instancesBuffer.GetGPUVirtualAddress() + description.Offset
		};
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO* info = device.GetRaytracingAccelerationStructurePrebuildInfo(&inputs, .. scope .());
		scratchBuffer = DX12RaytracingHelpers.CreateBuffer(device, (uint32)info.ScratchDataSizeInBytes, .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_UNORDERED_ACCESS, DX12RaytracingHelpers.kDefaultHeapProps);
		ResultBuffer = DX12RaytracingHelpers.CreateBuffer(device, (uint32)info.ResultDataMaxSizeInBytes, .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE, DX12RaytracingHelpers.kDefaultHeapProps);
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC  asDesc = D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC ()
		{
			Inputs = inputs,
			ScratchAccelerationStructureData = scratchBuffer.GetGPUVirtualAddress(),
			DestAccelerationStructureData = ResultBuffer.GetGPUVirtualAddress()
		};
		AccelerationStructureDescription = asDesc;
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12TopLevelAS" /> class.
	/// </summary>
	/// <param name="description">New top level description.</param>
	public void UpdateAccelerationStructure(ref TopLevelASDescription description)
	{
		//IL_00e2: Unknown result type (might be due to invalid IL or missing references)
		Description = description;
		D3D12_RAYTRACING_INSTANCE_DESC[] raytracingInstanceDescriptions = new D3D12_RAYTRACING_INSTANCE_DESC[description.Instances.Count];
		for (int32 i = 0; i < raytracingInstanceDescriptions.Count; i++)
		{
			AccelerationStructureInstance instance = description.Instances[i];
			SEDULOUS_D3D12_RAYTRACING_INSTANCE_DESC  raytracingInstanceDescription = default(SEDULOUS_D3D12_RAYTRACING_INSTANCE_DESC );
			raytracingInstanceDescription.InstanceID = instance.InstanceID;
			raytracingInstanceDescription.InstanceContributionToHitGroupIndex = instance.InstanceContributionToHitGroupIndex;
			raytracingInstanceDescription.Flags = (D3D12_RAYTRACING_INSTANCE_FLAGS)instance.Flags;
			raytracingInstanceDescription.InstanceMask = instance.InstanceMask;
			raytracingInstanceDescription.Transform = instance.Transform4x4.ToMatrix3x4();
			raytracingInstanceDescription.AccelerationStructure = ((DX12BottomLevelAS)instance.BottonLevel).ResultBuffer.GetGPUVirtualAddress();
			D3D12_RAYTRACING_INSTANCE_DESC  instanceDesc = raytracingInstanceDescription;
			raytracingInstanceDescriptions[i] = instanceDesc;
		}
		void* bufferPointer = null;
		instancesBuffer.Map(0, null, &bufferPointer);
		Internal.MemCpy((void*)bufferPointer, (void*)raytracingInstanceDescriptions.Ptr, (uint32)(sizeof(D3D12_RAYTRACING_INSTANCE_DESC) * raytracingInstanceDescriptions.Count));
		instancesBuffer.Unmap(0, null);
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS  inputs = D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS ()
		{
			Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL,
			DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY,
			Flags = (D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS)(description.Flags | (AccelerationStructureFlags)32),
			NumDescs = (uint32)description.Instances.Count,
			InstanceDescs = instancesBuffer.GetGPUVirtualAddress()
		};
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC  buildRaytracingAccelerationStructureDescription = default(D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC );
		buildRaytracingAccelerationStructureDescription.Inputs = inputs;
		buildRaytracingAccelerationStructureDescription.ScratchAccelerationStructureData = scratchBuffer.GetGPUVirtualAddress();
		buildRaytracingAccelerationStructureDescription.DestAccelerationStructureData = ResultBuffer.GetGPUVirtualAddress();
		buildRaytracingAccelerationStructureDescription.SourceAccelerationStructureData = ResultBuffer.GetGPUVirtualAddress();
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC  asDesc = buildRaytracingAccelerationStructureDescription;
		AccelerationStructureDescription = asDesc;
	}

	private D3D12_CPU_DESCRIPTOR_HANDLE GetAccelerationStructureView()
	{
		D3D12_CPU_DESCRIPTOR_HANDLE srv = default(D3D12_CPU_DESCRIPTOR_HANDLE);
		D3D12_SHADER_RESOURCE_VIEW_DESC  shaderResourceViewDescription = default(D3D12_SHADER_RESOURCE_VIEW_DESC );
		shaderResourceViewDescription.Shader4ComponentMapping = (uint32)DX12GraphicsContext.DefaultShader4ComponentMapping;
		shaderResourceViewDescription.ViewDimension = .D3D12_SRV_DIMENSION_RAYTRACING_ACCELERATION_STRUCTURE;
		shaderResourceViewDescription.RaytracingAccelerationStructure = .()
		{
			Location = ResultBuffer.GetGPUVirtualAddress()
		};
		D3D12_SHADER_RESOURCE_VIEW_DESC  description = shaderResourceViewDescription;
		DX12GraphicsContext obj = Context as DX12GraphicsContext;
		srv = obj.ShaderResourceViewAllocator.Allocate();
		obj.DXDevice.CreateShaderResourceView(null, &description, srv);
		return srv;
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
		if (disposed)
		{
			return;
		}
		if (disposing)
		{
			DX12GraphicsContext nativeContext = Context as DX12GraphicsContext;
			if (accerationStructureView.HasValue)
			{
				nativeContext.ShaderResourceViewAllocator.Free(accerationStructureView.Value);
			}
			ID3D12Resource* resultBuffer = ResultBuffer;
			if (resultBuffer != null)
			{
				resultBuffer.Release();
			}
		}
		disposed = true;
	}
}
