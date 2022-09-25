using Win32.Graphics.Direct3D12;
using System.Collections;
using NRI.D3DCommon;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

enum DescriptorHeapType : uint32
{
	RESOURCE = 0,
	SAMPLER,
	MAX_NUM
}

class DescriptorPoolD3D12 : DescriptorPool
{
	private DeviceD3D12 m_Device;
	private DescriptorHeapDesc[(.)DescriptorHeapType.MAX_NUM] m_DescriptorHeapDescs;
	private uint32[(.)DescriptorHeapType.MAX_NUM] m_DescriptorNum = .();
	private ID3D12DescriptorHeap*[(.)DescriptorHeapType.MAX_NUM] m_DescriptorHeaps = .();
	private uint32 m_DescriptorHeapNum = 0;
	private List<DescriptorSetD3D12> m_DescriptorSets;
	private uint32 m_DescriptorSetNum = 0;

	public this(DeviceD3D12 device)
	{
		m_Device = device;

		m_DescriptorSets = Allocate!<List<DescriptorSetD3D12>>(m_Device.GetAllocator());
	}
	public ~this()
	{
		for (int i = 0; i < m_DescriptorSetNum; i++)
			Deallocate!(m_Device.GetAllocator(), m_DescriptorSets[i]);

		Deallocate!(m_Device.GetAllocator(), m_DescriptorSets);

		for(var item in ref m_DescriptorHeapDescs){
			item.Dispose();
		}

		for(var item in ref m_DescriptorHeaps){
			if(item != null)
		   		//item.Release();
			item = null;
		}
	}

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(DescriptorPoolDesc descriptorPoolDesc)
	{
		uint32[(.)DescriptorHeapType.MAX_NUM] descriptorHeapSize = .();
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.constantBufferMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.textureMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.storageTextureMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.bufferMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.storageBufferMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.structuredBufferMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.storageStructuredBufferMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.RESOURCE] += descriptorPoolDesc.accelerationStructureMaxNum;
		descriptorHeapSize[(.)DescriptorHeapType.SAMPLER] += descriptorPoolDesc.samplerMaxNum;

		for (int i = 0; i < (.)DescriptorHeapType.MAX_NUM; i++)
		{
			if (descriptorHeapSize[i] > 0)
			{
				ComPtr<ID3D12DescriptorHeap> descriptorHeap = default;
				defer descriptorHeap.Dispose();
				D3D12_DESCRIPTOR_HEAP_DESC desc = .() { Type = (D3D12_DESCRIPTOR_HEAP_TYPE)i, NumDescriptors = descriptorHeapSize[i], Flags = .D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE, NodeMask = NRI_TEMP_NODE_MASK };
				HRESULT hr = ((ID3D12Device*)m_Device).CreateDescriptorHeap(&desc, ID3D12DescriptorHeap.IID, (void**)(&descriptorHeap));
				if (FAILED(hr))
				{
					REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateDescriptorHeap() failed, return code %d.", hr);
					return Result.FAILURE;
				}

				m_DescriptorHeapDescs[i].descriptorHeap = descriptorHeap;
				m_DescriptorHeapDescs[i].descriptorPointerCPU = descriptorHeap->GetCPUDescriptorHandleForHeapStart().ptr;
				m_DescriptorHeapDescs[i].descriptorPointerGPU = descriptorHeap->GetGPUDescriptorHandleForHeapStart().ptr;
				m_DescriptorHeapDescs[i].descriptorSize = ((ID3D12Device*)m_Device).GetDescriptorHandleIncrementSize((D3D12_DESCRIPTOR_HEAP_TYPE)i);

				m_DescriptorHeaps[m_DescriptorHeapNum] = descriptorHeap.Move();
				m_DescriptorHeapNum++;
			}
		}

		m_DescriptorSets.Resize(descriptorPoolDesc.descriptorSetMaxNum);

		return Result.SUCCESS;
	}

	public void Bind(ID3D12GraphicsCommandList* graphicsCommandList)
	{
		graphicsCommandList.SetDescriptorHeaps(m_DescriptorHeapNum, &m_DescriptorHeaps);
	}

	public uint32 AllocateDescriptors(DescriptorHeapType descriptorHeapType, uint32 descriptorNum)
	{
		uint32 descriptorOffset = m_DescriptorNum[(.)descriptorHeapType];
		m_DescriptorNum[(.)descriptorHeapType] += descriptorNum;

		return descriptorOffset;
	}

	public DescriptorPointerCPU GetDescriptorPointerCPU(DescriptorHeapType descriptorHeapType, uint32 offset)
	{
		readonly ref  DescriptorHeapDesc descriptorHeapDesc = ref m_DescriptorHeapDescs[(.)descriptorHeapType];
		DescriptorPointerCPU descriptorPointer = descriptorHeapDesc.descriptorPointerCPU + offset * descriptorHeapDesc.descriptorSize;

		return descriptorPointer;
	}

	public DescriptorPointerGPU GetDescriptorPointerGPU(DescriptorHeapType descriptorHeapType, uint32 offset)
	{
		readonly ref DescriptorHeapDesc descriptorHeapDesc = ref m_DescriptorHeapDescs[(.)descriptorHeapType];
		DescriptorPointerGPU descriptorPointer = descriptorHeapDesc.descriptorPointerGPU + offset * descriptorHeapDesc.descriptorSize;

		return descriptorPointer;
	}

	public void SetDebugName(char8* name)
	{
	}

	public Result AllocateDescriptorSets(PipelineLayout pipelineLayout, uint32 setIndex, DescriptorSet* descriptorSets, uint32 instanceNum, uint32 physicalDeviceMask, uint32 variableDescriptorNum)
	{
		//MaybeUnused(variableDescriptorNum);

		if (m_DescriptorSetNum + instanceNum > m_DescriptorSets.Count)
			return Result.FAILURE;

		readonly PipelineLayoutD3D12 pipelineLayoutD3D12 = (PipelineLayoutD3D12)pipelineLayout;
		readonly ref DescriptorSetMapping descriptorSetMapping = ref pipelineLayoutD3D12.GetDescriptorSetMapping(setIndex);
		readonly ref DynamicConstantBufferMapping dynamicConstantBufferMapping = ref pipelineLayoutD3D12.GetDynamicConstantBufferMapping(setIndex);

		for (uint32 i = 0; i < instanceNum; i++)
		{
			DescriptorSetD3D12 descriptorSet = Allocate!<DescriptorSetD3D12>(m_Device.GetAllocator(), m_Device, this, descriptorSetMapping, dynamicConstantBufferMapping.constantNum);
			m_DescriptorSets[m_DescriptorSetNum + i] = descriptorSet;
			descriptorSets[i] = (DescriptorSet)descriptorSet;
		}

		m_DescriptorSetNum += instanceNum;

		return Result.SUCCESS;
	}

	public void Reset()
	{
		for (uint32 i = 0; i < (.)DescriptorHeapType.MAX_NUM; i++)
			m_DescriptorNum[i] = 0;

		for (uint32 i = 0; i < m_DescriptorSetNum; i++)
			Deallocate!(m_Device.GetAllocator(), m_DescriptorSets[i]);

		m_DescriptorSets.Clear();

		m_DescriptorSetNum = 0;
	}
}