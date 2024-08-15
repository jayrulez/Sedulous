namespace Sedulous.RAL;

abstract class QueryInterface
{
	public T As<T>() where T : QueryInterface
	{
		return this as T;
	}
}