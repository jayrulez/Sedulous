namespace NRI.Helpers;

sealed class ResourceStateChangeHelper
{
	private Device m_Device;
	private CommandQueue m_CommandQueue;
	private CommandAllocator m_CommandAllocator = null;
	private CommandBuffer m_CommandBuffer = null;
	private WaitIdleHelper m_WaitIdleHelper;

	public this(Device device, CommandQueue commandQueue)
	{
		m_Device = device;
		m_CommandQueue = commandQueue;
		m_WaitIdleHelper = new WaitIdleHelper(m_Device, m_CommandQueue);

		if (m_Device.CreateCommandAllocator(commandQueue, WHOLE_DEVICE_GROUP, out m_CommandAllocator) == Result.SUCCESS)
			m_Device.CreateCommandBuffer(m_CommandAllocator, out m_CommandBuffer);
	}

	public ~this()
	{
		if (m_CommandBuffer != null)
			m_Device.DestroyCommandBuffer(m_CommandBuffer);
		m_CommandBuffer = null;

		if (m_CommandAllocator != null)
			m_Device.DestroyCommandAllocator(m_CommandAllocator);
		m_CommandAllocator = null;

		delete m_WaitIdleHelper;
	}

	public Result ChangeStates(TransitionBarrierDesc transitionBarriers)
	{
		if (m_CommandBuffer == null)
			return Result.FAILURE;

		readonly uint32 physicalDeviceNum = m_Device.GetDesc().phyiscalDeviceGroupSize;

		var transitionBarriers;
		for (uint32 i = 0; i < physicalDeviceNum; i++)
		{
			m_CommandBuffer.Begin(null, i);
			m_CommandBuffer.PipelineBarrier(&transitionBarriers, null, BarrierDependency.ALL_STAGES);
			m_CommandBuffer.End();

			WorkSubmissionDesc workSubmissionDesc = .();
			workSubmissionDesc.physicalDeviceIndex = i;
			workSubmissionDesc.commandBufferNum = 1;
			workSubmissionDesc.commandBuffers = &m_CommandBuffer;

			m_CommandQueue.SubmitWork(workSubmissionDesc, null);
		}

		return m_WaitIdleHelper.WaitIdle();
	}
}