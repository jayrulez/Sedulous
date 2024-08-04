using System;
using Win32.Graphics.Direct3D12;
using System.Collections;

namespace Sedulous.RHI.DirectX12;

/// <summary>
/// DX12 Shader binding table (buffer).
/// </summary>
public class DX12ShaderTable
{
	/// <summary>
	/// Shader Table Entry.
	/// </summary>
	public struct ShaderTableRecord
	{
		/// <summary>
		/// Pipeline shader identifier.
		/// </summary>
		public String Name;

		/// <summary>
		/// Descriptor heap handlers.
		/// </summary>
		public D3D12_GPU_DESCRIPTOR_HANDLE[] Handlers;

		/// <summary>
		/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ShaderTable.ShaderTableRecord" /> struct.
		/// </summary>
		/// <param name="name">Pipeline shader identifier.</param>
		/// <param name="handlers">Descriptor heap handlers.</param>
		public this(String name, D3D12_GPU_DESCRIPTOR_HANDLE[] handlers)
		{
			Name = name;
			Handlers = handlers;
		}
	}

	private const uint32 D3D12ShaderIdentifierSizeInBytes = 32;

	private const uint32 D3D12RaytracingShaderRecordByteAlignment = 32;

	/// <summary>
	/// Shader binding table buffer.
	/// </summary>
	public ID3D12Resource* Buffer;

	private DX12GraphicsContext context;

	private List<ShaderTableRecord> entries;

	private uint32 shaderTableEntrySize;

	private uint32 raygenCount;

	private uint32 missCount;

	private uint32 hitgroupCount;

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ShaderTable" /> class.
	/// </summary>
	/// <param name="graphicsContext">DX12 Graphics Context.</param>
	public this(DX12GraphicsContext graphicsContext)
	{
		context = graphicsContext;
		entries = new List<ShaderTableRecord>();
	}

	/// <summary>
	/// Add Raygen Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	/// <param name="handlers">GPU Descriptor Handles.</param>
	public void AddRayGenProgram(String shaderIdentifier, D3D12_GPU_DESCRIPTOR_HANDLE[] handlers)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, handlers));
		raygenCount++;
	}

	/// <summary>
	/// Add Miss Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	/// <param name="handlers">GPU Descriptor Handles.</param>
	public void AddMissProgram(String shaderIdentifier, D3D12_GPU_DESCRIPTOR_HANDLE[] handlers)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, handlers));
		missCount++;
	}

	/// <summary>
	/// Add HitGroup Program.
	/// </summary>
	/// <param name="shaderIdentifier">Shader identifier.</param>
	/// <param name="handlers">GPU Descriptor Handles.</param>
	public void AddHitGroupProgram(String shaderIdentifier, D3D12_GPU_DESCRIPTOR_HANDLE[] handlers)
	{
		entries.Add(ShaderTableRecord(shaderIdentifier, handlers));
		hitgroupCount++;
	}

	/// <summary>
	/// Generate ShaderTable (filling buffer).
	/// </summary>
	/// <param name="pipeline">Raytracing pipeline.</param>
	public void Generate(ID3D12StateObject* pipeline)
	{
		shaderTableEntrySize = 32;
		shaderTableEntrySize += 8;
		shaderTableEntrySize = AlignTo(32, shaderTableEntrySize);
		uint32 shaderTableSize = shaderTableEntrySize * (uint32)entries.Count;
		ID3D12Device5* device = (ID3D12Device5*)context.DXDevice;
		Buffer = DX12RaytracingHelpers.CreateBuffer(device, shaderTableSize, D3D12_RESOURCE_FLAGS.D3D12_RESOURCE_FLAG_NONE, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_GENERIC_READ, DX12RaytracingHelpers.kUploadHeapProps);
		ID3D12StateObjectProperties* pipelineProperties = pipeline.QueryInterface<ID3D12StateObjectProperties>();
		void* pData = null;
		Buffer.Map(0, null, &pData);
		for (ShaderTableRecord entry in entries)
		{
			Internal.MemCpy((void*)pData, (void*)pipelineProperties.GetShaderIdentifier(entry.Name.ToScopedNativeWChar!()), 32);
			if (entry.Handlers != null)
			{
				Internal.MemCpy((void*)(((int)pData) + 32), (void*)(int)entry.Handlers[0].ptr, sizeof(decltype(entry.Handlers[0].ptr)));
			}
			pData = (void*)(((int)pData) + shaderTableEntrySize);
		}
		Buffer.Unmap(0, null);
	}

	private uint32 AlignTo(uint32 alignment, uint32 val)
	{
		return (val + alignment - 1) / alignment * alignment;
	}

	/// <summary>
	/// Get Ray generation start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetRayGenStartAddress()
	{
		uint64 gPUVirtualAddress = Buffer.GetGPUVirtualAddress();
		uint32 shaderTableEntrySize2 = shaderTableEntrySize;
		return gPUVirtualAddress + 0;
	}

	/// <summary>
	/// Gets Ray generation stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetRayGenStride()
	{
		return shaderTableEntrySize;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetRayGenSize()
	{
		return shaderTableEntrySize * raygenCount;
	}

	/// <summary>
	/// Get Miss start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetMissStartAddress()
	{
		return Buffer.GetGPUVirtualAddress() + shaderTableEntrySize * raygenCount;
	}

	/// <summary>
	/// Gets Miss stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetMissStride()
	{
		return shaderTableEntrySize;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetMissSize()
	{
		return shaderTableEntrySize * missCount;
	}

	/// <summary>
	/// Get HitGroup start address.
	/// </summary>
	/// <returns>buffer adress.</returns>
	public uint64 GetHitGroupStartAddress()
	{
		return Buffer.GetGPUVirtualAddress() + shaderTableEntrySize * (raygenCount + missCount);
	}

	/// <summary>
	/// Gets Miss stride.
	/// </summary>
	/// <returns>Entry stride.</returns>
	public uint64 GetHitGroupStride()
	{
		return shaderTableEntrySize;
	}

	/// <summary>
	/// Gets Ray generation entry size.
	/// </summary>
	/// <returns>Entry size.</returns>
	public uint64 GetHitGroupSize()
	{
		return shaderTableEntrySize * hitgroupCount;
	}
}
