namespace Sedulous.RAL;

abstract class View : QueryInterface
{
	public abstract Resource GetResource();
	public abstract uint32 GetDescriptorId();
	public abstract uint32 GetBaseMipLevel();
	public abstract uint32 GetLevelCount();
	public abstract uint32 GetBaseArrayLayer();
	public abstract uint32 GetLayerCount();
}