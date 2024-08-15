namespace Sedulous.RAL;

abstract class Framebuffer : QueryInterface
{
}

class FramebufferBase : Framebuffer
{
	private FramebufferDesc m_desc;
	private Resource m_dummy_attachment;

	public this(in FramebufferDesc desc)
	{
		m_desc = desc;
	}

	public readonly ref FramebufferDesc GetDesc()
	{
		return ref m_desc;
	}

	public readonly ref Resource GetDummyAttachment()
	{
		return ref m_dummy_attachment;
	}
}