namespace NRI.Helpers;

sealed class WaitIdleHelper
{
	private Device m_Device;
	private CommandQueue m_CommandQueue;
	private DeviceSemaphore m_DeviceSemaphore = null;

	public this(Device device, CommandQueue commandQueue)
	{
		m_Device = device;
		m_CommandQueue = commandQueue;

		m_Device.CreateDeviceSemaphore(false, out m_DeviceSemaphore);
	}
	public ~this()
	{
		if (m_DeviceSemaphore != null)
			m_Device.DestroyDeviceSemaphore(m_DeviceSemaphore);
		m_DeviceSemaphore = null;
	}

	public Result WaitIdle()
	{
		if (m_DeviceSemaphore == null)
			return Result.FAILURE;

		readonly uint32 physicalDeviceNum = m_Device.GetDesc().phyiscalDeviceGroupSize;

		for (uint32 i = 0; i < physicalDeviceNum; i++)
		{
			WorkSubmissionDesc workSubmissionDesc = .();
			workSubmissionDesc.physicalDeviceIndex = i;
			m_CommandQueue.SubmitWork(workSubmissionDesc, m_DeviceSemaphore);
			m_CommandQueue.WaitForSemaphore(m_DeviceSemaphore);
		}

		return Result.SUCCESS;
	}
}