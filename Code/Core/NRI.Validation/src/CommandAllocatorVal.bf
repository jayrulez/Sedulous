using System;
namespace NRI.Validation;

class CommandAllocatorVal : CommandAllocator,  DeviceObjectVal<CommandAllocator>
{
	public this(DeviceVal device, CommandAllocator commandAllocator) : base(device, commandAllocator)
	{
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}

	public Result CreateCommandBuffer(out CommandBuffer commandBuffer)
	{
		commandBuffer = ?;
		CommandBuffer commandBufferImpl = null;
		readonly Result result = m_ImplObject.CreateCommandBuffer(out commandBufferImpl);

		if (result == Result.SUCCESS)
		{
			RETURN_ON_FAILURE!(m_Device.GetLogger(), commandBufferImpl != null, Result.FAILURE, "Implementation failure: 'commandBufferImpl' is NULL!");
			commandBuffer = (CommandBuffer)Allocate!<CommandBufferVal>(m_Device.GetAllocator(), m_Device, commandBufferImpl, false);
		}

		return result;
	}

	public void Reset()
	{
		m_ImplObject.Reset();
	}
}