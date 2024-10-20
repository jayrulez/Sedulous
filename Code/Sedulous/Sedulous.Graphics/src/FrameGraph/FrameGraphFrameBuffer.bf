using Sedulous.RHI;
namespace Sedulous.Graphics.FrameGraph;

class FrameGraphFrameBuffer : FrameGraphResource
{
	private readonly FrameBuffer mFrameBuffer;

	public this(FrameBuffer frameBuffer)
	{
		mFrameBuffer = frameBuffer;
	}
}