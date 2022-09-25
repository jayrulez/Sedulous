using NRI.D3DCommon;
using Win32.Graphics.Direct3D12;
using System;
using System.Collections;
using NRI.Helpers;
using Win32.Foundation;
using Win32;
namespace NRI.D3D12;

class CommandQueueD3D12 : CommandQueue
{
	private DeviceD3D12 m_Device;
	private ComPtr<ID3D12CommandQueue> m_CommandQueue;
	private D3D12_COMMAND_LIST_TYPE m_CommandListType = (D3D12_COMMAND_LIST_TYPE)(-1);


	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}
	public ~this()
	{
		m_CommandQueue.Dispose();
	}

	public static implicit operator ID3D12CommandQueue*(Self self) => self.m_CommandQueue.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(CommandQueueType queueType)
	{
		D3D12_COMMAND_QUEUE_DESC commandQueueDesc = .();
		commandQueueDesc.Priority = (.)D3D12_COMMAND_QUEUE_PRIORITY.D3D12_COMMAND_QUEUE_PRIORITY_NORMAL;
		commandQueueDesc.Flags = .D3D12_COMMAND_QUEUE_FLAG_NONE;
		commandQueueDesc.NodeMask = NRI_TEMP_NODE_MASK;
		commandQueueDesc.Type = NRI.D3D12.GetCommandListType(queueType);

		HRESULT hr = ((ID3D12Device*)m_Device).CreateCommandQueue(&commandQueueDesc, ID3D12CommandQueue.IID, (void**)(&m_CommandQueue));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateCommandQueue() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		m_CommandListType = commandQueueDesc.Type;

		return Result.SUCCESS;
	}

	public Result Create(ID3D12CommandQueue* commandQueue)
	{
		readonly /*ref*/ D3D12_COMMAND_QUEUE_DESC commandQueueDesc = /*ref*/ commandQueue.GetDesc();

		m_CommandQueue = commandQueue;
		m_CommandListType = commandQueueDesc.Type;

		return Result.SUCCESS;
	}

	public D3D12_COMMAND_LIST_TYPE GetCommandListType()
	{
		return m_CommandListType;
	}

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_CommandQueue, scope String(name));
	}

	public void SubmitWork(WorkSubmissionDesc workSubmissionDesc, DeviceSemaphore deviceSemaphore)
	{
		for (uint32 i = 0; i < workSubmissionDesc.waitNum; i++)
			((QueueSemaphoreD3D12)workSubmissionDesc.wait[i]).Wait(m_CommandQueue);

		if (workSubmissionDesc.commandBufferNum > 0)
		{
			List<ID3D12GraphicsCommandList*> commandLists = Allocate!<List<ID3D12GraphicsCommandList*>>(m_Device.GetAllocator());
			defer { Deallocate!(m_Device.GetAllocator(), commandLists); }
			for (uint32 j = 0; j < workSubmissionDesc.commandBufferNum; j++)
				commandLists.Add(((CommandBufferD3D12)workSubmissionDesc.commandBuffers[j]));

			m_CommandQueue->ExecuteCommandLists((uint32)commandLists.Count, (ID3D12CommandList**)commandLists.Ptr);
		}

		for (uint32 i = 0; i < workSubmissionDesc.signalNum; i++)
			((QueueSemaphoreD3D12)workSubmissionDesc.signal[i]).Signal(m_CommandQueue);

		if (deviceSemaphore != null)
			((DeviceSemaphoreD3D12)deviceSemaphore).Signal(m_CommandQueue);
	}

	public void WaitForSemaphore(DeviceSemaphore deviceSemaphore)
	{
		((DeviceSemaphoreD3D12)deviceSemaphore).Wait();
	}

	public Result ChangeResourceStates(TransitionBarrierDesc transitionBarriers)
	{
		ResourceStateChangeHelper resourceStateChange = scope .(m_Device, (CommandQueue)this);

		return resourceStateChange.ChangeStates(transitionBarriers);
	}

	public Result UploadData(NRI.Helpers.TextureUploadDesc* textureUploadDescs, uint32 textureUploadDescNum, NRI.Helpers.BufferUploadDesc* bufferUploadDescs, uint32 bufferUploadDescNum)
	{
		DataUploadHelper helperDataUpload = scope .(m_Device, m_Device.GetAllocator(), (CommandQueue)this);

		return helperDataUpload.UploadData(textureUploadDescs, textureUploadDescNum, bufferUploadDescs, bufferUploadDescNum);
	}

	public Result WaitForIdle()
	{
		WaitIdleHelper helperWaitIdle = scope .(m_Device, (CommandQueue)this);

		return helperWaitIdle.WaitIdle();
	}
}