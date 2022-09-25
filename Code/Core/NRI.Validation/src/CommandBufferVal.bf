using System.Collections;
using System;
namespace NRI.Validation;

enum ValidationCommandType : uint32
{
	NONE,
	BEGIN_QUERY,
	END_QUERY,
	RESET_QUERY,
	MAX_NUM
}

struct ValidationCommandUseQuery
{
	public ValidationCommandType type;
	public QueryPool queryPool;
	public uint32 queryPoolOffset;
}

struct ValidationCommandResetQuery
{
	public ValidationCommandType type;
	public QueryPool queryPool;
	public uint32 queryPoolOffset;
	public uint32 queryNum;
}

public static
{
	public static bool ValidateBufferTransitionBarrierDesc(DeviceVal device, uint32 i, BufferTransitionBarrierDesc bufferTransitionBarrierDesc)
	{
		RETURN_ON_FAILURE!(device.GetLogger(), bufferTransitionBarrierDesc.buffer != null, false,
			"Can't record pipeline barrier: 'transitionBarriers.buffers[{}].buffer' is invalid.", i);

		readonly BufferVal bufferVal = (BufferVal)bufferTransitionBarrierDesc.buffer;

		RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(bufferVal.GetDesc().usageMask, bufferTransitionBarrierDesc.prevAccess), false,
			"Can't record pipeline barrier: 'transitionBarriers.buffers[{}].prevAccess' is not supported by the usage mask of the buffer ('{}').",
			i, bufferVal.GetDebugName());

		RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(bufferVal.GetDesc().usageMask, bufferTransitionBarrierDesc.nextAccess), false,
			"Can't record pipeline barrier: 'transitionBarriers.buffers[{}].nextAccess' is not supported by the usage mask of the buffer ('{}').",
			i, bufferVal.GetDebugName());

		return true;
	}

	public static bool ValidateTextureTransitionBarrierDesc(DeviceVal device, uint32 i, TextureTransitionBarrierDesc textureTransitionBarrierDesc)
	{
		RETURN_ON_FAILURE!(device.GetLogger(), textureTransitionBarrierDesc.texture != null, false,
			"Can't record pipeline barrier: 'transitionBarriers.textures[{}].texture' is invalid.", i);

		readonly TextureVal textureVal = (TextureVal)textureTransitionBarrierDesc.texture;

		RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.prevAccess), false,
			"Can't record pipeline barrier: 'transitionBarriers.textures[{}].prevAccess' is not supported by the usage mask of the texture ('{}').",
			i, textureVal.GetDebugName());

		RETURN_ON_FAILURE!(device.GetLogger(), IsAccessMaskSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.nextAccess), false,
			"Can't record pipeline barrier: 'transitionBarriers.textures[{}].nextAccess' is not supported by the usage mask of the texture ('{}').",
			i, textureVal.GetDebugName());

		RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.prevLayout), false,
			"Can't record pipeline barrier: 'transitionBarriers.textures[{}].prevLayout' is not supported by the usage mask of the texture ('{}').",
			i, textureVal.GetDebugName());

		RETURN_ON_FAILURE!(device.GetLogger(), IsTextureLayoutSupported(textureVal.GetDesc().usageMask, textureTransitionBarrierDesc.nextLayout), false,
			"Can't record pipeline barrier: 'transitionBarriers.textures[{}].nextLayout' is not supported by the usage mask of the texture ('{}').",
			i, textureVal.GetDebugName());

		return true;
	}
}

class CommandBufferVal : CommandBuffer,  DeviceObjectVal<CommandBuffer>
{
	private mut Command AllocateValidationCommand<Command>()
	{
		readonly int commandSize = sizeof(Command);
		readonly int newSize = m_ValidationCommands.Count + commandSize;
		readonly int capacity = m_ValidationCommands.Capacity;

		if (newSize > capacity)
			m_ValidationCommands.Reserve(Math.Max(capacity + (capacity >> 1), newSize));

		readonly int offset = m_ValidationCommands.Count;
		m_ValidationCommands.Resize(newSize);

		return mut *(Command*)(m_ValidationCommands.Ptr + offset);
	}

	private List<uint8> m_ValidationCommands;
	private bool m_IsRecordingStarted = false;
	private bool m_IsWrapped = false;
	private FrameBuffer m_FrameBuffer = null;
	private int32 m_AnnotationStack = 0;

	public this(DeviceVal device, CommandBuffer commandBuffer, bool isWrapped) : base(device, commandBuffer)
	{
		m_ValidationCommands = Allocate!<List<uint8>>(m_Device.GetAllocator());

		m_IsWrapped = isWrapped;
		m_IsRecordingStarted = isWrapped;
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_ValidationCommands);
	}

	public List<uint8> GetValidationCommands()
		{ return m_ValidationCommands; }

	public void* GetCommandBufferNativeObject()
		{ return m_ImplObject.GetCommandBufferNativeObject(); }

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}

	public Result Begin(DescriptorPool descriptorPool, uint32 physicalDeviceIndex)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), !m_IsRecordingStarted, Result.FAILURE,
			"Can't begin recording of CommandBuffer: the command buffer is already in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), physicalDeviceIndex < m_Device.GetPhysicalDeviceNum(), Result.FAILURE,
			"Can't begin recording of CommandBuffer: 'physicalDeviceIndex' is invalid.");

		DescriptorPool descriptorPoolImpl = null;
		if (descriptorPool != null)
			descriptorPoolImpl = NRI_GET_IMPL_PTR!<DescriptorPool...>((DescriptorPoolVal)descriptorPool);

		Result result = m_ImplObject.Begin(descriptorPoolImpl, physicalDeviceIndex);
		if (result == Result.SUCCESS)
			m_IsRecordingStarted = true;

		m_ValidationCommands.Clear();

		return result;
	}

	public Result End()
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, Result.FAILURE,
			"Can't end command buffer: the command buffer must be in the recording state.");

		if (m_AnnotationStack > 0)
			REPORT_ERROR(m_Device.GetLogger(), "BeginAnnotation() is called more times than EndAnnotation()");
		else if (m_AnnotationStack < 0)
			REPORT_ERROR(m_Device.GetLogger(), "EndAnnotation() is called more times than BeginAnnotation()");

		Result result = m_ImplObject.End();

		if (result == Result.SUCCESS)
		{
			m_IsRecordingStarted = m_IsWrapped;
			m_FrameBuffer = null;
		}

		return result;
	}

	public void  SetPipeline(Pipeline pipeline)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set pipeline: the command buffer must be in the recording state.");

		Pipeline pipelineImpl = NRI_GET_IMPL_REF!<Pipeline...>((PipelineVal)pipeline);

		m_ImplObject.SetPipeline(pipelineImpl);
	}

	public void  SetPipelineLayout(PipelineLayout pipelineLayout)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set pipeline layout: the command buffer must be in the recording state.");

		PipelineLayout pipelineLayoutImpl = NRI_GET_IMPL_REF!<PipelineLayout...>((PipelineLayoutVal)pipelineLayout);

		m_ImplObject.SetPipelineLayout(pipelineLayoutImpl);
	}

	public void  SetDescriptorSets(uint32 baseIndex, uint32 descriptorSetNum, DescriptorSet* descriptorSets, uint32* dynamicConstantBufferOffsets)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set descriptor sets: the command buffer must be in the recording state.");

		DescriptorSet* descriptorSetsImpl = STACK_ALLOC!<DescriptorSet>(descriptorSetNum);
		for (uint32 i = 0; i < descriptorSetNum; i++)
			descriptorSetsImpl[i] = NRI_GET_IMPL_PTR!<DescriptorSet...>((DescriptorSetVal)descriptorSets[i]);

		m_ImplObject.SetDescriptorSets(baseIndex, descriptorSetNum, descriptorSetsImpl, dynamicConstantBufferOffsets);
	}

	public void  SetConstants(uint32 pushConstantIndex, void* data, uint32 size)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set constants: the command buffer must be in the recording state.");

		m_ImplObject.SetConstants(pushConstantIndex, data, size);
	}
	public void  SetDescriptorPool(DescriptorPool descriptorPool)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set descriptor pool: the command buffer must be in the recording state.");

		DescriptorPool descriptorPoolImpl = NRI_GET_IMPL_REF!<DescriptorPool...>((DescriptorPoolVal)descriptorPool);

		m_ImplObject.SetDescriptorPool(descriptorPoolImpl);
	}

	public void  PipelineBarrier(TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency)
	{
		var transitionBarriers;
		var aliasingBarriers;
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record pipeline barrier: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't record pipeline barrier: this operation is allowed only outside render pass.");

		TransitionBarrierDesc transitionBarrierImpl;
		if (transitionBarriers != null)
		{
			transitionBarrierImpl = *transitionBarriers;

			for (uint32 i = 0; i < transitionBarriers.bufferNum; i++)
			{
				if (!ValidateBufferTransitionBarrierDesc(m_Device, i, transitionBarriers.buffers[i]))
					return;
			}

			for (uint32 i = 0; i < transitionBarriers.textureNum; i++)
			{
				if (!ValidateTextureTransitionBarrierDesc(m_Device, i, transitionBarriers.textures[i]))
					return;
			}

			transitionBarrierImpl.buffers = STACK_ALLOC!<BufferTransitionBarrierDesc>(transitionBarriers.bufferNum);
			Internal.MemCpy((void*)transitionBarrierImpl.buffers, transitionBarriers.buffers, sizeof(BufferTransitionBarrierDesc) * transitionBarriers.bufferNum);
			for (uint32 i = 0; i < transitionBarrierImpl.bufferNum; i++)
				((BufferTransitionBarrierDesc*)transitionBarrierImpl.buffers)[i].buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)transitionBarriers.buffers[i].buffer);

			transitionBarrierImpl.textures = STACK_ALLOC!<TextureTransitionBarrierDesc>(transitionBarriers.textureNum);
			Internal.MemCpy((void*)transitionBarrierImpl.textures, transitionBarriers.textures, sizeof(TextureTransitionBarrierDesc) * transitionBarriers.textureNum);
			for (uint32 i = 0; i < transitionBarrierImpl.textureNum; i++)
				((TextureTransitionBarrierDesc*)transitionBarrierImpl.textures)[i].texture = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)transitionBarriers.textures[i].texture);

			transitionBarriers = &transitionBarrierImpl;
		}

		AliasingBarrierDesc aliasingBarriersImpl;
		if (aliasingBarriers != null)
		{
			aliasingBarriersImpl = *aliasingBarriers;

			aliasingBarriersImpl.buffers = STACK_ALLOC!<BufferAliasingBarrierDesc>(aliasingBarriers.bufferNum);
			Internal.MemCpy((void*)aliasingBarriersImpl.buffers, aliasingBarriers.buffers, sizeof(BufferAliasingBarrierDesc) * aliasingBarriers.bufferNum);
			for (uint32 i = 0; i < aliasingBarriersImpl.bufferNum; i++)
			{
				((BufferAliasingBarrierDesc*)aliasingBarriersImpl.buffers)[i].before = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)aliasingBarriers.buffers[i].before);
				((BufferAliasingBarrierDesc*)aliasingBarriersImpl.buffers)[i].after = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)aliasingBarriers.buffers[i].after);
			}

			aliasingBarriersImpl.textures = STACK_ALLOC!<TextureAliasingBarrierDesc>(aliasingBarriers.textureNum);
			Internal.MemCpy((void*)aliasingBarriersImpl.textures, aliasingBarriers.textures, sizeof(TextureAliasingBarrierDesc) * aliasingBarriers.textureNum);
			for (uint32 i = 0; i < aliasingBarriersImpl.textureNum; i++)
			{
				((TextureAliasingBarrierDesc*)aliasingBarriersImpl.textures)[i].before = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)aliasingBarriers.textures[i].before);
				((TextureAliasingBarrierDesc*)aliasingBarriersImpl.textures)[i].after = NRI_GET_IMPL_PTR!<Texture...>((TextureVal)aliasingBarriers.textures[i].after);
			}

			aliasingBarriers = &aliasingBarriersImpl;
		}

		m_ImplObject.PipelineBarrier(transitionBarriers, aliasingBarriers, dependency);
	}

	public void  BeginRenderPass(FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't begin render pass: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't begin render pass: render pass already started.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), renderPassBeginFlag < RenderPassBeginFlag.MAX_NUM, void(),
			"Can't begin render pass: 'renderPassBeginFlag' is invalid.");

		m_FrameBuffer = frameBuffer;

		FrameBuffer frameBufferImpl = NRI_GET_IMPL_REF!<FrameBuffer...>((FrameBufferVal)frameBuffer);

		m_ImplObject.BeginRenderPass(frameBufferImpl, renderPassBeginFlag);
	}

	public void  EndRenderPass()
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't end render pass: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't end render pass: no render pass.");

		m_FrameBuffer = null;

		m_ImplObject.EndRenderPass();
	}

	public void  SetViewports(Viewport* viewports, uint32 viewportNum)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set viewports: the command buffer must be in the recording state.");

		if (viewportNum == 0)
			return;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), viewports != null, void(),
			"Can't set viewports: 'viewports' is invalid.");

		m_ImplObject.SetViewports(viewports, viewportNum);
	}

	public void  SetScissors(Rect* rects, uint32 rectNum)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set scissors: the command buffer must be in the recording state.");

		if (rectNum == 0)
			return;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), rects != null, void(),
			"Can't set scissor rects: 'rects' is invalid.");

		m_ImplObject.SetScissors(rects, rectNum);
	}

	public void  SetDepthBounds(float boundsMin, float boundsMax)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set depth bounds: the command buffer must be in the recording state.");

		m_ImplObject.SetDepthBounds(boundsMin, boundsMax);
	}

	public void  SetStencilReference(uint8 reference)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set stencil reference: the command buffer must be in the recording state.");

		m_ImplObject.SetStencilReference(reference);
	}

	public void  SetSamplePositions(SamplePosition* positions, uint32 positionNum)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set sample positions: the command buffer must be in the recording state.");

		m_ImplObject.SetSamplePositions(positions, positionNum);
	}

	public void  ClearAttachments(ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't clear attachments: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't clear attachments: no FrameBuffer bound.");

		m_ImplObject.ClearAttachments(clearDescs, clearDescNum, rects, rectNum);
	}

	public void  SetIndexBuffer(Buffer buffer, uint64 offset, IndexType indexType)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set index buffers: the command buffer must be in the recording state.");

		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.SetIndexBuffer(bufferImpl, offset, indexType);
	}

	public void  SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, Buffer* buffers, uint64* offsets)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't set vertex buffers: the command buffer must be in the recording state.");

		Buffer* buffersImpl = STACK_ALLOC!<Buffer>(bufferNum);
		for (uint32 i = 0; i < bufferNum; i++)
			buffersImpl[i] = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)buffers[i]);

		m_ImplObject.SetVertexBuffers(baseSlot, bufferNum, buffersImpl, offsets);
	}

	public void  Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record draw call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't record draw call: this operation is allowed only inside render pass.");

		m_ImplObject.Draw(vertexNum, instanceNum, baseVertex, baseInstance);
	}

	public void  DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record draw call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't record draw call: this operation is allowed only inside render pass.");

		m_ImplObject.DrawIndexed(indexNum, instanceNum, baseIndex, baseVertex, baseInstance);
	}

	public void  DrawIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record draw call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't record draw call: this operation is allowed only inside render pass.");

		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.DrawIndirect(bufferImpl, offset, drawNum, stride);
	}

	public void  DrawIndexedIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record draw call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer != null, void(),
			"Can't record draw call: this operation is allowed only inside render pass.");

		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.DrawIndexedIndirect(bufferImpl, offset, drawNum, stride);
	}

	public void  Dispatch(uint32 x, uint32 y, uint32 z)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record dispatch call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't record dispatch call: this operation is allowed only outside render pass.");

		m_ImplObject.Dispatch(x, y, z);
	}

	public void  DispatchIndirect(Buffer buffer, uint64 offset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record dispatch call: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't record dispatch call: this operation is allowed only outside render pass.");

		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.DispatchIndirect(bufferImpl, offset);
	}

	public void  BeginQuery(QueryPool queryPool, uint32 offset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't begin query: the command buffer must be in the recording state.");

		readonly QueryPoolVal queryPoolVal = (QueryPoolVal)queryPool;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), queryPoolVal.GetQueryType() != QueryType.TIMESTAMP, void(),
			"Can't begin query: BeginQuery() is not supported for timestamp queries.");

		if (!queryPoolVal.IsImported())
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), offset < queryPoolVal.GetQueryNum(), void(),
				"Can't begin query: the offset ('{}') is out of range.", offset);

			ref ValidationCommandUseQuery validationCommand = ref AllocateValidationCommand<ValidationCommandUseQuery>();
			validationCommand.type = ValidationCommandType.BEGIN_QUERY;
			validationCommand.queryPool = (QueryPool)queryPool;
			validationCommand.queryPoolOffset = offset;
		}

		QueryPool queryPoolImpl = NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool);

		m_ImplObject.BeginQuery(queryPoolImpl, offset);
	}

	public void  EndQuery(QueryPool queryPool, uint32 offset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't end query: the command buffer must be in the recording state.");

		readonly QueryPoolVal queryPoolVal = (QueryPoolVal)queryPool;

		if (!queryPoolVal.IsImported())
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), offset < queryPoolVal.GetQueryNum(), void(),
				"Can't end query: the offset ('{}') is out of range.", offset);

			ref ValidationCommandUseQuery validationCommand = ref AllocateValidationCommand<ValidationCommandUseQuery>();
			validationCommand.type = ValidationCommandType.END_QUERY;
			validationCommand.queryPool = queryPool;
			validationCommand.queryPoolOffset = offset;
		}

		QueryPool queryPoolImpl = NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool);

		m_ImplObject.EndQuery(queryPoolImpl, offset);
	}

	public void  BeginAnnotation(char8* name)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy queries: the command buffer must be in the recording state.");

		m_AnnotationStack++;
		m_ImplObject.BeginAnnotation(name);
	}

	public void  EndAnnotation()
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy queries: the command buffer must be in the recording state.");

		m_ImplObject.EndAnnotation();
		m_AnnotationStack--;
	}

	public void  ClearStorageBuffer(ClearStorageBufferDesc clearDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't clear storage buffer: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't clear storage buffer: this operation is not allowed in render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), clearDesc.storageBuffer != null, void(),
			"Can't clear storage buffer: 'clearDesc.storageBuffer' is invalid.");

		var clearDescImpl = clearDesc;
		clearDescImpl.storageBuffer = NRI_GET_IMPL_PTR!<Descriptor...>((DescriptorVal)clearDesc.storageBuffer);

		m_ImplObject.ClearStorageBuffer(clearDescImpl);
	}

	public void  ClearStorageTexture(ClearStorageTextureDesc clearDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't clear storage texture: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't clear storage texture: this operation is not allowed in render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), clearDesc.storageTexture != null, void(),
			"Can't clear storage texture: 'clearDesc.storageTexture' is invalid.");

		var clearDescImpl = clearDesc;
		clearDescImpl.storageTexture = NRI_GET_IMPL_PTR!<Descriptor...>((DescriptorVal)clearDesc.storageTexture);

		m_ImplObject.ClearStorageTexture(clearDescImpl);
	}

	public void  CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy buffer: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't copy buffer: this operation is allowed only outside render pass.");

		if (size == WHOLE_SIZE)
		{
			readonly ref BufferDesc dstDesc = ref ((BufferVal)dstBuffer).GetDesc();
			readonly ref BufferDesc srcDesc = ref ((BufferVal)srcBuffer).GetDesc();

			if (dstDesc.size != srcDesc.size)
			{
				REPORT_WARNING(m_Device.GetLogger(), "WHOLE_SIZE is used but 'dstBuffer' and 'srcBuffer' have diffenet sizes. 'srcDesc.size' bytes will be copied to the destination.");
				return;
			}
		}

		Buffer dstBufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)dstBuffer);
		Buffer srcBufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)srcBuffer);

		m_ImplObject.CopyBuffer(dstBufferImpl, dstPhysicalDeviceIndex, dstOffset, srcBufferImpl, srcPhysicalDeviceIndex,
			srcOffset, size);
	}

	public void  CopyTexture(Texture dstTexture, uint32 dstPhysicalDeviceIndex, TextureRegionDesc* dstRegionDesc, Texture srcTexture, uint32 srcPhysicalDeviceIndex, TextureRegionDesc* srcRegionDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy texture: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't copy texture: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), (dstRegionDesc == null && srcRegionDesc == null) || (dstRegionDesc != null && srcRegionDesc != null), void(),
			"Can't copy texture: 'dstRegionDesc' and 'srcRegionDesc' must be valid pointers or be both NULL.");

		Texture dstTextureImpl = NRI_GET_IMPL_REF!<Texture...>((TextureVal)dstTexture);
		Texture srcTextureImpl = NRI_GET_IMPL_REF!<Texture...>((TextureVal)srcTexture);

		m_ImplObject.CopyTexture(dstTextureImpl, dstPhysicalDeviceIndex, dstRegionDesc, srcTextureImpl, srcPhysicalDeviceIndex,
			srcRegionDesc);
	}

	public void  UploadBufferToTexture(Texture dstTexture, TextureRegionDesc dstRegionDesc, Buffer srcBuffer, TextureDataLayoutDesc srcDataLayoutDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't upload buffer to texture: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't upload buffer to texture: this operation is allowed only outside render pass.");

		Texture dstTextureImpl = NRI_GET_IMPL_REF!<Texture...>((TextureVal)dstTexture);
		Buffer srcBufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)srcBuffer);

		m_ImplObject.UploadBufferToTexture(dstTextureImpl, dstRegionDesc, srcBufferImpl, srcDataLayoutDesc);
	}

	public void  ReadbackTextureToBuffer(Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, Texture srcTexture, TextureRegionDesc srcRegionDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't readback texture to buffer: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't readback texture to buffer: this operation is allowed only outside render pass.");

		Buffer dstBufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)dstBuffer);
		Texture srcTextureImpl = NRI_GET_IMPL_REF!<Texture...>((TextureVal)srcTexture);

		m_ImplObject.ReadbackTextureToBuffer(dstBufferImpl, ref dstDataLayoutDesc, srcTextureImpl, srcRegionDesc);
	}

	public void  CopyQueries(QueryPool queryPool, uint32 offset, uint32 num, Buffer dstBuffer, uint64 dstOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy queries: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't copy queries: this operation is allowed only outside render pass.");

		readonly QueryPoolVal queryPoolVal = (QueryPoolVal)queryPool;

		if (!queryPoolVal.IsImported())
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), offset + num <= queryPoolVal.GetQueryNum(), void(),
				"Can't copy queries: offset + num ('{}') is out of range.", offset + num);
		}

		QueryPool queryPoolImpl = NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool);
		Buffer dstBufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)dstBuffer);

		m_ImplObject.CopyQueries(queryPoolImpl, offset, num, dstBufferImpl, dstOffset);
	}

	public void  ResetQueries(QueryPool queryPool, uint32 offset, uint32 num)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't reset queries: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't reset queries: this operation is allowed only outside render pass.");

		readonly QueryPoolVal queryPoolVal = (QueryPoolVal)queryPool;

		if (!queryPoolVal.IsImported())
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), offset + num <= queryPoolVal.GetQueryNum(), void(),
				"Can't reset queries: offset + num ('{}') is out of range.", offset + num);

			ref ValidationCommandResetQuery validationCommand = ref AllocateValidationCommand<ValidationCommandResetQuery>();
			validationCommand.type = ValidationCommandType.RESET_QUERY;
			validationCommand.queryPool = queryPool;
			validationCommand.queryPoolOffset = offset;
			validationCommand.queryNum = num;
		}

		QueryPool queryPoolImpl = NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool);

		m_ImplObject.ResetQueries(queryPoolImpl, offset, num);
	}

	public void  BuildTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't build TLAS: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't build TLAS: this operation is allowed only outside render pass.");

		BufferVal bufferVal = (BufferVal)buffer;
		BufferVal scratchVal = (BufferVal)scratch;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), bufferOffset < bufferVal.GetDesc().size, void(),
			"Can't update TLAS: 'bufferOffset' is out of bounds.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
			"Can't update TLAS: 'scratchOffset' is out of bounds.");

		AccelerationStructure dstImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)dst);
		Buffer scratchImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)scratch);
		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.BuildTopLevelAccelerationStructure(instanceNum, bufferImpl, bufferOffset, flags, dstImpl, scratchImpl, scratchOffset);
	}

	public void  BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't build BLAS: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't build BLAS: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), geometryObjects != null, void(),
			"Can't update BLAS: 'geometryObjects' is invalid.");

		BufferVal scratchVal = (BufferVal)scratch;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
			"Can't build BLAS: 'scratchOffset' is out of bounds.");

		AccelerationStructure dstImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)dst);
		Buffer scratchImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)scratch);

		List<GeometryObject> objectImplArray = Allocate!<List<GeometryObject>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), objectImplArray); }
		objectImplArray.Resize(geometryObjectNum);
		ConvertGeometryObjectsVal(objectImplArray.Ptr, geometryObjects, geometryObjectNum);

		m_ImplObject.BuildBottomLevelAccelerationStructure(geometryObjectNum, objectImplArray.Ptr, flags, dstImpl, scratchImpl, scratchOffset);
	}

	public void  UpdateTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't update TLAS: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't update TLAS: this operation is allowed only outside render pass.");

		BufferVal bufferVal = (BufferVal)buffer;
		BufferVal scratchVal = (BufferVal)scratch;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), bufferOffset < bufferVal.GetDesc().size, void(),
			"Can't update TLAS: 'bufferOffset' is out of bounds.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
			"Can't update TLAS: 'scratchOffset' is out of bounds.");

		AccelerationStructure dstImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)dst);
		AccelerationStructure srcImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)src);
		Buffer scratchImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)scratch);
		Buffer bufferImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)buffer);

		m_ImplObject.UpdateTopLevelAccelerationStructure(instanceNum, bufferImpl, bufferOffset, flags, dstImpl, srcImpl, scratchImpl, scratchOffset);
	}

	public void  UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't update BLAS: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't update BLAS: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), geometryObjects != null, void(),
			"Can't update BLAS: 'geometryObjects' is invalid.");

		BufferVal scratchVal = (BufferVal)scratch;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), scratchOffset < scratchVal.GetDesc().size, void(),
			"Can't update BLAS: 'scratchOffset' is out of bounds.");

		AccelerationStructure dstImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)dst);
		AccelerationStructure srcImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)src);
		Buffer scratchImpl = NRI_GET_IMPL_REF!<Buffer...>((BufferVal)scratch);

		List<GeometryObject> objectImplArray = Allocate!<List<GeometryObject>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), objectImplArray); }
		objectImplArray.Resize(geometryObjectNum);
		ConvertGeometryObjectsVal(objectImplArray.Ptr, geometryObjects, geometryObjectNum);

		m_ImplObject.UpdateBottomLevelAccelerationStructure(geometryObjectNum, objectImplArray.Ptr, flags, dstImpl, srcImpl, scratchImpl, scratchOffset);
	}

	public void  CopyAccelerationStructure(AccelerationStructure dst, AccelerationStructure src, CopyMode copyMode)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't copy AS: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't copy AS: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), copyMode < CopyMode.MAX_NUM, void(),
			"Can't copy AS: 'copyMode' is invalid.");

		AccelerationStructure dstImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)dst);
		AccelerationStructure srcImpl = NRI_GET_IMPL_REF!<AccelerationStructure...>((AccelerationStructureVal)src);

		m_ImplObject.CopyAccelerationStructure(dstImpl, srcImpl, copyMode);
	}

	public void  WriteAccelerationStructureSize(AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, QueryPool queryPool, uint32 queryOffset)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't write AS size: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't write AS size: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), accelerationStructures != null, void(),
			"Can't write AS size: 'accelerationStructures' is invalid.");

		AccelerationStructure* accelerationStructureArray = STACK_ALLOC!<AccelerationStructure>(accelerationStructureNum);
		for (uint32 i = 0; i < accelerationStructureNum; i++)
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), accelerationStructures[i] != null, void(),
				"Can't write AS size: 'accelerationStructures[{}]' is invalid.", i);

			accelerationStructureArray[i] = NRI_GET_IMPL_PTR!<AccelerationStructure...>((AccelerationStructureVal)accelerationStructures[i]);
		}

		QueryPool queryPoolImpl = NRI_GET_IMPL_REF!<QueryPool...>((QueryPoolVal)queryPool);

		m_ImplObject.WriteAccelerationStructureSize(accelerationStructures, accelerationStructureNum, queryPoolImpl, queryOffset);
	}

	public void  DispatchRays(DispatchRaysDesc dispatchRaysDesc)
	{
		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_IsRecordingStarted, void(),
			"Can't record ray tracing dispatch: the command buffer must be in the recording state.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), m_FrameBuffer == null, void(),
			"Can't record ray tracing dispatch: this operation is allowed only outside render pass.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.raygenShader.buffer != null, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.buffer' is invalid.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.raygenShader.size != 0, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.size' is 0.");

		readonly uint64 SBTAlignment = m_Device.GetDesc().rayTracingShaderTableAligment;

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.raygenShader.offset % SBTAlignment == 0, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.raygenShader.offset' is misaligned.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.missShaders.offset % SBTAlignment == 0, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.missShaders.offset' is misaligned.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.hitShaderGroups.offset % SBTAlignment == 0, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.hitShaderGroups.offset' is misaligned.");

		RETURN_ON_FAILURE!(m_Device.GetLogger(), dispatchRaysDesc.callableShaders.offset % SBTAlignment == 0, void(),
			"Can't record ray tracing dispatch: 'dispatchRaysDesc.callableShaders.offset' is misaligned.");

		var dispatchRaysDescImpl = dispatchRaysDesc;
		dispatchRaysDescImpl.raygenShader.buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)dispatchRaysDesc.raygenShader.buffer);
		dispatchRaysDescImpl.missShaders.buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)dispatchRaysDesc.missShaders.buffer);
		dispatchRaysDescImpl.hitShaderGroups.buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)dispatchRaysDesc.hitShaderGroups.buffer);
		dispatchRaysDescImpl.callableShaders.buffer = NRI_GET_IMPL_PTR!<Buffer...>((BufferVal)dispatchRaysDesc.callableShaders.buffer);

		m_ImplObject.DispatchRays(dispatchRaysDescImpl);
	}

	public void  DispatchMeshTasks(uint32 taskNum)
	{
		readonly uint32 meshTaskMaxNum = m_Device.GetDesc().meshTaskMaxNum;

		if (taskNum > meshTaskMaxNum)
		{
			REPORT_ERROR(m_Device.GetLogger(),
				"Can't dispatch the specified number of mesh tasks: the number exceeds the maximum number of mesh tasks.");
		}

		m_ImplObject.DispatchMeshTasks(Math.Min(taskNum, meshTaskMaxNum));
	}

	public void Destroy()
	{
		m_Device.DestroyCommandBuffer(m_ImplObject);
		Deallocate!(m_Device.GetAllocator(), this);
	}
}