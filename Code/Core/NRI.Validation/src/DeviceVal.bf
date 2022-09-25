using System;
using System.Threading;
using System.Collections;
using NRI.Helpers;
namespace NRI.Validation;

class DeviceVal : Device
{
	private Device m_Device;
	private String m_Name ~ delete _;
	private CommandQueueVal[COMMAND_QUEUE_TYPE_NUM] m_CommandQueues = .();
	private Dictionary<MemoryType, MemoryLocation> m_MemoryTypeMap;
	private Monitor m_Lock = new .() ~ delete _;
	private uint32 m_PhysicalDeviceNum = 0;
	private uint32 m_PhysicalDeviceMask = 0;
	/*private bool m_IsSwapChainSupported = false;
	private bool m_IsWrapperD3D11Supported = false;
	private bool m_IsWrapperD3D12Supported = false;
	private bool m_IsWrapperVKSupported = false;
	private bool m_IsRayTracingSupported = false;
	private bool m_IsMeshShaderExtSupported = false;*/

	public this(DeviceLogger logger, DeviceAllocator<uint8> allocator, Device device, uint32 physicalDeviceNum)
	{
		m_Device = device;
		m_Name = Allocate!<String>(m_Device.GetAllocator());
		m_PhysicalDeviceNum = physicalDeviceNum;
		m_PhysicalDeviceMask = (1 << (physicalDeviceNum + 1)) - 1;
		m_MemoryTypeMap = Allocate!<Dictionary<MemoryType, MemoryLocation>>(m_Device.GetAllocator());
	}

	public ~this()
	{
		for (uint i = 0; i < m_CommandQueues.Count; i++)
		{
			if (m_CommandQueues[i] != null)
				Deallocate!(GetAllocator(), m_CommandQueues[i]);
		}
		DeviceAllocator<uint8> allocator = m_Device.GetAllocator();

		((Device)m_Device).Destroy();

		Deallocate!(allocator, m_MemoryTypeMap);
	}

	public bool Create()
	{
		return true;
	}

	public void RegisterMemoryType(MemoryType memoryType, MemoryLocation memoryLocation)
	{
		using (m_Lock.Enter())
			m_MemoryTypeMap[memoryType] = memoryLocation;
	}

	public  void* GetDeviceNativeObject()
		{ return m_Device.GetDeviceNativeObject(); }

	public uint32 GetPhysicalDeviceNum()
		{ return m_PhysicalDeviceNum; }

	public bool IsPhysicalDeviceMaskValid(uint32 physicalDeviceMask)
		{ return (physicalDeviceMask & m_PhysicalDeviceMask) == physicalDeviceMask; }

	public Monitor GetLock()
		{ return m_Lock; }
	public DeviceLogger GetLogger()
	{
		return m_Device.GetLogger();
	}

	public DeviceAllocator<uint8> GetAllocator()
	{
		return m_Device.GetAllocator();
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_Device.SetDebugName(name);
	}

	public readonly ref DeviceDesc GetDesc()
	{
		return ref m_Device.GetDesc();
	}

	public Result GetCommandQueue(CommandQueueType commandQueueType, out CommandQueue commandQueue)
	{
		commandQueue = ?;
		RETURN_ON_FAILURE!(GetLogger(), commandQueueType < CommandQueueType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't get CommandQueue: 'commandQueueType' is invalid.");

		CommandQueue commandQueueImpl;
		readonly Result result = m_Device.GetCommandQueue(commandQueueType, out commandQueueImpl);

		if (result == Result.SUCCESS)
		{
			readonly uint32 index = (uint32)commandQueueType;
			if (m_CommandQueues[index] == null)
				m_CommandQueues[index] = Allocate!<CommandQueueVal>(GetAllocator(), this, commandQueueImpl);

			commandQueue = (CommandQueue)m_CommandQueues[index];
		}
		return result;
	}

	public Result CreateCommandAllocator(CommandQueue commandQueue, uint32 physicalDeviceMask, out CommandAllocator commandAllocator)
	{
		commandAllocator = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create CommandAllocator: 'physicalDeviceMask' is invalid.");

		var commandQueueImpl = NRI_GET_IMPL_REF!<CommandQueue...>((CommandQueueVal)commandQueue);

		CommandAllocator commandAllocatorImpl = null;
		readonly Result result = m_Device.CreateCommandAllocator(commandQueueImpl, physicalDeviceMask, out commandAllocatorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), commandAllocatorImpl != null, Result.FAILURE, "Unexpected error: 'commandAllocatorImpl' is NULL.");
			commandAllocator = (CommandAllocator)Allocate!<CommandAllocatorVal>(GetAllocator(), this, commandAllocatorImpl);
		}

		return result;
	}

	public Result CreateDescriptorPool(DescriptorPoolDesc descriptorPoolDesc, out DescriptorPool descriptorPool)
	{
		descriptorPool = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(descriptorPoolDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create DescriptorPool: 'descriptorPoolDesc.physicalDeviceMask' is invalid.");

		DescriptorPool descriptorPoolImpl = null;
		readonly Result result = m_Device.CreateDescriptorPool(descriptorPoolDesc, out descriptorPoolImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), descriptorPoolImpl != null, Result.FAILURE, "Unexpected error: 'descriptorPoolImpl' is NULL.");
			descriptorPool = (DescriptorPool)Allocate!<DescriptorPoolVal>(GetAllocator(), this, descriptorPoolImpl, descriptorPoolDesc);
		}

		return result;
	}

	public Result CreateBuffer(BufferDesc bufferDesc, out Buffer buffer)
	{
		buffer = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(bufferDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Buffer: 'bufferDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), bufferDesc.size > 0, Result.INVALID_ARGUMENT,
			"Can't create Buffer: 'bufferDesc.size' is 0.");

		Buffer bufferImpl = null;
		readonly Result result = m_Device.CreateBuffer(bufferDesc, out bufferImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), bufferImpl != null, Result.FAILURE, "Unexpected error: 'bufferImpl' is NULL.");
			buffer = (Buffer)Allocate!<BufferVal>(GetAllocator(), this, bufferImpl, bufferDesc);
		}

		return result;
	}

	public Result CreateTexture(TextureDesc textureDesc, out Texture texture)
	{
		texture = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Texture: 'textureDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureDesc.format > Format.UNKNOWN && textureDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Texture: 'textureDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureDesc.sampleNum > 0, Result.INVALID_ARGUMENT,
			"Can't create Texture: 'textureDesc.sampleNum' is invalid.");

		Texture textureImpl = null;
		readonly Result result = m_Device.CreateTexture(textureDesc, out textureImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), textureImpl != null, Result.FAILURE, "Unexpected error: 'textureImpl' is NULL.");
			texture = (Texture)Allocate!<TextureVal>(GetAllocator(), this, textureImpl, textureDesc);
		}

		return result;
	}

	public Result CreateBufferView(BufferViewDesc bufferViewDesc, out Descriptor bufferView)
	{
		bufferView = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(bufferViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.buffer != null, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.buffer' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.viewType < BufferViewType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.viewType' is invalid");

		readonly ref BufferDesc bufferDesc = ref ((BufferVal)bufferViewDesc.buffer).GetDesc();

		RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.offset < bufferDesc.size, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.offset' is invalid. (bufferViewDesc.offset=%llu, bufferDesc.size=%llu)",
			bufferViewDesc.offset, bufferDesc.size);

		RETURN_ON_FAILURE!(GetLogger(), bufferViewDesc.offset + bufferViewDesc.size <= bufferDesc.size, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'bufferViewDesc.size' is invalid. (bufferViewDesc.offset=%llu, bufferViewDesc.size=%llu, bufferDesc.size=%llu)",
			bufferViewDesc.offset, bufferViewDesc.size, bufferDesc.size);

		var bufferViewDescImpl = bufferViewDesc;
		bufferViewDescImpl.buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)bufferViewDesc.buffer);

		Descriptor descriptorImpl = null;
		readonly Result result = m_Device.CreateBufferView(bufferViewDescImpl, out descriptorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
			bufferView = (Descriptor)Allocate!<DescriptorVal>(GetAllocator(), this, descriptorImpl, bufferViewDesc);
		}

		return result;
	}

	public Result CreateTexture1DView(Texture1DViewDesc textureViewDesc, out Descriptor textureView)
	{
		textureView = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture1DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

		readonly ref TextureDesc textureDesc = ref ((TextureVal)textureViewDesc.texture).GetDesc();

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureDesc.mipNum={})",
			textureViewDesc.mipOffset, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
			textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset < textureDesc.arraySize, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.arrayOffset={}, textureDesc.arraySize={})",
			textureViewDesc.arrayOffset, textureDesc.arraySize);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset + textureViewDesc.arraySize <= textureDesc.arraySize, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.arrayOffset={}, textureViewDesc.arraySize={}, textureDesc.arraySize={})",
			textureViewDesc.arrayOffset, textureViewDesc.arraySize, textureDesc.arraySize);

		var textureViewDescImpl = textureViewDesc;
		textureViewDescImpl.texture = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)textureViewDesc.texture);

		Descriptor descriptorImpl = null;
		readonly Result result = m_Device.CreateTexture1DView(textureViewDescImpl, out descriptorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
			textureView = (Descriptor)Allocate!<DescriptorVal>(GetAllocator(), this, descriptorImpl, textureViewDesc);
		}

		return result;
	}

	public Result CreateTexture2DView(Texture2DViewDesc textureViewDesc, out Descriptor textureView)
	{
		textureView = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture2DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

		readonly ref TextureDesc textureDesc = ref ((TextureVal)textureViewDesc.texture).GetDesc();

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureDesc.mipNum={})",
			textureViewDesc.mipOffset, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
			textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset < textureDesc.arraySize, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.arrayOffset={}, textureDesc.arraySize={})",
			textureViewDesc.arrayOffset, textureDesc.arraySize);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.arrayOffset + textureViewDesc.arraySize <= textureDesc.arraySize, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.arrayOffset={}, textureViewDesc.arraySize={}, textureDesc.arraySize={})",
			textureViewDesc.arrayOffset, textureViewDesc.arraySize, textureDesc.arraySize);

		var textureViewDescImpl = textureViewDesc;
		textureViewDescImpl.texture = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)textureViewDesc.texture);

		Descriptor descriptorImpl = null;
		readonly Result result = m_Device.CreateTexture2DView(textureViewDescImpl, out descriptorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
			textureView = (Descriptor)Allocate!<DescriptorVal>(GetAllocator(), this, descriptorImpl, textureViewDesc);
		}

		return result;
	}

	public Result CreateTexture3DView(Texture3DViewDesc textureViewDesc, out Descriptor textureView)
	{
		textureView = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(textureViewDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.texture != null, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.texture' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.format > Format.UNKNOWN && textureViewDesc.format < Format.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.viewType < Texture3DViewType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.viewType' is invalid.");

		readonly ref TextureDesc textureDesc = ref ((TextureVal)textureViewDesc.texture).GetDesc();

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset < textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipOffset' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipOffset={})",
			textureViewDesc.mipOffset, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.mipOffset + textureViewDesc.mipNum <= textureDesc.mipNum, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.mipNum' is invalid. (textureViewDesc.mipOffset={}, textureViewDesc.mipNum={}, textureDesc.mipNum={})",
			textureViewDesc.mipOffset, textureViewDesc.mipNum, textureDesc.mipNum);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.sliceOffset < textureDesc.size[2], Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arrayOffset' is invalid. (textureViewDesc.sliceOffset={}, textureDesc.size[2]={})",
			textureViewDesc.sliceOffset, textureDesc.size[2]);

		RETURN_ON_FAILURE!(GetLogger(), textureViewDesc.sliceOffset + textureViewDesc.sliceNum <= textureDesc.size[2], Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'textureViewDesc.arraySize' is invalid. (textureViewDesc.sliceOffset={}, textureViewDesc.sliceNum={}, textureDesc.size[2]={})",
			textureViewDesc.sliceOffset, textureViewDesc.sliceNum, textureDesc.size[2]);

		var textureViewDescImpl = textureViewDesc;
		textureViewDescImpl.texture = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)textureViewDesc.texture);

		Descriptor descriptorImpl = null;
		readonly Result result = m_Device.CreateTexture3DView(textureViewDescImpl, out descriptorImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), descriptorImpl != null, Result.FAILURE, "Unexpected error: 'descriptorImpl' is NULL.");
			textureView = (Descriptor)Allocate!<DescriptorVal>(GetAllocator(), this, descriptorImpl, textureViewDesc);
		}

		return result;
	}

	public Result CreateSampler(SamplerDesc samplerDesc, out Descriptor sampler)
	{
		sampler = ?;
		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.magnification < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.magnification' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.minification < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.magnification' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.mip < Filter.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.mip' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.filterExt < FilterExt.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.filterExt' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.u < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.addressModes.u' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.v < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.addressModes.v' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.addressModes.w < AddressMode.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.addressModes.w' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.compareFunc < CompareFunc.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.compareFunc' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), samplerDesc.borderColor < BorderColor.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create Descriptor: 'samplerDesc.borderColor' is invalid.");

		Descriptor samplerImpl = null;
		readonly Result result = m_Device.CreateSampler(samplerDesc, out samplerImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), samplerImpl != null, Result.FAILURE, "Unexpected error: 'samplerImpl' is NULL.");
			sampler = (Descriptor)Allocate!<DescriptorVal>(GetAllocator(), this, samplerImpl);
		}

		return result;
	}

	public Result CreatePipelineLayout(PipelineLayoutDesc pipelineLayoutDesc, out PipelineLayout pipelineLayout)
	{
		pipelineLayout = ?;
		readonly bool isGraphics = pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.ALL_GRAPHICS);
		readonly bool isCompute = pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.COMPUTE);
		readonly bool isRayTracing = pipelineLayoutDesc.stageMask.HasFlag(PipelineLayoutShaderStageBits.ALL_RAY_TRACING);
		readonly uint32 supportedTypes = (uint32)(isGraphics ? 1 : 0) + (uint32)(isCompute ? 1 : 0) + (uint32)(isRayTracing ? 1 : 0);

		RETURN_ON_FAILURE!(GetLogger(), supportedTypes > 0, Result.INVALID_ARGUMENT,
			"Can't create pipeline layout: 'pipelineLayoutDesc.stageMask' is 0.");
		RETURN_ON_FAILURE!(GetLogger(), supportedTypes == 1, Result.INVALID_ARGUMENT,
			"Can't create pipeline layout: 'pipelineLayoutDesc.stageMask' is invalid, it can't be compatible with more than one type of pipeline.");

		for (uint32 i = 0; i < pipelineLayoutDesc.descriptorSetNum; i++)
		{
			readonly ref DescriptorSetDesc descriptorSetDesc = ref pipelineLayoutDesc.descriptorSets[i];

			for (uint32 j = 0; j < descriptorSetDesc.rangeNum; j++)
			{
				readonly ref DescriptorRangeDesc range = ref descriptorSetDesc.ranges[j];

				RETURN_ON_FAILURE!(GetLogger(), !range.isDescriptorNumVariable || range.isArray, Result.INVALID_ARGUMENT,
					"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}]' is invalid, 'isArray' can't be false if 'isDescriptorNumVariable' is true.",
					i, j);

				RETURN_ON_FAILURE!(GetLogger(), range.descriptorNum > 0, Result.INVALID_ARGUMENT,
					"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].descriptorNum' can't be 0.",
					i, j);

				RETURN_ON_FAILURE!(GetLogger(), range.visibility < ShaderStage.MAX_NUM, Result.INVALID_ARGUMENT,
					"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].visibility' is invalid.",
					i, j);

				RETURN_ON_FAILURE!(GetLogger(), range.descriptorType < DescriptorType.MAX_NUM, Result.INVALID_ARGUMENT,
					"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].descriptorType' is invalid.",
					i, j);

				if (range.visibility != ShaderStage.ALL)
				{
					readonly PipelineLayoutShaderStageBits visibilityMask = (PipelineLayoutShaderStageBits)(1 << (uint32)range.visibility);
					readonly uint32 filteredVisibilityMask = (.)(visibilityMask & pipelineLayoutDesc.stageMask);

					RETURN_ON_FAILURE!(GetLogger(), (uint32)visibilityMask == filteredVisibilityMask, Result.INVALID_ARGUMENT,
						"Can't create pipeline layout: 'pipelineLayoutDesc.descriptorSets[{}].ranges[{}].visibility' is not compatible with 'pipelineLayoutDesc.stageMask'.", i, j);
				}
			}
		}

		PipelineLayout pipelineLayoutImpl = null;
		readonly Result result = m_Device.CreatePipelineLayout(pipelineLayoutDesc, out pipelineLayoutImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), pipelineLayoutImpl != null, Result.FAILURE, "Unexpected error: 'pipelineLayoutImpl' is NULL.");
			pipelineLayout = (PipelineLayout)Allocate!<PipelineLayoutVal>(GetAllocator(), this, pipelineLayoutImpl, pipelineLayoutDesc);
		}

		return result;
	}

	public Result CreateGraphicsPipeline(GraphicsPipelineDesc graphicsPipelineDesc, out Pipeline pipeline)
	{
		pipeline = ?;
		RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'graphicsPipelineDesc.pipelineLayout' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.outputMerger != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'graphicsPipelineDesc.outputMerger' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.rasterization != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'graphicsPipelineDesc.rasterization' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.shaderStages != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.shaderStageNum > 0, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'graphicsPipelineDesc.shaderStageNum' is 0.");

	/*readonly*/ ShaderDesc* vertexShader = null;
		for (uint32 i = 0; i < graphicsPipelineDesc.shaderStageNum; i++)
		{
			readonly ShaderDesc* shaderDesc = graphicsPipelineDesc.shaderStages + i;

			if (shaderDesc.stage == ShaderStage.VERTEX)
				vertexShader = shaderDesc;

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.bytecode != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].bytecode' is invalid.", i);

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.size != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].size' is 0.", i);

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.stage > ShaderStage.ALL && shaderDesc.stage < ShaderStage.COMPUTE, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'graphicsPipelineDesc.shaderStages[{}].stage' is invalid.", i);
		}

		if (graphicsPipelineDesc.inputAssembly != null)
		{
			RETURN_ON_FAILURE!(GetLogger(), graphicsPipelineDesc.inputAssembly.attributes == null || vertexShader != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: vertex shader is not specified, but input assembly attributes provided.");

			readonly PipelineLayoutVal pipelineLayout = (PipelineLayoutVal)graphicsPipelineDesc.pipelineLayout;
			readonly PipelineLayoutShaderStageBits stageMask = pipelineLayout.GetPipelineLayoutDesc().stageMask;

			RETURN_ON_FAILURE!(GetLogger(), (stageMask & PipelineLayoutShaderStageBits.VERTEX) != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: vertex stage is not enabled in the pipeline layout.");
		}

		var graphicsPipelineDescImpl = graphicsPipelineDesc;
		graphicsPipelineDescImpl.pipelineLayout = NRI_GET_IMPL_PTR!<PipelineLayout...>((PipelineLayoutVal)graphicsPipelineDesc.pipelineLayout);

		Pipeline pipelineImpl = null;
		readonly Result result = m_Device.CreateGraphicsPipeline(graphicsPipelineDescImpl, out pipelineImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
			pipeline = (Pipeline)Allocate!<PipelineVal>(GetAllocator(), this, pipelineImpl, graphicsPipelineDesc);
		}

		return result;
	}

	public Result CreateComputePipeline(ComputePipelineDesc computePipelineDesc, out Pipeline pipeline)
	{
		pipeline = ?;
		RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'computePipelineDesc.pipelineLayout' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.bytecode != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'computePipelineDesc.computeShader.bytecode' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.size != 0, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'computePipelineDesc.computeShader.size' is 0.");

		RETURN_ON_FAILURE!(GetLogger(), computePipelineDesc.computeShader.stage == ShaderStage.COMPUTE, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'computePipelineDesc.computeShader.stage' must be ShaderStage.COMPUTE.");

		var computePipelineDescImpl = computePipelineDesc;
		computePipelineDescImpl.pipelineLayout = NRI_GET_IMPL_PTR!<PipelineLayout...>((PipelineLayoutVal)computePipelineDesc.pipelineLayout);

		Pipeline pipelineImpl = null;
		readonly Result result = m_Device.CreateComputePipeline(computePipelineDescImpl, out pipelineImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
			pipeline = (Pipeline)Allocate!<PipelineVal>(GetAllocator(), this, pipelineImpl, computePipelineDesc);
		}

		return result;
	}

	public Result CreateFrameBuffer(FrameBufferDesc frameBufferDesc, out FrameBuffer frameBuffer)
	{
		frameBuffer = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(frameBufferDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create FrameBuffer: 'frameBufferDesc.physicalDeviceMask' is invalid.");

		if (frameBufferDesc.colorAttachmentNum > 0)
		{
			RETURN_ON_FAILURE!(GetLogger(), frameBufferDesc.colorAttachments != null, Result.INVALID_ARGUMENT,
				"Can't create FrameBuffer: 'frameBufferDesc.colorAttachments' is invalid.");

			for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
			{
				DescriptorVal descriptorVal = (DescriptorVal)frameBufferDesc.colorAttachments[i];

				RETURN_ON_FAILURE!(GetLogger(), descriptorVal.IsColorAttachment(), Result.INVALID_ARGUMENT,
					"Can't create FrameBuffer: 'frameBufferDesc.colorAttachments[{}]' is not a color attachment descriptor.", i);
			}
		}

		if (frameBufferDesc.depthStencilAttachment != null)
		{
			DescriptorVal descriptorVal = (DescriptorVal)frameBufferDesc.depthStencilAttachment;
			RETURN_ON_FAILURE!(GetLogger(), descriptorVal.IsDepthStencilAttachment(), Result.INVALID_ARGUMENT,
				"Can't create FrameBuffer: 'frameBufferDesc.depthStencilAttachment' is not a depth stencil attachment descriptor.");
		}

		var frameBufferDescImpl = frameBufferDesc;
		if (frameBufferDesc.depthStencilAttachment != null)
			frameBufferDescImpl.depthStencilAttachment = NRI_GET_IMPL_PTR!<Descriptor...>((DescriptorVal)frameBufferDesc.depthStencilAttachment);
		if (frameBufferDesc.colorAttachmentNum > 0)
		{
			frameBufferDescImpl.colorAttachments = STACK_ALLOC!<Descriptor>(frameBufferDesc.colorAttachmentNum);
			for (uint32 i = 0; i < frameBufferDesc.colorAttachmentNum; i++)
				((Descriptor*)frameBufferDescImpl.colorAttachments)[i] = NRI_GET_IMPL_PTR!<Descriptor...>((DescriptorVal)frameBufferDesc.colorAttachments[i]);
		}

		FrameBuffer frameBufferImpl = null;
		readonly Result result = m_Device.CreateFrameBuffer(frameBufferDescImpl, out frameBufferImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), frameBufferImpl != null, Result.FAILURE, "Unexpected error: 'frameBufferImpl' is NULL!");
			frameBuffer = (FrameBuffer)Allocate!<FrameBufferVal>(GetAllocator(), this, frameBufferImpl);
		}

		return result;
	}

	public Result CreateQueryPool(QueryPoolDesc queryPoolDesc, out QueryPool queryPool)
	{
		queryPool = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(queryPoolDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create QueryPool: 'queryPoolDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), queryPoolDesc.queryType < QueryType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create QueryPool: 'queryPoolDesc.queryType' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), queryPoolDesc.capacity > 0, Result.INVALID_ARGUMENT,
			"Can't create QueryPool: 'queryPoolDesc.capacity' is 0.");

		QueryPool queryPoolImpl = null;
		readonly Result result = m_Device.CreateQueryPool(queryPoolDesc, out queryPoolImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), queryPoolImpl != null, Result.FAILURE, "Unexpected error: 'queryPoolImpl' is NULL!");
			queryPool = (QueryPool)Allocate!<QueryPoolVal>(GetAllocator(), this, queryPoolImpl, queryPoolDesc.queryType,
				queryPoolDesc.capacity);
		}

		return result;
	}

	public Result CreateQueueSemaphore(out QueueSemaphore queueSemaphore)
	{
		queueSemaphore = ?;
		QueueSemaphore queueSemaphoreImpl = null;
		readonly Result result = m_Device.CreateQueueSemaphore(out queueSemaphoreImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), queueSemaphoreImpl != null, Result.FAILURE, "Unexpected error: 'queueSemaphoreImpl' is NULL!");
			queueSemaphore = (QueueSemaphore)Allocate!<QueueSemaphoreVal>(GetAllocator(), this, queueSemaphoreImpl);
		}

		return result;
	}

	public Result CreateDeviceSemaphore(bool signaled, out DeviceSemaphore deviceSemaphore)
	{
		deviceSemaphore = ?;
		DeviceSemaphore deviceSemaphoreImpl;
		readonly Result result = m_Device.CreateDeviceSemaphore(signaled, out deviceSemaphoreImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), deviceSemaphoreImpl != null, Result.FAILURE, "Unexpected error: 'queueSemaphoreImpl' is NULL!");
			DeviceSemaphoreVal deviceSemaphoreVal = Allocate!<DeviceSemaphoreVal>(GetAllocator(), this, deviceSemaphoreImpl);
			deviceSemaphoreVal.Create(signaled);
			deviceSemaphore = (DeviceSemaphore)deviceSemaphoreVal;
		}

		return result;
	}

	public Result CreateCommandBuffer(CommandAllocator commandAllocator, out CommandBuffer commandBuffer)
	{
		commandBuffer = ?;
		return commandAllocator.CreateCommandBuffer(out commandBuffer);
	}

	public Result CreateSwapChain(SwapChainDesc swapChainDesc, out SwapChain swapChain)
	{
		swapChain = ?;
		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.commandQueue != null, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.commandQueue' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.windowSystemType < WindowSystemType.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.windowSystemType' is invalid.");

		if (swapChainDesc.windowSystemType == WindowSystemType.WINDOWS)
		{
			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.windows.hwnd != null, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.window.windows.hwnd' is invalid.");
		}
		else if (swapChainDesc.windowSystemType == WindowSystemType.X11)
		{
			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.x11.dpy != null, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.window.x11.dpy' is invalid.");
			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.x11.window != 0, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.window.x11.window' is invalid.");
		}
		else if (swapChainDesc.windowSystemType == WindowSystemType.WAYLAND)
		{
			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.wayland.display != null, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.window.wayland.display' is invalid.");
			RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.window.wayland.surface != null, Result.INVALID_ARGUMENT,
				"Can't create SwapChain: 'swapChainDesc.window.wayland.surface' is invalid.");
		}

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.width != 0, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.width' is 0.");

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.height != 0, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.height' is 0.");

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.textureNum > 0, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.textureNum' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.format < SwapChainFormat.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.format' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), swapChainDesc.physicalDeviceIndex < m_PhysicalDeviceNum, Result.INVALID_ARGUMENT,
			"Can't create SwapChain: 'swapChainDesc.physicalDeviceIndex' is invalid.");

		var swapChainDescImpl = swapChainDesc;
		swapChainDescImpl.commandQueue = NRI_GET_IMPL_PTR!<CommandQueue...>((CommandQueueVal)swapChainDesc.commandQueue);

		SwapChain swapChainImpl = null;
		readonly Result result = m_Device.CreateSwapChain(swapChainDescImpl, out swapChainImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), swapChainImpl != null, Result.FAILURE, "Unexpected error: 'swapChainImpl' is NULL.");
			swapChain = (SwapChain)Allocate!<SwapChainVal>(GetAllocator(), this, swapChainImpl, swapChainDesc);
		}

		return result;
	}

	public Result CreateRayTracingPipeline(RayTracingPipelineDesc pipelineDesc, out Pipeline pipeline)
	{
		pipeline = ?;
		RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.pipelineLayout != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'pipelineDesc.pipelineLayout' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderLibrary != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'pipelineDesc.shaderLibrary' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderGroupDescs != null, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'pipelineDesc.shaderGroupDescs' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.shaderGroupDescNum != 0, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'pipelineDesc.shaderGroupDescNum' is 0.");

		RETURN_ON_FAILURE!(GetLogger(), pipelineDesc.recursionDepthMax != 0, Result.INVALID_ARGUMENT,
			"Can't create Pipeline: 'pipelineDesc.recursionDepthMax' is 0.");

		for (uint32 i = 0; i < pipelineDesc.shaderLibrary.shaderNum; i++)
		{
			readonly ref ShaderDesc shaderDesc = ref pipelineDesc.shaderLibrary.shaderDescs[i];

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.bytecode != null, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].bytecode' is invalid.", i);

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.size != 0, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].size' is 0.", i);

			RETURN_ON_FAILURE!(GetLogger(), shaderDesc.stage > ShaderStage.COMPUTE && shaderDesc.stage < ShaderStage.MAX_NUM, Result.INVALID_ARGUMENT,
				"Can't create Pipeline: 'pipelineDesc.shaderLibrary.shaderDescs[{}].stage' is invalid.", i);
		}

		var pipelineDescImpl = pipelineDesc;
		pipelineDescImpl.pipelineLayout = NRI_GET_IMPL_PTR!<PipelineLayout...>((PipelineLayoutVal)pipelineDesc.pipelineLayout);

		Pipeline pipelineImpl = null;
		readonly Result result = m_Device.CreateRayTracingPipeline(pipelineDescImpl, out pipelineImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), pipelineImpl != null, Result.FAILURE, "Unexpected error: 'pipelineImpl' is NULL.");
			pipeline = (Pipeline)Allocate!<PipelineVal>(GetAllocator(), this, pipelineImpl);
		}

		return result;
	}

	public Result CreateAccelerationStructure(AccelerationStructureDesc accelerationStructureDesc, out AccelerationStructure accelerationStructure)
	{
		accelerationStructure = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(accelerationStructureDesc.physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't create AccelerationStructure: 'accelerationStructureDesc.physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), accelerationStructureDesc.instanceOrGeometryObjectNum != 0, Result.INVALID_ARGUMENT,
			"Can't create AccelerationStructure: 'accelerationStructureDesc.instanceOrGeometryObjectNum' is 0.");

		AccelerationStructureDesc accelerationStructureDescImpl = accelerationStructureDesc;

		List<GeometryObject> objectImplArray = Allocate!<List<GeometryObject>>(GetAllocator());
		defer { Deallocate!(GetAllocator(), objectImplArray); }
		if (accelerationStructureDesc.type == AccelerationStructureType.BOTTOM_LEVEL)
		{
			readonly uint32 geometryObjectNum = accelerationStructureDesc.instanceOrGeometryObjectNum;
			objectImplArray.Resize(geometryObjectNum);
			ConvertGeometryObjectsVal(objectImplArray.Ptr, accelerationStructureDesc.geometryObjects, geometryObjectNum);
			accelerationStructureDescImpl.geometryObjects = objectImplArray.Ptr;
		}

		AccelerationStructure accelerationStructureImpl = null;
		readonly Result result = m_Device.CreateAccelerationStructure(accelerationStructureDescImpl, out accelerationStructureImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), accelerationStructureImpl != null, Result.FAILURE, "Unexpected error: 'accelerationStructureImpl' is NULL.");
			accelerationStructure = (AccelerationStructure)Allocate!<AccelerationStructureVal>(GetAllocator(), this, accelerationStructureImpl);
		}

		return result;
	}

	public void DestroyCommandAllocator(CommandAllocator commandAllocator)
	{
		m_Device.DestroyCommandAllocator(NRI_GET_IMPL_REF!<CommandAllocator...>((CommandAllocatorVal)commandAllocator));
		Deallocate!(GetAllocator(), (CommandAllocatorVal)commandAllocator);
	}

	public void DestroyDescriptorPool(DescriptorPool descriptorPool)
	{
		m_Device.DestroyDescriptorPool(NRI_GET_IMPL_REF!<DescriptorPool...>((DescriptorPoolVal)descriptorPool));
		Deallocate!(GetAllocator(), (DescriptorPoolVal)descriptorPool);
	}

	public void DestroyBuffer(Buffer buffer)
	{
		m_Device.DestroyBuffer(NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer));
		Deallocate!(GetAllocator(), (BufferVal)buffer);
	}

	public void DestroyTexture(Texture texture)
	{
		m_Device.DestroyTexture(NRI_GET_IMPL_REF!<Texture...>((TextureVal)texture));
		Deallocate!(GetAllocator(), (TextureVal)texture);
	}

	public void DestroyDescriptor(Descriptor descriptor)
	{
		m_Device.DestroyDescriptor(NRI_GET_IMPL_REF!<Descriptor...>((DescriptorVal)descriptor));
		Deallocate!(GetAllocator(), (DescriptorVal)descriptor);
	}

	public void DestroyPipelineLayout(PipelineLayout pipelineLayout)
	{
		m_Device.DestroyPipelineLayout(NRI_GET_IMPL_REF!<PipelineLayout...>((PipelineLayoutVal)pipelineLayout));
		Deallocate!(GetAllocator(), (PipelineLayoutVal)pipelineLayout);
	}

	public void DestroyPipeline(Pipeline pipeline)
	{
		m_Device.DestroyPipeline(NRI_GET_IMPL_REF!<Pipeline...>((PipelineVal)pipeline));
		Deallocate!(GetAllocator(), (PipelineVal)pipeline);
	}

	public void DestroyFrameBuffer(FrameBuffer frameBuffer)
	{
		m_Device.DestroyFrameBuffer(NRI_GET_IMPL_REF!<FrameBuffer...>((FrameBufferVal)frameBuffer));
		Deallocate!(GetAllocator(), (FrameBufferVal)frameBuffer);
	}

	public void DestroyQueryPool(QueryPool queryPool)
	{
		m_Device.DestroyQueryPool(NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool));
		Deallocate!(GetAllocator(), (QueryPoolVal)queryPool);
	}

	public void DestroyQueueSemaphore(QueueSemaphore queueSemaphore)
	{
		m_Device.DestroyQueueSemaphore(NRI_GET_IMPL_REF!<QueueSemaphore...>((QueueSemaphoreVal)queueSemaphore));
		Deallocate!(GetAllocator(), (QueueSemaphoreVal)queueSemaphore);
	}

	public void DestroyDeviceSemaphore(DeviceSemaphore deviceSemaphore)
	{
		m_Device.DestroyDeviceSemaphore(NRI_GET_IMPL_REF!<DeviceSemaphore...>((DeviceSemaphoreVal)deviceSemaphore));
		Deallocate!(GetAllocator(), (DeviceSemaphoreVal)deviceSemaphore);
	}

	public void DestroyCommandBuffer(CommandBuffer commandBuffer)
	{
		m_Device.DestroyCommandBuffer(NRI_GET_IMPL_REF!<CommandBuffer...>((CommandBufferVal)commandBuffer));
		Deallocate!(GetAllocator(), (CommandBufferVal)commandBuffer);
	}

	public void DestroySwapChain(SwapChain swapChain)
	{
		m_Device.DestroySwapChain(NRI_GET_IMPL_REF!<SwapChain...>((SwapChainVal)swapChain));
		Deallocate!(GetAllocator(), (SwapChainVal)swapChain);
	}

	public void DestroyAccelerationStructure(AccelerationStructure accelerationStructure)
	{
		Deallocate!(GetAllocator(), (AccelerationStructureVal)accelerationStructure);
	}

	public void Destroy()
	{
		Deallocate!(GetAllocator(), this);
	}

	public Result GetDisplays(Display** displays, ref uint32 displayNum)
	{
		RETURN_ON_FAILURE!(GetLogger(), displayNum == 0 || displays != null, Result.INVALID_ARGUMENT,
			"Can't get displays: 'displays' is invalid.");

		return m_Device.GetDisplays(displays, ref displayNum);
	}

	public Result GetDisplaySize(ref Display display, ref uint16 width, ref uint16 height)
	{
		return m_Device.GetDisplaySize(ref display, ref width, ref height);
	}

	public Result AllocateMemory(uint32 physicalDeviceMask, uint32 memoryType, uint64 size, out Memory memory)
	{
		memory = ?;
		RETURN_ON_FAILURE!(GetLogger(), IsPhysicalDeviceMaskValid(physicalDeviceMask), Result.INVALID_ARGUMENT,
			"Can't allocate Memory: 'physicalDeviceMask' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), size > 0, Result.INVALID_ARGUMENT,
			"Can't allocate Memory: 'size' is 0.");

		bool hasMemoryType = false;
		MemoryLocation memoryLocation = .MAX_NUM;

		using (m_Lock.Enter())
		{
			if (m_MemoryTypeMap.ContainsKey(memoryType))
			{
				hasMemoryType = true;
				memoryLocation = m_MemoryTypeMap[memoryType];
			}
		}

		RETURN_ON_FAILURE!(GetLogger(), hasMemoryType, Result.FAILURE,
			"Can't allocate Memory: 'memoryType' is invalid.");

		Memory memoryImpl;
		readonly Result result = m_Device.AllocateMemory(physicalDeviceMask, memoryType, size, out memoryImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(GetLogger(), memoryImpl != null, Result.FAILURE, "Unexpected error: 'memoryImpl' is NULL!");
			memory = (Memory)Allocate!<MemoryVal>(GetAllocator(), this, memoryImpl, size, memoryLocation);
		}

		return result;
	}

	public Result BindBufferMemory(BufferMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		if (memoryBindingDescNum == 0)
			return Result.SUCCESS;

		RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null, Result.INVALID_ARGUMENT,
			"Can't bind memory to buffers: 'memoryBindingDescs' is invalid.");

		BufferMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<BufferMemoryBindingDesc>(memoryBindingDescNum);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			ref BufferMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
			readonly ref BufferMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

			RETURN_ON_FAILURE!(GetLogger(), srcDesc.buffer != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].buffer' is invalid.", i);
			RETURN_ON_FAILURE!(GetLogger(), srcDesc.memory != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].memory' is invalid.", i);

			MemoryVal memory = (MemoryVal)srcDesc.memory;
			BufferVal buffer = (BufferVal)srcDesc.buffer;

			RETURN_ON_FAILURE!(GetLogger(), !buffer.IsBoundToMemory(), Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].buffer' is already bound to memory.", i);

			// Skip validation if memory has been created from GAPI object using a wrapper extension
			if (memory.GetMemoryLocation() == MemoryLocation.MAX_NUM)
				continue;

			MemoryDesc memoryDesc = .();
			buffer.GetMemoryInfo(memory.GetMemoryLocation(), ref memoryDesc);

			RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

			RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

			RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' is misaligned.", i);

			readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
			readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

			RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
				"Can't bind memory to buffers: 'memoryBindingDescs[{}].offset' is invalid.", i);

			destDesc = srcDesc;
			destDesc.memory = memory.GetImpl();
			destDesc.buffer = buffer.GetImpl();
		}

		readonly Result result = m_Device.BindBufferMemory(memoryBindingDescsImpl, memoryBindingDescNum);

		if (result == Result.SUCCESS)
		{
			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				MemoryVal memory = (MemoryVal)memoryBindingDescs[i].memory;
				memory.BindBuffer((BufferVal)memoryBindingDescs[i].buffer);
			}
		}

		return result;
	}

	public Result BindTextureMemory(TextureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null || memoryBindingDescNum == 0, Result.INVALID_ARGUMENT,
			"Can't bind memory to textures: 'memoryBindingDescs' is a NULL.");

		TextureMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<TextureMemoryBindingDesc>(memoryBindingDescNum);

		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			ref TextureMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
			readonly ref TextureMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

			RETURN_ON_FAILURE!(GetLogger(), srcDesc.texture != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].texture' is invalid.", i);
			RETURN_ON_FAILURE!(GetLogger(), srcDesc.memory != null, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].memory' is invalid.", i);

			MemoryVal memory = (MemoryVal)srcDesc.memory;
			TextureVal texture = (TextureVal)srcDesc.texture;

			RETURN_ON_FAILURE!(GetLogger(), !texture.IsBoundToMemory(), Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].texture' is already bound to memory.", i);

			// Skip validation if memory has been created from GAPI object using a wrapper extension
			if (memory.GetMemoryLocation() == MemoryLocation.MAX_NUM)
				continue;

			MemoryDesc memoryDesc = .();
			texture.GetMemoryInfo(memory.GetMemoryLocation(), ref memoryDesc);

			RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

			RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

			RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' is misaligned.", i);

			readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
			readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

			RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
				"Can't bind memory to textures: 'memoryBindingDescs[{}].offset' is invalid.", i);

			destDesc = srcDesc;
			destDesc.memory = memory.GetImpl();
			destDesc.texture = texture.GetImpl();
		}

		readonly Result result = m_Device.BindTextureMemory(memoryBindingDescsImpl, memoryBindingDescNum);

		if (result == Result.SUCCESS)
		{
			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				MemoryVal memory = (MemoryVal)memoryBindingDescs[i].memory;
				memory.BindTexture((TextureVal)memoryBindingDescs[i].texture);
			}
		}

		return result;
	}

	public Result BindAccelerationStructureMemory(AccelerationStructureMemoryBindingDesc* memoryBindingDescs, uint32 memoryBindingDescNum)
	{
		if (memoryBindingDescNum == 0)
			return Result.SUCCESS;

		RETURN_ON_FAILURE!(GetLogger(), memoryBindingDescs != null, Result.INVALID_ARGUMENT,
			"Can't bind memory to acceleration structures: 'memoryBindingDescs' is invalid.");

		AccelerationStructureMemoryBindingDesc* memoryBindingDescsImpl = STACK_ALLOC!<AccelerationStructureMemoryBindingDesc>(memoryBindingDescNum);
		for (uint32 i = 0; i < memoryBindingDescNum; i++)
		{
			ref AccelerationStructureMemoryBindingDesc destDesc = ref memoryBindingDescsImpl[i];
			readonly ref AccelerationStructureMemoryBindingDesc srcDesc = ref memoryBindingDescs[i];

			MemoryVal memory = (MemoryVal)srcDesc.memory;
			AccelerationStructureVal accelerationStructure = (AccelerationStructureVal)srcDesc.accelerationStructure;

			RETURN_ON_FAILURE!(GetLogger(), !accelerationStructure.IsBoundToMemory(), Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].accelerationStructure' is already bound to memory.", i);

			MemoryDesc memoryDesc = .();
			accelerationStructure.GetMemoryInfo(ref memoryDesc);

			RETURN_ON_FAILURE!(GetLogger(), !memoryDesc.mustBeDedicated || srcDesc.offset == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' must be zero for dedicated allocation.", i);

			RETURN_ON_FAILURE!(GetLogger(), memoryDesc.alignment != 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].alignment' can't be zero.", i);

			RETURN_ON_FAILURE!(GetLogger(), srcDesc.offset % memoryDesc.alignment == 0, Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' is misaligned.", i);

			readonly uint64 rangeMax = srcDesc.offset + memoryDesc.size;
			readonly bool memorySizeIsUnknown = memory.GetSize() == 0;

			RETURN_ON_FAILURE!(GetLogger(), memorySizeIsUnknown || rangeMax <= memory.GetSize(), Result.INVALID_ARGUMENT,
				"Can't bind memory to acceleration structures: 'memoryBindingDescs[{}].offset' is invalid.", i);

			destDesc = srcDesc;
			destDesc.memory = memory.GetImpl();
			destDesc.accelerationStructure = accelerationStructure.GetImpl();
		}

		readonly Result result = m_Device.BindAccelerationStructureMemory(memoryBindingDescsImpl, memoryBindingDescNum);

		if (result == Result.SUCCESS)
		{
			for (uint32 i = 0; i < memoryBindingDescNum; i++)
			{
				MemoryVal memory = (MemoryVal)memoryBindingDescs[i].memory;
				memory.BindAccelerationStructure((AccelerationStructureVal)memoryBindingDescs[i].accelerationStructure);
			}
		}

		return result;
	}

	public void FreeMemory(Memory memory)
	{
		MemoryVal memoryVal = (MemoryVal)memory;

		if (memoryVal.HasBoundResources())
		{
			memoryVal.ReportBoundResources();
			REPORT_ERROR(GetLogger(), "Can't free Memory: some resources are still bound to the memory.");
			return;
		}

		m_Device.FreeMemory(NRI_GET_IMPL_REF!<Memory...>((MemoryVal)memory));
		Deallocate!(GetAllocator(), (MemoryVal)memory);
	}

	public FormatSupportBits GetFormatSupport(Format format)
	{
		return m_Device.GetFormatSupport(format);
	}

	public uint32 CalculateAllocationNumber(NRI.Helpers.ResourceGroupDesc resourceGroupDesc)
	{
		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.memoryLocation < MemoryLocation.MAX_NUM, 0,
			"Can't calculate the number of allocations: 'resourceGroupDesc.memoryLocation' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.bufferNum == 0 || resourceGroupDesc.buffers != null, 0,
			"Can't calculate the number of allocations: 'resourceGroupDesc.buffers' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textureNum == 0 || resourceGroupDesc.textures != null, 0,
			"Can't calculate the number of allocations: 'resourceGroupDesc.textures' is invalid.");

		Buffer* buffersImpl = STACK_ALLOC!<Buffer>(resourceGroupDesc.bufferNum);

		for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
		{
			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.buffers[i] != null, 0,
				"Can't calculate the number of allocations: 'resourceGroupDesc.buffers[{}]' is invalid.", i);

			BufferVal bufferVal = (BufferVal)resourceGroupDesc.buffers[i];
			buffersImpl[i] = (bufferVal.GetImpl());
		}

		Texture* texturesImpl = STACK_ALLOC!<Texture>(resourceGroupDesc.textureNum);

		for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
		{
			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textures[i] != null, 0,
				"Can't calculate the number of allocations: 'resourceGroupDesc.textures[{}]' is invalid.", i);

			TextureVal textureVal = (TextureVal)resourceGroupDesc.textures[i];
			texturesImpl[i] = (textureVal.GetImpl());
		}

		ResourceGroupDesc resourceGroupDescImpl = resourceGroupDesc;
		resourceGroupDescImpl.buffers = buffersImpl;
		resourceGroupDescImpl.textures = texturesImpl;

		return m_Device.CalculateAllocationNumber(resourceGroupDescImpl);
	}

	public Result AllocateAndBindMemory(NRI.Helpers.ResourceGroupDesc resourceGroupDesc, Memory* allocations)
	{
		RETURN_ON_FAILURE!(GetLogger(), allocations != null, Result.INVALID_ARGUMENT,
			"Can't allocate and bind memory: 'allocations' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.memoryLocation < MemoryLocation.MAX_NUM, Result.INVALID_ARGUMENT,
			"Can't allocate and bind memory: 'resourceGroupDesc.memoryLocation' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.bufferNum == 0 || resourceGroupDesc.buffers != null, Result.INVALID_ARGUMENT,
			"Can't allocate and bind memory: 'resourceGroupDesc.buffers' is invalid.");

		RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textureNum == 0 || resourceGroupDesc.textures != null, Result.INVALID_ARGUMENT,
			"Can't allocate and bind memory: 'resourceGroupDesc.textures' is invalid.");

		Buffer* buffersImpl = STACK_ALLOC!<Buffer>(resourceGroupDesc.bufferNum);

		for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
		{
			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.buffers[i] != null, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'resourceGroupDesc.buffers[{}]' is invalid.", i);

			BufferVal bufferVal = (BufferVal)resourceGroupDesc.buffers[i];
			buffersImpl[i] = (bufferVal.GetImpl());
		}

		Texture* texturesImpl = STACK_ALLOC!<Texture>(resourceGroupDesc.textureNum);

		for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
		{
			RETURN_ON_FAILURE!(GetLogger(), resourceGroupDesc.textures[i] != null, Result.INVALID_ARGUMENT,
				"Can't allocate and bind memory: 'resourceGroupDesc.textures[{}]' is invalid.", i);

			TextureVal textureVal = (TextureVal)resourceGroupDesc.textures[i];
			texturesImpl[i] = (textureVal.GetImpl());
		}

		readonly int allocationNum = CalculateAllocationNumber(resourceGroupDesc);

		ResourceGroupDesc resourceGroupDescImpl = resourceGroupDesc;
		resourceGroupDescImpl.buffers = buffersImpl;
		resourceGroupDescImpl.textures = texturesImpl;

		readonly Result result = m_Device.AllocateAndBindMemory(resourceGroupDescImpl, allocations);

		if (result == Result.SUCCESS)
		{
			for (uint32 i = 0; i < resourceGroupDesc.bufferNum; i++)
			{
				BufferVal bufferVal = (BufferVal)resourceGroupDesc.buffers[i];
				bufferVal.SetBoundToMemory();
			}

			for (uint32 i = 0; i < resourceGroupDesc.textureNum; i++)
			{
				TextureVal textureVal = (TextureVal)resourceGroupDesc.textures[i];
				textureVal.SetBoundToMemory();
			}

			for (uint32 i = 0; i < allocationNum; i++)
			{
				RETURN_ON_FAILURE!(GetLogger(), allocations[i] != null, Result.FAILURE, "Unexpected error: 'memoryImpl' is invalid");
				allocations[i] = (Memory)Allocate!<MemoryVal>(GetAllocator(), this, allocations[i], 0, resourceGroupDesc.memoryLocation);
			}
		}

		return result;
	}
}

public static
{
	public static Result CreateDeviceValidation(DeviceCreationDesc deviceCreationDesc, Device device, out Device outDeviceVal)
	{
		outDeviceVal = ?;

		uint32 physicalDeviceNum = 1;
		if (deviceCreationDesc.physicalDeviceGroup != null)
			physicalDeviceNum = deviceCreationDesc.physicalDeviceGroup.physicalDeviceGroupSize;

		DeviceVal deviceVal = Allocate!<DeviceVal>(device.GetAllocator(), device.GetLogger(), device.GetAllocator(), device, physicalDeviceNum);

		if (!deviceVal.Create())
		{
			Deallocate!(device.GetAllocator(), deviceVal);
			deviceVal = null;
			return .FAILURE;
		}

		outDeviceVal = deviceVal;
		return .SUCCESS;
	}
}