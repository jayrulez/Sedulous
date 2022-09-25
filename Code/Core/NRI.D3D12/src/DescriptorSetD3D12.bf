using System;
using System.Collections;
using Win32.Graphics.Direct3D12;
using NRI.Helpers;
namespace NRI.D3D12;

struct DescriptorRangeMapping
{
	public DescriptorHeapType descriptorHeapType;
	public uint32 heapOffset;
	public uint32 descriptorNum;
}

struct DescriptorSetMapping : IDisposable
{
	private DeviceAllocator<uint8> m_Allocator;

	public this(DeviceAllocator<uint8> allocator)
	{
		m_Allocator = allocator;
		descriptorRangeMappings = .();
		//descriptorRangeMappings = Allocate!<List<DescriptorRangeMapping>>(m_Allocator);
	}

	public uint32[(.)DescriptorHeapType.MAX_NUM] descriptorNum = .();
	//public List<DescriptorRangeMapping> descriptorRangeMappings;
	public StaticList<DescriptorRangeMapping, 128> descriptorRangeMappings;

	public void Dispose()
	{
		//descriptorRangeMappings.Clear();
		//Deallocate!(m_Allocator, descriptorRangeMappings);
	}
}

class DescriptorSetD3D12 : DescriptorSet
{
	private DeviceD3D12 m_Device;
	private DescriptorPoolD3D12 m_DescriptorPoolD3D12;
	private DescriptorSetMapping m_DescriptorSetMapping;
	private List<DescriptorPointerGPU> m_DynamicConstantBuffers;


	public this(DeviceD3D12 device, DescriptorPoolD3D12 desriptorPoolD3D12, DescriptorSetMapping descriptorSetMapping, uint16 dynamicConstantBufferNum)
	{
		m_Device = device;
		m_DescriptorPoolD3D12 = desriptorPoolD3D12;
		m_DescriptorSetMapping = descriptorSetMapping;

		m_DynamicConstantBuffers = Allocate!<List<DescriptorPointerGPU>>(m_Device.GetAllocator());

		uint32[(.)DescriptorHeapType.MAX_NUM] heapOffset = .();

		for (uint32 i = 0; i < (.)DescriptorHeapType.MAX_NUM; i++)
		{
			if (m_DescriptorSetMapping.descriptorNum[i] > 0)
				heapOffset[i] = m_DescriptorPoolD3D12.AllocateDescriptors((DescriptorHeapType)i, m_DescriptorSetMapping.descriptorNum[i]);
		}

		for (uint32 i = 0; i < (uint32)m_DescriptorSetMapping.descriptorRangeMappings.Count; i++)
		{
			DescriptorHeapType descriptorHeapType = m_DescriptorSetMapping.descriptorRangeMappings[i].descriptorHeapType;
			m_DescriptorSetMapping.descriptorRangeMappings[i].heapOffset += heapOffset[(.)descriptorHeapType];
		}

		m_DynamicConstantBuffers.Resize(dynamicConstantBufferNum, 0);
	}
	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_DynamicConstantBuffers);
	}

	public DeviceD3D12 GetDevice() => m_Device;

	public static void BuildDescriptorSetMapping(DescriptorSetDesc descriptorSetDesc, ref DescriptorSetMapping descriptorSetMapping)
	{
		descriptorSetMapping.descriptorRangeMappings.Resize(descriptorSetDesc.rangeNum);
		for (uint32 i = 0; i < descriptorSetDesc.rangeNum; i++)
		{
			D3D12_DESCRIPTOR_HEAP_TYPE descriptorHeapType = GetDescriptorHeapType(descriptorSetDesc.ranges[i].descriptorType);
			descriptorSetMapping.descriptorRangeMappings[i].descriptorHeapType = (DescriptorHeapType)descriptorHeapType;
			descriptorSetMapping.descriptorRangeMappings[i].heapOffset = descriptorSetMapping.descriptorNum[(.)descriptorHeapType];
			descriptorSetMapping.descriptorRangeMappings[i].descriptorNum = descriptorSetDesc.ranges[i].descriptorNum;

			descriptorSetMapping.descriptorNum[(.)descriptorHeapType] += descriptorSetDesc.ranges[i].descriptorNum;
		}
	}

	public DescriptorPointerCPU GetPointerCPU(uint32 rangeIndex, uint32 rangeOffset)
	{
		readonly ref DescriptorHeapType descriptorHeapType = ref m_DescriptorSetMapping.descriptorRangeMappings[rangeIndex].descriptorHeapType;
		uint32 offset = m_DescriptorSetMapping.descriptorRangeMappings[rangeIndex].heapOffset + rangeOffset;
		DescriptorPointerCPU descriptorPointerCPU = m_DescriptorPoolD3D12.GetDescriptorPointerCPU(descriptorHeapType, offset);

		return descriptorPointerCPU;
	}

	public DescriptorPointerGPU GetPointerGPU(uint32 rangeIndex, uint32 rangeOffset)
	{
		readonly ref DescriptorHeapType descriptorHeapType = ref m_DescriptorSetMapping.descriptorRangeMappings[rangeIndex].descriptorHeapType;
		uint32 offset = m_DescriptorSetMapping.descriptorRangeMappings[rangeIndex].heapOffset + rangeOffset;
		DescriptorPointerGPU descriptorPointerGPU = m_DescriptorPoolD3D12.GetDescriptorPointerGPU(descriptorHeapType, offset);

		return descriptorPointerGPU;
	}
	public DescriptorPointerGPU GetDynamicPointerGPU(uint32 dynamicConstantBufferIndex)
	{
		return m_DynamicConstantBuffers[dynamicConstantBufferIndex];
	}

	public void SetDebugName(char8* name)
	{
	}

	public void UpdateDescriptorRanges(uint32 physicalDeviceMask, uint32 rangeOffset, uint32 rangeNum, DescriptorRangeUpdateDesc* rangeUpdateDescs)
	{
		for (uint32 i = 0; i < rangeNum; i++)
		{
			readonly ref DescriptorRangeMapping rangeMapping = ref m_DescriptorSetMapping.descriptorRangeMappings[rangeOffset + i];
			readonly uint32 baseOffset = rangeMapping.heapOffset + rangeUpdateDescs[i].offsetInRange;
			for (uint32 j = 0; j < rangeUpdateDescs[i].descriptorNum; j++)
			{
				DescriptorPointerCPU dstPointer = m_DescriptorPoolD3D12.GetDescriptorPointerCPU(rangeMapping.descriptorHeapType, baseOffset + j);
				DescriptorPointerCPU srcPointer = ((DescriptorD3D12)rangeUpdateDescs[i].descriptors[j]).GetPointerCPU();
				D3D12_DESCRIPTOR_HEAP_TYPE descriptorHeapType = (D3D12_DESCRIPTOR_HEAP_TYPE)rangeMapping.descriptorHeapType;

				((ID3D12Device*)m_Device).CopyDescriptorsSimple(1, .() { ptr = dstPointer }, .() { ptr = srcPointer }, descriptorHeapType);
			}
		}
	}

	public void UpdateDynamicConstantBuffers(uint32 physicalDeviceMask, uint32 baseBuffer, uint32 bufferNum, Descriptor* descriptors)
	{
		for (uint32 i = 0; i < bufferNum; i++)
			m_DynamicConstantBuffers[baseBuffer + i] = ((DescriptorD3D12)descriptors[i]).GetBufferLocation();
	}

	public void Copy(DescriptorSetCopyDesc descriptorSetCopyDesc)
	{
		readonly DescriptorSetD3D12 srcDescriptorSet = (DescriptorSetD3D12)descriptorSetCopyDesc.srcDescriptorSet;

		for (uint32 i = 0; i < descriptorSetCopyDesc.rangeNum; i++)
		{
			DescriptorPointerCPU dstPointer = GetPointerCPU(descriptorSetCopyDesc.baseDstRange + i, 0);
			DescriptorPointerCPU srcPointer = srcDescriptorSet.GetPointerCPU(descriptorSetCopyDesc.baseSrcRange + i, 0);

			uint32 descriptorNum = m_DescriptorSetMapping.descriptorRangeMappings[i].descriptorNum;
			D3D12_DESCRIPTOR_HEAP_TYPE descriptorHeapType = (D3D12_DESCRIPTOR_HEAP_TYPE)m_DescriptorSetMapping.descriptorRangeMappings[i].descriptorHeapType;

			((ID3D12Device*)m_Device).CopyDescriptorsSimple(descriptorNum, .() { ptr = dstPointer }, .() { ptr = srcPointer }, descriptorHeapType);
		}

		for (uint32 i = 0; i < descriptorSetCopyDesc.dynamicConstantBufferNum; i++)
		{
			DescriptorPointerGPU descriptorPointerGPU = srcDescriptorSet.GetDynamicPointerGPU(descriptorSetCopyDesc.baseSrcDynamicConstantBuffer + i);
			m_DynamicConstantBuffers[descriptorSetCopyDesc.baseDstDynamicConstantBuffer + i] = descriptorPointerGPU;
		}
	}
}