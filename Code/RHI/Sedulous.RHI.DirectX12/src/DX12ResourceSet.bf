using System;
using Sedulous.RHI;
using Win32.Graphics.Direct3D12;

namespace Sedulous.RHI.DirectX12;

using internal Sedulous.RHI.DirectX12;
using static Sedulous.RHI.DirectX12.DX12ExtensionsMethods;

/// <summary>
/// The DX12 implementation of the ResourceSet object.
/// </summary>
public class DX12ResourceSet : ResourceSet
{
	private static ShaderStages[?] stagesByIndex = .(
			ShaderStages.Vertex,
			ShaderStages.Hull,
			ShaderStages.Domain,
			ShaderStages.Geometry,
			ShaderStages.Pixel,
			ShaderStages.Compute,
			ShaderStages.RayGeneration,
			ShaderStages.Miss,
			ShaderStages.ClosestHit,
			ShaderStages.AnyHit,
			ShaderStages.Intersection
		);;

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
		}
	}

	/// <summary>
	/// Initializes a new instance of the <see cref="T:Sedulous.RHI.DirectX12.DX12ResourceSet" /> class.
	/// </summary>
	/// <param name="description">The resource set description.</param>
	public this(in ResourceSetDescription description)
		: base(description)
	{
	}

	internal void BindResourceSet(DX12CommandBuffer commandBuffer, uint32 index, uint32[] offsets)
	{
		ID3D12Device* dxDevice = commandBuffer.context.DXDevice;
		int32 dynamicOffsetCounter = 0;
		for (int32 i = 0; i < Description.Resources.Count; i++)
		{
			LayoutElementDescription element = Description.Layout.Description.Elements[i];
			GraphicsResource resource = Description.Resources[i];
			if (resource == null)
			{
				if (element.Type != ResourceType.Sampler)
				{
					continue;
				}
				resource = commandBuffer.context.DefaultSampler;
			}
			switch (element.Type)
			{
			case ResourceType.ConstantBuffer:
			{
				uint32 slot = element.Slot;
				DX12Buffer buffer = resource as DX12Buffer;
				D3D12_CONSTANT_BUFFER_VIEW_DESC cBVDescription = default(D3D12_CONSTANT_BUFFER_VIEW_DESC);
				uint32 bufferOffset = 0;
				bool overrideOffset = element.AllowDynamicOffset && offsets != null;
				if (overrideOffset)
				{
					bufferOffset = offsets[dynamicOffsetCounter];
					dynamicOffsetCounter++;
					D3D12_CONSTANT_BUFFER_VIEW_DESC constantBufferViewDescription = default(D3D12_CONSTANT_BUFFER_VIEW_DESC);
					constantBufferViewDescription.SizeInBytes = ((element.Range == 0) ? (buffer.alignedSize - bufferOffset) : Helpers.AlignUp(element.Range));
					constantBufferViewDescription.BufferLocation = buffer.NativeBuffer.GetGPUVirtualAddress() + bufferOffset;
					cBVDescription = constantBufferViewDescription;
					cBVDescription.SizeInBytes = Math.Min(cBVDescription.SizeInBytes, 65536);
				}
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						if (overrideOffset)
						{
							D3D12_CPU_DESCRIPTOR_HANDLE destDescriptor = commandBuffer.resourceDescriptorsGPU.UpdateDescriptorHandle(currentStage, slot);
							commandBuffer.context.DXDevice.CreateConstantBufferView(&cBVDescription, destDescriptor);
						}
						else
						{
							D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = buffer.ConstantBufferView;
							commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
						}
					}
				}
				break;
			}
			case ResourceType.StructuredBuffer:
			{
				uint32 slot = (uint32)(DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + element.Slot);
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (resource as DX12Buffer).ShaderResourceView;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				break;
			}
			case ResourceType.AccelerationStructure:
			{
				uint32 slot = (uint32)(DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + element.Slot);
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (resource as DX12TopLevelAS).AccelerationStructureView;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				break;
			}
			case ResourceType.StructuredBufferReadWrite:
			{
				uint32 slot = (uint32)(DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + DX12GraphicsContext.GPU_RESOURCE_HEAP_SRV_COUNT + element.Slot);
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (resource as DX12Buffer).UnorderedAccessView;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				break;
			}
			case ResourceType.Texture:
			{
				uint32 slot = (uint32)(DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + element.Slot);
				DX12Texture dx12Texture = resource as DX12Texture;
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = dx12Texture.ShaderResourceView;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				dx12Texture.ResourceTransition(commandBuffer.CommandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE, -1);
				break;
			}
			case ResourceType.TextureReadWrite:
			{
				uint32 slot = (uint32)(DX12GraphicsContext.GPU_RESOURCE_HEAP_CBV_COUNT + DX12GraphicsContext.GPU_RESOURCE_HEAP_SRV_COUNT + element.Slot);
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (resource as DX12Texture).UnorderedAccessView;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.resourceDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				(resource as DX12Texture).ResourceTransition(commandBuffer.CommandList, D3D12_RESOURCE_STATES.D3D12_RESOURCE_STATE_UNORDERED_ACCESS);
				break;
			}
			case ResourceType.Sampler:
			{
				uint32 slot = element.Slot;
				D3D12_CPU_DESCRIPTOR_HANDLE descriptorHandle = (resource as DX12SamplerState).NativeSampler;
				for (int32 s = 0; s < DX12DescriptorTableAllocator.ShaderStageCount; s++)
				{
					ShaderStages currentStage = stagesByIndex[s];
					if ((element.Stages & currentStage) != 0)
					{
						commandBuffer.samplerDescriptorsGPU.UpdateDescriptor(dxDevice, currentStage, descriptorHandle, slot);
					}
				}
				break;
			}
			default:
				commandBuffer.context.ValidationLayer?.Notify("DX12", "Invalid resource type.");
				break;
			}
		}
	}

	/// <inheritdoc />
	public override void Dispose()
	{
	}
}
