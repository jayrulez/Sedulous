namespace NRI.Validation;

class DeviceSemaphoreVal : DeviceSemaphore, DeviceObjectVal<DeviceSemaphore>
{
	private uint64 m_Value = 0;

	public this(DeviceVal device, DeviceSemaphore deviceSemaphore) : base(device, deviceSemaphore)
	{
	}

	public void Create(bool signaled)
	{
		m_Value = signaled ? 1 : 0;
	}

	public bool IsUnsignaled()
		{ return (m_Value & 0x1) == 0; }

	public void Signal()
	{
		if (!IsUnsignaled())
			REPORT_ERROR(m_Device.GetLogger(), "Semaphore is already in signaled state!");

		m_Value++;
	}
	public void Wait()
	{
		if (IsUnsignaled())
			REPORT_ERROR(m_Device.GetLogger(), "Semaphore is already in unsignaled state!");

		m_Value++;
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
}