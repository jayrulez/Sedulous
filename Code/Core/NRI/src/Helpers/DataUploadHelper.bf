using System.Collections;
using System;
namespace NRI.Helpers;

sealed class DataUploadHelper
{
	private Result Create()
	{
		BufferDesc bufferDesc = .();
		bufferDesc.size = m_UploadBufferSize;
		Result result = m_Device.CreateBuffer(bufferDesc, out m_UploadBuffer);
		if (result != Result.SUCCESS)
			return result;

		MemoryDesc memoryDesc = .();
		m_UploadBuffer.GetMemoryInfo(MemoryLocation.HOST_UPLOAD, ref memoryDesc);

		result = m_Device.AllocateMemory(WHOLE_DEVICE_GROUP, memoryDesc.type, memoryDesc.size, out m_UploadBufferMemory);
		if (result != Result.SUCCESS)
			return result;

		/*readonly*/ BufferMemoryBindingDesc bufferMemoryBindingDesc = .() { memory = m_UploadBufferMemory, buffer = m_UploadBuffer, offset = 0 };
		result = m_Device.BindBufferMemory(&bufferMemoryBindingDesc, 1);
		if (result != Result.SUCCESS)
			return result;

		result = m_Device.CreateDeviceSemaphore(false, out m_DeviceSemaphore);
		if (result != Result.SUCCESS)
			return result;

		m_CommandAllocators.Resize(m_DeviceDesc.phyiscalDeviceGroupSize);
		m_CommandBuffers.Resize(m_DeviceDesc.phyiscalDeviceGroupSize);

		for (uint32 i = 0; i < m_CommandBuffers.Count; i++)
		{
			result = m_Device.CreateCommandAllocator(m_CommandQueue, WHOLE_DEVICE_GROUP, out m_CommandAllocators[i]);
			if (result != Result.SUCCESS)
				return result;

			result = m_Device.CreateCommandBuffer(m_CommandAllocators[i], out m_CommandBuffers[i]);
			if (result != Result.SUCCESS)
				return result;
		}

		return result;
	}

	private void Destroy()
	{
		for (uint32 i = 0; i < m_CommandBuffers.Count; i++)
		{
			m_Device.DestroyCommandBuffer(m_CommandBuffers[i]);
			m_Device.DestroyCommandAllocator(m_CommandAllocators[i]);
		}
		m_Device.DestroyDeviceSemaphore(m_DeviceSemaphore);

		m_Device.DestroyBuffer(m_UploadBuffer);
		m_Device.FreeMemory(m_UploadBufferMemory);
	}

	private Result UploadTextures(TextureUploadDesc* textureUploadDescs, uint32 textureDataDescNum)
	{
		Result result = DoTransition<true>(textureUploadDescs, textureDataDescNum);
		if (result != Result.SUCCESS)
			return result;

		uint32 i = 0;
		uint16 arrayOffset = 0;
		uint16 mipOffset = 0;

		while (i < textureDataDescNum)
		{
			result = BeginCommandBuffers();
			if (result != Result.SUCCESS)
				return result;

			m_UploadBufferOffset = 0;
			bool isCapacityInsufficient = false;

			for (; i < textureDataDescNum && CopyTextureContent(textureUploadDescs[i], ref arrayOffset, ref mipOffset, ref isCapacityInsufficient); i++)
			{
			}

			if (isCapacityInsufficient)
				return Result.OUT_OF_MEMORY;

			result = EndCommandBuffersAndSubmit();
			if (result != Result.SUCCESS)
				return result;
		}

		return DoTransition<false>(textureUploadDescs, textureDataDescNum);
	}

	private Result UploadBuffers(BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum)
	{
		Result result = DoTransition<true>(bufferUploadDescs, bufferUploadDescNum);
		if (result != Result.SUCCESS)
			return result;

		uint32 i = 0;
		uint64 bufferContentOffset = 0;

		while (i < bufferUploadDescNum)
		{
			result = BeginCommandBuffers();
			if (result != Result.SUCCESS)
				return result;

			m_UploadBufferOffset = 0;
			m_MappedMemory = (uint8*)m_UploadBuffer.Map(0, m_UploadBufferSize);

			for (; i < bufferUploadDescNum && CopyBufferContent(bufferUploadDescs[i], ref bufferContentOffset); i++)
			{
			}

			m_UploadBuffer.Unmap();

			result = EndCommandBuffersAndSubmit();
			if (result != Result.SUCCESS)
				return result;
		}

		return DoTransition<false>(bufferUploadDescs, bufferUploadDescNum);
	}
	private Result BeginCommandBuffers()
	{
		Result result = Result.SUCCESS;

		for (uint32 i = 0; i < m_CommandBuffers.Count && result == Result.SUCCESS; i++)
			result = m_CommandBuffers[i].Begin(null, i);

		return result;
	}
	private Result EndCommandBuffersAndSubmit()
	{
		for (uint32 i = 0; i < m_CommandBuffers.Count; i++)
		{
			readonly Result result = m_CommandBuffers[i].End();
			if (result != Result.SUCCESS)
				return result;
		}

		WorkSubmissionDesc workSubmissionDesc = .();
		workSubmissionDesc.commandBufferNum = 1;

		for (uint32 i = 0; i < m_CommandBuffers.Count; i++)
		{
			workSubmissionDesc.commandBuffers = &m_CommandBuffers[i];
			workSubmissionDesc.physicalDeviceIndex = i;
			m_CommandQueue.SubmitWork(workSubmissionDesc, m_DeviceSemaphore);
			m_CommandQueue.WaitForSemaphore(m_DeviceSemaphore);
		}

		for (uint32 i = 0; i < m_CommandAllocators.Count; i++)
			m_CommandAllocators[i].Reset();

		return Result.SUCCESS;
	}

	private bool CopyTextureContent(TextureUploadDesc textureUploadDesc, ref uint16 arrayOffset, ref uint16 mipOffset, ref bool isCapacityInsufficient)
	{
		if (textureUploadDesc.subresources == null)
			return true;

		for (; arrayOffset < textureUploadDesc.arraySize; arrayOffset++)
		{
			for (; mipOffset < textureUploadDesc.mipNum; mipOffset++)
			{
				readonly var subresource = ref textureUploadDesc.subresources[arrayOffset * textureUploadDesc.mipNum + mipOffset];

				readonly uint32 sliceRowNum = subresource.slicePitch / subresource.rowPitch;
				readonly uint32 alignedRowPitch = Align(subresource.rowPitch, m_DeviceDesc.uploadBufferTextureRowAlignment);
				readonly uint32 alignedSlicePitch = Align(sliceRowNum * alignedRowPitch, m_DeviceDesc.uploadBufferTextureSliceAlignment);
				readonly uint64 mipLevelContentSize = uint64(alignedSlicePitch) * subresource.sliceNum;
				readonly uint64 freeSpace = m_UploadBufferSize - m_UploadBufferOffset;

				if (mipLevelContentSize > freeSpace)
				{
					isCapacityInsufficient = mipLevelContentSize > m_UploadBufferSize;
					return false;
				}

				CopyTextureSubresourceContent(subresource, alignedRowPitch, alignedSlicePitch);

				TextureDataLayoutDesc srcDataLayout = .();
				srcDataLayout.offset = m_UploadBufferOffset;
				srcDataLayout.rowPitch = alignedRowPitch;
				srcDataLayout.slicePitch = alignedSlicePitch;

				TextureRegionDesc dstRegion = .();
				dstRegion.arrayOffset = arrayOffset;
				dstRegion.mipOffset = mipOffset;

				for (uint32 k = 0; k < m_CommandBuffers.Count; k++)
					m_CommandBuffers[k].UploadBufferToTexture(textureUploadDesc.texture, dstRegion, m_UploadBuffer, srcDataLayout);

				m_UploadBufferOffset = Align(m_UploadBufferOffset + mipLevelContentSize, COPY_ALIGMENT);
			}
			mipOffset = 0;
		}
		arrayOffset = 0;

		m_UploadBufferOffset = Align(m_UploadBufferOffset, COPY_ALIGMENT);

		return true;
	}

	private void CopyTextureSubresourceContent(TextureSubresourceUploadDesc subresource, uint64 alignedRowPitch, uint64 alignedSlicePitch)
	{
		readonly uint32 sliceRowNum = subresource.slicePitch / subresource.rowPitch;

		// TODO: D3D11 does not allow to call CmdUploadBufferToTexture() while the upload buffer is mapped.
		m_MappedMemory = (uint8*)m_UploadBuffer.Map(m_UploadBufferOffset, subresource.sliceNum * alignedSlicePitch);

		uint8* slices = m_MappedMemory;
		for (uint32 k = 0; k < subresource.sliceNum; k++)
		{
			for (uint32 l = 0; l < sliceRowNum; l++)
			{
				uint8* dstRow = slices + k * alignedSlicePitch + l * alignedRowPitch;
				uint8* srcRow = (uint8*)subresource.slices + k * subresource.slicePitch + l * subresource.rowPitch;
				Internal.MemCpy(dstRow, srcRow, subresource.rowPitch);
			}
		}

		m_UploadBuffer.Unmap();
	}

	private bool CopyBufferContent(BufferUploadDesc bufferUploadDesc, ref uint64 bufferContentOffset)
	{
		if (bufferUploadDesc.dataSize == 0)
			return true;

		readonly uint64 freeSpace = m_UploadBufferSize - m_UploadBufferOffset;
		readonly uint64 copySize = Math.Min(bufferUploadDesc.dataSize - bufferContentOffset, freeSpace);

		if (freeSpace == 0)
			return false;

		Internal.MemCpy(m_MappedMemory + m_UploadBufferOffset, (uint8*)bufferUploadDesc.data + bufferContentOffset, (int)copySize);

		for (uint32 j = 0; j < m_CommandBuffers.Count; j++)
		{
			m_CommandBuffers[j].CopyBuffer(bufferUploadDesc.buffer, j, bufferUploadDesc.bufferOffset + bufferContentOffset,
				m_UploadBuffer, 0, m_UploadBufferOffset, copySize);
		}

		bufferContentOffset += copySize;
		m_UploadBufferOffset += copySize;

		if (bufferContentOffset != bufferUploadDesc.dataSize)
			return false;

		bufferContentOffset = 0;
		m_UploadBufferOffset = Align(m_UploadBufferOffset, COPY_ALIGMENT);
		return true;
	}

	private Result DoTransition<isInitialTransition>(TextureUploadDesc* textureUploadDescs, uint32 textureDataDescNum) where isInitialTransition : const bool
	{
		readonly Result result = BeginCommandBuffers();
		if (result != Result.SUCCESS)
			return result;

		const uint32 TEXTURES_PER_PASS = 1024;
		TextureTransitionBarrierDesc[TEXTURES_PER_PASS] textureTransitions = .InitAll;

		for (uint32 i = 0; i < textureDataDescNum;)
		{
			readonly uint32 passBegin = i;
			readonly uint32 passEnd = Math.Min(i + TEXTURES_PER_PASS, textureDataDescNum);

			for (; i < passEnd; i++)
			{
				readonly ref TextureUploadDesc textureDesc = ref textureUploadDescs[i];
				ref TextureTransitionBarrierDesc transition = ref textureTransitions[i - passBegin];

				transition = .();
				transition.texture = textureDesc.texture;
				transition.mipNum = textureDesc.mipNum;
				transition.arraySize = textureDesc.arraySize;

				if (isInitialTransition)
				{
					transition.prevAccess = AccessBits.UNKNOWN;
					transition.nextAccess = AccessBits.COPY_DESTINATION;
					transition.prevLayout = TextureLayout.UNKNOWN;
					transition.nextLayout = TextureLayout.GENERAL;
				}
				else
				{
					transition.prevAccess = AccessBits.COPY_DESTINATION;
					transition.nextAccess = textureDesc.nextAccess;
					transition.prevLayout = TextureLayout.GENERAL;
					transition.nextLayout = textureDesc.nextLayout;
				}
			}

			TransitionBarrierDesc transitions = .();
			transitions.textures = &textureTransitions;
			transitions.textureNum = passEnd - passBegin;

			for (uint32 j = 0; j < m_CommandBuffers.Count; j++)
				m_CommandBuffers[j].PipelineBarrier(&transitions, null, BarrierDependency.COPY_STAGE);
		}

		return EndCommandBuffersAndSubmit();
	}

	private Result DoTransition<isInitialTransition>(BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum) where isInitialTransition : const bool
	{
		readonly Result result = BeginCommandBuffers();
		if (result != Result.SUCCESS)
			return result;

		const uint32 BUFFERS_PER_PASS = 1024;
		BufferTransitionBarrierDesc[BUFFERS_PER_PASS] bufferTransitions = .InitAll;

		for (uint32 i = 0; i < bufferUploadDescNum;)
		{
			readonly uint32 passBegin = i;
			readonly uint32 passEnd = Math.Min(i + BUFFERS_PER_PASS, bufferUploadDescNum);

			for (; i < passEnd; i++)
			{
				readonly ref BufferUploadDesc bufferUploadDesc = ref bufferUploadDescs[i];
				ref BufferTransitionBarrierDesc bufferTransition = ref bufferTransitions[i - passBegin];

				bufferTransition = .();
				bufferTransition.buffer = bufferUploadDesc.buffer;

				if (isInitialTransition)
				{
					bufferTransition.prevAccess = bufferUploadDesc.prevAccess;
					bufferTransition.nextAccess = AccessBits.COPY_DESTINATION;
				}
				else
				{
					bufferTransition.prevAccess = AccessBits.COPY_DESTINATION;
					bufferTransition.nextAccess = bufferUploadDesc.nextAccess;
				}
			}

			TransitionBarrierDesc transitions = .();
			transitions.buffers = &bufferTransitions;
			transitions.bufferNum = passEnd - passBegin;

			for (uint32 j = 0; j < m_CommandBuffers.Count; j++)
				m_CommandBuffers[j].PipelineBarrier(&transitions, null, BarrierDependency.COPY_STAGE);
		}

		return EndCommandBuffersAndSubmit();
	}

	private DeviceDesc m_DeviceDesc; // todo sed: make this a pointer?
	private Device m_Device;
	private CommandQueue m_CommandQueue;
	private DeviceSemaphore m_DeviceSemaphore = null;
	private List<CommandAllocator> m_CommandAllocators;
	private List<CommandBuffer> m_CommandBuffers;
	private Buffer m_UploadBuffer = null;
	private Memory m_UploadBufferMemory = null;
	private uint8* m_MappedMemory = null;
	private uint64 m_UploadBufferSize = 0;
	private uint64 m_UploadBufferOffset = 0;

	private const uint64 COPY_ALIGMENT = 16;

	private const uint BASE_UPLOAD_BUFFER_SIZE = 65536;

	public this(Device device, DeviceAllocator<uint8> allocator, CommandQueue commandQueue)
	{
		m_Device = device;
		m_DeviceDesc = device.GetDesc();
		m_CommandQueue = commandQueue;
		m_CommandAllocators = Allocate!<List<CommandAllocator>>(m_Device.GetAllocator());
		m_CommandBuffers = Allocate!<List<CommandBuffer>>(m_Device.GetAllocator());
		m_UploadBufferSize = BASE_UPLOAD_BUFFER_SIZE;
	}

	public ~this()
	{
		Deallocate!(m_Device.GetAllocator(), m_CommandBuffers);
		Deallocate!(m_Device.GetAllocator(), m_CommandAllocators);
	}

	public Result UploadData(TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum, BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum)
	{
		readonly ref DeviceDesc deviceDesc = ref m_Device.GetDesc();

		for (uint32 i = 0; i < textureUploadDescNum; i++)
		{
			if (textureUploadDescs[i].subresources == null)
				continue;

			readonly ref TextureSubresourceUploadDesc subresource = ref textureUploadDescs[i].subresources[0];

			readonly uint32 sliceRowNum = Math.Max(subresource.slicePitch / subresource.rowPitch, 1);
			readonly uint64 alignedRowPitch = Align(subresource.rowPitch, deviceDesc.uploadBufferTextureRowAlignment);
			readonly uint64 alignedSlicePitch = Align(sliceRowNum * alignedRowPitch, deviceDesc.uploadBufferTextureSliceAlignment);
			readonly uint64 mipLevelContentSize = alignedSlicePitch * Math.Max(subresource.sliceNum, 1);
			m_UploadBufferSize = Math.Max(m_UploadBufferSize, mipLevelContentSize);
		}

		m_UploadBufferSize = Align(m_UploadBufferSize, COPY_ALIGMENT);

		Result result = Create();

		if (result != Result.SUCCESS)
			return result;

		result = UploadTextures(textureUploadDescs, textureUploadDescNum);

		if (result == Result.SUCCESS)
			result = UploadBuffers(bufferUploadDescs, bufferUploadDescNum);

		Destroy();

		return result;
	}
}