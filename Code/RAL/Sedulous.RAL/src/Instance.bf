using System.Collections;
using System;
namespace Sedulous.RAL;

abstract class Instance : QueryInterface
{
	public abstract Result<void> EnumerateAdapters(List<Adapter> adapters);
}