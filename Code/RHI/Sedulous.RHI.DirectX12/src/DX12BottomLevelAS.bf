using System;
using Sedulous.RHI.Raytracing;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// DX12 Bottom Level Acceleration Structure implementation.
/// </summary>
public class DX12BottomLevelAS : BottomLevelAS
{
	internal D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC AccelerationStructureDescription;

	private ID3D12Resource* scratchBuffer;

	/// <summary>
	/// DX12 Acceleration Structure Result buffer.
	/// </summary>
	public ID3D12Resource* ResultBuffer;

	/// <inheritdoc />
	public override void* NativePointer => ResultBuffer;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12BottomLevelAS" /> class.
	/// </summary>
	/// <param name="context">Graphics Context.</param>
	/// <param name="description">Bottom Level Description.</param>
	public this(DX12GraphicsContext context, in BottomLevelASDescription description)
		: base(context, description)
	{
		D3D12_RAYTRACING_GEOMETRY_DESC[] raytracingGeometryDescriptions = scope D3D12_RAYTRACING_GEOMETRY_DESC[description.Geometries.Count];
		for (int32 i = 0; i < raytracingGeometryDescriptions.Count; i++)
		{
			AccelerationStructureGeometry geometry = description.Geometries[i];
			D3D12_RAYTRACING_GEOMETRY_DESC  geometryDesc = default(D3D12_RAYTRACING_GEOMETRY_DESC );
			AccelerationStructureTriangles trianglesGeometry = geometry as AccelerationStructureTriangles;
			if (trianglesGeometry != null)
			{
				geometryDesc = D3D12_RAYTRACING_GEOMETRY_DESC()
				{
					Type = .D3D12_RAYTRACING_GEOMETRY_TYPE_TRIANGLES,
					Flags = (D3D12_RAYTRACING_GEOMETRY_FLAGS)trianglesGeometry.Flags,
					Triangles = .()
					{
						VertexBuffer = .()
						{
							StartAddress = ((DX12Buffer)trianglesGeometry.VertexBuffer).NativeBuffer.GetGPUVirtualAddress() + trianglesGeometry.VertexOffset,
							StrideInBytes = trianglesGeometry.VertexStride
						},
						VertexFormat = trianglesGeometry.VertexFormat.ToDirectX(),
						VertexCount = (uint32)trianglesGeometry.VertexCount,
						IndexBuffer = ((trianglesGeometry.IndexBuffer != null) ? (((DX12Buffer)trianglesGeometry.IndexBuffer).NativeBuffer.GetGPUVirtualAddress() + trianglesGeometry.IndexOffset) : 0),
						IndexFormat = ((trianglesGeometry.IndexBuffer != null) ? trianglesGeometry.IndexFormat.ToDirectX() : .DXGI_FORMAT_UNKNOWN),
						IndexCount = (uint32)trianglesGeometry.IndexCount
					}
				};
			}
			else
			{
				AccelerationStructureAABBs aabbsGeometry = geometry as AccelerationStructureAABBs;
				if (aabbsGeometry != null)
				{
					geometryDesc = D3D12_RAYTRACING_GEOMETRY_DESC()
					{
						Type = .D3D12_RAYTRACING_GEOMETRY_TYPE_PROCEDURAL_PRIMITIVE_AABBS,
						Flags = (D3D12_RAYTRACING_GEOMETRY_FLAGS)aabbsGeometry.Flags,
						AABBs = .()
						{
							AABBCount = aabbsGeometry.Count,
							AABBs = .()
							{
								StartAddress = ((DX12Buffer)aabbsGeometry.AABBs).NativeBuffer.GetGPUVirtualAddress() + aabbsGeometry.Offset,
								StrideInBytes = aabbsGeometry.Stride
							}
						}
					};
				}
				else
				{
					context.ValidationLayer.Notify("DX12", "Acceleration Structure geometry type not supported!");
				}
			}
			raytracingGeometryDescriptions[i] = geometryDesc;
		}
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS inputs = .()
		{
			Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL,
			DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY,
			Flags = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_NONE,
			NumDescs = (uint32)raytracingGeometryDescriptions.Count,
			pGeometryDescs = raytracingGeometryDescriptions.Ptr
		};
		ID3D12Device5* device = (ID3D12Device5*)context.DXDevice;
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO* info = device.GetRaytracingAccelerationStructurePrebuildInfo(&inputs, .. scope .());
		scratchBuffer = DX12RaytracingHelpers.CreateBuffer(device, (uint32)info.ScratchDataSizeInBytes, .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, .D3D12_RESOURCE_STATE_UNORDERED_ACCESS, DX12RaytracingHelpers.kDefaultHeapProps);
		ResultBuffer = DX12RaytracingHelpers.CreateBuffer(device, (uint32)info.ResultDataMaxSizeInBytes, .D3D12_RESOURCE_FLAG_ALLOW_UNORDERED_ACCESS, .D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE, DX12RaytracingHelpers.kDefaultHeapProps);
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC  asDesc = .()
		{
			Inputs = inputs,
			ScratchAccelerationStructureData = scratchBuffer.GetGPUVirtualAddress(),
			DestAccelerationStructureData = ResultBuffer.GetGPUVirtualAddress()
		};
		AccelerationStructureDescription = asDesc;
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
				ResultBuffer?.Release();
			}
			disposed = true;
		}
	}
}
