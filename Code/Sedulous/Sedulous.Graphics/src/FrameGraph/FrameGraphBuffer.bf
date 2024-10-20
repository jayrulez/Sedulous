using Sedulous.RHI;
namespace Sedulous.Graphics.FrameGraph;

class FrameGraphBuffer : FrameGraphResource
{
	private readonly Buffer mBuffer;

	public this(Buffer buffer)
	{
		mBuffer = buffer;
	}
}