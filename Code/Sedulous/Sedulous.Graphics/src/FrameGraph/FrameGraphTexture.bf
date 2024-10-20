using Sedulous.RHI;
namespace Sedulous.Graphics.FrameGraph;

class FrameGraphTexture : FrameGraphResource
{
	private readonly Texture mTexture;

	public this(Texture texture)
	{
		mTexture = texture;
	}
}