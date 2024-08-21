namespace Sedulous.Renderer.VK.Internal;

class CCVKGPUDeviceObject
{
	public this() { }
	public ~this()
	{
		shutdown();
	}

	public virtual void shutdown() { }
}