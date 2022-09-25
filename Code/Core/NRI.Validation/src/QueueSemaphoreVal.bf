namespace NRI.Validation;

class QueueSemaphoreVal : QueueSemaphore, DeviceObjectVal<QueueSemaphore>
{
	private bool m_isSignaled = false;

	public this(DeviceVal device, QueueSemaphore queueSemaphore) : base(device, queueSemaphore)
	{
	}

	public void Signal()
	{
		if (m_isSignaled)
			REPORT_ERROR(m_Device.GetLogger(), "Can't signal QueueSemaphore: it's already in signaled state.");

		m_isSignaled = true;
	}
	public void Wait()
	{
		if (!m_isSignaled)
			REPORT_ERROR(m_Device.GetLogger(), "Can't wait for QueueSemaphore: it's already in unsignaled state.");

		m_isSignaled = false;
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
}