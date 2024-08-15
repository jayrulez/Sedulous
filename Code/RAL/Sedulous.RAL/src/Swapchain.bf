namespace Sedulous.RAL;

abstract class Swapchain : QueryInterface
{
	public abstract Format GetFormat();
	public abstract Resource GetBackBuffer(uint32 buffer);
	public abstract uint32 NextImage(in Fence fence, uint64 signal_value);
	public abstract void Present(in Fence fence, uint64 wait_value);
}