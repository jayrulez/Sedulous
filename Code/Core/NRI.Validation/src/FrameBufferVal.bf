namespace NRI.Validation;

class FrameBufferVal : FrameBuffer, DeviceObjectVal<FrameBuffer>
{
	public this(DeviceVal device, FrameBuffer frameBuffer) : base(device, frameBuffer)
	{
	}

	public void SetDebugName(char8* name)
	{
		m_Name.Set(scope .(name));
		m_ImplObject.SetDebugName(name);
	}
}