namespace Sedulous.RAL;

abstract class Fence : QueryInterface
{
	public abstract uint64 GetCompletedValue();
	public abstract void Wait(uint64 value);
	public abstract void Signal(uint64 value);
}