using System.Collections;
namespace Sedulous.RAL;

abstract class BindingSet : QueryInterface
{
	public abstract void WriteBindings(in List<BindingDesc> bindings);
}