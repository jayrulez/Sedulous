using NRI.D3DCommon;
using Win32.Graphics.Direct3D12;
using Win32.Foundation;
using System;
using Win32;
namespace NRI.D3D12;

class CommandAllocatorD3D12 : CommandAllocator
{
	private DeviceD3D12 m_Device;
	private ComPtr<ID3D12CommandAllocator> m_CommandAllocator;
	private D3D12_COMMAND_LIST_TYPE m_CommandListType = (D3D12_COMMAND_LIST_TYPE)(-1);


	public this(DeviceD3D12 device)
	{
		m_Device = device;
	}

	public ~this()
	{
		m_CommandAllocator.Dispose();
	}

	public static implicit operator ID3D12CommandAllocator*(Self self) => self.m_CommandAllocator.GetInterface();

	public DeviceD3D12 GetDevice() => m_Device;

	public Result Create(CommandQueue commandQueue)
	{
		readonly CommandQueueD3D12 commandQueueD3D12 = (CommandQueueD3D12)commandQueue;
		m_CommandListType = commandQueueD3D12.GetCommandListType();
		HRESULT hr = ((ID3D12Device*)m_Device).CreateCommandAllocator(m_CommandListType, ID3D12CommandAllocator.IID, (void**)(&m_CommandAllocator));
		if (FAILED(hr))
		{
			REPORT_ERROR(m_Device.GetLogger(), "ID3D12Device::CreateCommandAllocator() failed, error code: 0x{0:X}.", hr);
			return Result.FAILURE;
		}

		return Result.SUCCESS;
	}

	public void SetDebugName(char8* name)
	{
		SET_D3D_DEBUG_OBJECT_NAME!(m_CommandAllocator, scope String(name));
	}

	public Result CreateCommandBuffer(out CommandBuffer commandBuffer)
	{
		CommandBufferD3D12 commandBufferD3D12 = Allocate!<CommandBufferD3D12>(m_Device.GetAllocator(), m_Device);
		readonly Result result = commandBufferD3D12.Create(m_CommandListType, m_CommandAllocator);

		if (result == Result.SUCCESS)
		{
			commandBuffer = (CommandBuffer)commandBufferD3D12;
			return Result.SUCCESS;
		}

		Deallocate!(m_Device.GetAllocator(), commandBufferD3D12);
		commandBuffer = ?;

		return result;
	}

	public void Reset()
	{
		m_CommandAllocator->Reset();
	}
}