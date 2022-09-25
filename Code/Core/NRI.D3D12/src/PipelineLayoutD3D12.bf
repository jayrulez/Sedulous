using System;
using System.Collections;
using Win32.Graphics.Direct3D12;
using NRI.D3DCommon;
using Win32.Graphics.Direct3D;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

public static
{
	public const uint16 ROOT_PARAMETER_UNUSED = uint16(-1);
}

struct DescriptorSetRootMapping : IDisposable
{
	private DeviceAllocator<uint8> m_Allocator;

	public this(DeviceAllocator<uint8> allocator)
	{
		m_Allocator = allocator;

		rootOffsets = Allocate!<List<uint16>>(m_Allocator);
	}

	public List<uint16> rootOffsets;

	public void Dispose()
	{
		Deallocate!(m_Allocator, rootOffsets);
	}
}

struct DynamicConstantBufferMapping
{
	public uint16 constantNum;
	public uint16 rootOffset;
}

class PipelineLayoutD3D12 : PipelineLayout
{
	private void SetDescriptorSetsImpl<isGraphics>(ref ID3D12GraphicsCommandList graphicsCommandList, uint32 baseIndex,
		uint32 setNum, DescriptorSet* descriptorSets, uint32* offsets) where isGraphics : const bool
	{
		uint32 dynamicConstantBufferNum = 0;

		for (uint32 i = 0; i < setNum; i++)
		{
			readonly DescriptorSetD3D12 descriptorSet = (DescriptorSetD3D12)descriptorSets[i];

			uint32 setIndex = baseIndex + i;
			readonly var rootOffsets = ref m_DescriptorSetRootMappings[setIndex].rootOffsets;

			uint32 descriptorRangeNum = (uint32)rootOffsets.Count;
			for (uint32 j = 0; j < descriptorRangeNum; j++)
			{
				uint16 rootParameterIndex = rootOffsets[j];
				if (rootParameterIndex == ROOT_PARAMETER_UNUSED)
					continue;

				DescriptorPointerGPU descriptorPointerGPU = descriptorSet.GetPointerGPU(j, 0);

				if (isGraphics)
					graphicsCommandList.SetGraphicsRootDescriptorTable(rootParameterIndex, .() { ptr = descriptorPointerGPU });
				else
					graphicsCommandList.SetComputeRootDescriptorTable(rootParameterIndex, .() { ptr = descriptorPointerGPU });
			}

			readonly var dynamicConstantBufferMapping = ref m_DynamicConstantBufferMappings[setIndex];

			for (uint16 j = 0; j < dynamicConstantBufferMapping.constantNum; j++)
			{
				uint16 rootParameterIndex = dynamicConstantBufferMapping.rootOffset + j;
				DescriptorPointerGPU descriptorPointerGPU = descriptorSet.GetDynamicPointerGPU(j) + offsets[dynamicConstantBufferNum];

				if (isGraphics)
					graphicsCommandList.SetGraphicsRootConstantBufferView(rootParameterIndex, descriptorPointerGPU);
				else
					graphicsCommandList.SetComputeRootConstantBufferView(rootParameterIndex, descriptorPointerGPU);

				dynamicConstantBufferNum++;
			}
		}
	}

	private ComPtr<ID3D12RootSignature> m_RootSignature;
	private bool m_IsGraphicsPipelineLayout = false;
	private uint32 m_PushConstantsBaseIndex = 0;
	private List<DescriptorSetMapping> m_DescriptorSetMappings;
	private List<DescriptorSetRootMapping> m_DescriptorSetRootMappings;
	private List<DynamicConstantBufferMapping> m_DynamicConstantBufferMappings;
	private DeviceD3D12 m_Device;


	public this(DeviceD3D12 device)
	{
		m_Device = device;

		m_DescriptorSetMappings = Allocate!<List<DescriptorSetMapping>>(m_Device.GetAllocator());
		m_DescriptorSetRootMappings = Allocate!<List<DescriptorSetRootMapping>>(m_Device.GetAllocator());
		m_DynamicConstantBufferMappings = Allocate!<List<DynamicConstantBufferMapping>>(m_Device.GetAllocator());
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_DynamicConstantBufferMappings);

		for(var item in ref m_DescriptorSetRootMappings){
			item.Dispose();
		}
		Deallocate!(m_Device.GetAllocator(), m_DescriptorSetRootMappings);

		for(var item in ref m_DescriptorSetMappings){
			item.Dispose();
		}
		Deallocate!(m_Device.GetAllocator(), m_DescriptorSetMappings);

		m_RootSignature.Dispose();
	}

	public static implicit operator ID3D12RootSignature*(Self self) => self.m_RootSignature.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;
	public bool IsGraphicsPipelineLayout() => m_IsGraphicsPipelineLayout;

	public readonly ref DescriptorSetMapping GetDescriptorSetMapping(uint32 setIndex) => ref m_DescriptorSetMappings[setIndex];
	public readonly ref DescriptorSetRootMapping GetDescriptorSetRootMapping(uint32 setIndex) => ref m_DescriptorSetRootMappings[setIndex];
	public readonly ref DynamicConstantBufferMapping GetDynamicConstantBufferMapping(uint32 setIndex) => ref m_DynamicConstantBufferMappings[setIndex];
	public uint32 GetPushConstantsRootOffset(uint32 rangeIndex) => m_PushConstantsBaseIndex + rangeIndex;

	public void SetDescriptorSets(ref ID3D12GraphicsCommandList graphicsCommandList, bool isGraphics, uint32 baseIndex,
		uint32 setNum, DescriptorSet* descriptorSets, uint32* offsets)
	{
		{
			if (isGraphics)
				SetDescriptorSetsImpl<true>(ref graphicsCommandList, baseIndex, setNum, descriptorSets, offsets);
			else
				SetDescriptorSetsImpl<false>(ref graphicsCommandList, baseIndex, setNum, descriptorSets, offsets);
		}
	}

	private D3D12_ROOT_SIGNATURE_FLAGS GetRootSignatureStageFlags(PipelineLayoutDesc pipelineLayoutDesc, DeviceD3D12 device)
	{
		D3D12_ROOT_SIGNATURE_FLAGS flags = .D3D12_ROOT_SIGNATURE_FLAG_NONE;

		if (pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.VERTEX))
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT;
		else
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_VERTEX_SHADER_ROOT_ACCESS;

		if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.TESS_CONTROL)))
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_HULL_SHADER_ROOT_ACCESS;
		if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.TESS_EVALUATION)))
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_DOMAIN_SHADER_ROOT_ACCESS;
		if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.GEOMETRY)))
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_GEOMETRY_SHADER_ROOT_ACCESS;
		if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.FRAGMENT)))
			flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_PIXEL_SHADER_ROOT_ACCESS;

		// Windows versions prior to 20H1 (which introduced DirectX Ultimate) can
		// produce errors when the following flags are added. To avoid this, we
		// only add these mesh shading pipeline flags when the device
		// (and thus Windows) supports mesh shading.
		if (device.IsMeshShaderSupported())
		{
			if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.MESH_CONTROL)))
				flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_AMPLIFICATION_SHADER_ROOT_ACCESS;
			if (!(pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.MESH_EVALUATION)))
				flags |= .D3D12_ROOT_SIGNATURE_FLAG_DENY_MESH_SHADER_ROOT_ACCESS;
		}

		return flags;
	}

	public Result Create(PipelineLayoutDesc pipelineLayoutDesc)
	{
		m_IsGraphicsPipelineLayout = pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.ALL_GRAPHICS);

		uint32 rangeMax = 0;
		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
			rangeMax += pipelineLayoutDesc.descriptorSets[i].rangeNum;

		DeviceAllocator<uint8> allocator = m_Device.GetAllocator();

		uint32 totalRangeNum = 0;
		List<D3D12_ROOT_PARAMETER1> rootParameters = Allocate!<List<D3D12_ROOT_PARAMETER1>>(allocator);
		defer { Deallocate!(allocator, rootParameters); }

		List<D3D12_DESCRIPTOR_RANGE1> descriptorRanges = Allocate!<List<D3D12_DESCRIPTOR_RANGE1>>(allocator);
		defer { Deallocate!(allocator, descriptorRanges); }
		descriptorRanges.Resize(rangeMax);

		List<D3D12_STATIC_SAMPLER_DESC> staticSamplerDescs = Allocate!<List<D3D12_STATIC_SAMPLER_DESC>>(allocator);
		defer { Deallocate!(allocator, staticSamplerDescs); }

		m_DescriptorSetMappings.Resize(pipelineLayoutDesc.descriptorSetNum);
		for(int i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++){
			m_DescriptorSetMappings[i] = DescriptorSetMapping(allocator);
		}

		m_DescriptorSetRootMappings.Resize(pipelineLayoutDesc.descriptorSetNum);
		for(int i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++){
			m_DescriptorSetRootMappings[i] = DescriptorSetRootMapping(allocator);
		}

		m_DynamicConstantBufferMappings.Resize(pipelineLayoutDesc.descriptorSetNum);

		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
		{
			readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[i];
			DescriptorSetD3D12.BuildDescriptorSetMapping(descriptorSetDesc, ref m_DescriptorSetMappings[i]);
			m_DescriptorSetRootMappings[i].rootOffsets.Resize(descriptorSetDesc.rangeNum);

			uint32 heapIndex = 0;
			D3D12_ROOT_PARAMETER1 rootParameter = .();
			rootParameter.ParameterType = .D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE;

			uint32 groupedRangeNum = 0;
			D3D12_DESCRIPTOR_RANGE_TYPE groupedRangeType = .();
			for (uint32 j = 0; j < descriptorSetDesc.rangeNum; j++)
			{
				var descriptorRangeMapping = ref m_DescriptorSetMappings[i].descriptorRangeMappings[j];

				D3D12_SHADER_VISIBILITY shaderVisibility = GetShaderVisibility(descriptorSetDesc.ranges[j].visibility);
				D3D12_DESCRIPTOR_RANGE_TYPE rangeType = GetDescriptorRangesType(descriptorSetDesc.ranges[j].descriptorType);

				if (groupedRangeNum > 0 &&
					(   rootParameter.ShaderVisibility != shaderVisibility ||
					groupedRangeType != rangeType ||
					descriptorRangeMapping.descriptorHeapType != (.)heapIndex)
					)
				{
					rootParameter.DescriptorTable.NumDescriptorRanges = groupedRangeNum;
					rootParameters.Add(rootParameter);

					totalRangeNum += groupedRangeNum;
					groupedRangeNum = 0;
				}

				groupedRangeType = rangeType;
				heapIndex = (uint32)descriptorRangeMapping.descriptorHeapType;
				m_DescriptorSetRootMappings[i].rootOffsets[j] = groupedRangeNum != 0 ? ROOT_PARAMETER_UNUSED : (uint16)rootParameters.Count;

				rootParameter.ShaderVisibility = shaderVisibility;
				rootParameter.DescriptorTable.pDescriptorRanges = &descriptorRanges[totalRangeNum];

				ref D3D12_DESCRIPTOR_RANGE1 descriptorRange = ref descriptorRanges[totalRangeNum + groupedRangeNum];
				descriptorRange.RangeType = rangeType;
				descriptorRange.NumDescriptors = descriptorSetDesc.ranges[j].descriptorNum;
				descriptorRange.BaseShaderRegister = descriptorSetDesc.ranges[j].baseRegisterIndex;
				descriptorRange.RegisterSpace = i;
				descriptorRange.Flags = .D3D12_DESCRIPTOR_RANGE_FLAG_NONE; // TODO:
				descriptorRange.OffsetInDescriptorsFromTableStart = D3D12_DESCRIPTOR_RANGE_OFFSET_APPEND;
				groupedRangeNum++;
			}

			if (groupedRangeNum != 0)
			{
				rootParameter.DescriptorTable.NumDescriptorRanges = groupedRangeNum;
				rootParameters.Add(rootParameter);
				totalRangeNum += groupedRangeNum;
			}

			if (descriptorSetDesc.dynamicConstantBufferNum != 0)
			{
				D3D12_ROOT_PARAMETER1 rootParameterLocal = .();
				rootParameterLocal.ParameterType = .D3D12_ROOT_PARAMETER_TYPE_CBV;
				rootParameterLocal.Descriptor.Flags = .D3D12_ROOT_DESCRIPTOR_FLAG_NONE;
				m_DynamicConstantBufferMappings[i].constantNum = (uint16)descriptorSetDesc.dynamicConstantBufferNum;
				m_DynamicConstantBufferMappings[i].rootOffset = (uint16)rootParameters.Count;

				for (uint32 j = 0; j < descriptorSetDesc.dynamicConstantBufferNum; j++)
				{
					rootParameterLocal.Descriptor.ShaderRegister = descriptorSetDesc.dynamicConstantBuffers[j].registerIndex;
					rootParameterLocal.Descriptor.RegisterSpace = i;
					rootParameterLocal.ShaderVisibility = GetShaderVisibility(descriptorSetDesc.dynamicConstantBuffers[j].visibility);
					rootParameters.Add(rootParameterLocal);
				}
			}
			else
			{
				m_DynamicConstantBufferMappings[i].constantNum = 0;
				m_DynamicConstantBufferMappings[i].rootOffset = 0;
			}

			if (descriptorSetDesc.staticSamplerNum != 0)
			{
				for (uint32 j = 0; j < descriptorSetDesc.staticSamplerNum; j++)
				{
					readonly ref SamplerDesc samplerDesc = ref descriptorSetDesc.staticSamplers[j].samplerDesc;
					bool useAnisotropy = samplerDesc.anisotropy > 1 ? true : false;
					bool useComparison = samplerDesc.compareFunc != CompareFunc.NONE;

					D3D12_STATIC_SAMPLER_DESC desc = .();
					desc.Filter = useAnisotropy ?
						GetFilterAnisotropic(samplerDesc.filterExt, useComparison) :
						GetFilterIsotropic(samplerDesc.mip, samplerDesc.magnification, samplerDesc.minification, samplerDesc.filterExt, useComparison);
					desc.AddressU = GetAddressMode(samplerDesc.addressModes.u);
					desc.AddressV = GetAddressMode(samplerDesc.addressModes.v);
					desc.AddressW = GetAddressMode(samplerDesc.addressModes.w);
					desc.MipLODBias = samplerDesc.mipBias;
					desc.MaxAnisotropy = samplerDesc.anisotropy;
					desc.ComparisonFunc = GetComparisonFunc(samplerDesc.compareFunc);
					desc.MinLOD = samplerDesc.mipMin;
					desc.MaxLOD = samplerDesc.mipMax;
					desc.ShaderRegister = descriptorSetDesc.staticSamplers[j].registerIndex;
					desc.RegisterSpace = i;
					desc.ShaderVisibility = GetShaderVisibility(descriptorSetDesc.staticSamplers[j].visibility);

					if (samplerDesc.borderColor == BorderColor.FLOAT_TRANSPARENT_BLACK || samplerDesc.borderColor == BorderColor.INT_TRANSPARENT_BLACK)
						desc.BorderColor = .D3D12_STATIC_BORDER_COLOR_TRANSPARENT_BLACK;
					else if (samplerDesc.borderColor == BorderColor.FLOAT_OPAQUE_BLACK || samplerDesc.borderColor == BorderColor.INT_OPAQUE_BLACK)
						desc.BorderColor = .D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK;
					else if (samplerDesc.borderColor == BorderColor.FLOAT_OPAQUE_WHITE || samplerDesc.borderColor == BorderColor.INT_OPAQUE_WHITE)
						desc.BorderColor = .D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE;

					staticSamplerDescs.Add(desc);
				}
			}
		}

		if (pipelineLayoutDesc.pushConstantNum != 0)
		{
			m_PushConstantsBaseIndex = (uint32)rootParameters.Count;

			D3D12_ROOT_PARAMETER1 rootParameterLocal = .();
			rootParameterLocal.ParameterType = .D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS;
			for (uint32 i = 0; i < pipelineLayoutDesc.pushConstantNum; i++)
			{
				rootParameterLocal.ShaderVisibility = GetShaderVisibility(pipelineLayoutDesc.pushConstants[i].visibility);
				rootParameterLocal.Constants.ShaderRegister = pipelineLayoutDesc.pushConstants[i].registerIndex;
				rootParameterLocal.Constants.RegisterSpace = 0;
				rootParameterLocal.Constants.Num32BitValues = pipelineLayoutDesc.pushConstants[i].size / 4;
				rootParameters.Add(rootParameterLocal);
			}
		}

		D3D12_VERSIONED_ROOT_SIGNATURE_DESC rootSignatureDesc = .();
		rootSignatureDesc.Version = .D3D_ROOT_SIGNATURE_VERSION_1_1;
		rootSignatureDesc.Desc_1_1.NumParameters = (uint32)rootParameters.Count;
		rootSignatureDesc.Desc_1_1.pParameters = rootParameters.IsEmpty ? null : &rootParameters[0];
		rootSignatureDesc.Desc_1_1.NumStaticSamplers = (uint32)staticSamplerDescs.Count;
		rootSignatureDesc.Desc_1_1.pStaticSamplers = staticSamplerDescs.IsEmpty ? null : &staticSamplerDescs[0];
		rootSignatureDesc.Desc_1_1.Flags = GetRootSignatureStageFlags(pipelineLayoutDesc, m_Device);

		ComPtr<ID3DBlob> rootSignatureBlob = default;
		defer rootSignatureBlob.Dispose();

		ComPtr<ID3DBlob> errorBlob = null;
		defer errorBlob.Dispose();

		HRESULT hr = D3D12SerializeVersionedRootSignature(&rootSignatureDesc, rootSignatureBlob.GetAddressOf(), errorBlob.GetAddressOf());
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "D3D12SerializeVersionedRootSignature() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		hr = ((ID3D12Device*)m_Device).CreateRootSignature(NRI_TEMP_NODE_MASK, rootSignatureBlob->GetBufferPointer(), rootSignatureBlob->GetBufferSize(), ID3D12RootSignature.IID, (void**)(&m_RootSignature));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device.CreateRootSignature() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_RootSignature, scope String(name));
	}
}