using Win32.Graphics.Direct3D12;
using NRI.D3DCommon;
using Win32.Graphics.Direct3D;
using Win32.Foundation;
using System;
using System.Collections;
using Win32;
namespace NRI.D3D12;

class CommandBufferD3D12 : CommandBuffer
{
	private static void AddResourceBarrier(ID3D12Resource* resource, AccessBits before, AccessBits after, ref D3D12_RESOURCE_BARRIER resourceBarrier, uint32 subresource)
	{
		D3D12_RESOURCE_STATES resourceStateBefore = GetResourceStates(before);
		D3D12_RESOURCE_STATES resourceStateAfter = GetResourceStates(after);

		if (resourceStateBefore == resourceStateAfter && resourceStateBefore == .D3D12_RESOURCE_STATE_UNORDERED_ACCESS)
		{
			resourceBarrier.Type = .D3D12_RESOURCE_BARRIER_TYPE_UAV;
			resourceBarrier.UAV.pResource = resource;
		}
		else
		{
			resourceBarrier.Type = .D3D12_RESOURCE_BARRIER_TYPE_TRANSITION;
			resourceBarrier.Transition.pResource = resource;
			resourceBarrier.Transition.StateBefore = resourceStateBefore;
			resourceBarrier.Transition.StateAfter = resourceStateAfter;
			resourceBarrier.Transition.Subresource = subresource;
		}
	}

	private DeviceD3D12 m_Device;
	private ComPtr<ID3D12CommandAllocator> m_CommandAllocator;
	private ComPtr<ID3D12GraphicsCommandList> m_GraphicsCommandList;
	private ComPtr<ID3D12GraphicsCommandList1> m_GraphicsCommandList1;
//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
	private ComPtr<ID3D12GraphicsCommandList4> m_GraphicsCommandList4;
//#endif
//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
	private ComPtr<ID3D12GraphicsCommandList6> m_GraphicsCommandList6;
//#endif
	private PipelineLayoutD3D12 m_PipelineLayout = null;
	private bool m_IsGraphicsPipelineLayout = false;
	private PipelineD3D12 m_Pipeline = null;
	private FrameBufferD3D12 m_FrameBuffer = null;
	private D3D_PRIMITIVE_TOPOLOGY m_PrimitiveTopology = .D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;
	private DescriptorSetD3D12[64] m_DescriptorSets = .();


	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_GraphicsCommandList6.Dispose();
		m_GraphicsCommandList4.Dispose();
		m_GraphicsCommandList1.Dispose();
		m_GraphicsCommandList.Dispose();
		m_CommandAllocator.Dispose();
	}

	public static implicit operator ID3D12GraphicsCommandList*(Self self) => self.m_GraphicsCommandList.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(D3D12_COMMAND_LIST_TYPE commandListType, ID3D12CommandAllocator* commandAllocator)
	{
		ComPtr<ID3D12GraphicsCommandList> graphicsCommandList = null;
		defer graphicsCommandList.Dispose();
		HRESULT hr = ((ID3D12Device*)m_Device).CreateCommandList(NRI_TEMP_NODE_MASK, commandListType, commandAllocator, null, ID3D12GraphicsCommandList.IID, (void**)(&graphicsCommandList));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device.CreateCommandList() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		m_CommandAllocator = commandAllocator;
		m_GraphicsCommandList = graphicsCommandList.Move();
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList1.IID, (void**)(&m_GraphicsCommandList1));

	//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList4.IID, (void**)(&m_GraphicsCommandList4));
	//#endif

	//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList6.IID, (void**)(&m_GraphicsCommandList6));
	//#endif

		hr = m_GraphicsCommandList->Close();
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12GraphicsCommandList.Close() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	public Result Create(CommandBufferD3D12Desc commandBufferDesc)
	{
		m_CommandAllocator = (ID3D12CommandAllocator*)commandBufferDesc.d3d12CommandAllocator;
		m_GraphicsCommandList = (ID3D12GraphicsCommandList*)commandBufferDesc.d3d12CommandList;
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList1.IID, (void**)(&m_GraphicsCommandList1));

	//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList4.IID, (void**)(&m_GraphicsCommandList4));
	//#endif

	//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
		m_GraphicsCommandList->QueryInterface(ID3D12GraphicsCommandList6.IID, (void**)(&m_GraphicsCommandList6));
	//#endif

		return Result.SUCCESS;
	}
	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_GraphicsCommandList, scope String(name));
	}

	public void* GetCommandBufferNativeObject(){
		return (CommandBufferD3D12)this;
	}

	public Result Begin(DescriptorPool descriptorPool, uint32 physicalDeviceIndex)
	{
		HRESULT hr = m_GraphicsCommandList->Reset(m_CommandAllocator, null);
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12GraphicsCommandList.Reset() failed, return code {}.", hr);
			return Result.FAILURE;
		}

		if (descriptorPool != null)
			SetDescriptorPool(descriptorPool);

		m_PipelineLayout = null;
		m_IsGraphicsPipelineLayout = false;
		m_Pipeline = null;
		m_FrameBuffer = null;
		m_PrimitiveTopology = .D3D_PRIMITIVE_TOPOLOGY_UNDEFINED;

		return Result.SUCCESS;
	}

	public Result End()
	{
		HRESULT hr = m_GraphicsCommandList->Close();
		if (FAILED(hr))
			return Result.FAILURE;

		return Result.SUCCESS;
	}

	public void SetPipeline(Pipeline pipeline)
	{
		PipelineD3D12 pipelineD3D12 = (PipelineD3D12)pipeline;

		if (m_Pipeline == pipelineD3D12)
			return;

		pipelineD3D12.Bind(m_GraphicsCommandList, ref m_PrimitiveTopology);

		m_Pipeline = pipelineD3D12;
	}

	public void SetPipelineLayout(PipelineLayout pipelineLayout)
	{
		readonly PipelineLayoutD3D12 pipelineLayoutD3D12 = (PipelineLayoutD3D12)pipelineLayout;

		if (m_PipelineLayout == pipelineLayoutD3D12)
			return;

		m_PipelineLayout = pipelineLayoutD3D12;
		m_IsGraphicsPipelineLayout = pipelineLayoutD3D12.IsGraphicsPipelineLayout();

		if (m_IsGraphicsPipelineLayout)
			m_GraphicsCommandList->SetGraphicsRootSignature(pipelineLayoutD3D12);
		else
			m_GraphicsCommandList->SetComputeRootSignature(pipelineLayoutD3D12);
	}

	public void SetDescriptorSets(uint32 baseIndex, uint32 setNum, DescriptorSet* descriptorSets, uint32* offsets)
	{
		m_PipelineLayout.SetDescriptorSets(ref *m_GraphicsCommandList.Get(), m_IsGraphicsPipelineLayout, baseIndex, setNum, descriptorSets, offsets);

		for (uint32 i = 0; i < setNum; i++)
			m_DescriptorSets[baseIndex + i] = (DescriptorSetD3D12)descriptorSets[i];
	}

	public void SetConstants(uint32 pushConstantRangeIndex, void* data, uint32 size)
	{
		uint32 rootParameterIndex = m_PipelineLayout.GetPushConstantsRootOffset(pushConstantRangeIndex);
		uint32 constantNum = size / 4;

		if (m_IsGraphicsPipelineLayout)
			m_GraphicsCommandList->SetGraphicsRoot32BitConstants(rootParameterIndex, constantNum, data, 0);
		else
			m_GraphicsCommandList->SetComputeRoot32BitConstants(rootParameterIndex, constantNum, data, 0);
	}

	public void SetDescriptorPool(DescriptorPool descriptorPool)
	{
		((DescriptorPoolD3D12)descriptorPool).Bind(m_GraphicsCommandList);
	}

	public void PipelineBarrier(TransitionBarrierDesc* transitionBarriers, AliasingBarrierDesc* aliasingBarriers, BarrierDependency dependency)
	{
		//MaybeUnused(dependency);

		uint32 barrierNum = 0;
		if (transitionBarriers != null)
		{
			barrierNum += transitionBarriers.bufferNum;
			for (uint16 i = 0; i < transitionBarriers.textureNum; i++)
			{
				readonly var barrierDesc = ref transitionBarriers.textures[i];
				readonly TextureD3D12 texture = (TextureD3D12)barrierDesc.texture;
				readonly uint32 arraySize = barrierDesc.arraySize == REMAINING_ARRAY_LAYERS ? texture.GetTextureDesc().DepthOrArraySize : barrierDesc.arraySize;
				readonly uint32 mipNum = barrierDesc.mipNum == REMAINING_MIP_LEVELS ? texture.GetTextureDesc().MipLevels : barrierDesc.mipNum;
				if (barrierDesc.arrayOffset == 0 &&
					barrierDesc.arraySize == REMAINING_ARRAY_LAYERS &&
					barrierDesc.mipOffset == 0 &&
					barrierDesc.mipNum == REMAINING_MIP_LEVELS)
					barrierNum++;
				else
					barrierNum += arraySize * mipNum;
			}
		}
		if (aliasingBarriers != null)
		{
			barrierNum += aliasingBarriers.bufferNum;
			barrierNum += aliasingBarriers.textureNum;
		}

		if (barrierNum == 0)
			return;

		D3D12_RESOURCE_BARRIER* resourceBarriers = STACK_ALLOC!<D3D12_RESOURCE_BARRIER>(barrierNum);
		//Internal.MemSet(resourceBarriers, 0, sizeof(D3D12_RESOURCE_BARRIER) * barrierNum);

		D3D12_RESOURCE_BARRIER* ptr = resourceBarriers;
		if (transitionBarriers != null) // UAV and transitions barriers
		{
			for (uint32 i = 0; i < transitionBarriers.bufferNum; i++)
			{
				readonly var barrierDesc = ref transitionBarriers.buffers[i];
				AddResourceBarrier(((BufferD3D12)barrierDesc.buffer), barrierDesc.prevAccess, barrierDesc.nextAccess, ref *ptr++, 0);
			}

			for (uint32 i = 0; i < transitionBarriers.textureNum; i++)
			{
				readonly var barrierDesc = ref transitionBarriers.textures[i];
				readonly TextureD3D12 texture = (TextureD3D12)barrierDesc.texture;
				readonly uint32 arraySize = barrierDesc.arraySize == REMAINING_ARRAY_LAYERS ? texture.GetTextureDesc().DepthOrArraySize : barrierDesc.arraySize;
				readonly uint32 mipNum = barrierDesc.mipNum == REMAINING_MIP_LEVELS ? texture.GetTextureDesc().MipLevels : barrierDesc.mipNum;
				if (barrierDesc.arrayOffset == 0 &&
					barrierDesc.arraySize == REMAINING_ARRAY_LAYERS &&
					barrierDesc.mipOffset == 0 &&
					barrierDesc.mipNum == REMAINING_MIP_LEVELS)
				{
					AddResourceBarrier(texture, barrierDesc.prevAccess, barrierDesc.nextAccess, ref *ptr++, D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES);
				}
				else
				{
					for (uint16 arrayOffset = barrierDesc.arrayOffset; arrayOffset < barrierDesc.arrayOffset + arraySize; arrayOffset++)
					{
						for (uint16 mipOffset = barrierDesc.mipOffset; mipOffset < barrierDesc.mipOffset + mipNum; mipOffset++)
						{
							uint32 subresource = texture.GetSubresourceIndex(arrayOffset, mipOffset);
							AddResourceBarrier(texture, barrierDesc.prevAccess, barrierDesc.nextAccess, ref *ptr++, subresource);
						}
					}
				}
			}
		}

		if (aliasingBarriers != null)
		{
			for (uint32 i = 0; i < aliasingBarriers.bufferNum; i++)
			{
				ref D3D12_RESOURCE_BARRIER barrier = ref *ptr++;
				barrier.Type = .D3D12_RESOURCE_BARRIER_TYPE_ALIASING;
				barrier.Aliasing.pResourceBefore = ((BufferD3D12)aliasingBarriers.buffers[i].before);
				barrier.Aliasing.pResourceAfter = ((BufferD3D12)aliasingBarriers.buffers[i].after);
			}

			for (uint32 i = 0; i < aliasingBarriers.textureNum; i++)
			{
				ref D3D12_RESOURCE_BARRIER barrier = ref *ptr++;
				barrier.Type = .D3D12_RESOURCE_BARRIER_TYPE_ALIASING;
				barrier.Aliasing.pResourceBefore = ((TextureD3D12)aliasingBarriers.textures[i].before);
				barrier.Aliasing.pResourceAfter = ((TextureD3D12)aliasingBarriers.textures[i].after);
			}
		}

		m_GraphicsCommandList->ResourceBarrier(barrierNum, resourceBarriers);
	}

	public void BeginRenderPass(FrameBuffer frameBuffer, RenderPassBeginFlag renderPassBeginFlag)
	{
		m_FrameBuffer = (FrameBufferD3D12)frameBuffer;
		m_FrameBuffer.Bind(m_GraphicsCommandList, renderPassBeginFlag);
	}

	public void EndRenderPass()
	{
		m_FrameBuffer = null;
	}

	public void SetViewports(Viewport* viewports, uint32 viewportNum)
	{
		Compiler.Assert(offsetof(Viewport, offset) == 0, "Unsupported viewport data layout.");
		Compiler.Assert(offsetof(Viewport, size) == 8, "Unsupported viewport data layout.");
		Compiler.Assert(offsetof(Viewport, depthRangeMin) == 16, "Unsupported viewport data layout.");
		Compiler.Assert(offsetof(Viewport, depthRangeMax) == 20, "Unsupported viewport data layout.");

		m_GraphicsCommandList->RSSetViewports(viewportNum, (D3D12_VIEWPORT*)viewports);
	}

	public void SetScissors(Rect* rects, uint32 rectNum)
	{
		D3D12_RECT* rectsD3D12 = STACK_ALLOC!<D3D12_RECT>(rectNum);
		ConvertRects(rectsD3D12, rects, rectNum);

		m_GraphicsCommandList->RSSetScissorRects(rectNum, rectsD3D12);
	}

	public void SetDepthBounds(float boundsMin, float boundsMax)
	{
		if (m_GraphicsCommandList1.Get() != null)
			m_GraphicsCommandList1->OMSetDepthBounds(boundsMin, boundsMax);
	}

	public void SetStencilReference(uint8 reference)
	{
		m_GraphicsCommandList->OMSetStencilRef(reference);
	}

	public void SetSamplePositions(SamplePosition* positions, uint32 positionNum)
	{
		if (m_GraphicsCommandList1.Get() != null)
		{
			uint8 sampleNum = m_Pipeline.GetSampleNum();
			uint32 pixelNum = positionNum / sampleNum;

			m_GraphicsCommandList1->SetSamplePositions(sampleNum, pixelNum, (D3D12_SAMPLE_POSITION*)positions);
		}
	}

	public void ClearAttachments(ClearDesc* clearDescs, uint32 clearDescNum, Rect* rects, uint32 rectNum)
	{
		m_FrameBuffer.Clear(m_GraphicsCommandList, clearDescs, clearDescNum, rects, rectNum);
	}

	public void SetIndexBuffer(Buffer buffer, uint64 offset, IndexType indexType)
	{
		readonly BufferD3D12 bufferD3D12 = (BufferD3D12)buffer;

		D3D12_INDEX_BUFFER_VIEW indexBufferView;
		indexBufferView.BufferLocation = bufferD3D12.GetPointerGPU() + offset;
		indexBufferView.SizeInBytes = (uint32)(bufferD3D12.GetByteSize() - offset);
		indexBufferView.Format = indexType == IndexType.UINT16 ? .DXGI_FORMAT_R16_UINT : .DXGI_FORMAT_R32_UINT;

		m_GraphicsCommandList->IASetIndexBuffer(&indexBufferView);
	}

	public void SetVertexBuffers(uint32 baseSlot, uint32 bufferNum, Buffer* buffers, uint64* offsets)
	{
		D3D12_VERTEX_BUFFER_VIEW* vertexBufferViews = STACK_ALLOC!<D3D12_VERTEX_BUFFER_VIEW>(bufferNum);

		for (uint32 i = 0; i < bufferNum; i++)
		{
			if (buffers[i] != null)
			{
				readonly BufferD3D12 buffer = (BufferD3D12)buffers[i];
				uint64 offset = offsets != null ? offsets[i] : 0;
				vertexBufferViews[i].BufferLocation = buffer.GetPointerGPU() + offset;
				vertexBufferViews[i].SizeInBytes = (uint32)(buffer.GetByteSize() - offset);
				vertexBufferViews[i].StrideInBytes = m_Pipeline.GetIAStreamStride(baseSlot + i);
			}
			else
			{
				vertexBufferViews[i].BufferLocation = 0;
				vertexBufferViews[i].SizeInBytes = 0;
				vertexBufferViews[i].StrideInBytes = 0;
			}
		}

		m_GraphicsCommandList->IASetVertexBuffers(baseSlot, bufferNum, vertexBufferViews);
	}

	public void Draw(uint32 vertexNum, uint32 instanceNum, uint32 baseVertex, uint32 baseInstance)
	{
		m_GraphicsCommandList->DrawInstanced(vertexNum, instanceNum, baseVertex, baseInstance);
	}

	public void DrawIndexed(uint32 indexNum, uint32 instanceNum, uint32 baseIndex, uint32 baseVertex, uint32 baseInstance)
	{
		m_GraphicsCommandList->DrawIndexedInstanced(indexNum, instanceNum, baseIndex, (.)baseVertex, baseInstance);
	}

	public void DrawIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
	{
		m_GraphicsCommandList->ExecuteIndirect(m_Device.GetDrawCommandSignature(stride), drawNum, (BufferD3D12)buffer, offset, null, 0);
	}

	public void DrawIndexedIndirect(Buffer buffer, uint64 offset, uint32 drawNum, uint32 stride)
	{
		m_GraphicsCommandList->ExecuteIndirect(m_Device.GetDrawIndexedCommandSignature(stride), drawNum, (BufferD3D12)buffer, offset, null, 0);
	}

	public void Dispatch(uint32 x, uint32 y, uint32 z)
	{
		m_GraphicsCommandList->Dispatch(x, y, z);
	}

	public void DispatchIndirect(Buffer buffer, uint64 offset)
	{
		m_GraphicsCommandList->ExecuteIndirect(m_Device.GetDispatchCommandSignature(), 1, (BufferD3D12)buffer, offset, null, 0);
	}

	public void BeginQuery(QueryPool queryPool, uint32 offset)
	{
		readonly QueryPoolD3D12 queryPoolD3D12 = (QueryPoolD3D12)queryPool;
		m_GraphicsCommandList->BeginQuery(queryPoolD3D12, queryPoolD3D12.GetQueryType(), offset);
	}

	public void EndQuery(QueryPool queryPool, uint32 offset)
	{
		readonly QueryPoolD3D12 queryPoolD3D12 = (QueryPoolD3D12)queryPool;
		m_GraphicsCommandList->EndQuery(queryPoolD3D12, queryPoolD3D12.GetQueryType(), offset);
	}

	public void BeginAnnotation(char8* name)
	{
		WinPixEventRuntime.PIXBeginEvent(m_GraphicsCommandList.Get(), WinPixEventRuntime.PIX_COLOR_DEFAULT, scope String(name));
	}

	public void EndAnnotation()
	{
		WinPixEventRuntime.PIXEndEvent(m_GraphicsCommandList.Get());
	}

	public void ClearStorageBuffer(ClearStorageBufferDesc clearDesc)
	{
		DescriptorSetD3D12 descriptorSet = m_DescriptorSets[clearDesc.setIndex];
		DescriptorD3D12 resourceView = (DescriptorD3D12)clearDesc.storageBuffer;
		/*readonly*/ uint32[4] clearValues = .(clearDesc.value, clearDesc.value, clearDesc.value, clearDesc.value); // todo sed  check that this is correct

		m_GraphicsCommandList->ClearUnorderedAccessViewUint(
			.() { ptr = descriptorSet.GetPointerGPU(clearDesc.rangeIndex, clearDesc.offsetInRange) },
			.() { ptr = resourceView.GetPointerCPU() },
			resourceView,
			&clearValues,
			0,
			null);
	}

	public void ClearStorageTexture(ClearStorageTextureDesc clearDesc)
	{
		var clearDesc;
		DescriptorSetD3D12 descriptorSet = m_DescriptorSets[clearDesc.setIndex];
		DescriptorD3D12 resourceView = (DescriptorD3D12)clearDesc.storageTexture;

		if (resourceView.IsFloatingPointUAV())
		{
			m_GraphicsCommandList->ClearUnorderedAccessViewFloat(
				.() { ptr = descriptorSet.GetPointerGPU(clearDesc.rangeIndex, clearDesc.offsetInRange) },
				.() { ptr = resourceView.GetPointerCPU() },
				resourceView,
				&clearDesc.value.rgba32f.r,
				0,
				null);
		}
		else
		{
			m_GraphicsCommandList->ClearUnorderedAccessViewUint(
				.() { ptr = descriptorSet.GetPointerGPU(clearDesc.rangeIndex, clearDesc.offsetInRange) },
				.() { ptr = resourceView.GetPointerCPU() },
				resourceView,
				&clearDesc.value.rgba32ui.r,
				0,
				null);
		}
	}

	public void CopyBuffer(Buffer dstBuffer, uint32 dstPhysicalDeviceIndex, uint64 dstOffset, Buffer srcBuffer, uint32 srcPhysicalDeviceIndex, uint64 srcOffset, uint64 size)
	{
		var size;
		if (size == WHOLE_SIZE)
			size = ((BufferD3D12)srcBuffer).GetByteSize();

		m_GraphicsCommandList->CopyBufferRegion((BufferD3D12)dstBuffer, dstOffset, (BufferD3D12)srcBuffer, srcOffset, size);
	}

	public void CopyTexture(Texture dstTexture, uint32 dstPhysicalDeviceIndex, TextureRegionDesc* dstRegion, Texture srcTexture, uint32 srcPhysicalDeviceIndex, TextureRegionDesc* srcRegion)
	{
		TextureD3D12 dstTextureD3D12 = (TextureD3D12)dstTexture;
		TextureD3D12 srcTextureD3D12 = (TextureD3D12)srcTexture;

		if (dstRegion  == null || srcRegion == null)
		{
			m_GraphicsCommandList->CopyResource(dstTextureD3D12, srcTextureD3D12);
		}
		else
		{
			D3D12_TEXTURE_COPY_LOCATION dstTextureCopyLocation = .()
				{
					pResource = dstTextureD3D12, Type = .D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX, SubresourceIndex = dstTextureD3D12.GetSubresourceIndex(dstRegion.arrayOffset, dstRegion.mipOffset)
				};

			D3D12_TEXTURE_COPY_LOCATION srcTextureCopyLocation = .()
				{
					pResource = srcTextureD3D12, Type = .D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX, SubresourceIndex = srcTextureD3D12.GetSubresourceIndex(srcRegion.arrayOffset, srcRegion.mipOffset)
				};

			readonly uint16[3] offset = srcRegion.offset;
			readonly uint16[3] size = .(srcRegion.size[0] == WHOLE_SIZE ? srcTextureD3D12.GetSize(0, srcRegion.mipOffset) : srcRegion.size[0], srcRegion.size[1] == WHOLE_SIZE ? srcTextureD3D12.GetSize(1, srcRegion.mipOffset) : srcRegion.size[1], srcRegion.size[2] == WHOLE_SIZE ? srcTextureD3D12.GetSize(2, srcRegion.mipOffset) : srcRegion.size[2]
				);
			D3D12_BOX @box = .() { left =  offset[0], top = offset[1], front = offset[2], right = uint16(offset[0] + size[0]), bottom = uint16(offset[1] + size[1]), back = uint16(offset[2] + size[2]) };

			readonly uint16[3] dstOffset = dstRegion.offset;

			m_GraphicsCommandList->CopyTextureRegion(&dstTextureCopyLocation, dstOffset[0], dstOffset[1], dstOffset[2], &srcTextureCopyLocation, &@box);
		}
	}

	public void UploadBufferToTexture(Texture dstTexture, TextureRegionDesc dstRegionDesc, Buffer srcBuffer, TextureDataLayoutDesc srcDataLayoutDesc)
	{
		TextureD3D12 dstTextureD3D12 = (TextureD3D12)dstTexture;
		readonly ref D3D12_RESOURCE_DESC textureDesc = ref dstTextureD3D12.GetTextureDesc();
		D3D12_TEXTURE_COPY_LOCATION dstTextureCopyLocation = .()
			{
				pResource = dstTextureD3D12, Type = .D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX, SubresourceIndex = dstTextureD3D12.GetSubresourceIndex(dstRegionDesc.arrayOffset, dstRegionDesc.mipOffset)
			};

		readonly uint16[3] size = .(dstRegionDesc.size[0] == WHOLE_SIZE ? dstTextureD3D12.GetSize(0, dstRegionDesc.mipOffset) : dstRegionDesc.size[0], dstRegionDesc.size[1] == WHOLE_SIZE ? dstTextureD3D12.GetSize(1, dstRegionDesc.mipOffset) : dstRegionDesc.size[1], dstRegionDesc.size[2] == WHOLE_SIZE ? dstTextureD3D12.GetSize(2, dstRegionDesc.mipOffset) : dstRegionDesc.size[2]
			);

		D3D12_TEXTURE_COPY_LOCATION srcTextureCopyLocation;
		srcTextureCopyLocation.pResource = (BufferD3D12)srcBuffer;
		srcTextureCopyLocation.Type = .D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
		srcTextureCopyLocation.PlacedFootprint.Offset = srcDataLayoutDesc.offset;
		srcTextureCopyLocation.PlacedFootprint.Footprint.Format = textureDesc.Format;
		srcTextureCopyLocation.PlacedFootprint.Footprint.Width = size[0];
		srcTextureCopyLocation.PlacedFootprint.Footprint.Height = size[1];
		srcTextureCopyLocation.PlacedFootprint.Footprint.Depth = size[2];
		srcTextureCopyLocation.PlacedFootprint.Footprint.RowPitch = srcDataLayoutDesc.rowPitch;

		readonly uint16[3] offset = dstRegionDesc.offset;
		D3D12_BOX @box = .() { left = offset[0], top = offset[1], front = offset[2], right = uint16(offset[0] + size[0]), bottom = uint16(offset[1] + size[1]), back = uint16(offset[2] + size[2]) };

		m_GraphicsCommandList->CopyTextureRegion(&dstTextureCopyLocation, offset[0], offset[1], offset[2], &srcTextureCopyLocation, &@box);
	}

	public void ReadbackTextureToBuffer(Buffer dstBuffer, ref TextureDataLayoutDesc dstDataLayoutDesc, Texture srcTexture, TextureRegionDesc srcRegionDesc)
	{
		TextureD3D12 srcTextureD3D12 = (TextureD3D12)srcTexture;
		readonly ref D3D12_RESOURCE_DESC textureDesc = ref srcTextureD3D12.GetTextureDesc();
		D3D12_TEXTURE_COPY_LOCATION srcTextureCopyLocation = .()
			{
				pResource = srcTextureD3D12, Type = .D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX, SubresourceIndex = srcTextureD3D12.GetSubresourceIndex(srcRegionDesc.arrayOffset, srcRegionDesc.mipOffset)
			};

		D3D12_TEXTURE_COPY_LOCATION dstTextureCopyLocation;
		dstTextureCopyLocation.pResource = (BufferD3D12)dstBuffer;
		dstTextureCopyLocation.Type = .D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT;
		dstTextureCopyLocation.PlacedFootprint.Offset = dstDataLayoutDesc.offset;
		dstTextureCopyLocation.PlacedFootprint.Footprint.Format = textureDesc.Format;
		dstTextureCopyLocation.PlacedFootprint.Footprint.Width = srcRegionDesc.size[0];
		dstTextureCopyLocation.PlacedFootprint.Footprint.Height = srcRegionDesc.size[1];
		dstTextureCopyLocation.PlacedFootprint.Footprint.Depth = srcRegionDesc.size[2];
		dstTextureCopyLocation.PlacedFootprint.Footprint.RowPitch = dstDataLayoutDesc.rowPitch;

		readonly uint16[3] offset = srcRegionDesc.offset;
		readonly uint16[3] size = .(srcRegionDesc.size[0] == WHOLE_SIZE ? srcTextureD3D12.GetSize(0, srcRegionDesc.mipOffset) : srcRegionDesc.size[0], srcRegionDesc.size[1] == WHOLE_SIZE ? srcTextureD3D12.GetSize(1, srcRegionDesc.mipOffset) : srcRegionDesc.size[1], srcRegionDesc.size[2] == WHOLE_SIZE ? srcTextureD3D12.GetSize(2, srcRegionDesc.mipOffset) : srcRegionDesc.size[2]
			);
		D3D12_BOX @box = .() { left = offset[0], top = offset[1], front = offset[2], right = uint16(offset[0] + size[0]), bottom = uint16(offset[1] + size[1]), back = uint16(offset[2] + size[2]) };

		m_GraphicsCommandList->CopyTextureRegion(&dstTextureCopyLocation, 0, 0, 0, &srcTextureCopyLocation, &@box);
	}

	public void CopyQueries(QueryPool queryPool, uint32 offset, uint32 num, Buffer buffer, uint64 alignedBufferOffset)
	{
		readonly QueryPoolD3D12 queryPoolD3D12 = (QueryPoolD3D12)queryPool;
		readonly BufferD3D12 bufferD3D12 = (BufferD3D12)buffer;

		// WAR: QueryHeap uses a readback buffer for QueryType.ACCELERATION_STRUCTURE_COMPACTED_SIZE
		if (queryPoolD3D12.GetQueryType() == (D3D12_QUERY_TYPE) - 1)
		{
			readonly uint64 srcOffset = offset * queryPoolD3D12.GetQuerySize();
			readonly uint64 size = num * queryPoolD3D12.GetQuerySize();
			m_GraphicsCommandList->CopyBufferRegion(bufferD3D12, alignedBufferOffset, queryPoolD3D12.GetReadbackBuffer(), srcOffset, size);
			return;
		}

		m_GraphicsCommandList->ResolveQueryData(queryPoolD3D12, queryPoolD3D12.GetQueryType(), offset, num, bufferD3D12, alignedBufferOffset);
	}

	public void ResetQueries(QueryPool queryPool, uint32 offset, uint32 num)
	{
	}

	public void BuildTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
	{
		//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC desc = .();
		desc.DestAccelerationStructureData = ((AccelerationStructureD3D12)dst).GetHandle(0);
		desc.ScratchAccelerationStructureData = ((BufferD3D12)scratch).GetPointerGPU() + scratchOffset;
		desc.Inputs.Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL;
		desc.Inputs.Flags = GetAccelerationStructureBuildFlags(flags);
		desc.Inputs.NumDescs = instanceNum;
		desc.Inputs.DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY;

		desc.Inputs.InstanceDescs = ((BufferD3D12)buffer).GetPointerGPU() + bufferOffset;

		m_GraphicsCommandList4->BuildRaytracingAccelerationStructure(&desc, 0, null);
		//#endif
	}

	public void BuildBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, Buffer scratch, uint64 scratchOffset)
	{
//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC desc = .();
		desc.DestAccelerationStructureData = ((AccelerationStructureD3D12)dst).GetHandle(0);
		desc.ScratchAccelerationStructureData = ((BufferD3D12)scratch).GetPointerGPU() + scratchOffset;
		desc.Inputs.Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL;
		desc.Inputs.Flags = GetAccelerationStructureBuildFlags(flags);
		desc.Inputs.NumDescs = geometryObjectNum;
		desc.Inputs.DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY;

		List<D3D12_RAYTRACING_GEOMETRY_DESC> geometryDescs = Allocate!<List<D3D12_RAYTRACING_GEOMETRY_DESC>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), geometryDescs); }
		geometryDescs.Resize(geometryObjectNum);
		ConvertGeometryDescs(&geometryDescs[0], geometryObjects, geometryObjectNum);
		desc.Inputs.pGeometryDescs = &geometryDescs[0];

		m_GraphicsCommandList4->BuildRaytracingAccelerationStructure(&desc, 0, null);
//#endif
	}

	public void UpdateTopLevelAccelerationStructure(uint32 instanceNum, Buffer buffer, uint64 bufferOffset, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
	{
		//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC desc = .();
		desc.DestAccelerationStructureData = ((AccelerationStructureD3D12)dst).GetHandle(0);
		desc.SourceAccelerationStructureData = ((AccelerationStructureD3D12)src).GetHandle(0);
		desc.ScratchAccelerationStructureData = ((BufferD3D12)scratch).GetPointerGPU() + scratchOffset;
		desc.Inputs.Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL;
		desc.Inputs.Flags = GetAccelerationStructureBuildFlags(flags) & .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_PERFORM_UPDATE;
		desc.Inputs.NumDescs = instanceNum;
		desc.Inputs.InstanceDescs = ((BufferD3D12)buffer).GetPointerGPU() + bufferOffset;

		m_GraphicsCommandList4->BuildRaytracingAccelerationStructure(&desc, 0, null);
		//#endif
	}

	public void UpdateBottomLevelAccelerationStructure(uint32 geometryObjectNum, GeometryObject* geometryObjects, AccelerationStructureBuildBits flags, AccelerationStructure dst, AccelerationStructure src, Buffer scratch, uint64 scratchOffset)
	{
//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC desc = .();
		desc.DestAccelerationStructureData = ((AccelerationStructureD3D12)dst).GetHandle(0);
		desc.SourceAccelerationStructureData = ((AccelerationStructureD3D12)src).GetHandle(0);
		desc.ScratchAccelerationStructureData = ((BufferD3D12)scratch).GetPointerGPU() + scratchOffset;
		desc.Inputs.Type = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL;
		desc.Inputs.Flags = GetAccelerationStructureBuildFlags(flags) & .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_PERFORM_UPDATE;
		desc.Inputs.NumDescs = geometryObjectNum;
		desc.Inputs.DescsLayout = .D3D12_ELEMENTS_LAYOUT_ARRAY;

		List<D3D12_RAYTRACING_GEOMETRY_DESC> geometryDescs = Allocate!<List<D3D12_RAYTRACING_GEOMETRY_DESC>>(m_Device.GetAllocator());
		defer { Deallocate!(m_Device.GetAllocator(), geometryDescs); }
		geometryDescs.Resize(geometryObjectNum);
		ConvertGeometryDescs(&geometryDescs[0], geometryObjects, geometryObjectNum);
		desc.Inputs.pGeometryDescs = &geometryDescs[0];

		m_GraphicsCommandList4->BuildRaytracingAccelerationStructure(&desc, 0, null);
//#endif
	}

	public void CopyAccelerationStructure(AccelerationStructure dst, AccelerationStructure src, CopyMode copyMode)
	{

//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		m_GraphicsCommandList4->CopyRaytracingAccelerationStructure(((AccelerationStructureD3D12)dst).GetHandle(0), ((AccelerationStructureD3D12)src).GetHandle(0), GetCopyMode(copyMode));
//#endif
	}

	public void WriteAccelerationStructureSize(AccelerationStructure* accelerationStructures, uint32 accelerationStructureNum, QueryPool queryPool, uint32 queryPoolOffset)
	{
		//MaybeUnused(accelerationStructures);
		//MaybeUnused(queryOffset);

//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_GPU_VIRTUAL_ADDRESS* virtualAddresses = ALLOCATE_SCRATCH!<D3D12_GPU_VIRTUAL_ADDRESS>(m_Device, accelerationStructureNum);

		QueryPoolD3D12 queryPoolD3D12 = (QueryPoolD3D12)queryPool;

		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC postbuildInfo = .();
		postbuildInfo.InfoType = .D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_COMPACTED_SIZE;
		postbuildInfo.DestBuffer = queryPoolD3D12.GetReadbackBuffer().GetGPUVirtualAddress();

		m_GraphicsCommandList4->EmitRaytracingAccelerationStructurePostbuildInfo(&postbuildInfo, accelerationStructureNum, virtualAddresses);

		FREE_SCRATCH!(m_Device, virtualAddresses, accelerationStructureNum);
//#endif
	}

	public void DispatchRays(DispatchRaysDesc dispatchRaysDesc)
	{
//#ifdef __ID3D12GraphicsCommandList4_INTERFACE_DEFINED__
		D3D12_DISPATCH_RAYS_DESC desc = .();

		desc.RayGenerationShaderRecord.StartAddress = ((BufferD3D12)dispatchRaysDesc.raygenShader.buffer).GetPointerGPU() + dispatchRaysDesc.raygenShader.offset;
		desc.RayGenerationShaderRecord.SizeInBytes = D3D12_SHADER_IDENTIFIER_SIZE_IN_BYTES;

		if (dispatchRaysDesc.missShaders.buffer != null)
		{
			desc.MissShaderTable.StartAddress = ((BufferD3D12)dispatchRaysDesc.missShaders.buffer).GetPointerGPU() + dispatchRaysDesc.missShaders.offset;
			desc.MissShaderTable.SizeInBytes = dispatchRaysDesc.missShaders.size;
			desc.MissShaderTable.StrideInBytes = dispatchRaysDesc.missShaders.stride;
		}

		if (dispatchRaysDesc.hitShaderGroups.buffer != null)
		{
			desc.HitGroupTable.StartAddress = ((BufferD3D12)dispatchRaysDesc.hitShaderGroups.buffer).GetPointerGPU() + dispatchRaysDesc.hitShaderGroups.offset;
			desc.HitGroupTable.SizeInBytes = dispatchRaysDesc.hitShaderGroups.size;
			desc.HitGroupTable.StrideInBytes = dispatchRaysDesc.hitShaderGroups.stride;
		}

		if (dispatchRaysDesc.callableShaders.buffer != null)
		{
			desc.CallableShaderTable.StartAddress = ((BufferD3D12)dispatchRaysDesc.callableShaders.buffer).GetPointerGPU() + dispatchRaysDesc.callableShaders.offset;
			desc.CallableShaderTable.SizeInBytes = dispatchRaysDesc.callableShaders.size;
			desc.CallableShaderTable.StrideInBytes = dispatchRaysDesc.callableShaders.stride;
		}

		desc.Width = dispatchRaysDesc.width;
		desc.Height = dispatchRaysDesc.height;
		desc.Depth = dispatchRaysDesc.depth;

		m_GraphicsCommandList4->DispatchRays(&desc);
//#endif
	}

	public void DispatchMeshTasks(uint32 taskNum)
	{
//#ifdef __ID3D12GraphicsCommandList6_INTERFACE_DEFINED__
		m_GraphicsCommandList6->DispatchMesh(taskNum, 1, 1);
//#endif
	}
}