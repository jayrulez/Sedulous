namespace Sedulous.RAL;

abstract class RenderPass : QueryInterface
{
	public abstract readonly ref RenderPassDesc GetDesc();
}