namespace NRI;

interface CommandBuffer
{
	public void SetDebugName(char8* name);

	public Result Begin(DescriptorPool descriptorPool, uint32 physicalDeviceIndex);
	public Result End();

	public void  SetPipeline(Pipeline pipeline);
	public void  SetPipelineLayout(PipelineLayout pipelineLayout);
	public void  SetDescriptorSets(uint32 baseSlot, uint32 descriptorSetNum, DescriptorSet* descriptorSets, uint32* dynamicConstantBufferOffsets);
	public void  SetConstants(uint32 pushConstantIndex, void* data, uint32 size);
	public void  SetDescriptorPool(DescriptorPool descriptorPool);
	public void  PipelineBarrier(TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency);

	public void  BeginRenderPass(FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag);
	public void  EndRenderPass();
	public void  SetViewports(Viewport* viewports, uint32 viewportNum);
	public void  SetScissors(Rect* rects, uint32 rectNum);
	public void  SetDepthBounds(float boundsMin, float boundsMax);
	public void  SetStencilReference(uint8 reference);
	public void  SetSamplePositions(SamplePosition* positions, uint32 positionNum);
	public void  ClearAttachments(ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum);
	public void  SetIndexBuffer(Buffer buffer, uint64 offset, IndexType indexType);
	public void  SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, Buffer* buffers, uint64* offsets);

	public void  Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance);
	public void  DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance);
	public void  DrawIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride);
	public void  DrawIndexedIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride);
	public void  Dispatch(uint32 x, uint32 y, uint32 z);
	public void  DispatchIndirect(Buffer buffer, uint64 offset);
	public void  BeginQuery(QueryPool queryPool, uint32 offset);
	public void  EndQuery(QueryPool queryPool, uint32 offset);
	public void  BeginAnnotation(char8* name);
	public void  EndAnnotation();

	public void  ClearStorageBuffer(ClearStorageBufferDesc clearDesc);
	public void  ClearStorageTexture(ClearStorageTextureDesc clearDesc);
	public void  CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size);
	public void  CopyTexture(Texture dstTexture, uint32 dstPhysicalDeviceIndex, TextureRegionDesc* dstRegionDesc, Texture srcTexture, uint32 srcPhysicalDeviceIndex, TextureRegionDesc* srcRegionDesc);
	public void  UploadBufferToTexture(Texture dstTexture, TextureRegionDesc dstRegionDesc, Buffer srcBuffer, TextureDataLayoutDesc srcDataLayoutDesc);
	public void  ReadbackTextureToBuffer(Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, Texture srcTexture, TextureRegionDesc srcRegionDesc);
	public void  CopyQueries(QueryPool queryPool, uint32 offset, uint32 num, Buffer dstBuffer, uint64 dstOffset);
	public void  ResetQueries(QueryPool queryPool, uint32 offset, uint32 num);

	public void  BuildTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset);
	public void  BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset);
	public void  UpdateTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset);
	public void  UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects,
		AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset);

	public void  CopyAccelerationStructure(AccelerationStructure dst, AccelerationStructure src, CopyMode copyMode);
	public void  WriteAccelerationStructureSize(AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, QueryPool queryPool, uint32 queryPoolOffset);

	public void  DispatchRays(DispatchRaysDesc dispatchRaysDesc);

	public void  DispatchMeshTasks(uint32 taskNum);

	public void* GetCommandBufferNativeObject();
}