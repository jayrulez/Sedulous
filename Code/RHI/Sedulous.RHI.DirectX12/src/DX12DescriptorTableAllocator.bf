using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;
using Win32.Foundation;
using Win32;

namespace Sedulous.RHI.DirectX12;
using internal Sedulous.RHI.DirectX12;

internal class DX12DescriptorTableAllocator : IDisposable
{
	public static readonly int ShaderStageCount = ShaderStagesHelpers.ShaderStagesCount;

	public ID3D12DescriptorHeap* GPUheap;

	public ID3D12DescriptorHeap* CPUheap;

	public D3D12_CPU_DESCRIPTOR_HANDLE HeapStart;

	public D3D12_DESCRIPTOR_HEAP_TYPE DescriptorType;

	private D3D12_CPU_DESCRIPTOR_HANDLE[] boundDescriptors;

	private uint32 itemCount;

	private uint32 descriptorSize;

	private bool[] dirty;

	private uint32 ringOffset;

	public this(DX12GraphicsContext context, D3D12_DESCRIPTOR_HEAP_TYPE heapType, uint32 maxRenameCount = 1)
	{
		DescriptorType = heapType;
		if (heapType == D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER)
		{
			itemCount = DX12GraphicsContext.GPU_SAMPLER_HEAP_COUNT;
		}
		else
		{
			itemCount = DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + DX12GraphicsContext.GPU_RESOURCE_HEAP_SRV_COUNT + DX12GraphicsContext.GPU_RESOURCE_HEAP_UAV_COUNT;
		}
		D3D12_DESCRIPTOR_HEAP_DESC cpuHeapDescription = D3D12_DESCRIPTOR_HEAP_DESC()
		{
			Flags = D3D12_DESCRIPTOR_HEAP_FLAGS.D3D12_DESCRIPTOR_HEAP_FLAG_NONE,
			Type = heapType,
			NodeMask = 0,
			NumDescriptors = uint32(itemCount * ShaderStageCount)
		};
		HRESULT result = context.DXDevice.CreateDescriptorHeap(&cpuHeapDescription, ID3D12DescriptorHeap.IID, (void**)&CPUheap);
		if (!SUCCEEDED(result))
		{
			context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		D3D12_DESCRIPTOR_HEAP_DESC gpuHeapDescription = D3D12_DESCRIPTOR_HEAP_DESC()
		{
			Flags = .D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE,
			Type = heapType,
			NodeMask = 0,
			NumDescriptors = uint32(itemCount * ShaderStageCount * (uint32)maxRenameCount)
		};
		result = context.DXDevice.CreateDescriptorHeap(&gpuHeapDescription, ID3D12DescriptorHeap.IID, (void**)&GPUheap);
		if (!SUCCEEDED(result))
		{
			context.ValidationLayer?.Notify("DX12", scope $"Error code: {result}, see: https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues");
		}
		descriptorSize = (uint32)context.DXDevice.GetDescriptorHandleIncrementSize(heapType);
		HeapStart = CPUheap.GetCPUDescriptorHandleForHeapStart();
		dirty = new bool[ShaderStageCount];
		ringOffset = 0;
		boundDescriptors = new .[itemCount * ShaderStageCount];
	}

	public void UpdateDescriptor(ID3D12Device* device, ShaderStages stage, D3D12_CPU_DESCRIPTOR_HANDLE descriptor, uint32 slot)
	{
		int stageIndex = ShaderStagesHelpers.IndexOf(stage);
		uint32 index = (uint32)(stageIndex * itemCount) + slot;
		if ((uint64)boundDescriptors[index].ptr != descriptor.ptr)
		{
			boundDescriptors[index] = descriptor;
			dirty[stageIndex] = true;
			D3D12_CPU_DESCRIPTOR_HANDLE dst_staging = CPUheap.GetCPUDescriptorHandleForHeapStart();
			dst_staging.ptr += index * descriptorSize;
			device.CopyDescriptorsSimple(1, dst_staging, descriptor, DescriptorType);
		}
	}

	public D3D12_CPU_DESCRIPTOR_HANDLE UpdateDescriptorHandle(ShaderStages stage, uint32 offset)
	{
		int stageIndex = ShaderStagesHelpers.IndexOf(stage);
		uint32 index = (uint32)(stageIndex * itemCount) + offset;
		D3D12_CPU_DESCRIPTOR_HANDLE dst_staging = CPUheap.GetCPUDescriptorHandleForHeapStart();
		dst_staging.ptr += index * descriptorSize;
		boundDescriptors[index] = dst_staging;
		dirty[stageIndex] = true;
		return dst_staging;
	}

	public D3D12_GPU_DESCRIPTOR_HANDLE StartStageHandle(ShaderStages stage)
	{
		uint32 index = (uint32)(ShaderStagesHelpers.IndexOf(stage) * itemCount);
		D3D12_GPU_DESCRIPTOR_HANDLE handle = GPUheap.GetGPUDescriptorHandleForHeapStart();
		handle.ptr += index * descriptorSize;
		return handle;
	}

	public void Submit(ID3D12Device* device, ID3D12GraphicsCommandList* commandList)
	{
		for (int32 stageIndex = 0; stageIndex < ShaderStageCount; stageIndex++)
		{
			if (!dirty[stageIndex])
			{
				continue;
			}
			D3D12_CPU_DESCRIPTOR_HANDLE dst = GPUheap.GetCPUDescriptorHandleForHeapStart();
			dst.ptr += ringOffset;
			D3D12_CPU_DESCRIPTOR_HANDLE src = CPUheap.GetCPUDescriptorHandleForHeapStart();
			int64 offset = stageIndex * itemCount * descriptorSize;
			src.ptr += (uint32)offset;
			device.CopyDescriptorsSimple(itemCount, dst, src, DescriptorType);
			D3D12_GPU_DESCRIPTOR_HANDLE descriptorTable = GPUheap.GetGPUDescriptorHandleForHeapStart();
			descriptorTable.ptr += ringOffset;
			if (stageIndex >= ShaderStagesHelpers.IndexOf(ShaderStages.Compute))
			{
				if (DescriptorType == D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV)
				{
					commandList.SetComputeRootDescriptorTable(0, descriptorTable);
				}
				else
				{
					commandList.SetComputeRootDescriptorTable(1, descriptorTable);
				}
			}
			else if (DescriptorType == D3D12_DESCRIPTOR_HEAP_TYPE.D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV)
			{
				commandList.SetGraphicsRootDescriptorTable(uint32(stageIndex * 2), descriptorTable);
			}
			else
			{
				commandList.SetGraphicsRootDescriptorTable(uint32(stageIndex * 2 + 1), descriptorTable);
			}
			dirty[stageIndex] = false;
			ringOffset += (uint32)(itemCount * descriptorSize);
		}
	}

	public void Reset(ID3D12Device* device, D3D12_CPU_DESCRIPTOR_HANDLE[] nullDescriptors)
	{
		Array.Clear(boundDescriptors, 0, boundDescriptors.Count);
		ringOffset = 0;
	}

	/// <inheritdoc />
	public void Dispose()
	{
		CPUheap?.Release();
		GPUheap?.Release();
	}
}
